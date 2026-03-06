import SwiftUI
import AVKit

struct HazardTestView: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(HazardVideoCache.self) private var videoCache
    @Environment(\.dismiss) private var dismiss

    let mode: Mode

    enum Mode {
        case exam
        case practice
        case chapter(Int)
    }

    // MARK: - State

    @State private var situations: [HazardSituation] = []
    @State private var currentIndex = 0
    @State private var tapTimes: [Int: Double?] = [:]
    @State private var showExitDialog = false
    @State private var navigateToResult = false
    @State private var hazardResult: HazardResult?
    @State private var playerState = PlayerState()
    @State private var scoreRevealed = false

    private var isLast: Bool { currentIndex + 1 >= situations.count }
    private var isPractice: Bool {
        if case .exam = mode { return false }
        return true
    }

    var body: some View {
        Group {
            if situations.isEmpty {
                ExamLoadingView()
            } else {
                testContent
            }
        }
        .background(Color.scaffoldBg.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { showExitDialog = true } label: {
                    Image(systemName: "xmark")
                }
            }

            ToolbarItem(placement: .principal) {
                HazardProgressCapsule(
                    current: currentIndex + 1,
                    total: situations.count
                )
            }
        }
        .alert("Thoát bài thi?", isPresented: $showExitDialog) {
            Button("Tiếp tục", role: .cancel) {}
            Button("Thoát", role: .destructive) { dismiss() }
        } message: {
            Text("Kết quả sẽ không được lưu.")
        }
        .task { startTest() }
        .onChange(of: playerState.isFinished) { _, finished in
            if finished { revealScore() }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let result = hazardResult {
                HazardResultView(
                    situations: situations,
                    tapTimes: tapTimes,
                    result: result
                )
            }
        }
    }

    // MARK: - Test Content

    @ViewBuilder
    private var testContent: some View {
        let situation = situations[currentIndex]
        let hasTapped = tapTimes[currentIndex] != nil

        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: Situation Info
                    HStack(spacing: 10) {
                        Image(systemName: "film")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.appPrimary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tình huống \(situation.id)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.appTextDark)
                            Text("Chương \(situation.chapter): \(situation.chapterName)")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.appTextMedium)
                        }

                        Spacer(minLength: 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .glassCard()

                    // MARK: Video Player
                    HazardVideoPlayer(
                        url: videoCache.playableURL(for: situation),
                        state: $playerState
                    )
                    .aspectRatio(16/9, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.25),
                                        Color.appPrimary.opacity(0.08),
                                        Color.white.opacity(0.06),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.appPrimary.opacity(0.06), radius: 10, y: 3)

                    // MARK: Divider
                    Divider()
                        .padding(.horizontal, 4)

                    // MARK: Hazard Button / Score
                    if playerState.isFinished && scoreRevealed {
                        // Score + Tip
                        let score = situation.score(tapTime: tapTimes[currentIndex] ?? nil)

                        VStack(spacing: 14) {
                            HazardScoreReveal(score: score)

                            Divider().padding(.horizontal, 20)

                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.appWarning)
                                    .padding(.top, 1)
                                Text(situation.tip)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.appTextMedium)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.vertical, 16)
                        .glassCard()
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .opacity
                        ))
                    } else if !playerState.isFinished {
                        // Detect button
                        Button {
                            handleTap(at: playerState.currentTime)
                        } label: {
                            let content = HStack(spacing: 10) {
                                Image(systemName: hasTapped ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .contentTransition(.symbolEffect(.replace))

                                Text(hasTapped ? "Đã phát hiện nguy hiểm!" : "Nhấn khi phát hiện nguy hiểm")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundStyle(hasTapped ? Color.appSuccess : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)

                            if #available(iOS 26.0, *) {
                                content
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(hasTapped ? Color.appSuccess.opacity(0.15) : Color.appError.opacity(0.85))
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 14))
                            } else {
                                content
                                    .background(hasTapped ? Color.appSuccess.opacity(0.15) : Color.appError)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                        .disabled(hasTapped)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
            .id(currentIndex)

            // MARK: Bottom Bar
            HStack(spacing: 10) {
                if isPractice {
                    Button {
                        Haptics.selection()
                        goToPrevious()
                    } label: {
                        AppButton(label: "Trước", style: .secondary, height: 48, cornerRadius: 24)
                    }
                    .disabled(currentIndex == 0)
                }

                if playerState.isFinished {
                    Button {
                        Haptics.selection()
                        advanceOrFinish()
                    } label: {
                        AppButton(
                            icon: isLast ? "checkmark" : "forward.fill",
                            label: isLast ? "Xem kết quả" : "Tiếp theo",
                            height: 48,
                            cornerRadius: 24
                        )
                    }
                } else {
                    HazardTimerButton(
                        currentTime: playerState.currentTime,
                        duration: playerState.duration
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 4)
        }
    }

    // MARK: - Logic

    private func startTest() {
        switch mode {
        case .exam:
            situations = HazardSituation.random(count: AppConstants.Hazard.situationsPerExam)
        case .practice:
            situations = HazardSituation.all
        case .chapter(let chapterId):
            situations = HazardSituation.all.filter { $0.chapter == chapterId }
        }
        playerState = PlayerState()
    }

    private func handleTap(at time: Double) {
        guard tapTimes[currentIndex] == nil else { return }
        tapTimes[currentIndex] = time
        Haptics.impact(.rigid)
    }

    private func advanceOrFinish() {
        if isLast {
            finishTest()
        } else {
            withAnimation(.easeOut(duration: 0.25)) {
                currentIndex += 1
                playerState = PlayerState()
                scoreRevealed = false
            }
        }
    }

    private func goToPrevious() {
        guard currentIndex > 0 else { return }
        withAnimation(.easeOut(duration: 0.25)) {
            currentIndex -= 1
            playerState = PlayerState()
            scoreRevealed = false
        }
    }

    private func finishTest() {
        Haptics.notification(.success)

        let result = HazardResult.calculate(
            situations: situations,
            tapTimes: tapTimes
        )
        hazardResult = result
        progressStore.recordHazardResult(result)
        navigateToResult = true
    }

    private func revealScore() {
        let situation = situations[currentIndex]
        let score = situation.score(tapTime: tapTimes[currentIndex] ?? nil)

        withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
            scoreRevealed = true
        }

        if score >= 4 {
            Haptics.notification(.success)
        } else if score >= 2 {
            Haptics.impact(.light)
        } else {
            Haptics.notification(.error)
        }
    }
}

// MARK: - PlayerState

struct PlayerState {
    var isFinished = false
    var currentTime: Double = 0
    var duration: Double = 0
    var isBuffering = false
    var hasError = false
}

// MARK: - Hazard Progress Capsule

private struct HazardProgressCapsule: View {
    let current: Int
    let total: Int

    var body: some View {
        let content = HStack(spacing: 6) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.appPrimary)
            Text("\(current)/\(total)")
                .font(.system(size: 16, weight: .bold).monospacedDigit())
                .foregroundStyle(Color.appTextDark)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)

        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            content
                .background(Color.appDivider.opacity(0.3))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Timer Button

private struct HazardTimerButton: View {
    let currentTime: Double
    let duration: Double

    private var fraction: Double {
        duration > 0 ? min(currentTime / duration, 1.0) : 0
    }

    private var timeText: String {
        let cur = Int(currentTime)
        let dur = Int(duration)
        return String(format: "%d:%02d / %d:%02d", cur / 60, cur % 60, dur / 60, dur % 60)
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "play.fill")
                .font(.system(size: 12))
                .foregroundStyle(Color.appPrimary)
            Text(duration > 0 ? timeText : "Đang tải...")
                .font(.system(size: 14, weight: .semibold).monospacedDigit())
                .foregroundStyle(Color.appTextMedium)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background {
            // Track
            Capsule()
                .fill(Color.appDivider.opacity(0.4))
        }
        .overlay(alignment: .leading) {
            // Progress fill — clipped to capsule
            GeometryReader { geo in
                Capsule()
                    .fill(Color.appPrimary.opacity(0.2))
                    .frame(width: max(geo.size.width * fraction, 0))
                    .animation(.linear(duration: 0.1), value: fraction)
            }
        }
        .clipShape(Capsule())
    }
}

// MARK: - Score Reveal

private struct HazardScoreReveal: View {
    let score: Int

    @State private var animatedDots = 0

    private var scoreColor: Color {
        if score >= 4 { return .appSuccess }
        if score >= 2 { return .appWarning }
        return .appError
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("\(score)")
                .font(.system(size: 40, weight: .heavy).monospacedDigit())
                .foregroundStyle(scoreColor)
                .contentTransition(.numericText())

            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .fill(i < animatedDots ? Color.appPrimary : Color.appDivider)
                        .frame(width: 14, height: 14)
                        .scaleEffect(i < animatedDots ? 1.0 : 0.6)
                        .animation(
                            .spring(duration: 0.35, bounce: 0.4).delay(Double(i) * 0.08),
                            value: animatedDots
                        )
                }
            }

            Text(scoreLabel)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(scoreColor)
        }
        .onAppear {
            withAnimation {
                animatedDots = score
            }
        }
    }

    private var scoreLabel: String {
        switch score {
        case 5: return "Hoàn hảo!"
        case 4: return "Rất tốt"
        case 3: return "Tốt"
        case 2: return "Tạm được"
        case 1: return "Muộn"
        default: return "Không đạt"
        }
    }
}

// MARK: - HazardVideoPlayer

struct HazardVideoPlayer: UIViewControllerRepresentable {
    let url: URL
    @Binding var state: PlayerState

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let vc = AVPlayerViewController()
        vc.showsPlaybackControls = true
        vc.videoGravity = .resizeAspectFill
        vc.allowsVideoFrameAnalysis = false

        let player = AVPlayer(url: url)
        vc.player = player

        context.coordinator.setup(player: player)

        player.play()
        return vc
    }

    func updateUIViewController(_ vc: AVPlayerViewController, context: Context) {
        if !state.isFinished && state.currentTime == 0 && state.duration == 0 && !state.hasError {
            guard let currentAsset = vc.player?.currentItem?.asset as? AVURLAsset else {
                replacePlayer(vc: vc, context: context)
                return
            }
            if currentAsset.url != url {
                replacePlayer(vc: vc, context: context)
            }
        }
    }

    private func replacePlayer(vc: AVPlayerViewController, context: Context) {
        vc.player?.pause()
        context.coordinator.cleanup(player: vc.player)

        let player = AVPlayer(url: url)
        vc.player = player
        context.coordinator.setup(player: player)
        player.play()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject {
        let parent: HazardVideoPlayer
        var endObserver: NSObjectProtocol?
        var errorObserver: NSObjectProtocol?
        var timeObserver: Any?
        var statusObservation: NSKeyValueObservation?
        var bufferObservation: NSKeyValueObservation?

        init(parent: HazardVideoPlayer) {
            self.parent = parent
        }

        func setup(player: AVPlayer) {
            cleanup(player: nil)

            endObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { [weak self] _ in
                self?.parent.state.isFinished = true
            }

            errorObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemFailedToPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { [weak self] _ in
                self?.parent.state.hasError = true
            }

            let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                guard let self else { return }
                self.parent.state.currentTime = time.seconds
                if let duration = player.currentItem?.duration.seconds, duration.isFinite {
                    self.parent.state.duration = duration
                }
            }

            bufferObservation = player.currentItem?.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] item, _ in
                Task { @MainActor in
                    self?.parent.state.isBuffering = !item.isPlaybackLikelyToKeepUp
                }
            }

            statusObservation = player.currentItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
                if item.status == .failed {
                    Task { @MainActor in
                        self?.parent.state.hasError = true
                    }
                }
            }
        }

        func cleanup(player: AVPlayer?) {
            if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
            if let errorObserver { NotificationCenter.default.removeObserver(errorObserver) }
            if let timeObserver, let player { player.removeTimeObserver(timeObserver) }
            statusObservation?.invalidate()
            bufferObservation?.invalidate()
            endObserver = nil
            errorObserver = nil
            timeObserver = nil
            statusObservation = nil
            bufferObservation = nil
        }

        deinit {
            if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
            if let errorObserver { NotificationCenter.default.removeObserver(errorObserver) }
            statusObservation?.invalidate()
            bufferObservation?.invalidate()
        }
    }

    static func dismantleUIViewController(_ vc: AVPlayerViewController, coordinator: Coordinator) {
        vc.player?.pause()
        coordinator.cleanup(player: vc.player)
    }
}
