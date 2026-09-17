import SwiftUI
import RealityKit
import simd

struct Trajectory3DView: View {
    
    let points: [SIMD3<Float>]
    
    // 回転
    @State private var yaw: Float = 0
    @State private var pitch: Float = 0
    @State private var startYaw: Float = 0
    @State private var startPitch: Float = 0
    
    // 拡大縮小
    @State private var zoom: Float = 1
    @State private var startZoom: Float = 1
    
    // 表示用に点群の中心を原点へ移動
    private var centeredPoints: [SIMD3<Float>] {
        
        guard !points.isEmpty else {
            return []
        }
        
        let minX = points.map { $0.x }.min()!
        let maxX = points.map { $0.x }.max()!
        
        let minY = points.map { $0.y }.min()!
        let maxY = points.map { $0.y }.max()!
        
        let minZ = points.map { $0.z }.min()!
        let maxZ = points.map { $0.z }.max()!
        
        let center = SIMD3<Float>(
            (minX + maxX) / 2,
            (minY + maxY) / 2,
            (minZ + maxZ) / 2
        )
        
        return points.map { point in
            point - center
        }
    }
    
    // 点群のサイズに応じた自動倍率
    private var displayScale: Float {
        
        guard !points.isEmpty else {
            return 1
        }
        
        let rangeX = points.map { $0.x }.max()! - points.map { $0.x }.min()!
        let rangeY = points.map { $0.y }.max()! - points.map { $0.y }.min()!
        let rangeZ = points.map { $0.z }.max()! - points.map { $0.z }.min()!
        
        let maxRange = max(rangeX, rangeY, rangeZ)
        
        guard maxRange > 0 else {
            return 1
        }
        
        // RealityView上で最大幅が約0.6mになるよう調整
        let targetSize: Float = 1.0
        
        return targetSize / maxRange
    }
    
    var body: some View {
        
        RealityView { content in
            
            let root = Entity()
            root.name = "trajectoryRoot"
            
            for point in centeredPoints {
                
                let sphere = ModelEntity(
                    mesh: .generateSphere(radius: 0.005),
                    materials: [
                        SimpleMaterial()
                    ]
                )
                
                sphere.position = point * displayScale
                root.addChild(sphere)
            }
            
            // カメラ前方へ配置
            root.position = [0, 0, -1]
            
            content.add(root)
            
        } update: { content in
            
            if let root = content.entities.first(
                where: { $0.name == "trajectoryRoot" }
            ) {
                
                // 回転
                let yawRotation = simd_quatf(
                    angle: yaw,
                    axis: [0, 1, 0]
                )
                
                let pitchRotation = simd_quatf(
                    angle: pitch,
                    axis: [1, 0, 0]
                )
                
                root.orientation =
                yawRotation * pitchRotation
                
                
                root.scale = [
                    zoom,
                    zoom,
                    zoom
                ]
            }
        }
        
        .contentShape(Rectangle())
        
        // ドラッグで回転
        .gesture(
            DragGesture()
                .onChanged { value in
                    
                    yaw =
                    startYaw
                    + Float(value.translation.width) * 0.01
                    
                    pitch =
                    startPitch
                    + Float(value.translation.height) * 0.01
                }
            
                .onEnded { _ in
                    startYaw = yaw
                    startPitch = pitch
                }
        )
        
        // ピンチで拡大縮小
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    
                    zoom = startZoom * Float(value)
                    
                    // 拡大率を制限
                    zoom = min(
                        max(zoom, 0.3),
                        8.0
                    )
                }
            
                .onEnded { _ in
                    startZoom = zoom
                }
        )
    }
}
