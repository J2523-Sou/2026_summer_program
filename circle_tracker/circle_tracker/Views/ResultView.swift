import SwiftUI

struct ResultView: View {
    
    let result: CircleAnalysisResult
    let trajectory: [SIMD3<Float>]
    
    let on2DRetry: () -> Void
    let on3DRetry: () -> Void
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
                Button("RETRY to 2D") {
                    on2DRetry()
                }
                .buttonStyle(.glassProminent)
                
                Button("RETRY to 3D") {
                    on3DRetry()
                }
                .buttonStyle(.glassProminent)

                Button("HOME") {
                    onHome()
                }
                .buttonStyle(.glass)
            } else {
                Button("RETRY to 2D") {
                    on2DRetry()
                }
                .buttonStyle(.glassProminent)
                
                Button("RETRY to 3D") {
                    on3DRetry()
                }
                .buttonStyle(.glassProminent)
                Button("HOME") {
                    onHome()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
