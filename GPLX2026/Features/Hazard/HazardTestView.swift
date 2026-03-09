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
        .background {
            ZStack {
                Color.scaffoldBg.ignoresSafeArea()
                AnimatedBackground()
            }
        }
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
                    situationId: situations.isEmpty ? 0 : situations[currentIndex].id,
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
                    result: result,
                    retryMode: mode
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
                VStack(spacing: 14) {
                    // MARK: Video Player
                    ZStack {
                        HazardVideoPlayer(
                            url: videoCache.playableURL(for: situation),
                            state: $playerState
                        )
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                        )

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
                            .aspectRatio(16 / 9, contentMode: .fit)
                            .background(Color.scaffoldBg)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        } else if playerState.isBuffering {
                            ProgressView()
                                .tint(Color.appPrimary)
                        }
                    }
                    .padding(.horizontal, 16)

                    // MARK: Chapter info + timer
                    HStack(spacing: 8) {
                        Text("Ch.\(situation.chapter): \(situation.chapterName)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.appTextMedium)
                            .lineLimit(1)

                        Spacer()

                        if playerState.duration > 0 && !playerState.isFinished {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(hasTapped ? Color.appSuccess : Color.appError)
                                    .frame(width: 6, height: 6)
                                Text(timeText)
                                    .font(.system(size: 12, weight: .semibold).monospacedDigit())
                                    .foregroundStyle(Color.appTextMedium)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // MARK: Video progress bar (3-state after tap)
                    if !playerState.isFinished && playerState.duration > 0 {
                        HazardPlayingBar(
                            currentTime: playerState.currentTime,
                            duration: playerState.duration,
                            situation: situation,
                            hasTapped: hasTapped
                        )
                        .padding(.horizontal, 20)
                    }

                    // MARK: Action area
                    if playerState.isFinished && scoreRevealed {
                        let score = situation.score(tapTime: tapTimes[currentIndex] ?? nil)
                        HazardScoreCard(
                            score: score,
                            situation: situation,
                            tapTime: tapTimes[currentIndex] ?? nil,
                            duration: playerState.duration
                        )
                        .padding(.horizontal, 16)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.96).combined(with: .opacity),
                            removal: .opacity
                        ))
                    } else if playerState.isFinished && !scoreRevealed {
                        // Brief processing state before score reveal
                        VStack(spacing: 8) {
                            ProgressView()
                                .tint(Color.appPrimary)
                            Text("Đang tính điểm...")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.appTextLight)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .transition(.opacity)
                    } else if !playerState.isFinished {
                        VStack(spacing: 10) {
                            HazardDangerButton(hasTapped: hasTapped) {
                                handleTap(at: playerState.currentTime)
                            }

                            // Skip button after confirming
                            if hasTapped {
                                Button {
                                    Haptics.selection()
                                    skipVideo()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "forward.fill")
                                            .font(.system(size: 12))
                                        Text("Bỏ qua")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    .foregroundStyle(Color.appPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                }
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 16)
                        .transition(.opacity)
                        .animation(.easeOut(duration: 0.25), value: hasTapped)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
                .animation(.spring(duration: 0.4, bounce: 0.1), value: playerState.isFinished && scoreRevealed)
                .animation(.easeOut(duration: 0.15), value: currentIndex)
            }
            .id(currentIndex)

            // MARK: Bottom Navigation
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
                    if isPractice {
                        Button {
                            Haptics.selection()
                            retryCurrent()
                        } label: {
                            AppButton(icon: "arrow.counterclockwise", label: "Xem lại", style: .secondary, height: 48, cornerRadius: 24)
                        }
                    }

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
                    // Subtle progress indicator during playback
                    Text("\(currentIndex + 1) / \(situations.count)")
                        .font(.system(size: 14, weight: .semibold).monospacedDigit())
                        .foregroundStyle(Color.appTextLight)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .contentTransition(.numericText())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 4)
            .animation(.easeOut(duration: 0.25), value: playerState.isFinished)
        }
    }

    private var timeText: String {
        let cur = Int(playerState.currentTime)
        let dur = Int(playerState.duration)
        return String(format: "%d:%02d / %d:%02d", cur / 60, cur % 60, dur / 60, dur % 60)
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

    private func skipVideo() {
        playerState.isFinished = true
    }

    private func advanceOrFinish() {
        if isLast {
            finishTest()
        } else {
            currentIndex += 1
            playerState = PlayerState()
            scoreRevealed = false
        }
    }

    private func retryCurrent() {
        tapTimes.removeValue(forKey: currentIndex)
        playerState = PlayerState()
        scoreRevealed = false
    }

    private func goToPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        playerState = PlayerState()
        scoreRevealed = false
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

// MARK: - Playing Progress Bar (3-state after tap)

private struct HazardPlayingBar: View {
    let currentTime: Double
    let duration: Double
    let situation: HazardSituation
    let hasTapped: Bool

    private var fraction: Double {
        duration > 0 ? min(currentTime / duration, 1.0) : 0
    }

    private enum Zone { case early, perfect, late }

    private var currentZone: Zone {
        if currentTime < situation.perfectStart { return .early }
        if currentTime <= situation.perfectEnd { return .perfect }
        return .late
    }

    private var progressColor: Color {
        if !hasTapped { return .appPrimary }
        switch currentZone {
        case .early: return .appTextLight
        case .perfect: return .appSuccess
        case .late: return .appError
        }
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width

            ZStack(alignment: .leading) {
                // Track
                Capsule()
                    .fill(Color.appDivider.opacity(0.4))

                // 3 zone backgrounds (only visible after tap)
                if hasTapped && duration > 0 {
                    let startFrac = situation.perfectStart / duration
                    let endFrac = min(situation.perfectEnd / duration, 1.0)

                    // Early zone
                    Capsule()
                        .fill(Color.appTextLight.opacity(0.15))
                        .frame(width: max(w * startFrac, 0))

                    // Perfect zone
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.appSuccess.opacity(0.2))
                        .frame(width: max(w * (endFrac - startFrac), 0))
                        .offset(x: w * startFrac)

                    // Late zone
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.appError.opacity(0.12))
                        .frame(width: max(w * (1.0 - endFrac), 0))
                        .offset(x: w * endFrac)
                }

                // Progress fill
                Capsule()
                    .fill(progressColor.opacity(0.6))
                    .frame(width: max(w * fraction, 0))
                    .animation(.linear(duration: 0.1), value: fraction)
            }
        }
        .frame(height: hasTapped ? 8 : 4)
        .animation(.easeOut(duration: 0.3), value: hasTapped)

        // Zone labels (only after tap)
        if hasTapped {
            HStack(spacing: 0) {
                HStack(spacing: 3) {
                    Circle().fill(Color.appTextLight).frame(width: 5, height: 5)
                    Text("Sớm")
                }
                .foregroundStyle(Color.appTextLight)
                Spacer()
                HStack(spacing: 3) {
                    Circle().fill(Color.appSuccess).frame(width: 5, height: 5)
                    Text("Đúng lúc")
                }
                .foregroundStyle(Color.appSuccess)
                Spacer()
                HStack(spacing: 3) {
                    Circle().fill(Color.appError).frame(width: 5, height: 5)
                    Text("Muộn")
                }
                .foregroundStyle(Color.appError)
            }
            .font(.system(size: 10, weight: .semibold))
            .transition(.opacity)
        }
    }
}

// MARK: - Hazard Progress Capsule (toolbar principal)

private struct HazardProgressCapsule: View {
    let situationId: Int
    let current: Int
    let total: Int

    var body: some View {
        let content = HStack(spacing: 6) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 13))
                .foregroundStyle(Color.appPrimary)
            Text("TH \(situationId)")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.appTextDark)
            Text("·")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.appTextLight)
            Text("\(current)/\(total)")
                .font(.system(size: 15, weight: .bold).monospacedDigit())
                .foregroundStyle(Color.appTextMedium)
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

// MARK: - Hazard Danger Button

private struct HazardDangerButton: View {
    let hasTapped: Bool
    let action: () -> Void

    @State private var isPulsing = false

    var body: some View {
        Button(action: action) {
            let content = HStack(spacing: 10) {
                Image(systemName: hasTapped ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace))

                Text(hasTapped ? "Đã phát hiện nguy hiểm!" : "Nhấn khi phát hiện nguy hiểm")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(hasTapped ? Color.appSuccess : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 64)

            if #available(iOS 26.0, *) {
                content
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(hasTapped ? Color.appSuccess.opacity(0.15) : Color.appError.opacity(0.85))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 18))
            } else {
                content
                    .background(hasTapped ? Color.appSuccess.opacity(0.15) : Color.appError)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
        .disabled(hasTapped)
        // Pulsing red glow when active (not yet tapped)
        .shadow(
            color: hasTapped ? .clear : Color.appError.opacity(isPulsing ? 0.55 : 0.15),
            radius: isPulsing ? 18 : 6,
            y: isPulsing ? 4 : 2
        )
        .scaleEffect(hasTapped ? 0.97 : 1.0)
        .animation(.spring(duration: 0.35, bounce: 0.3), value: hasTapped)
        .onAppear {
            guard !hasTapped else { return }
            withAnimation(
                .easeInOut(duration: 1.1)
                .repeatForever(autoreverses: true)
            ) {
                isPulsing = true
            }
        }
        .onChange(of: hasTapped) { _, tapped in
            if tapped { isPulsing = false }
        }
    }
}

// MARK: - Hazard Score Card (combined score + timeline + tip)

private struct HazardScoreCard: View {
    let score: Int
    let situation: HazardSituation
    let tapTime: Double?
    let duration: Double

    var body: some View {
        VStack(spacing: 14) {
            HazardScoreReveal(score: score)

            HazardTimeline(
                situation: situation,
                tapTime: tapTime,
                duration: duration
            )
            .padding(.horizontal, 4)

            // Tip inline at bottom — no separate divider
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
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .glassCard(interactive: false)
    }
}

// MARK: - Score Reveal

private struct HazardScoreReveal: View {
    let score: Int

    @State private var displayedScore = 0
    @State private var animatedDots = 0

    private var displayScoreColor: Color {
        if displayedScore >= 4 { return .appSuccess }
        if displayedScore >= 2 { return .appWarning }
        return .appError
    }

    var body: some View {
        VStack(spacing: 8) {
            Text("\(displayedScore)")
                .font(.system(size: 44, weight: .heavy).monospacedDigit())
                .foregroundStyle(displayScoreColor)
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

            Text(displayScoreLabel)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(displayScoreColor)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            // Count up score from 0 with numericText transition
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(150))
                for i in 1...max(score, 1) {
                    withAnimation(.spring(duration: 0.3, bounce: 0.15)) {
                        displayedScore = min(i, score)
                    }
                    try? await Task.sleep(for: .milliseconds(120))
                }
                // Ensure final value if score is 0
                if score == 0 {
                    withAnimation(.spring(duration: 0.3, bounce: 0.15)) {
                        displayedScore = 0
                    }
                }
                withAnimation {
                    animatedDots = score
                }
            }
        }
    }

    private var displayScoreLabel: String {
        switch displayedScore {
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

                    // Zone 2: Perfect zone (green → yellow → red gradient)
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

            // Zone labels
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
        vc.showsPlaybackControls = false
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
