import SwiftUI

struct RootView: View {
    
    // 現在表示している画面
    @State private var gameState: GameState = .home
    
    // 計測した3次元軌跡
    @State private var trajectory: [SIMD3<Float>] = []
    
    // 円の解析結果
    @State private var analysisResult: CircleAnalysisResult?
    
    var body: some View {
        
        switch gameState {
            
        case .home:
            HomeView(
                onStart: {
                    gameState = .tracking
                }
            )
            
        case .tracking:
            TrackingView { points in
                
                // 計測結果を保存
                trajectory = points
                
                // 点群を解析
                analysisResult = CircleAnalyzer.analyze(
                    points: points
                )
                
                // Resultへ切り替え
                gameState = .result
            }
            
        case .result:
            if let analysisResult = analysisResult {
                
                ResultView(
                    result: analysisResult,
                    trajectory: trajectory,
                    onRetry: {
                        gameState = .tracking
                    },
                    onHome: {
                        gameState = .home
                    }
                )
                
            } else {
                Text("解析結果がありません")
            }
        }
    }
}

#Preview {
    RootView()
}
