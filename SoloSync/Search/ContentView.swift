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

    @State private var searchResults = [SearchResult]()

    @State private var selectedLocation: SearchResult?
    @State private var isSheetPresented: Bool = true

    var body: some View {

        Map(position: $position, selection: $selectedLocation) {
            // 4
            ForEach(searchResults) { result in
                Marker(coordinate: result.location) {
                    Image(systemName: "mappin")
                }
                .tag(result)
            }
            
            UserAnnotation()
        }
        .ignoresSafeArea()

        .onChange(of: selectedLocation) {
            isSheetPresented = selectedLocation == nil
        }

        .onChange(of: searchResults) {
            if let firstResult = searchResults.first, searchResults.count == 1 {
                selectedLocation = firstResult
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            SheetView(searchResults: $searchResults)
        }
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
}

#Preview {
    ContentView()
}
