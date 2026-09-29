//
//  TrackingView.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/13/26.
//

import SwiftUI
import ARKit
import RealityKit
import UIKit

struct TrackingView: View {
    
    @State private var haptics = HapticManager()
    
    let onFinish: ([SIMD3<Float>]) -> Void
    
    // ARTrackingManagerのインスタンスを生成
    @StateObject private var tracker = ARTrackingManager()

    // 記録完了後にAR表示へ切り替える
    @State private var isARPreviewPresented = false
    
    var body: some View {
        Group {
            if isARPreviewPresented,
               let origin = tracker.origin {
                ZStack(alignment: .bottom) {
                    // 記録に使ったARSessionのカメラ映像を背景にする
                    ARTrajectoryPreview(
                        session: tracker.session,
                        origin: origin,
                        trajectory: tracker.trajectory
                    )
                    .ignoresSafeArea()

                    HStack(spacing: 12) {
                        previewResultButton
                        previewResetButton
                    }
                    .padding()
                }
            } else {
                trackingControls
            }
        }
        .onAppear {
            // RETRY時は前回のAR PREVIEW状態を引き継がない
            isARPreviewPresented = false
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

            if tracker.trackingState == .completed {
                Button("AR PREVIEW") {
                    isARPreviewPresented = true
                }
                .buttonStyle(.borderedProminent)
            }

            if #available(iOS 26.0, *) {
                if tracker.trackingState == .recording ||
                    tracker.trackingState == .completed {
                    resetButton
                }
                finishButton.buttonStyle(.glassProminent)
            } else {
                if tracker.trackingState == .recording ||
                    tracker.trackingState == .completed {
                    resetButton
                }
                finishButton.buttonStyle(.borderedProminent)
            }
        }
    }

    private var finishButton: some View {
        Button("FINISH") {
            tracker.stop()
            onFinish(tracker.trajectory)
        }
    }

    private var resetButton: some View {
        Button("RESTART") {
            tracker.reset()
        }
    }

    private var previewResetButton: some View {
        Button("RESTART") {
            isARPreviewPresented = false
            // ARViewが使用した後も新しい記録を開始できるようにする
            tracker.start()
        }
    }

    private var previewResultButton: some View {
        Button("RESULT") {
            tracker.stop()
            onFinish(tracker.trajectory)
        }
        .buttonStyle(.borderedProminent)
    }

}

// 記録した相対座標をorigin配下の球としてAR空間へ表示する
private struct ARTrajectoryPreview: UIViewRepresentable {
    let session: ARSession
    let origin: SIMD3<Float>
    let trajectory: [SIMD3<Float>]

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(
            frame: .zero,
            cameraMode: .ar,
            automaticallyConfigureSession: false
        )
        arView.session = session

        let anchor = AnchorEntity(world: origin)
        let material = SimpleMaterial(color: .cyan, isMetallic: false)

        for point in trajectory {
            let entity = ModelEntity(
                mesh: .generateSphere(radius: 0.005),
                materials: [material]
            )
            entity.position = point
            anchor.addChild(entity)
        }

        arView.scene.addAnchor(anchor)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}

#Preview {
    TrackingView { points in
        print(points.count)
    }
}
