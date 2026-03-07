import SwiftUI

struct AnimatedBackground: View {
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @AppStorage("backgroundAnimation") private var animationStyle = "none"
    @AppStorage("backgroundSpeed") private var speedKey = "normal"
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var speed: Double {
        switch speedKey {
        case "slow": return 0.4
        case "fast": return 2.0
        default: return 1.0
        }
    }

    var body: some View {
        if animationStyle != "none" && !reduceMotion {
            TimelineView(.animation(minimumInterval: 1.0 / 20)) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate * speed
                    let color = Color.primaryColor(for: primaryColorKey)

                    switch animationStyle {
                    case "bubbles":
                        drawBubbles(context: context, size: size, t: t, color: color)
                    case "waves":
                        drawWaves(context: context, size: size, t: t, color: color)
                    default:
                        break
                    }
                }
            }
            .drawingGroup()
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }

    // MARK: - Bubbles
    // Soft blurred orbs covering the full screen

    private func drawBubbles(context: GraphicsContext, size: CGSize, t: Double, color: Color) {
        let w = Double(size.width)
        let h = Double(size.height)
        let n = 8

        // Draw all bubbles inside a blurred sublayer
        context.drawLayer { blurCtx in
            blurCtx.addFilter(.blur(radius: 40))

            for i in 0..<n {
                let s = Double(i) * 137.508
                let fi = Double(i)

                let freqX = 0.06 + fi * 0.01
                let freqY = 0.05 + fi * 0.008

                let baseX = w * fract(sin(s) * 0.5 + 0.5)
                let baseY = h * fract(cos(s * 1.3) * 0.5 + 0.5)

                let tanWarp = atan(sin(t * freqX * 0.3 + s))
                let x = baseX
                    + sin(t * freqX + s) * w * 0.08
                    + cos(t * freqX * 0.6 + s * 2) * w * 0.05
                    + tanWarp * 20
                let y = baseY
                    + cos(t * freqY + s) * h * 0.06
                    + sin(t * freqY * 0.5 + s * 1.7) * h * 0.04

                // Large radii for soft glowing blobs
                let baseR = min(w, h) * 0.18
                let r = baseR
                    + baseR * 0.5 * sin(t * 0.25 + s)
                    + baseR * 0.15 * cos(t * 0.5 + s * 2)

                let opacity = 0.15
                    + 0.08 * sin(t * 0.2 + s * 2)
                    + 0.03 * cos(t * 0.4 + fi)

                let circle = Path(ellipseIn: CGRect(
                    x: x - r, y: y - r, width: r * 2, height: r * 2
                ))
                blurCtx.fill(circle, with: .color(color.opacity(opacity)))
            }
        }
    }

    // MARK: - Waves
    // Bold layered waves spanning the full width, covering top and bottom

    private func drawWaves(context: GraphicsContext, size: CGSize, t: Double, color: Color) {
        let w = Double(size.width)
        let h = Double(size.height)
        let step = 5.0

        // Bottom waves (rise from bottom)
        for layer in 0..<3 {
            let fl = Double(layer)
            let yBase = h * (0.55 + fl * 0.12)
            let amplitude = h * 0.06 + fl * h * 0.02

            let phaseA = t * (0.4 + fl * 0.07)
            let phaseB = t * (0.28 + fl * 0.05)
            let phaseC = t * (0.18 + fl * 0.03)

            let opacity = 0.12 - fl * 0.025

            var path = Path()
            path.move(to: CGPoint(x: 0, y: h))
            path.addLine(to: CGPoint(x: 0, y: yBase))

            var px = 0.0
            while px <= w {
                let norm = px / w
                let wave1 = sin(norm * .pi * 3 + phaseA) * amplitude
                let wave2 = cos(norm * .pi * 5 + phaseB) * amplitude * 0.45
                let wave3 = sin(norm * .pi * 2 + phaseC) * amplitude * 0.3
                let tanBend = atan(sin(norm * .pi * 2.5 + t * 0.25)) * amplitude * 0.2

                let y = yBase + wave1 + wave2 + wave3 + tanBend
                path.addLine(to: CGPoint(x: px, y: y))
                px += step
            }

            path.addLine(to: CGPoint(x: w, y: h))
            path.closeSubpath()
            context.fill(path, with: .color(color.opacity(opacity)))
        }

        // Top waves (hang from top)
        for layer in 0..<2 {
            let fl = Double(layer)
            let yBase = h * (0.25 + fl * 0.1)
            let amplitude = h * 0.05 + fl * h * 0.015

            let phaseA = t * (0.35 + fl * 0.06) + .pi
            let phaseB = t * (0.22 + fl * 0.04) + .pi * 0.5

            let opacity = 0.08 - fl * 0.02

            var path = Path()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: yBase))

            var px = 0.0
            while px <= w {
                let norm = px / w
                let wave1 = sin(norm * .pi * 4 + phaseA) * amplitude
                let wave2 = cos(norm * .pi * 3 + phaseB) * amplitude * 0.4
                let tanBend = atan(sin(norm * .pi * 2 + t * 0.3 + fl)) * amplitude * 0.25

                let y = yBase + wave1 + wave2 + tanBend
                path.addLine(to: CGPoint(x: px, y: y))
                px += step
            }

            path.addLine(to: CGPoint(x: w, y: 0))
            path.closeSubpath()
            context.fill(path, with: .color(color.opacity(opacity)))
        }
    }

    private func fract(_ x: Double) -> Double {
        x - floor(x)
    }
}
