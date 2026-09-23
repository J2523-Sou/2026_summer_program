import SwiftUI

struct ResultView: View {
    
    let result: CircleAnalysisResult
    let trajectory: [SIMD3<Float>]
    
    let onRetry: () -> Void
    let onHome: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("RESULT")
                .font(.largeTitle)
                .bold()
            
            Text("\(result.score)")
                .font(.system(size: 80))
                .bold()
            
            Text("points")
            
            Text(
                String(
                    format: "Aspect: %.3f",
                    result.aspectScore
                )
            )
            
            Text(
                String(
                    format: "Radial Error: %.3f",
                    result.radialError
                )
            )
            
            Text("Points: \(result.pointCount)")
            
            Trajectory3DView(points: trajectory)
                .frame(height: 350)
            
            if #available(iOS 26.0, *) {
                Button("RETRY") {
                    onRetry()
                }
                .buttonStyle(.glassProminent)

                Button("HOME") {
                    onHome()
                }
                .buttonStyle(.glass)
            } else {
                Button("RETRY") {
                    onRetry()
                }
                .buttonStyle(.borderedProminent)

                Button("HOME") {
                    onHome()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
