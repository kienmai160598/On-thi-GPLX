import SwiftUI

// MARK: - Celebration Overlay (confetti effect)

struct CelebrationOverlay: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false

    private let confettiColors: [Color] = [.appPrimary, .appSuccess, .appWarning, .appError, .blue, .purple]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size * 0.6)
                        .position(
                            x: particle.x,
                            y: isAnimating ? geo.size.height + 20 : particle.startY
                        )
                        .opacity(isAnimating ? 0 : 1)
                        .rotationEffect(.degrees(isAnimating ? particle.rotation : 0))
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            let screenWidth = UIScreen.main.bounds.width
            particles = (0..<40).map { _ in
                ConfettiParticle(
                    x: CGFloat.random(in: 0...screenWidth),
                    startY: CGFloat.random(in: -100...(-10)),
                    size: CGFloat.random(in: 5...12),
                    color: confettiColors.randomElement()!,
                    rotation: Double.random(in: 180...720)
                )
            }
            withAnimation(.easeIn(duration: 2.5)) {
                isAnimating = true
            }
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let startY: CGFloat
    let size: CGFloat
    let color: Color
    let rotation: Double
}

// MARK: - Daily Goal Celebration Modifier

struct DailyGoalCelebrationModifier: ViewModifier {
    let isDone: Bool
    @State private var hasShownCelebration = false
    @State private var showCelebration = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                if showCelebration && !reduceMotion {
                    CelebrationOverlay()
                        .transition(.opacity)
                }
            }
            .onChange(of: isDone) { _, done in
                if done && !hasShownCelebration {
                    hasShownCelebration = true
                    if !reduceMotion {
                        withAnimation { showCelebration = true }
                        Task { @MainActor in
                            try? await Task.sleep(for: .seconds(2.5))
                            withAnimation { showCelebration = false }
                        }
                    }
                }
            }
    }
}

extension View {
    func dailyGoalCelebration(isDone: Bool) -> some View {
        modifier(DailyGoalCelebrationModifier(isDone: isDone))
    }
}
