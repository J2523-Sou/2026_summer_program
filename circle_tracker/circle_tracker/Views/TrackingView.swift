//
//  TrackingView.swift
//  CircleTrackerApp
//
//  Created by 髙橋湊 on 9/13/26.
//

import SwiftUI

struct TrackingView: View {
    
    let onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Tracking")
                .font(.largeTitle)
            Button("FINISH") {
                onFinish()
            }
        }
    }
}

#Preview {
    TrackingView {
        print("FINISH")
    }
}
