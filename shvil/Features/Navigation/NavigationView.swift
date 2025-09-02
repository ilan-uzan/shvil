//
//  NavigationView.swift
//  shvil
//
//  Created by ilan on 2024.
//

import SwiftUI
import MapKit

struct ShvilNavigationView: View {
    @EnvironmentObject private var navigationService: NavigationService
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var searchService: SearchService
    
    @State private var showingRouteOptions = false
    @State private var showingTransportModes = false
    @State private var selectedTransportMode: TransportMode = .car
    @State private var startLocation: CLLocationCoordinate2D?
    @State private var destinationLocation: CLLocationCoordinate2D?
    @State private var isCalculatingRoute = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map View
                MapView(
                    startLocation: $startLocation,
                    destinationLocation: $destinationLocation,
                    currentRoute: navigationService.currentRoute,
                    alternativeRoutes: navigationService.alternativeRoutes
                )
                .ignoresSafeArea()
                
                // Top Controls
                VStack {
                    HStack {
                        // Transport Mode Selector
                        Button(action: {
                            showingTransportModes = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: selectedTransportMode.icon)
                                    .foregroundColor(.white)
                                Text(selectedTransportMode.displayName)
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(25)
                        }
                        
                        Spacer()
                        
                        // Route Options
                        Button(action: {
                            showingRouteOptions = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Bottom Route Info
                    if let route = navigationService.currentRoute {
                        RouteInfoCard(route: route) {
                            navigationService.startNavigation()
                        }
                    } else if startLocation != nil && destinationLocation != nil {
                        // Calculate Route Button
                        Button(action: calculateRoute) {
                            HStack {
                                if isCalculatingRoute {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.white)
                                }
                                Text(isCalculatingRoute ? "Calculating..." : "Get Directions")
                                    .foregroundColor(.white)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(isCalculatingRoute)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Navigation")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingTransportModes) {
                TransportModeSelector(
                    selectedMode: $selectedTransportMode,
                    isPresented: $showingTransportModes
                )
            }
            .sheet(isPresented: $showingRouteOptions) {
                RouteOptionsView(
                    options: $navigationService.routeOptions,
                    isPresented: $showingRouteOptions
                )
            }
        }
    }
    
    private func calculateRoute() {
        guard let start = startLocation, let destination = destinationLocation else { return }
        
        isCalculatingRoute = true
        
        Task {
            await navigationService.calculateRoutes(
                from: start,
                to: destination,
                options: RouteOptions(
                    transportMode: selectedTransportMode,
                    avoidTolls: navigationService.routeOptions.avoidTolls,
                    avoidHighways: navigationService.routeOptions.avoidHighways,
                    avoidFerries: navigationService.routeOptions.avoidFerries,
                    preferBikeLanes: navigationService.routeOptions.preferBikeLanes,
                    truckHeight: navigationService.routeOptions.truckHeight,
                    truckWeight: navigationService.routeOptions.truckWeight,
                    truckHazmat: navigationService.routeOptions.truckHazmat
                )
            )
            
            isCalculatingRoute = false
        }
    }
}

// MARK: - Map View
struct MapView: UIViewRepresentable {
    @Binding var startLocation: CLLocationCoordinate2D?
    @Binding var destinationLocation: CLLocationCoordinate2D?
    let currentRoute: RouteResult?
    let alternativeRoutes: [RouteResult]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Clear existing overlays
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        // Add start and destination annotations
        if let start = startLocation {
            let startAnnotation = MKPointAnnotation()
            startAnnotation.coordinate = start
            startAnnotation.title = "Start"
            mapView.addAnnotation(startAnnotation)
        }
        
        if let destination = destinationLocation {
            let destinationAnnotation = MKPointAnnotation()
            destinationAnnotation.coordinate = destination
            destinationAnnotation.title = "Destination"
            mapView.addAnnotation(destinationAnnotation)
        }
        
        // Add route overlays
        if let route = currentRoute {
            let polyline = MKPolyline(coordinates: route.polyline, count: route.polyline.count)
            polyline.title = "Primary Route"
            mapView.addOverlay(polyline)
        }
        
        for (index, route) in alternativeRoutes.enumerated() {
            let polyline = MKPolyline(coordinates: route.polyline, count: route.polyline.count)
            polyline.title = "Alternative \(index + 1)"
            mapView.addOverlay(polyline)
        }
        
        // Fit map to show all annotations and routes
        if !mapView.annotations.isEmpty {
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = polyline.title == "Primary Route" ? .blue : .gray
                renderer.lineWidth = polyline.title == "Primary Route" ? 4 : 2
                return renderer
            }
            return MKOverlayRenderer()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            
            let identifier = "LocationAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            
            if annotation.title == "Start" {
                (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .green
            } else if annotation.title == "Destination" {
                (annotationView as? MKMarkerAnnotationView)?.markerTintColor = .red
            }
            
            return annotationView
        }
    }
}

// MARK: - Route Info Card
struct RouteInfoCard: View {
    let route: RouteResult
    let onStartNavigation: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Route Summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(route.transportMode.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text(route.formattedTime)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "location")
                            .foregroundColor(.secondary)
                        Text(route.formattedDistance)
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                }
                
                Spacer()
                
                Button(action: onStartNavigation) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(20)
                }
            }
            
            // Route Details
            if !route.tolls.isEmpty {
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(.orange)
                    Text("Tolls: \(route.tolls.map { $0.formattedCost }.joined(separator: ", "))")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            if !route.gasStations.isEmpty {
                HStack {
                    Image(systemName: "fuelpump")
                        .foregroundColor(.green)
                    Text("\(route.gasStations.count) gas stations along route")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 8)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Transport Mode Selector
struct TransportModeSelector: View {
    @Binding var selectedMode: TransportMode
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(TransportMode.allCases, id: \.self) { mode in
                HStack {
                    Image(systemName: mode.icon)
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    
                    Text(mode.displayName)
                        .font(.headline)
                    
                    Spacer()
                    
                    if selectedMode == mode {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedMode = mode
                    isPresented = false
                }
            }
            .navigationTitle("Transport Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Route Options View
struct RouteOptionsView: View {
    @Binding var options: RouteOptions
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section("Avoid") {
                    Toggle("Tolls", isOn: $options.avoidTolls)
                    Toggle("Highways", isOn: $options.avoidHighways)
                    Toggle("Ferries", isOn: $options.avoidFerries)
                }
                
                if options.transportMode == .bike {
                    Section("Bike Options") {
                        Toggle("Prefer Bike Lanes", isOn: $options.preferBikeLanes)
                    }
                }
                
                if options.transportMode == .truck {
                    Section("Truck Options") {
                        HStack {
                            Text("Height (m)")
                            Spacer()
                            TextField("0.0", value: $options.truckHeight, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                        }
                        
                        HStack {
                            Text("Weight (tons)")
                            Spacer()
                            TextField("0.0", value: $options.truckWeight, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 80)
                        }
                        
                        Toggle("Hazmat", isOn: $options.truckHazmat)
                    }
                }
            }
            .navigationTitle("Route Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    ShvilNavigationView()
        .environmentObject(NavigationService.shared)
        .environmentObject(LocationService.shared)
        .environmentObject(SearchService.shared)
}
