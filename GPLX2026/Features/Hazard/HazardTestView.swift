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
                    HStack(spacing: 12) {
                        Image(systemName: "film")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.appPrimary, in: RoundedRectangle(cornerRadius: 9))

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Tình huống \(situation.id)")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.appTextDark)
                            Text("Chương \(situation.chapter): \(situation.chapterName)")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.appTextMedium)
                        }

                        Spacer(minLength: 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .glassCard()

                    // MARK: Video Player
                    ZStack {
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

                        if playerState.hasError {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(Color.appError)
                                Text("Không thể tải video")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.appTextDark)
                                Text("Kiểm tra kết nối mạng")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.appTextMedium)
                            }
                            .frame(maxWidth: .infinity)
                            .aspectRatio(16/9, contentMode: .fit)
                            .background(Color.scaffoldBg)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        } else if playerState.isBuffering {
                            ProgressView()
                                .tint(Color.appPrimary)
                        }
                    }

                    // MARK: Divider
                    Divider()
                        .padding(.horizontal, 4)

                    // MARK: Hazard Button / Score
                    if playerState.isFinished && scoreRevealed {
                        // Score + Tip
                        let score = situation.score(tapTime: tapTimes[currentIndex] ?? nil)

                        VStack(spacing: 14) {
                            HazardScoreReveal(score: score)

                            // Timeline with 3 zones
                            HazardTimeline(
                                situation: situation,
                                tapTime: tapTimes[currentIndex] ?? nil,
                                duration: playerState.duration
                            )
                            .padding(.horizontal, 16)

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
                        duration: playerState.duration,
                        situation: situation,
                        hasTapped: hasTapped
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
    let situation: HazardSituation
    let hasTapped: Bool

    private var fraction: Double {
        duration > 0 ? min(currentTime / duration, 1.0) : 0
    }

    private var timeText: String {
        let cur = Int(currentTime)
        let dur = Int(duration)
        return String(format: "%d:%02d / %d:%02d", cur / 60, cur % 60, dur / 60, dur % 60)
    }

    private enum Zone {
        case early, perfect, late
    }

    private var currentZone: Zone {
        if currentTime < situation.perfectStart { return .early }
        if currentTime <= situation.perfectEnd { return .perfect }
        return .late
    }

    private var zoneColor: Color {
        switch currentZone {
        case .early: return .appPrimary
        case .perfect: return .appSuccess
        case .late: return .appError
        }
    }

    private var zoneIcon: String {
        switch currentZone {
        case .early: return "play.fill"
        case .perfect: return "exclamationmark.triangle.fill"
        case .late: return "clock.badge.xmark"
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: hasTapped ? "checkmark.circle.fill" : zoneIcon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(hasTapped ? Color.appSuccess : zoneColor)
                .contentTransition(.symbolEffect(.replace))
            Text(duration > 0 ? timeText : "Đang tải...")
                .font(.system(size: 14, weight: .semibold).monospacedDigit())
                .foregroundStyle(Color.appTextMedium)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background {
            Capsule()
                .fill(Color.appDivider.opacity(0.4))
        }
        .overlay(alignment: .leading) {
            GeometryReader { geo in
                let w = geo.size.width

                ZStack(alignment: .leading) {
                    // 3-zone background markers (subtle)
                    if duration > 0 {
                        let startFrac = situation.perfectStart / duration
                        let endFrac = min(situation.perfectEnd / duration, 1.0)

                        // Perfect zone indicator (subtle green band)
                        Capsule()
                            .fill(Color.appSuccess.opacity(0.12))
                            .frame(width: max(w * (endFrac - startFrac), 0))
                            .offset(x: w * startFrac)
                    }

                    // Progress fill
                    Capsule()
                        .fill(zoneColor.opacity(hasTapped ? 0.15 : 0.25))
                        .frame(width: max(w * fraction, 0))
                        .animation(.linear(duration: 0.1), value: fraction)
                }
            }
        }
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.3), value: currentZone)
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

// MARK: - Hazard Timeline (3 Zones)

private struct HazardTimeline: View {
    let situation: HazardSituation
    let tapTime: Double?
    let duration: Double

    @State private var appeared = false

    private var perfectStartFraction: Double {
        duration > 0 ? situation.perfectStart / duration : 0
    }
    private var perfectEndFraction: Double {
        duration > 0 ? situation.perfectEnd / duration : 0
    }
    private var tapFraction: Double? {
        guard let tapTime, duration > 0 else { return nil }
        return tapTime / duration
    }

    var body: some View {
        VStack(spacing: 8) {
            // Timeline bar with zones
            GeometryReader { geo in
                let w = geo.size.width
                let startX = w * perfectStartFraction
                let endX = w * perfectEndFraction

                ZStack(alignment: .leading) {
                    // Full track
                    Capsule()
                        .fill(Color.appDivider.opacity(0.4))

                    // Zone 1: Before danger (gray)
                    Capsule()
                        .fill(Color.appTextLight.opacity(0.3))
                        .frame(width: max(startX, 0))

                    // Zone 2: Perfect zone (green gradient)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.appSuccess, .appWarning, .appError],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(endX - startX, 0))
                        .offset(x: startX)

                    // Zone 3: After danger (red tint) — already gray track, no extra fill needed

                    // Tap marker
                    if let tapFraction {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 14, height: 14)
                            .shadow(color: .black.opacity(0.2), radius: 3, y: 1)
                            .overlay(
                                Circle()
                                    .fill(markerColor)
                                    .frame(width: 8, height: 8)
                            )
                            .offset(x: w * tapFraction - 7)
                            .scaleEffect(appeared ? 1 : 0)
                            .animation(.spring(duration: 0.4, bounce: 0.3).delay(0.3), value: appeared)
                    }
                }
            }
            .frame(height: 14)

            // Labels
            HStack(spacing: 0) {
                Label("Sớm", systemImage: "clock")
                    .foregroundStyle(Color.appTextLight)
                Spacer()
                Label("Tốt", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(Color.appSuccess)
                Spacer()
                Label("Muộn", systemImage: "clock.badge.xmark")
                    .foregroundStyle(Color.appError)
            }
            .font(.system(size: 11, weight: .semibold))

            // Tap time info
            if let tapTime {
                let score = situation.score(tapTime: tapTime)
                Text("Nhấn tại \(String(format: "%.1f", tapTime))s — \(score)/5 điểm")
                    .font(.system(size: 12, weight: .medium).monospacedDigit())
                    .foregroundStyle(Color.appTextMedium)
            } else {
                Text("Không nhấn — 0/5 điểm")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.appError)
            }
        }
        .onAppear { appeared = true }
    }

    private var markerColor: Color {
        guard let tapTime else { return .appError }
        let score = situation.score(tapTime: tapTime)
        if score >= 4 { return .appSuccess }
        if score >= 2 { return .appWarning }
        return .appError
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
        weak var player: AVPlayer?
        var endObserver: NSObjectProtocol?
        var errorObserver: NSObjectProtocol?
        var timeObserver: Any?
        var statusObservation: NSKeyValueObservation?
        var bufferObservation: NSKeyValueObservation?

        init(parent: HazardVideoPlayer) {
            self.parent = parent
        }

        func setup(player: AVPlayer) {
            cleanup(player: self.player)
            self.player = player

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
            if let timeObserver, let player { player.removeTimeObserver(timeObserver) }
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
