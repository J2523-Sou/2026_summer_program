//
//  TrackingView.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/13/26.
//

import SwiftUI
import UIKit

struct TrackingView: View {
    
    @State private var haptics = HapticManager()
    
    @ObservedObject var tracker: ARTrackingManager

    let onFinish: ([SIMD3<Float>]) -> Void

    var body: some View {
        trackingControls
        .onAppear {
            tracker.start()
        }
        .onDisappear {
            tracker.stop()
        }
        .onChange(of: tracker.trackingState) { _, _ in
            haptics.pulse()
        }
    }

    private var trackingControls: some View {
        VStack(spacing: 20) {
            
            Text("Tracking")
                .font(.largeTitle)
            
            Text("X: \(tracker.x)")
            Text("Y: \(tracker.y)")
            Text("Z: \(tracker.z)")
            Text(String(format: "Speed: %.4f m/s", tracker.speed))
            Text(tracker.isStill ? "静止中" : "移動中")
            
            switch tracker.trackingState {
                
            case .calibrating:
                Text("3秒間静止してください")
                ProgressView(value: tracker.calibrationProgress)
                    .progressViewStyle(.linear)
                
            case .ready:
                Text("準備完了")
                Text("動かすと記録を開始します")
                
            case .recording:
                Text("● RECORDING")
                Text("Points: \(tracker.recordedPointCount)")
                
            case .completed:
                Text("記録完了")
            }

            if #available(iOS 26.0, *) {
                if tracker.trackingState == .recording {
                    resetButton
                }
                finishButton.buttonStyle(.glassProminent)
            } else {
                if tracker.trackingState == .recording {
                    resetButton
                }
                finishButton.buttonStyle(.borderedProminent)
            }
        }
    }

    private var finishButton: some View {
        Button("END") {
            tracker.stop()
            onFinish(tracker.trajectory)
        }
    }

    private var resetButton: some View {
        Button("RESTART") {
            tracker.reset()
        }
    }

}

#Preview {
    TrackingView(tracker: ARTrackingManager()) { points in
        print(points.count)
    }
}
