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
    @Published var z: Float = 0         // 座標データ3つ
    @Published var speed: Float = 0     // 移動速度
    
    private let session = ARSession()
    private var previousPosition: SIMD3<Float>?     // 1フレーム前の距離
    private var previousTimestamp: TimeInterval?    // 1フレーム前の時刻
    
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
        
        // 現在の位置をcurrentPositionへ格納
        let currentPosition = SIMD3<Float>(
            position.x,
            position.y,
            position.z
        )
        
        let currentTimestamp = frame.timestamp
        
        // 速度計算部
        if let previousPosition = previousPosition,
           let previousTimestamp = previousTimestamp {
            
            let dx = currentPosition.x - previousPosition.x
            let dy = currentPosition.y - previousPosition.y
            let dz = currentPosition.z - previousPosition.z
            
            let distance = sqrt(dx * dx + dy * dy + dz * dz)
            
            let deltaTime = currentTimestamp - previousTimestamp
            
            if deltaTime > 0 {
                let currentSpeed = distance / Float(deltaTime)
                
                DispatchQueue.main.async {
                    self.speed = currentSpeed
                }
            }
        }
        
        // previousへ現在のデータを格納．
        previousPosition = currentPosition
        previousTimestamp = currentTimestamp
        
        DispatchQueue.main.async {
            self.x = position.x
            self.y = position.y
            self.z = position.z
        }
    }
}
