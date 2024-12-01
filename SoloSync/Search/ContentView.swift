//
//  ContentView.swift
//  SoloSync
//
//  Created by Aaron Chen on 2024/11/12.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var position = MapCameraPosition.automatic
    @State private var mapSelection: MKMapItem?
//    @Namespace private var locationSpace

    @State private var searchText: String = ""
    @State private var showSearch: Bool = false
    @State private var searchBarResults: [MKMapItem] = []
    
    @State private var showDetails: Bool = false
    @State private var lookAroundScene: MKLookAroundScene?
    
//    @State private var searchResults = [SearchResult]()

//    @State private var selectedLocation: SearchResult?
//    @State private var isSheetPresented: Bool = true

    var body: some View {
        NavigationStack {
            Map(position: $position, selection: $mapSelection) {
                
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
                
                UserAnnotation()
            }
            .mapControls {
                MapCompass()
                MapUserLocationButton()
                MapPitchToggle()
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
            .sheet(isPresented: $showDetails) {
                
            } content: {
                MapDetails()
                    .presentationDetents([.height(300)])
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
                    .presentationCornerRadius(25)
                    .interactiveDismissDisabled(true)
            }
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
                await searchPlaces()
            }
        }
        .onChange(of: showSearch, initial: false) {
            if !showSearch {
                searchBarResults.removeAll(keepingCapacity: false)
                showDetails = false
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
            
            Button("Get Directions") {
                
            }
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
}

#Preview {
    ContentView()
}
