//
//  RootView.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/13/26.
//

import SwiftUI

struct RootView: View {
    
    @State private var gameState: GameState = .home
    
    var body: some View {
        switch gameState {
            
        case .home:
            HomeView {
                gameState = .tracking
            }
            
        case .tracking:
            TrackingView {
                gameState = .result
            }
            
        case .result:
            ResultView(
                score: 85,
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
