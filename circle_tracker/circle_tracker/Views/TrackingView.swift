//
//  TrackingView.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/13/26.
//

import SwiftUI

struct TrackingView: View {
    
    let onFinish: () -> Void
    
    @StateObject private var tracker = ARTrackingManager()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Tracking")
                .font(.largeTitle)
            
            Text("X: \(tracker.x)")
            Text("Y: \(tracker.y)")
            Text("Z: \(tracker.z)")
            
            Button("FINISH") {
                onFinish()
            }
        }
        .onAppear {
            tracker.start()
        }
        .onDisappear {
            tracker.stop()
        }
    }
}

#Preview {
    TrackingView {
        print("FINISH")
    }
}
