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
            Text(String(format: "Speed: %.4f m/s", tracker.speed))
            Text(tracker.isStill ? "静止中" : "移動中")
            
            if tracker.isCalibrated {
                Text("原点設定完了")
                
                Text(String(format: "X: %.3f m", tracker.relativeX))
                Text(String(format: "Y: %.3f m", tracker.relativeY))
                Text(String(format: "Z: %.3f m", tracker.relativeZ))

            } else {
                Text("3秒間静止してください")
                
                ProgressView(value: tracker.calibrationProgress)
            }
            
            Text("Points: \(tracker.recordedPointCount)")
            
            if tracker.isRecording {
                Button("STOP RECORDING") {
                    tracker.stopRecording()
                }
            } else {
                Button("RECORD") {
                    tracker.startRecording()
                }
            }
            
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
