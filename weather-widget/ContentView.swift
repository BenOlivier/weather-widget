//
//  ContentView.swift
//  weather-widget
//
//  Created by Ben Olivier on 21/01/2026.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    
    @State var dampedPitch: Double = 0.0
    @State var dampedRoll: Double = 0.0
    @State private var parallaxOffset: CGSize = .zero
    
    let motionManager = CMMotionManager()
    let decayHz: Double = 1.5
    
    var body: some View {
        ZStack {
            
            // Background
            Color("anti-flash-white").ignoresSafeArea()
            
            ZStack{
                ZStack(alignment: .top) {
                    Color("background")
                    
                    Image("clouds")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.5)
                        .padding(.top, 50)
                    
                    RainCanvasLayer(
                        dropsPer10kPixels: 80,
                        globalFallSpeed: 1.2,
                        baseDropLength: 8,
                        baseDropThickness: 0.75,
                        farOpacity: 0.2,
                        nearOpacity: 0.3,
                        blurRadius: 0
                    )
                }
                .frame(width: 300, height: 400)
                .scaleEffect(1.6)
                .offset(x: CGFloat(dampedRoll * 90), y: CGFloat(dampedPitch * 90))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .animation(.linear(duration: 0.1), value: dampedPitch)
                .animation(.linear(duration: 0.1), value: dampedRoll)
                
                VStack{
                    Spacer()
                    HStack(alignment: .top) {
                        VStack{
                            Text("London")
                                .font(.callout)
                                .fontWeight(.semibold)
                            Text("14°")
                                .font(.largeTitle)
                                .fontWeight(.light)
                        }
                        .opacity(0.8)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Image(systemName: "cloud.rain.fill")
                                .padding(.bottom, 1)
                            VStack(alignment: .trailing) {
                                Text("Rain for the next hour")
                                Text("H:15° L:8°")
                            }
                            .font(.caption)
                            .fontWeight(.semibold)
                        }
                        .opacity(0.6)
                    }
                    .foregroundStyle(.white)
                    .padding()
                }
                
            }
            .frame(width: 300, height: 400)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .statusBarHidden()
            .onAppear() {
                // Start device motion updates
                motionManager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
                    guard let motionData = motionData else { return }
                    
                    let deltaTime = motionManager.deviceMotionUpdateInterval
                    
                    let pitchDelta = motionData.rotationRate.x * deltaTime
                    let rollDelta  = motionData.rotationRate.y * deltaTime
                    
                    let decay = exp(-decayHz * deltaTime)
                    
                    dampedPitch = dampedPitch * decay + pitchDelta
                    dampedRoll = dampedRoll * decay + rollDelta
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
