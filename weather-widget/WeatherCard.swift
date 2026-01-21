//
//  WeatherCard.swift
//  weather-widget
//
//  Created by Ben Olivier on 21/01/2026.
//

import SwiftUI

struct WeatherCard: View {
    
    @State private var particlesSpeed: Double = 1.2
    
    @Binding var dampedPitch: Double
    @Binding var dampedRoll: Double
    @Binding var isExpanded: Bool
    
    let id: String
    let onTap: () -> Void
    
    // MARK: - Weather Data
    let backgroundColorTop: Color
    let backgroundColorBottom: Color
    let backgroundImage: String
    let location: String
    let currentTemperature: Int
    let weatherIcon: String
    let forecast: String
    let highTemperature: Int
    let lowTemperature: Int
    
    // MARK: - Constants
    private let backgroundImageParallax: Double = 20
    private let particlesParallax: Double = 60
    private let particleDensity: Double = 60
    private let normalSpeed: Double = 1.2
    private let slowSpeed: Double = 0.1
    
    private var particlesOffset: CGSize {
        CGSize(
            width: dampedRoll * particlesParallax,
            height: dampedPitch * particlesParallax
        )
    }
    
    var body: some View {
        ZStack {
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [backgroundColorTop, backgroundColorBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                Image(backgroundImage)
                    .resizable()
                    .scaledToFit()
                    .opacity(0.6)
                    .scaleEffect(1.2)
                    .offset(
                        x: dampedRoll * backgroundImageParallax,
                        y: dampedPitch * backgroundImageParallax
                    )
                
                ParticlesCanvasLayer(
                    parallaxOffset: particlesOffset,
                    dropsPer10kPixels: particleDensity,
                    globalFallSpeed: particlesSpeed,
                    baseDropLength: 10,
                    baseDropThickness: 0.75,
                    farOpacity: 0.2,
                    nearOpacity: 0.3,
                    blurRadius: 0
                )
                .scaleEffect(1.2)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .animation(.linear(duration: 0.1), value: dampedPitch)
            .animation(.linear(duration: 0.1), value: dampedRoll)
            
            weatherInfo
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 8)
//        .gesture(particleSpeedGesture)
        .onTapGesture {
            onTap()
        }
    }
    
    // MARK: - Subviews
    private var weatherInfo: some View {
        VStack {
            Spacer()
            HStack(alignment: .top) {
                VStack {
                    Text(location)
                        .font(.callout)
                        .fontWeight(.semibold)
                    Text("\(currentTemperature)°")
                        .font(.largeTitle)
                        .fontWeight(.light)
                }
                .opacity(0.8)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Image(systemName: weatherIcon)
                        .padding(.bottom, 1)
                    
                    VStack(alignment: .trailing) {
                        Text(forecast)
                        Text("H:\(highTemperature)° L:\(lowTemperature)°")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                }
                .opacity(isExpanded ? 0.6 : 0)
            }
            .foregroundStyle(.white)
            .padding()
        }
    }
    
    private var particleSpeedGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                particlesSpeed = slowSpeed
            }
            .onEnded { _ in
                particlesSpeed = normalSpeed
            }
    }
}
