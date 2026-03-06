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
            TimelineView(.animation(minimumInterval: 1.0 / 30)) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate * speed
                    let color = Color.primaryColor(for: primaryColorKey)

                    switch animationStyle {
                    case "bubbles":
                        drawBubbles(context: context, size: size, t: t, color: color)
                    case "waves":
                        drawWaves(context: context, size: size, t: t, color: color)
                    case "mesh":
                        drawMesh(context: context, size: size, t: t, color: color)
                    case "aurora":
                        drawAurora(context: context, size: size, t: t, color: color)
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
    // Floating orbs with layered sin/cos/tan orbits and pulsating radii

    private func drawBubbles(context: GraphicsContext, size: CGSize, t: Double, color: Color) {
        let n = 10
        for i in 0..<n {
            let s = Double(i) * 137.508 // golden angle seed
            let fi = Double(i)

            // Lissajous-style orbit using sin/cos/tan mix
            let freqX = 0.13 + fi * 0.017
            let freqY = 0.11 + fi * 0.013
            let baseX = size.width * fract(sin(s) * 0.5 + 0.5)
            let baseY = size.height * fract(cos(s * 1.3) * 0.5 + 0.5)

            let tanWarp = atan(sin(t * freqX * 0.3 + s)) // bounded tan via atan(sin())
            let x = baseX
                + sin(t * freqX + s) * 35
                + cos(t * freqX * 0.6 + s * 2) * 20
                + tanWarp * 15
            let y = baseY
                + cos(t * freqY + s) * 30
                + sin(t * freqY * 0.5 + s * 1.7) * 18

            // Pulsating radius with harmonic stacking
            let r = 35
                + 25 * sin(t * 0.4 + s)
                + 10 * cos(t * 0.7 + s * 2)
                + 5 * sin(t * 1.1 + fi)

            // Opacity breathes with a different rhythm
            let opacity = 0.04
                + 0.03 * sin(t * 0.35 + s * 2)
                + 0.01 * cos(t * 0.8 + fi)

            let circle = Path(ellipseIn: CGRect(
                x: x - r, y: y - r, width: r * 2, height: r * 2
            ))
            context.fill(circle, with: .color(color.opacity(opacity)))
        }
    }

    // MARK: - Waves
    // Multi-layer sinusoidal waves with harmonic distortion via tan

    private func drawWaves(context: GraphicsContext, size: CGSize, t: Double, color: Color) {
        let w = Double(size.width)
        let h = Double(size.height)

        for layer in 0..<4 {
            let fl = Double(layer)
            let yBase = h * (0.4 + fl * 0.12)
            let amplitude = 22.0 + fl * 10
            let opacity = 0.05 - fl * 0.008

            // Phase offsets per layer
            let phaseA = t * (0.5 + fl * 0.08)
            let phaseB = t * (0.35 + fl * 0.06)
            let phaseC = t * (0.2 + fl * 0.04)

            var path = Path()
            path.move(to: CGPoint(x: 0, y: h))
            path.addLine(to: CGPoint(x: 0, y: yBase))

            let step = 3.0
            var px = 0.0
            while px <= w {
                let norm = px / w // 0…1

                // Three harmonics + tan distortion
                let wave1 = sin(norm * .pi * 4 + phaseA) * amplitude
                let wave2 = cos(norm * .pi * 6 + phaseB) * amplitude * 0.4
                let wave3 = sin(norm * .pi * 2 + phaseC) * amplitude * 0.25
                let tanBend = atan(sin(norm * .pi * 3 + t * 0.3)) * amplitude * 0.2

                let y = yBase + wave1 + wave2 + wave3 + tanBend
                path.addLine(to: CGPoint(x: px, y: y))
                px += step
            }

            path.addLine(to: CGPoint(x: w, y: h))
            path.closeSubpath()
            context.fill(path, with: .color(color.opacity(opacity)))
        }
    }

    // MARK: - Mesh
    // Nodes connected by faint lines, positions driven by sin/cos/tan

    private func drawMesh(context: GraphicsContext, size: CGSize, t: Double, color: Color) {
        let w = Double(size.width)
        let h = Double(size.height)
        let cols = 5
        let rows = 8
        let cellW = w / Double(cols)
        let cellH = h / Double(rows)

        // Calculate all node positions
        var nodes: [CGPoint] = []
        for row in 0..<rows {
            for col in 0..<cols {
                let idx = Double(row * cols + col)
                let seed = idx * 42.17

                let freqX = 0.25 + idx * 0.007
                let freqY = 0.20 + idx * 0.009

                let tanDrift = atan(sin(t * 0.15 + seed)) * 12
                let cx = cellW * (Double(col) + 0.5)
                    + sin(t * freqX + seed) * 18
                    + cos(t * freqX * 0.5 + seed * 1.3) * 10
                    + tanDrift
                let cy = cellH * (Double(row) + 0.5)
                    + cos(t * freqY + seed) * 15
                    + sin(t * freqY * 0.7 + seed * 0.8) * 8

                nodes.append(CGPoint(x: cx, y: cy))
            }
        }

        // Draw connections between neighboring nodes
        for row in 0..<rows {
            for col in 0..<cols {
                let i = row * cols + col
                let neighbors = [
                    col + 1 < cols ? i + 1 : -1,
                    row + 1 < rows ? i + cols : -1,
                    col + 1 < cols && row + 1 < rows ? i + cols + 1 : -1,
                ]

                for j in neighbors where j >= 0 {
                    var line = Path()
                    line.move(to: nodes[i])
                    line.addLine(to: nodes[j])
                    context.stroke(line, with: .color(color.opacity(0.04)), lineWidth: 0.8)
                }
            }
        }

        // Draw node blobs
        for (i, node) in nodes.enumerated() {
            let seed = Double(i) * 42.17
            let r = 6 + 4 * sin(t * 0.5 + seed)
            let opacity = 0.04 + 0.025 * sin(t * 0.4 + seed * 2)

            let dot = Path(ellipseIn: CGRect(
                x: node.x - r, y: node.y - r, width: r * 2, height: r * 2
            ))
            context.fill(dot, with: .color(color.opacity(opacity)))
        }
    }

    // MARK: - Aurora
    // Smooth flowing aurora bands using layered sin/cos with tan warping

    private func drawAurora(context: GraphicsContext, size: CGSize, t: Double, color: Color) {
        let w = Double(size.width)
        let h = Double(size.height)

        for band in 0..<5 {
            let fb = Double(band)
            let bandPhase = t * (0.15 + fb * 0.04) + fb * 1.2

            let yCenter = h * (0.2 + fb * 0.14)
                + sin(bandPhase) * 30
                + cos(bandPhase * 0.6) * 15
            let thickness = 60.0 + 30 * sin(t * 0.3 + fb * 0.7)
            let opacity = 0.035 - fb * 0.004

            var topPath = Path()
            var botPath = Path()

            topPath.move(to: CGPoint(x: 0, y: yCenter))
            botPath.move(to: CGPoint(x: 0, y: yCenter))

            let step = 4.0
            var px = 0.0
            while px <= w {
                let norm = px / w

                // Aurora undulation: stacked harmonics with tan warp
                let wave = sin(norm * .pi * 3 + bandPhase) * 25
                    + cos(norm * .pi * 5 + bandPhase * 0.7) * 12
                    + atan(sin(norm * .pi * 2 + t * 0.2 + fb)) * 10

                // Thickness variation along x
                let thickVar = thickness * (0.7 + 0.3 * sin(norm * .pi * 2 + bandPhase * 0.5))

                let yMid = yCenter + wave
                topPath.addLine(to: CGPoint(x: px, y: yMid - thickVar * 0.5))
                botPath.addLine(to: CGPoint(x: px, y: yMid + thickVar * 0.5))

                px += step
            }

            // Close into a filled shape
            var shape = topPath
            // Walk botPath backwards
            let botPoints = stride(from: 0, through: w, by: step).reversed().map { px -> CGPoint in
                let norm = px / w
                let wave = sin(norm * .pi * 3 + bandPhase) * 25
                    + cos(norm * .pi * 5 + bandPhase * 0.7) * 12
                    + atan(sin(norm * .pi * 2 + t * 0.2 + fb)) * 10
                let thickVar = thickness * (0.7 + 0.3 * sin(norm * .pi * 2 + bandPhase * 0.5))
                return CGPoint(x: px, y: yCenter + wave + thickVar * 0.5)
            }
            for pt in botPoints {
                shape.addLine(to: pt)
            }
            shape.closeSubpath()

            context.fill(shape, with: .color(color.opacity(opacity)))
        }
    }

    private func fract(_ x: Double) -> Double {
        x - floor(x)
    }
}
