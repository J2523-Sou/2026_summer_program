//
//  ContentView.swift
//  circle_tracker
//
//  Created by 髙橋湊 on 9/13/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Perfect Circle")
                .font(.largeTitle)
                .bold()
            
            Text("できるだけ綺麗な円を描こう")
                .font(.headline)
            
            Button("START") {
                print("START button pressed")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
