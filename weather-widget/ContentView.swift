//
//  WeatherCardsView.swift
//  weather-widget
//
//  Created by Ben Olivier on 21/01/2026.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    
    @State private var dampedPitch: Double = 0.0
    @State private var dampedRoll: Double = 0.0
    @State private var expandedCardID: String? = nil
    
    private let motionManager = CMMotionManager()
    private let decayHz: Double = 1.5
    
    private let gridPadding: CGFloat = 12
    
    // Sample weather data - you can replace this with your actual data
    private let weatherCards: [(id: String, data: WeatherCardData)] = [
        (id: "london", data: WeatherCardData(
            backgroundColorTop: Color("rain-background-1"),
            backgroundColorBottom: Color("rain-background-2"),
            backgroundImage: "clouds",
            location: "London",
            currentTemperature: 14,
            weatherIcon: "cloud.rain.fill",
            forecast: "Rain for the next hour",
            highTemperature: 15,
            lowTemperature: 8
        )),
        
        (id: "new-york", data: WeatherCardData(
            backgroundColorTop: Color("snow-background-1"),
            backgroundColorBottom: Color("snow-background-2"),
            backgroundImage: "clouds",
            location: "New York",
            currentTemperature: 14,
            weatherIcon: "snowflake",
            forecast: "Rain for the next hour",
            highTemperature: 15,
            lowTemperature: 8
        ))
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("anti-flash-white").ignoresSafeArea()
                
                VStack(spacing: gridPadding) {
                    ForEach(Array(weatherCards.enumerated()), id: \.offset) { index, card in
                        let isExpanded = expandedCardID == card.id
                        let isOtherExpanded = expandedCardID != nil && expandedCardID != card.id
                        
                        WeatherCard(
                            dampedPitch: $dampedPitch,
                            dampedRoll: $dampedRoll,
                            isExpanded: .constant(isExpanded),
                            id: card.id,
                            onTap: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    if expandedCardID == card.id {
                                        expandedCardID = nil
                                    } else {
                                        expandedCardID = card.id
                                    }
                                }
                            },
                            backgroundColorTop: card.data.backgroundColorTop,
                            backgroundColorBottom: card.data.backgroundColorBottom,
                            backgroundImage: card.data.backgroundImage,
                            location: card.data.location,
                            currentTemperature: card.data.currentTemperature,
                            weatherIcon: card.data.weatherIcon,
                            forecast: card.data.forecast,
                            highTemperature: card.data.highTemperature,
                            lowTemperature: card.data.lowTemperature
                        )
                        .frame(
                            width: isExpanded ? geometry.size.width : .infinity,
                            height: isExpanded ? geometry.size.height : .infinity
                        )
                        .opacity(isOtherExpanded ? 0 : 1)
                        .zIndex(isExpanded ? 1 : 0)
                    }
                }
                .padding(gridPadding)
                .frame(maxHeight: 300)
            }
            .onAppear {
                startMotionUpdates()
            }
            .onDisappear {
                motionManager.stopDeviceMotionUpdates()
            }
        }
    }
    
    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.startDeviceMotionUpdates(to: .main) { motionData, error in
            guard let motionData = motionData else { return }
            
            let deltaTime = motionManager.deviceMotionUpdateInterval
            let pitchDelta = motionData.rotationRate.x * deltaTime
            let rollDelta = motionData.rotationRate.y * deltaTime
            let decay = exp(-decayHz * deltaTime)
            
            dampedPitch = dampedPitch * decay + pitchDelta
            dampedRoll = dampedRoll * decay + rollDelta
        }
    }
}

// MARK: - Supporting Types

struct WeatherCardData {
    let backgroundColorTop: Color
    let backgroundColorBottom: Color
    let backgroundImage: String
    let location: String
    let currentTemperature: Int
    let weatherIcon: String
    let forecast: String
    let highTemperature: Int
    let lowTemperature: Int
}

#Preview {
    ContentView()
}
