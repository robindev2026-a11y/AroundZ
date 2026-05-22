// LocationService.swift
import Foundation
import Combine
import CoreLocation

/// Centralised service handling permissions, GPS fetching, and reverse‑geocoding.
public final class LocationService: NSObject, ObservableObject {
    public static let shared = LocationService()
    private var cancellables = Set<AnyCancellable>()
    
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    @Published var locationStatus: CLAuthorizationStatus = .notDetermined
    
    var currentLocationModel: LocationModel? {
        guard let loc = currentLocation else { return nil }
        return LocationModel(city: nil, state: nil, country: nil, latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
    }
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationStatus = locationManager.authorizationStatus
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    /// Request location optionally forcing a refresh regardless of last request timing.
    func requestLocation(force: Bool = false) {
        guard locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways else { return }
        // Force parameter currently unused; can be extended for throttling logic.
        requestLocation()
    }
    
    /// Fetch a fresh location and decode it into `LocationModel`.
    func fetchLocation(completion: @escaping (Result<LocationModel, Error>) -> Void) {
        // Ensure permission
        let status = locationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            requestPermission()
            completion(.failure(NSError(domain: "LocationPermission", code: -1, userInfo: nil)))
            return
        }
        // Trigger GPS request
        requestLocation()
        
        var subscription: AnyCancellable?
        subscription = $currentLocation
            .compactMap { $0 }
            .first()
            .setFailureType(to: NSError.self)
            .timeout(.seconds(8), scheduler: RunLoop.main) { NSError(domain: "Timeout", code: -1, userInfo: nil) }
            .receive(on: RunLoop.main)
            .sink { _ in
                subscription = nil
            } receiveValue: { location in
                self.decode(location: location, completion: completion)
            }
    }
    
    private func decode(location: CLLocation, completion: @escaping (Result<LocationModel, Error>) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let placemark = placemarks?.first else {
                    completion(.failure(NSError(domain: "Geocode", code: -2, userInfo: nil)))
                    return
                }
                let model = LocationModel(
                    city: placemark.locality,
                    state: placemark.administrativeArea,
                    country: placemark.country,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                completion(.success(model))
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.locationStatus = manager.authorizationStatus
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            currentLocation = loc
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}
