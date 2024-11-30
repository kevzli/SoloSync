//
//  ItemInfoView.swift
//  SoloSync
//
//  Created by Aaron Chen on 2024/11/12.
//

import SwiftUI
import MapKit

struct ItemInfoView: View {
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var selectedLocation: MKMapItem?
    
    func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(mapItem: selectedLocation!)
            lookAroundScene = try? await request.scene
        }
    }
    
    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                // ...
            }
            .onAppear() {
                getLookAroundScene()
            }
            .onChange(of: selectedLocation) {
                getLookAroundScene()
            }
    }
}
