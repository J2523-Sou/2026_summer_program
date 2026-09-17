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
            Text("Perfect Circle")
                .font(.largeTitle)
                .bold()
                
            Text("できるだけ綺麗な円を描こう")
                .font(.headline)
                
            Button("3D START") {
                onStart()
            }
            
            Button("2D START") {
                onDrawingStart()
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
