//
//  ContentView.swift
//  ToastsSwiftUI
//
//  Created by Rashid Latif on 27/08/2024.
//
import SwiftUI

struct ContentView: View {
    @State private var direction:ToastDirection = .top
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Button("Press Button") {
                    Toast.shared.showToast(
                        title: "Deleted",
                        icon: "bin.xmark",
                        isUserInteractionEnabled: true,
                        time: .long,
                        direction: direction
                    )
                }
                
                Button("Toast direction \(direction.rawValue)") {
                    direction = (direction == .top ? .bottom : .top)
                }
            }
            
        }
    }
    
}


#Preview {
    RootView {
        ContentView()
    }
}
