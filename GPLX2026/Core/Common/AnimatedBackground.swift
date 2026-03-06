import SwiftUI

struct AnimatedBackground: View {
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @AppStorage("backgroundAnimation") private var animationStyle = "none"

    var body: some View {
        if animationStyle != "none" {
            TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    let color = Color.primaryColor(for: primaryColorKey)

                    switch animationStyle {
                    case "bubbles":
                        drawBubbles(context: context, size: size, time: time, color: color)
                    case "waves":
                        drawWaves(context: context, size: size, time: time, color: color)
                    case "mesh":
                        drawMesh(context: context, size: size, time: time, color: color)
                    default:
                        break
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }

    // MARK: - Bubbles

    private func drawBubbles(context: GraphicsContext, size: CGSize, time: Double, color: Color) {
        let bubbleCount = 8
        for i in 0..<bubbleCount {
            let seed = Double(i) * 137.508
            let phase = time * (0.15 + Double(i) * 0.02)
            let x = size.width * (0.1 + 0.8 * fract(sin(seed) * 0.5 + 0.5))
                + sin(phase + seed) * 30
            let y = size.height * (0.1 + 0.8 * fract(cos(seed * 1.3) * 0.5 + 0.5))
                + cos(phase * 0.7 + seed) * 25
            let radius = 40 + 30 * sin(phase * 0.5 + seed)
            let opacity = 0.04 + 0.03 * sin(phase + seed * 2)

            let circle = Path(ellipseIn: CGRect(
                x: x - radius, y: y - radius,
                width: radius * 2, height: radius * 2
            ))
            context.fill(circle, with: .color(color.opacity(opacity)))
        }
    }

    // MARK: - Waves

    private func drawWaves(context: GraphicsContext, size: CGSize, time: Double, color: Color) {
        for wave in 0..<3 {
            let waveOffset = Double(wave) * 0.8
            let amplitude = 20.0 + Double(wave) * 8
            let yBase = size.height * (0.5 + Double(wave) * 0.15)
            let opacity = 0.04 - Double(wave) * 0.008

            var path = Path()
            path.move(to: CGPoint(x: 0, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: yBase))

            let step = 4.0
            var x = 0.0
            while x <= Double(size.width) {
                let phase = time * 0.4 + waveOffset
                let y = yBase + sin(x / 80 + phase) * amplitude
                    + cos(x / 120 + phase * 0.7) * amplitude * 0.5
                path.addLine(to: CGPoint(x: x, y: y))
                x += step
            }

            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.closeSubpath()
            context.fill(path, with: .color(color.opacity(opacity)))
        }
    }

    // MARK: - Mesh

    private func drawMesh(context: GraphicsContext, size: CGSize, time: Double, color: Color) {
        let cols = 4
        let rows = 6
        let cellW = size.width / Double(cols)
        let cellH = size.height / Double(rows)

        for row in 0..<rows {
            for col in 0..<cols {
                let seed = Double(row * cols + col) * 42.17
                let phase = time * 0.3 + seed
                let cx = cellW * (Double(col) + 0.5) + sin(phase) * 15
                let cy = cellH * (Double(row) + 0.5) + cos(phase * 0.8) * 12
                let radius = 30 + 15 * sin(phase * 0.5)
                let opacity = 0.03 + 0.02 * sin(phase + seed)

                let rect = CGRect(
                    x: cx - radius, y: cy - radius,
                    width: radius * 2, height: radius * 2
                )
                let ellipse = Path(ellipseIn: rect)
                context.fill(ellipse, with: .color(color.opacity(opacity)))
            }
        }
    }

    private func fract(_ x: Double) -> Double {
        x - floor(x)
    }
}
