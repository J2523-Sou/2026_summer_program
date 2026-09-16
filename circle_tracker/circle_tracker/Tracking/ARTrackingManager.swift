//
//  ARTrackingManager.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/13/26.
//

import ARKit
import Combine
import simd

class ARTrackingManager: NSObject, ObservableObject, ARSessionDelegate {
    
    // MARK: - UIに公開する値
    // 外部からは読み取り専用とする．また @Published により更新された場合に参照元へ通知する
    
    @Published private(set) var x: Float = 0
    @Published private(set) var y: Float = 0
    @Published private(set) var z: Float = 0                // 生座標
    
    @Published private(set) var relativeX: Float = 0
    @Published private(set) var relativeY: Float = 0
    @Published private(set) var relativeZ: Float = 0        // 補正後座標
    
    @Published private(set) var speed: Float = 0            // 移動速度
    @Published private(set) var isStill: Bool = false       // 静止フラグ
    
    @Published private(set) var calibrationProgress: Float = 0      // 補正の進行度
    
    @Published private(set) var recordedPointCount: Int = 0         // 軌跡データ量
    @Published private(set) var trajectory: [SIMD3<Float>] = []     // 軌跡
    
    @Published private(set) var trackingState: TrackingState = .calibrating
    
    
    // MARK: - ARKit
    
    private let session = ARSession()
    
    private var previousPosition: SIMD3<Float>?
    private var previousTimestamp: TimeInterval?
    
    
    // MARK: - 判定条件
    
    // これ未満なら静止とみなす
    private let stillnessThreshold: Float = 0.25
    
    // これを超えたら描画開始とみなす
    private let movementStartThreshold: Float = 0.35
    
    // 最初に必要な静止時間
    private let calibrationDuration: TimeInterval = 3.0
    
    // 描画終了とみなす静止時間
    private let finishStillDuration: TimeInterval = 2.0
    
    
    // MARK: - 静止時間管理
    
    private var stillStartTimestamp: TimeInterval?
    
    
    // MARK: - 原点補正
    
    private var calibrationPositions: [SIMD3<Float>] = []
    
    private var origin: SIMD3<Float>?
    
    
    // MARK: - 初期化
    
    override init() {
        super.init()
        
        session.delegate = self
        
        // ARSessionDelegateをMain Queueで処理する
        // @Publishedの変更も同じスレッドで扱える
        session.delegateQueue = .main
    }
    
    
    // MARK: - ARKit開始
    
    func start() {
        
        reset()
        
        let configuration = ARWorldTrackingConfiguration()
        
        session.run(
            configuration,
            options: [
                .resetTracking,
                .removeExistingAnchors
            ]
        )
    }
    
    
    // MARK: - ARKit停止
    
    func stop() {
        session.pause()
    }
    
    
    // MARK: - リセット
    
    func reset() {
        
        trackingState = .calibrating
        
        previousPosition = nil
        previousTimestamp = nil
        
        stillStartTimestamp = nil
        
        calibrationPositions.removeAll()
        origin = nil
        
        trajectory.removeAll()
        recordedPointCount = 0
        
        calibrationProgress = 0
        
        speed = 0
        isStill = false
        
        relativeX = 0
        relativeY = 0
        relativeZ = 0
    }
    
    
    // MARK: - 主処理
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        // -----------------------------------
        // 1. 現在位置を取得
        // -----------------------------------
        
        let transform = frame.camera.transform
        let translation = transform.columns.3
        
        let currentPosition = SIMD3<Float>(
            translation.x,
            translation.y,
            translation.z
        )
        
        let currentTimestamp = frame.timestamp
        
        
        // 生座標を更新
        x = currentPosition.x
        y = currentPosition.y
        z = currentPosition.z
        
        
        // -----------------------------------
        // 2. 原点からの相対座標を計算
        // -----------------------------------
        
        if let origin {
            
            let relativePosition =
            currentPosition - origin
            
            relativeX = relativePosition.x
            relativeY = relativePosition.y
            relativeZ = relativePosition.z
        }
        
        
        // -----------------------------------
        // 3. 前フレームがなければ終了
        // -----------------------------------
        
        guard
            let previousPosition,
            let previousTimestamp
        else {
            
            self.previousPosition = currentPosition
            self.previousTimestamp = currentTimestamp
            
            return
        }
        
        
        // -----------------------------------
        // 4. 速度を計算
        // -----------------------------------
        
        let deltaTime =
        currentTimestamp - previousTimestamp
        
        guard deltaTime > 0 else {
            return
        }
        
        let distance =
        simd_distance(
            currentPosition,
            previousPosition
        )
        
        let currentSpeed =
        distance / Float(deltaTime)
        
        let currentIsStill =
        currentSpeed < stillnessThreshold
        
        speed = currentSpeed
        isStill = currentIsStill
        
        
        // -----------------------------------
        // 5. 状態ごとの処理
        // -----------------------------------
        
        switch trackingState {
            
        case .calibrating:
            
            handleCalibration(
                position: currentPosition,
                timestamp: currentTimestamp,
                isStill: currentIsStill
            )
            
            
        case .ready:
            
            handleReady(
                speed: currentSpeed
            )
            
            
        case .recording:
            
            handleRecording(
                position: currentPosition,
                timestamp: currentTimestamp,
                isStill: currentIsStill
            )
            
            
        case .completed:
            
            break
        }
        
        
        // -----------------------------------
        // 6. 次フレーム用に保存
        // -----------------------------------
        
        self.previousPosition = currentPosition
        self.previousTimestamp = currentTimestamp
    }
    
    
    // MARK: - 補正処理
    
    private func handleCalibration(
        position: SIMD3<Float>,
        timestamp: TimeInterval,
        isStill: Bool
    ) {
        
        // 動いていた場合
        if !isStill {
            
            stillStartTimestamp = nil
            calibrationPositions.removeAll()
            
            calibrationProgress = 0
            
            return
        }
        
        
        // 静止を開始した瞬間
        if stillStartTimestamp == nil {
            
            stillStartTimestamp = timestamp
            
            calibrationPositions.removeAll()
        }
        
        
        // 静止中の位置を保存
        calibrationPositions.append(position)
        
        
        guard let startTimestamp =
                stillStartTimestamp
        else {
            return
        }
        
        
        // 静止時間
        let elapsed =
        timestamp - startTimestamp
        
        
        // 0.0 ～ 1.0
        calibrationProgress =
        min(
            Float(
                elapsed / calibrationDuration
            ),
            1.0
        )
        
        
        // まだ3秒経っていない
        guard elapsed >= calibrationDuration else {
            return
        }
        
        
        // 原点を設定
        setOrigin()
        
        
        // 次の状態へ
        stillStartTimestamp = nil
        
        trackingState = .ready
    }
    
    
    // MARK: - Ready
    
    private func handleReady(
        speed: Float
    ) {
        
        // 十分に動いていなければ待機
        guard speed > movementStartThreshold else {
            return
        }
        
        
        // 新しい軌跡を開始
        trajectory.removeAll()
        recordedPointCount = 0
        
        stillStartTimestamp = nil
        
        trackingState = .recording
    }
    
    
    // MARK: - 軌跡の記録
    
    private func handleRecording(
        position: SIMD3<Float>,
        timestamp: TimeInterval,
        isStill: Bool
    ) {
        
        // ----------------------------
        // 軌跡を記録
        // ----------------------------
        
        if let origin {
            
            let relativePosition =
            position - origin
            
            trajectory.append(relativePosition)
            
            recordedPointCount =
            trajectory.count
        }
        
        
        // ----------------------------
        // 動いている
        // ----------------------------
        
        if !isStill {
            
            // 静止判定をリセット
            stillStartTimestamp = nil
            
            return
        }
        
        
        // ----------------------------
        // 静止を開始
        // ----------------------------
        
        if stillStartTimestamp == nil {
            
            stillStartTimestamp =
            timestamp
        }
        
        
        guard let startTimestamp =
                stillStartTimestamp
        else {
            return
        }
        
        
        let elapsed =
        timestamp - startTimestamp
        
        
        // まだ1秒静止していない
        guard elapsed >= finishStillDuration else {
            return
        }
        
        
        // ----------------------------
        // 記録完了
        // ----------------------------
        
        stillStartTimestamp = nil
        
        trackingState = .completed
    }
    
    
    // MARK: - 原点設定
    
    private func setOrigin() {
        
        guard !calibrationPositions.isEmpty else {
            return
        }
        
        
        var sum =
        SIMD3<Float>(
            0,
            0,
            0
        )
        
        
        for position in calibrationPositions {
            sum += position
        }
        
        
        // 静止中に取得した座標の平均
        origin =
        sum
        / Float(
            calibrationPositions.count
        )
        
        
        calibrationProgress = 1.0
        
        calibrationPositions.removeAll()
    }
}
