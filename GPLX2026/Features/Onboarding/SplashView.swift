import SwiftUI

struct SplashView: View {
    @Environment(ThemeStore.self) private var themeStore
    @Binding var isFinished: Bool

    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var blastScale: CGFloat = 1.0
    @State private var bgOpacity: Double = 1.0
    @State private var logoFade: Double = 1.0

    var body: some View {
        ZStack {
            // Background fades out to reveal content underneath
            ScaffoldBackground()
                .opacity(bgOpacity)
            AnimatedBackground()
                .opacity(bgOpacity)

            // App icon logo
            Group {
                if let uiImage = UIImage(named: "AppIcon") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 90, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                } else {
                    Image(systemName: "car.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(themeStore.primaryColor)
                        .frame(width: 90, height: 90)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
            .scaleEffect(logoScale * blastScale)
            .opacity(logoOpacity * logoFade)
        }
        .onAppear {
            // Phase 1: spring in
            withAnimation(.spring(duration: 0.5, bounce: 0.25)) {
                logoScale = 1.0
                logoOpacity = 1
            }

            // Phase 2: blast logo + fade background simultaneously
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                Haptics.impact(.medium)

                // Logo blasts out fast
                withAnimation(.easeIn(duration: 0.3)) {
                    blastScale = 30
                    logoFade = 0
                }

                // Background fades slightly slower for smooth reveal
                withAnimation(.easeOut(duration: 0.4)) {
                    bgOpacity = 0
                } completion: {
                    isFinished = true
                }
            }
        }
    }
}
