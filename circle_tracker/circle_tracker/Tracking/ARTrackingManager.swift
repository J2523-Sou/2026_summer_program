//
//  ARTrackingManager.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/13/26.
//

import ARKit
import Combine

class ARTrackingManager: NSObject, ObservableObject, ARSessionDelegate {
    
    @Published var x: Float = 0
    @Published var y: Float = 0
    @Published var z: Float = 0
    
    private let session = ARSession()
    
    override init() {
        super.init()
        session.delegate = self
    }
    
    func start() {
        let configuration = ARWorldTrackingConfiguration()
        
        session.run(configuration)
    }
    
    func stop() {
        session.pause()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let transform = frame.camera.transform
        
        let position = transform.columns.3
        
        DispatchQueue.main.async {
            self.x = position.x
            self.y = position.y
            self.z = position.z
        }
    }
}
