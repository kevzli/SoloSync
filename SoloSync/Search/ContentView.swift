//
//  ContentView.swift
//  SoloSync
//
//  Created by Aaron Chen on 2024/11/12.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager.shared
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var mapSelection: MKMapItem?
//    @Namespace private var locationSpace

    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    @State private var searchBarResults: [MKMapItem] = []
    
    @State private var showDetails: Bool = false
    @State private var lookAroundScene: MKLookAroundScene?
    
    @State private var routeDisplaying: Bool = false
    @State private var route: MKRoute?
    
//    @State private var searchResults = [SearchResult]()

//    @State private var selectedLocation: SearchResult?
//    @State private var isSheetPresented: Bool = true

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition, selection: $mapSelection) {
                
//                ForEach(searchResults) { result in
//                    Marker(coordinate: result.location) {
//                        Image(systemName: "mappin")
//                    }
//                    .tag(result)
//                }
                ForEach(searchBarResults, id: \.self) { mapItem in
                    let placemark = mapItem.placemark
                    Marker(placemark.name ?? "Place", coordinate: placemark.coordinate)
                    
                }
                
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 7)
                }
                
                UserAnnotation()
            }
            .mapControls {
                MapCompass()
                MapUserLocationButton()
                MapPitchToggle()
                MapScaleView()
            }
            .onAppear {
                if let userLocation = locationManager.userLocation?.coordinate {
                    cameraPosition = .region(MKCoordinateRegion.myRegion(for: userLocation))
                }
            }

//            .onChange(of: selectedLocation) {
//                isSheetPresented = selectedLocation == nil
//            }

//            .onChange(of: searchResults) {
//                if let firstResult = searchResults.first, searchResults.count == 1 {
//                    selectedLocation = firstResult
//                }
//            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .searchable(text: $searchText, isPresented: $showSearch)
            .sheet(isPresented: $showDetails, content: {
                MapDetails()
                    .presentationDetents([.height(300)])
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled(true)
            })
    //        .sheet(isPresented: $isSheetPresented) {
    //            SheetView(searchResults: $searchResults)
    //        }
    //        .safeAreaInset(edge: .bottom) {
    //            HStack {
    //                Spacer()
    //                VStack(spacing:0) {
    //                    if let selectedLocation {
    //                        ItemInfoView(selectedResult: selectedResult, route: route)
    //                            .frame(height: 128)
    //                            .clipShape(RoundedRectangle(cornerRadius: 10))
    //                            .padding([.top, .horizontal])
    //                    }
    //                    BeantownButtons(position: $position, searchResults: $searchResults, visibleRegion: visibleRegion)
    //                        .padding(.top)
    //                }
    //                Spacer()
    //            }
    //            .background(.thinMaterial)
    //        }
        }
        .onSubmit(of: .search) {
            Task {
                guard !searchText.isEmpty else { return }
                cameraPosition = .automatic
                await searchPlaces()
            }
        }
        .onChange(of: showSearch, initial: false) {
            if !showSearch {
                searchBarResults.removeAll(keepingCapacity: false)
                showDetails = false
                withAnimation(.snappy) {
                    cameraPosition = .automatic
                }
            }
        }
        .onChange(of: mapSelection) { oldValue, newValue in
            showDetails = newValue != nil
            fetchLookAroundPreview()
        }
        
        
    }
    
    @ViewBuilder
    func MapDetails() -> some View {
        VStack(spacing: 15) {
            ZStack {
                if lookAroundScene == nil {
                    ContentUnavailableView("No Preview Available", systemImage: "eye.slash")
                } else {
                    LookAroundPreview(scene: $lookAroundScene)
                }
            }
            .frame(height: 200)
            .clipShape(.rect(cornerRadius: 15))
            .overlay(alignment: .topTrailing) {
                Button(action: {
                    showDetails = false
                    withAnimation(.snappy) {
                        mapSelection = nil
                    }
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.black)
                        .background(.white, in: .circle)
                })
                .padding(10)
            }
            
            Button("Get Directions", action: fetchRoute)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.blue.gradient, in: .rect(cornerRadius: 15))
            
        }
        .padding(15)
    }
    
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
//        request.region = .myRegion
        let results = try? await MKLocalSearch(request: request).start()
        searchBarResults = results?.mapItems ?? []
        
        
    }
    
    func fetchLookAroundPreview() {
        if let mapSelection {
            lookAroundScene = nil
            Task {
                let request = MKLookAroundSceneRequest(mapItem: mapSelection)
                lookAroundScene = try? await request.scene
            }
        }
    }
    
    func fetchRoute() {
        let request = MKDirections.Request()
        request.source = .init(placemark: .init(coordinate: locationManager.userLocation?.coordinate ?? CLLocationCoordinate2D.defaultLocation))
        request.destination = mapSelection
        
        Task {
            let result = try? await MKDirections(request: request).calculate()
            route = result?.routes.first
            
            withAnimation(.snappy) {
                routeDisplaying = true
            }
        }
    }
}

#Preview {
    ContentView()
}

extension CLLocationCoordinate2D {
    static var defaultLocation: CLLocationCoordinate2D {
        return .init(latitude: +37.78583400, longitude: -122.40641700)
    }
}

extension MKCoordinateRegion {
    static func myRegion(for userLocation: CLLocationCoordinate2D?) -> MKCoordinateRegion {
        let center = userLocation ?? .defaultLocation
        return MKCoordinateRegion(center: center, latitudinalMeters: 10000, longitudinalMeters: 10000)
    }
}


