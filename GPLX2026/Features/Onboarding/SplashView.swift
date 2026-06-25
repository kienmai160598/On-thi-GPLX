import SwiftUI

struct SplashView: View {
    @Environment(ThemeStore.self) private var themeStore
    @Binding var isFinished: Bool

    @State private var splashTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            ScaffoldBackground()
            AnimatedBackground()

            // App icon logo — shown statically, no entrance/exit animation.
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
        }
        .onAppear {
            // Hold the loading screen briefly, then hand off to the app. No blast/
            // zoom animation on open — the container simply swaps to the content.
            splashTask = Task { @MainActor in
                try? await Task.sleep(for: .seconds(0.9))
                guard !Task.isCancelled else { return }
                isFinished = true
            }
        }
        .onDisappear { splashTask?.cancel() }
    }
}
