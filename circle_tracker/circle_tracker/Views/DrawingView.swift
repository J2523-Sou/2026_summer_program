//
//  DrawingView.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/17/26.
//

import SwiftUI
import simd

struct DrawingView: View {
    
    let onFinish: ([SIMD3<Float>]) -> Void
    
    @State private var points: [SIMD3<Float>] = []
    
    var body: some View {
        
        VStack {
            
            Text("Draw a Circle")
                .font(.title)
                .bold()
            
            Text("画面に円を描いてください")
            
            
            // 描画エリア
            Canvas { context, size in
                
                guard points.count >= 2 else {
                    return
                }
                
                var path = Path()
                
                path.move(
                    to: CGPoint(
                        x: CGFloat(points[0].x),
                        y: CGFloat(points[0].y)
                    )
                )
                
                for point in points.dropFirst() {
                    
                    path.addLine(
                        to: CGPoint(
                            x: CGFloat(point.x),
                            y: CGFloat(point.y)
                        )
                    )
                }
                
                context.stroke(
                    path,
                    with: .color(.primary),
                    lineWidth: 4
                )
            }
            .background(.gray.opacity(0.1))
            .gesture(
                DragGesture(minimumDistance: 0)
                
                    .onChanged { value in
                        
                        // 手書きなのでZ座標は常に0
                        let point = SIMD3<Float>(
                            Float(value.location.x),
                            Float(value.location.y),
                            0
                        )
                        
                        points.append(point)
                    }
            )
            
            
            HStack {
                
                Button("RESET") {
                    points.removeAll()
                }
                
                Button("FINISH") {
                    onFinish(points)
                }
                .disabled(points.count < 10)
            }
        }
        .padding()
    }
}


#Preview {
    DrawingView { points in
        print(points.count)
    }
}
