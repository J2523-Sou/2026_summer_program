//
//  Trajectory3DView.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/13/26.
//

import SwiftUI
import RealityKit
import simd

struct Trajectory3DView: View {
    
    let points: [SIMD3<Float>]
    
    // ドラッグ用
    @State private var yaw: Float = 0
    @State private var pitch: Float = 0
    @State private var startYaw: Float = 0
    @State private var startPitch: Float = 0
    
    var body: some View {
        // 軌跡を描画する
        RealityView { content in
            
            // rootが点群3D領域全体
            let root = Entity()
            root.name = "trajectoryRoot"
            
            for point in points {
                
                let sphere = ModelEntity(
                    mesh: .generateSphere(radius: 0.005),
                    materials: [
                        SimpleMaterial()
                    ]
                )
                
                sphere.position = point
                root.addChild(sphere)
                
            }
            
            root.scale = [3, 3, 3]
            root.position = [0, 0, -1]
            
            content.add(root)
            
        } update: { content in          // 3D領域の更新処理
            
            if let root = content.entities.first(
                where: {$0.name == "trajectoryRoot"}
            ) {
                
                let yawRotation = simd_quatf(
                    angle: yaw,
                    axis: [0, 1, 0]
                )
                
                let pitchRotation = simd_quatf(
                    angle: pitch,
                    axis: [1, 0, 0]
                )
                
                root.orientation = yawRotation * pitchRotation
                
            }
            
        }
        
        // ユーザ操作部分
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { value in
                    
                    yaw = startYaw + Float(value.translation.width) * 0.01
                    pitch = startPitch + Float(value.translation.height) * 0.01
                    
                }
                .onEnded { _ in
                    
                    startYaw = yaw
                    startPitch = pitch
                    
                }
        )
        
    }
}
