//
//  Trajectory3DView.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/13/26.
//

import SwiftUI
import RealityKit

struct Trajectory3DView: View {
    
    let points: [SIMD3<Float>]
    
    var body: some View {
        RealityView { content in
            
            let root = Entity()
            
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
        }
    }
}
