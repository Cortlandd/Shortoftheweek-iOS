//
//  SOTWCustomLoader.swift
//  Short of the Week
//
//  Created by Cortland Walker on 12/13/25.
//

import SwiftUI

struct SOTWCustomLoader: View {
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Tuning
    var spinDuration: TimeInterval = 2.4
    var clockwise: Bool = true

    var radius: CGFloat = 92
    var blockSize: CGFloat = 44
    var blockCornerRadius: CGFloat = 10
    var ringLineWidth: CGFloat = 28
    
    /// Makes blocks sit ON TOP of the ring stroke (like the screenshot)
    var blockLift: CGFloat = 8              // extra lift beyond the ring (tweak 4–12)
    private var blockOffsetRadius: CGFloat {
        radius + (ringLineWidth / 2) + (blockSize / 2) + blockLift
    }
    
    private var ringStroke: Color { Color(.sRGB, white: 0.94, opacity: 1.0) }

    // Trail tuning (this is the “small trail” you want)
    var trailCount: Int = 4               // number of ghost blocks
    var trailAngleStep: Double = 6.0      // degrees between ghosts
    var trailOpacity: Double = 0.18       // starting opacity for first ghost
    var trailScaleStep: CGFloat = 0.03    // each ghost slightly smaller
    var trailBlur: CGFloat = 0.2          // subtle softness (keep low)

    // MARK: - Colors (approx SOTW palette)
    private let sotwColors: [Color] = [
        Color(red: 0.16, green: 0.78, blue: 0.78), // Teal
        Color(red: 0.96, green: 0.78, blue: 0.17), // Yellow
        Color(red: 0.49, green: 0.79, blue: 0.19), // Green
        Color(red: 0.97, green: 0.17, blue: 0.38), // Magenta
        Color(red: 0.99, green: 0.64, blue: 0.66)  // Light Pink
    ]

    // Order these to match the reference wheel
    private var spinningBlocks: [Color] {
        [
            sotwColors[3], // magenta (top)
            sotwColors[4], // pink
            sotwColors[0], // teal
            sotwColors[2], // green
            sotwColors[3], // magenta (bottom)
            sotwColors[2], // green
            sotwColors[1], // yellow
            sotwColors[0]  // teal
        ]
    }

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            let progress = (t.truncatingRemainder(dividingBy: spinDuration)) / spinDuration
            let degrees = (clockwise ? 1.0 : -1.0) * (progress * 360.0)

            ZStack {
                // 1) Static ring (does NOT spin)
                Circle()
                    .stroke(
                        ringStroke,
                        style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                    )
                    .frame(
                        width: (radius * 2) + blockSize + ringLineWidth,
                        height: (radius * 2) + blockSize + ringLineWidth
                    )

                // 2) Center image (static)
                Image(colorScheme == .dark ? "sotwFullLogoWhite" : "sotwFullLogo")
                    .resizable()
                    .scaledToFit()
                    .padding(32)

                // 3) Blocks (spin) + trails (spin)
                ZStack {
                    ForEach(spinningBlocks.indices, id: \.self) { index in
                        let base = Double(index) * (360.0 / Double(spinningBlocks.count))
                        let current = base + degrees

                        // draw trail first (behind)
                        trail(for: spinningBlocks[index], at: current)

                        // main block
                        block(color: spinningBlocks[index])
                            .offset(y: -blockOffsetRadius)
                            .rotationEffect(.degrees(current))
                    }
                }
            }
        }
        .background(Color.clear)
    }

    // MARK: - Block

    private func block(color: Color) -> some View {
        RoundedRectangle(cornerRadius: blockCornerRadius, style: .continuous)
            .fill(color)
            .frame(width: blockSize, height: blockSize)
            // subtle “stacked” look like your screenshot
            .shadow(color: color.opacity(0.18), radius: 0, x: blockSize * 0.12, y: blockSize * 0.12)
    }

    // MARK: - Trail

    private func trail(for color: Color, at currentAngle: Double) -> some View {
        ZStack {
            ForEach(1...trailCount, id: \.self) { i in
                let fade = trailOpacity * pow(0.65, Double(i - 1))
                let scale = 1.0 - (CGFloat(i) * trailScaleStep)
                let angle = currentAngle - (Double(i) * trailAngleStep)

                RoundedRectangle(cornerRadius: blockCornerRadius, style: .continuous)
                    .fill(color)
                    .frame(width: blockSize, height: blockSize)
                    .scaleEffect(scale)
                    .opacity(fade)
                    .blur(radius: trailBlur)
                    .offset(y: -blockOffsetRadius)
                    .rotationEffect(.degrees(angle))
            }
        }
    }
}

#Preview {
    ZStack {
        SOTWCustomLoader()
    }
}
