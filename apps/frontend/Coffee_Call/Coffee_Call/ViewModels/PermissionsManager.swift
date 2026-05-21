import Foundation
import CoreLocation
import UserNotifications
import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class PermissionsManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = PermissionsManager()

    @Published var locationStatus: CLAuthorizationStatus = .notDetermined
    @Published var notificationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isRadarVisible: Bool
    @Published var currentLocation: CLLocation? = nil

    private let locationManager = CLLocationManager()
    private let locationRefreshInterval: TimeInterval = 60 * 60
    private let lastLocationRefreshKey = "CoffeeCall.lastLocationRefreshAt"
    private let radarVisibilityKey = "CoffeeCall.isRadarVisible"
    private var isLocationRequestInFlight = false
    private var hasSyncedRadarVisibilityPreference = false
    private var isRadarVisibilitySyncInFlight = false

    override init() {
        self.isRadarVisible = UserDefaults.standard.object(forKey: radarVisibilityKey) as? Bool ?? true
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // Fetch current statuses on initialization
        self.locationStatus = locationManager.authorizationStatus
        checkNotificationStatus()
    }

    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationStatus = settings.authorizationStatus
            }
        }
    }

    func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .denied || status == .restricted {
            openSettings()
        }
    }

    func requestLocation(force: Bool = false) {
        guard isRadarVisible else {
            print("PermissionsManager: Skipping location request because radar presence is offline")
            return
        }
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            guard force || shouldRequestLocation() else {
                print("PermissionsManager: Skipping location request because last refresh is still fresh")
                return
            }
            guard !isLocationRequestInFlight else { return }
            isLocationRequestInFlight = true
            locationManager.requestLocation()
        }
    }

    func toggleRadarVisibility() {
        setRadarVisibility(!isRadarVisible)
    }

    func setRadarVisibility(_ isVisible: Bool) {
        guard isRadarVisible != isVisible else { return }
        isRadarVisible = isVisible
        UserDefaults.standard.set(isVisible, forKey: radarVisibilityKey)
        hasSyncedRadarVisibilityPreference = false
        syncRadarVisibility(isVisible)

        if isVisible {
            requestLocation(force: true)
        }
    }

    func syncRadarVisibilityPreference() {
        guard !hasSyncedRadarVisibilityPreference, !isRadarVisibilitySyncInFlight else { return }
        syncRadarVisibility(isRadarVisible)
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                        DispatchQueue.main.async {
                            self.checkNotificationStatus()
                        }
                    }
                } else if settings.authorizationStatus == .denied {
                    self.openSettings()
                }
            }
        }
    }

    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }

    private func shouldRequestLocation() -> Bool {
        guard let lastRefresh = UserDefaults.standard.object(forKey: lastLocationRefreshKey) as? Date else {
            return true
        }
        return Date().timeIntervalSince(lastRefresh) >= locationRefreshInterval
    }

    @discardableResult
    private func syncRadarVisibility(_ isVisible: Bool) -> Bool {
        let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        guard isFirebaseEnabled, let uid = Auth.auth().currentUser?.uid else { return false }

        isRadarVisibilitySyncInFlight = true
        Firestore.firestore().collection("users").document(uid).setData(
            [
                "isRadarVisible": isVisible,
                "radarVisibilityUpdatedAt": FieldValue.serverTimestamp()
            ],
            merge: true
        ) { error in
            DispatchQueue.main.async {
                self.isRadarVisibilitySyncInFlight = false
                if let error = error {
                    self.hasSyncedRadarVisibilityPreference = false
                    print("PermissionsManager: Error updating radar visibility: \(error.localizedDescription)")
                } else {
                    self.hasSyncedRadarVisibilityPreference = true
                }
            }
        }
        return true
    }

    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.locationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                self.requestLocation(force: true)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            isLocationRequestInFlight = false
            return
        }
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        print("PermissionsManager: Location updated to \(lat), \(lng)")

        DispatchQueue.main.async {
            self.currentLocation = location
        }

        guard isRadarVisible else {
            isLocationRequestInFlight = false
            syncRadarVisibility(false)
            print("PermissionsManager: Discarded location update because radar presence is offline")
            return
        }

        let isFirebaseEnabled = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        if isFirebaseEnabled, let uid = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let geoHash = GeohashHelper.encode(latitude: lat, longitude: lng)

            let data: [String: Any] = [
                "lastLocation": GeoPoint(latitude: lat, longitude: lng),
                "lastLocationGeoHash": geoHash,
                "lastLocationUpdate": FieldValue.serverTimestamp(),
                "isRadarVisible": true
            ]

            db.collection("users").document(uid).setData(data, merge: true) { error in
                self.isLocationRequestInFlight = false
                if let error = error {
                    print("PermissionsManager: Error updating location in Firestore: \(error.localizedDescription)")
                } else {
                    UserDefaults.standard.set(Date(), forKey: self.lastLocationRefreshKey)
                    print("PermissionsManager: Successfully updated location in Firestore for user \(uid)")
                }
            }
        } else {
            UserDefaults.standard.set(Date(), forKey: lastLocationRefreshKey)
            isLocationRequestInFlight = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLocationRequestInFlight = false
        print("PermissionsManager: Location update failed: \(error.localizedDescription)")
    }
}

// MARK: - Geohash Encoding Helper
struct GeohashHelper {
    private static let base32 = Array("0123456789bcdefghjkmnpqrstuvwxyz")

    static func encode(latitude: Double, longitude: Double, precision: Int = 9) -> String {
        var latRange = (-90.0, 90.0)
        var lonRange = (-180.0, 180.0)
        var geohash = ""
        var isEven = true
        var bit = 0
        var ch = 0

        while geohash.count < precision {
            let mid: Double
            if isEven {
                mid = (lonRange.0 + lonRange.1) / 2
                if longitude > mid {
                    ch |= (1 << (4 - bit))
                    lonRange.0 = mid
                } else {
                    lonRange.1 = mid
                }
            } else {
                mid = (latRange.0 + latRange.1) / 2
                if latitude > mid {
                    ch |= (1 << (4 - bit))
                    latRange.0 = mid
                } else {
                    latRange.1 = mid
                }
            }

            isEven.toggle()
            if bit < 4 {
                bit += 1
            } else {
                geohash.append(base32[ch])
                bit = 0
                ch = 0
            }
        }
        return geohash
    }
}
