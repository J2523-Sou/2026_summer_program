//
//  TrackingView.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/13/26.
//

import SwiftUI

struct TrackingView: View {
    
    let onFinish: ([SIMD3<Float>]) -> Void
    
    // ARTrackingManagerのインスタンスを生成
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
            
            switch tracker.trackingState {
                
            case .calibrating:
                Text("3秒間静止してください")
                
            case .ready:
                Text("準備完了")
                Text("動かすと記録を開始します")
                
            case .recording:
                Text("● RECORDING")
                Text("Points: \(tracker.recordedPointCount)")
                
            case .completed:
                Text("記録完了")
            }
            
            if tracker.trackingState == .recording ||
                tracker.trackingState == .completed {
                Button("RESTART") {
                    tracker.reset()
                }
            }
//            else {
//                Button("RECORD") {
//                    tracker.startRecording()
//                }
//            }
            
            Button("FINISH") {
                tracker.stop()
                onFinish(tracker.trajectory)
            }
        }
        
        // Viewが表示されたら追跡を開始する
        .onAppear {
            tracker.start()
        }
        .onDisappear {
            tracker.stop()
        }
    }
}

#Preview {
    TrackingView { points in
        print(points.count)
    }
}
