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
    @Published var z: Float = 0                             // 生座標データ3つ
    @Published var speed: Float = 0                         // 移動速度
    @Published var isStill: Bool = false                    // 静止中フラグ
    @Published var calibrationProgress: Float = 0           // 原点補正進行度
    @Published var isCalibrated: Bool = false               // 原点設定完了フラグ
    @Published var relativeX: Float = 0
    @Published var relativeY: Float = 0
    @Published var relativeZ: Float = 0                     // 原点補正後の座標
    @Published var isRecording: Bool = false
    @Published var recordedPointCount: Int = 0
    @Published private(set) var trajectory: [SIMD3<Float>] = []             // 軌跡

    
    private let session = ARSession()
    private var previousPosition: SIMD3<Float>?             // 1フレーム前の位置
    private var previousTimestamp: TimeInterval?            // 1フレーム前の時刻
    private let stillnessThreshold: Float = 0.25            // 動作検出閾値
    private let calibrationDuration: TimeInterval = 3.0
    private var stillStartTimestamp: TimeInterval?          // 静止開始時刻
    private var calibrationPositions: [SIMD3<Float>] = []   // 静止中の座標（配列として全て保存）
    private var origin: SIMD3<Float>?                       // 補正後の原点
    private var calibrationCompleted = false                // 補正完了フラグ
    
    // 初期化
    override init() {
        super.init()
        session.delegate = self
    }
    
    // 検出開始
    func start() {
        let configuration = ARWorldTrackingConfiguration()
        session.run(configuration)
    }
    
    // 検出停止
    func stop() {
        session.pause()
    }
    
    // 原点補正
    private func setOrigin() {
        
        guard !calibrationPositions.isEmpty else {
            return
        }
        
        var sum = SIMD3<Float>(0, 0, 0)
        
        // 静止中の全座標の重心を算出，originへ
        for position in calibrationPositions {
            sum += position
        }
        
        origin = sum / Float(calibrationPositions.count)
        
        calibrationCompleted = true
        
        DispatchQueue.main.async {
            self.calibrationProgress = 1.0
            self.isCalibrated = true
        }
    }
    
    // 記録開始
    func startRecording() {
        trajectory.removeAll()
        isRecording = true
        recordedPointCount = 0
    }
    
    // 記録停止
    func stopRecording() {
        isRecording = false
    }
    
    // 主処理（新たなフレームを検出するたびに呼び出される）
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
            
            // 変化量
            let dx = currentPosition.x - previousPosition.x
            let dy = currentPosition.y - previousPosition.y
            let dz = currentPosition.z - previousPosition.z
            
            // 空間ベクトルの距離
            let distance = sqrt(dx * dx + dy * dy + dz * dz)
            
            // 時間変化
            let deltaTime = currentTimestamp - previousTimestamp
            
            // もしも前フレームから時間差があれば
            if deltaTime > 0 {
                // currentSpeedに速度を格納
                let currentSpeed = distance / Float(deltaTime)
                
                // 動いているか？
                let currentIsStill = currentSpeed < stillnessThreshold
                
                // setOriginの呼び出し
                // 静止状態が閾値以上続いた場合，検出した座標の平均を原点とする．
                if !calibrationCompleted {
                    
                    if currentIsStill {
                        
                        if stillStartTimestamp == nil {
                            stillStartTimestamp = currentTimestamp
                            calibrationPositions.removeAll()
                        }
                        
                        calibrationPositions.append(currentPosition)
                        
                        let elapsed = currentTimestamp - stillStartTimestamp!
                        let progress = min(Float(elapsed / calibrationDuration), 1.0)
                        
                        DispatchQueue.main.async {
                            self.calibrationProgress = progress
                        }
                        
                        if elapsed >= calibrationDuration {
                            setOrigin()
                        }
                        
                    } else {
                        stillStartTimestamp = nil
                        calibrationPositions.removeAll()
                        
                        DispatchQueue.main.async {
                            self.calibrationProgress = 0
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.speed = currentSpeed
                    self.isStill = currentIsStill
                }
            }
        }
        
        // 補正後の座標を保存
        if let origin = origin {
            let relativePosition = currentPosition - origin
            
            if isRecording {
                trajectory.append(relativePosition)
                
                DispatchQueue.main.async {
                    self.recordedPointCount = self.trajectory.count
                }
            }
            
            DispatchQueue.main.async {
                self.relativeX = relativePosition.x
                self.relativeY = relativePosition.y
                self.relativeZ = relativePosition.z
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
