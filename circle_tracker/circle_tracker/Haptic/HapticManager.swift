//
//  HapticManager.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/16/26.
//

import CoreHaptics

class HapticManager {
        
    private var engine: CHHapticEngine?
    
    init() {
        engine = try? CHHapticEngine()
        try? engine?.start()
    }
    
    func pulse() {
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [],
            relativeTime: 0
        )
        
        // Hapticパターンを作る．guardにより，失敗したら（nilだったら）returnされる．
        guard let pattern = try? CHHapticPattern(
            events: [event],
            parameters: []
        ) else {
            return
        }
        
        // パターンを再生する
        guard let player = try? engine?.makePlayer(with: pattern) else {
            return
        }
        
        try? player.start(atTime: 0)
    }
}
