//
//  RainCanvasLayer.swift
//  weather-widget
//
//  Created by Ben Olivier on 21/01/2026.
//

import SwiftUI

struct RainCanvasLayer: View {
    /// Density controls how many drops are created relative to the view area.
    var dropsPer10kPixels: Double = 22

        /// Overall fall speed multiplier.
        var globalFallSpeed: Double = 1.0

        /// Visual tuning
        var baseDropLength: Double = 14
        var baseDropThickness: Double = 1.2
        var farOpacity: Double = 0.18
        var nearOpacity: Double = 0.55
        var blurRadius: Double = 0.0

        @State private var drops: [Drop] = []
        @State private var lastTimestamp: TimeInterval?
        @State private var lastSize: CGSize = .zero

        var body: some View {
            GeometryReader { geometry in
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        // Draw using current state
                        for drop in drops {
                            let depth = drop.depth01

                            let x = drop.x01 * size.width
                            let y = drop.y01 * size.height

                            // If drops are outside bounds, skip drawing
                            if x < -40 || x > size.width + 40 || y < -60 || y > size.height + 60 {
                                continue
                            }

                            // Depth-weighted look
                            let length = baseDropLength * lerp(0.55, 1.35, depth)
                            let thickness = baseDropThickness * lerp(0.75, 1.35, depth)
                            let opacity = lerp(farOpacity, nearOpacity, depth)

                            var path = Path()
                            path.move(to: CGPoint(x: x, y: y))
                            path.addLine(to: CGPoint(x: x, y: y + length))

                            // Create gradient from top (transparent) to bottom (full opacity)
                            let gradient = Gradient(colors: [
                                .white.opacity(0),
                                .white.opacity(opacity)
                            ])

                            context.stroke(path,
                               with: .linearGradient(gradient,
                                                    startPoint: CGPoint(x: x, y: y),
                                                    endPoint: CGPoint(x: x, y: y + length)),
                               style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                        }
                    }
                    .blur(radius: blurRadius)
                    .onChange(of: timeline.date) { _, newDate in
                        let now = newDate.timeIntervalSinceReferenceDate
                        let size = geometry.size
                        
                        // Calculate delta time
                        let dt: TimeInterval
                        if let last = lastTimestamp {
                            dt = min(max(now - last, 0), 1.0 / 20.0)
                        } else {
                            dt = 0
                        }
                        
                        lastTimestamp = now
                        
                        // Update drops state
                        if dt > 0 {
                            drops = updateDrops(drops: drops, dt: dt, in: size)
                        }
                    }
                }
                .onChange(of: geometry.size) { _, newSize in
                    let area = newSize.width * newSize.height
                    
                    if drops.isEmpty || shouldRebuildDrops(for: newSize, lastSize: lastSize) {
                        drops = makeDrops(for: newSize, targetCount: targetDropCount(area: area))
                    }
                    
                    lastSize = newSize
                }
                .onAppear {
                    let size = geometry.size
                    let area = size.width * size.height
                    
                    if drops.isEmpty {
                        drops = makeDrops(for: size, targetCount: targetDropCount(area: area))
                        lastSize = size
                    }
                }
            }
        }

        // MARK: - Simulation

        private func updateDrops(drops: [Drop], dt: Double, in size: CGSize) -> [Drop] {
            return drops.map { drop in
                var updatedDrop = drop
                let depth = drop.depth01

                // Near drops fall faster
                let fallSpeedNormPerSec = drop.fallSpeedNormPerSec * lerp(0.6, 1.6, depth) * globalFallSpeed

                updatedDrop.y01 += fallSpeedNormPerSec * dt

                // Wrap
                if updatedDrop.y01 > 1.12 {
                    updatedDrop.y01 = -0.12
                    updatedDrop.x01 = Double.random(in: 0...1)
                    // Re-roll a little variation so the pattern does not feel tiled
                    updatedDrop.fallSpeedNormPerSec = Double.random(in: 0.35...1.15) * 0.55
                }

                if updatedDrop.x01 < -0.15 { updatedDrop.x01 = 1.15 }
                if updatedDrop.x01 > 1.15  { updatedDrop.x01 = -0.15 }
                
                return updatedDrop
            }
        }

        private func targetDropCount(area: CGFloat) -> Int {
            // dropsPer10kPixels means: for each 10,000 px^2, how many drops
            let count = (Double(area) / 10_000.0) * dropsPer10kPixels
            return max(40, Int(count.rounded()))
        }

        private func shouldRebuildDrops(for size: CGSize, lastSize: CGSize) -> Bool {
            // If the view is extremely small, or if size changed significantly
            if size.width < 2 || size.height < 2 {
                return true
            }
            
            // Rebuild if size changed by more than 20% (e.g., rotation, split screen)
            let widthChange = abs(size.width - lastSize.width) / max(lastSize.width, 1)
            let heightChange = abs(size.height - lastSize.height) / max(lastSize.height, 1)
            
            return widthChange > 0.2 || heightChange > 0.2
        }

        private func makeDrops(for size: CGSize, targetCount: Int) -> [Drop] {
            (0..<targetCount).map { _ in
                let depth = Double.random(in: 0...1) // 0 far, 1 near
                return Drop(
                    x01: Double.random(in: 0...1),
                    y01: Double.random(in: 0...1),
                    depth01: depth,
                    fallSpeedNormPerSec: Double.random(in: 0.35...1.15) * 0.55
                )
            }
        }

        private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
            a + (b - a) * t
        }

        // MARK: - Model

        private struct Drop: Equatable {
            var x01: Double
            var y01: Double
            var depth01: Double
            var fallSpeedNormPerSec: Double
        }
}

#Preview {
    RainCanvasLayer()
}
