import SwiftUI
import ARKit
import SceneKit

// 記録した相対座標をARカメラ映像の上に表示する
struct ARTrajectoryPreview: UIViewRepresentable {
    let session: ARSession
    let origin: SIMD3<Float>
    let trajectory: [SIMD3<Float>]

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        sceneView.session = session
        sceneView.scene = SCNScene()
        sceneView.automaticallyUpdatesLighting = true

        let originNode = SCNNode()
        originNode.simdPosition = origin

        for point in trajectory {
            let sphere = SCNSphere(radius: 0.005)
            sphere.firstMaterial?.diffuse.contents = UIColor.cyan

            let pointNode = SCNNode(geometry: sphere)
            pointNode.simdPosition = point
            originNode.addChildNode(pointNode)
        }

        sceneView.scene.rootNode.addChildNode(originNode)

        // Resume tracking without resetting its world coordinate system.
        session.run(ARWorldTrackingConfiguration(), options: [])
        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}
}
