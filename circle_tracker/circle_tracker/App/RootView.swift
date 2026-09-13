//
//  RootView.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/13/26.
//

import SwiftUI

struct RootView: View {
    
    // 起動時の画面をhomeに設定．
    @State private var gameState: GameState = .home
    @State private var trajectory: [SIMD3<Float>] = []
    
    var body: some View {
        switch gameState {
        
        // homeにてonStartが渡された場合の処理
        // trackingへ移動する
        case .home:
            HomeView {
                gameState = .tracking
            }
        
        // trackingにてonFinishが渡された場合の処理
        // resultへ移動する
        case .tracking:
            TrackingView { points in
                trajectory = points
                gameState = .result
            }
            
        // resultでの処理
        case .result:
            ResultView(
                score: 85,
                trajectory: trajectory,
                onRetry: {
                    gameState = .tracking
                },
                onHome: {
                    gameState = .home
                }
            )
        }
    }
}

#Preview {
    RootView()
}
