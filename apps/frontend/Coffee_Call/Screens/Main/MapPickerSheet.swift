import SwiftUI
import MapKit

struct MapPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var region = MKCoordinateRegion(
        center: LocationService.shared.currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946), // Bangalore fallback
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var searchQuery = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedAddress = "Resolving location..."
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var isSearching = false
    
    var onConfirm: (String, Double, Double) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // Map picker representable
                MapViewRepresentable(region: $region, address: $selectedAddress, coordinate: $selectedCoordinate)
                    .ignoresSafeArea(edges: .bottom)
                
                // Centred Pin Indicator (Crosshair overlay)
                Image(systemName: "mappin")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.brandPrimary)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 4)
                    .offset(y: -18) // Offset to align the tip of the pin to exact center
                
                VStack(spacing: AppConstants.Layout.elementSpacing) {
                    // Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.textSecondary)
                        
                        TextField("Search location...", text: $searchQuery, onCommit: executeSearch)
                            .font(.bodyStandard)
                            .foregroundColor(.textPrimary)
                            .tint(.brandPrimary)
                            .submitLabel(.search)
                        
                        if !searchQuery.isEmpty {
                            Button(action: {
                                searchQuery = ""
                                searchResults.removeAll()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, AppConstants.Layout.standardPadding - 4)
                    .padding(.vertical, AppConstants.Layout.elementSpacing)
                    .background(Color.surfaceMain)
                    .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    .padding(.top, AppConstants.Layout.elementSpacing)
                    
                    // Search Results List overlay
                    if !searchResults.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(searchResults, id: \.self) { item in
                                    Button(action: {
                                        selectSearchItem(item)
                                    }) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name ?? "Unknown place")
                                                .font(.bodyBold)
                                                .foregroundColor(.textPrimary)
                                            Text(item.placemark.title ?? "")
                                                .font(.captionText)
                                                .foregroundColor(.textSecondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                    }
                                    Divider()
                                }
                            }
                            .background(Color.surfaceMain)
                            .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                        }
                        .frame(maxHeight: 200)
                        .padding(.horizontal, AppConstants.Layout.standardPadding)
                    }
                    
                    Spacer()
                    
                    // Bottom Confirmation Card
                    VStack(spacing: AppConstants.Layout.elementSpacing + 4) {
                        HStack(alignment: .center, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.brandPrimary.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.brandPrimary)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Selected Area")
                                    .font(.captionText)
                                    .foregroundColor(.textSecondary)
                                Text(selectedAddress)
                                    .font(.bodyBold)
                                    .foregroundColor(.textPrimary)
                                    .lineLimit(2)
                            }
                            Spacer()
                        }
                        
                        Button(action: confirmLocation) {
                            Text("Confirm Location")
                                .font(.buttonText)
                                .foregroundColor(.textOnBrand)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.brandPrimary)
                                .cornerRadius(AppConstants.UI.cornerRadiusMedium)
                        }
                        .disabled(selectedAddress == "Resolving location..." || selectedCoordinate == nil)
                        .opacity((selectedAddress == "Resolving location..." || selectedCoordinate == nil) ? 0.6 : 1.0)
                    }
                    .padding(AppConstants.Layout.standardPadding)
                    .background(Color.surfaceMain)
                    .cornerRadius(AppConstants.UI.cornerRadiusLarge)
                    .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: -4)
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textPrimary)
                }
            }
        }
    }
    
    private func executeSearch() {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, error == nil else { return }
            DispatchQueue.main.async {
                self.searchResults = response.mapItems
            }
        }
    }
    
    private func selectSearchItem(_ item: MKMapItem) {
        searchResults.removeAll()
        searchQuery = ""
        
        withAnimation {
            region = MKCoordinateRegion(
                center: item.placemark.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        }
    }
    
    private func confirmLocation() {
        if let coord = selectedCoordinate {
            onConfirm(selectedAddress, coord.latitude, coord.longitude)
            dismiss()
        }
    }
}

// Representable Map View to avoid region change coordinate update lag
struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var address: String
    @Binding var coordinate: CLLocationCoordinate2D?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: false)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Only update region if center coordinates are significantly different
        let currentCenter = uiView.region.center
        let targetCenter = region.center
        let deltaLat = abs(currentCenter.latitude - targetCenter.latitude)
        let deltaLng = abs(currentCenter.longitude - targetCenter.longitude)
        
        if deltaLat > 0.0001 || deltaLng > 0.0001 {
            uiView.setRegion(region, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        private var geocodeTimer: Timer?
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let center = mapView.centerCoordinate
            parent.coordinate = center
            
            // Debounce geocoding to prevent API throttling
            geocodeTimer?.invalidate()
            geocodeTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.geocode(coordinate: center)
            }
        }
        
        private func geocode(coordinate: CLLocationCoordinate2D) {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let error = error {
                        print("Map geocoding failed: \(error.localizedDescription)")
                        self.parent.address = "Unknown Location"
                        return
                    }
                    
                    guard let placemark = placemarks?.first else {
                        self.parent.address = "Unknown Location"
                        return
                    }
                    
                    let locality = placemark.locality ?? placemark.subLocality ?? placemark.name
                    let subAdministrativeArea = placemark.subAdministrativeArea ?? placemark.administrativeArea
                    
                    if let locality = locality, let subAdmin = subAdministrativeArea {
                        self.parent.address = "\(locality), \(subAdmin)"
                    } else if let locality = locality {
                        self.parent.address = locality
                    } else {
                        self.parent.address = placemark.title ?? "Unknown Location"
                    }
                }
            }
        }
    }
}
