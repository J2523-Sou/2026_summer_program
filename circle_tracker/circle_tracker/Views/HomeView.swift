//
//  HomeView.swift
//  circle_tracker
//
//  Created by 髙橋湊 on 9/13/26.
//

import SwiftUI

struct HomeView: View {
    
    //引数なし，戻り値なしの処理を外部から受け取る
    let onStart: () -> Void
    let onDrawingStart: () -> Void
    
    var body: some View {
        VStack {
            
            Image(systemName: "pencil.and.outline")
                .font(.system(size: 100))
            
//            Text("Perfect Circle")
//                .font(.largeTitle)
//                .bold()
                
            Text("できるだけ綺麗な円を描こう")
                .font(.headline)
                .padding()
            
            // LiquidGlass対応機種なら
            if #available(iOS 26.0, *) {
                Button("3D START") {
                    onStart()
                }
                .padding()
                .buttonStyle(.glassProminent)   // 強調
                
                Button("2D START") {
                    onDrawingStart()
                }
                .buttonStyle(.glass)
            } else {
                Button("3D START") {
                    onStart()
                }
                .padding()
                .buttonStyle(.borderedProminent)    // 強調
                
                Button("2D START") {
                    onDrawingStart()
                }
                .buttonStyle(.bordered)
            }
            
            
        }
        .padding()
    }
}

#Preview {
    HomeView(
        onStart: {},
        onDrawingStart: {}
    )
}
