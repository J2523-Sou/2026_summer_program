//
//  ResultView.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/13/26.
//

import SwiftUI

struct ResultView: View {
    
    //呼び出し時，外部から得点データを受け取る．
    let score: Int
    let trajectory: [SIMD3<Float>]
    
    let onRetry: () -> Void
    let onHome: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("RESULT")
                .font(.largeTitle)
                .bold()
            
            Text("\(score)")
                .font(.system(size: 80))
                .bold()
            
            Text("points: \(trajectory.count)")
                .font(.headline)
            
            Trajectory3DView(points: trajectory)
                .frame(height: 350)
            
            Button("RETRY") {
                onRetry()
            }
            
            Button("HOME") {
                onHome()
            }
        }
        .padding()
    }
}

#Preview {
    ResultView(
        score: 85,
        trajectory: [
            SIMD3<Float>(0, 0, 0),
            SIMD3<Float>(0.1, 0.1, 0)
        ],
        onRetry: {
            print("RETRY")
        },
        onHome: {
            print("HOME")
        }
    )
}
