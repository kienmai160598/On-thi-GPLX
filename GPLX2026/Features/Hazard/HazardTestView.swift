import SwiftUI
import AVKit

struct HazardTestView: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(HazardVideoCache.self) private var videoCache
    @Environment(ThemeStore.self) private var themeStore
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    let mode: Mode

    enum Mode {
        case exam
        case practice
        case chapter(Int)
        case examSet(Int)
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
    @State private var restartToken = 0
    @State private var showTapFlash = false
    @State private var isCurrentlyLandscape = false

    private var isLast: Bool { currentIndex + 1 >= situations.count }
    private var isPractice: Bool {
        if case .exam = mode { return false }
        return true
    }
    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        Group {
            if situations.isEmpty {
                ExamLoadingView()
            } else {
                testContent
            }
        }
        .screenHeaderStyle(titleDisplayMode: .inline, hideBackButton: true)
        .toolbarVisibility(isCurrentlyLandscape ? .hidden : .visible, for: .navigationBar)
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
        .onAppear {
            // The hazard player is landscape-only (design BSxMj): force landscape
            // on enter and restore portrait on exit.
            OrientationManager.shared.forceToLandscape()
        }
        .onDisappear { OrientationManager.shared.lock() }
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
        GeometryReader { geo in
            let situation = situations[currentIndex]
            let hasTapped = tapTimes[currentIndex] != nil
            // Landscape-only player (design BSxMj); the view is locked to
            // landscape on appear, and iPad has the room for it in any orientation.
            landscapeLayout(situation: situation, hasTapped: hasTapped, geo: geo)
        }
        .onGeometryChange(for: Bool.self) { geo in
            geo.size.width > geo.size.height
        } action: { isLandscape in
            isCurrentlyLandscape = isLandscape
        }
    }

    // MARK: - Landscape Layout (Design: BSxMj)

    @ViewBuilder
    private func landscapeLayout(situation: HazardSituation, hasTapped: Bool, geo: GeometryProxy) -> some View {
        let btnHeight: CGFloat = metrics.buttonHeight
        // The whole layout ignores the safe area, so lift the bottom controls
        // clear of the landscape home indicator manually.
        let bottomSafeInset = max(12, geo.safeAreaInsets.bottom + 4)
        // The video bleeds full-screen, but the overlaid controls must clear the
        // landscape notch / Dynamic Island, which sits on whichever side is up.
        let leadingInset = max(20, geo.safeAreaInsets.leading)
        let trailingInset = max(20, geo.safeAreaInsets.trailing)
        let topInset = max(20, geo.safeAreaInsets.top + 8)

        ZStack(alignment: .bottom) {
            // ── Video layer fills the entire frame ──────────────────────
            HazardVideoPlayer(
                url: videoCache.playableURL(for: situation),
                state: $playerState
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .overlay(
                Color.white
                    .opacity(showTapFlash ? 0.4 : 0)
                    .animation(.easeOut(duration: 0.2), value: showTapFlash)
                    .allowsHitTesting(false)
            )
            .overlay {
                if playerState.hasError {
                    videoErrorOverlay
                } else if playerState.isBuffering {
                    ProgressView().tint(.white)
                }
            }

            // ── Vignette overlay ────────────────────────────────────────
            LinearGradient(
                stops: [
                    .init(color: Color(hex: 0x000000, opacity: 0.50), location: 0.00),
                    .init(color: Color(hex: 0x000000, opacity: 0.00), location: 0.35),
                    .init(color: Color(hex: 0x000000, opacity: 0.25), location: 0.60),
                    .init(color: Color(hex: 0x000000, opacity: 0.80), location: 1.00),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // ── Top bar overlay ─────────────────────────────────────────
            HStack(spacing: 10) {
                // Close button — only shown in landscape (nav bar hidden).
                // In portrait on iPad the system nav bar xmark handles close.
                if isCurrentlyLandscape {
                    Button { showExitDialog = true } label: {
                        Image(systemName: "xmark")
                            .font(.appSans(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Color(hex: 0x000000, opacity: 0.35))
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(Color.white.opacity(0.10), lineWidth: 1))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Thoát bài thi")
                }

                // Situation chip with gold number badge
                HStack(spacing: 8) {
                    // Gold number badge
                    Text("\(situation.id)")
                        .font(.appSans(size: 11, weight: .black))
                        .foregroundStyle(Color(hex: 0x3A2400))
                        .frame(width: 22, height: 22)
                        .background(Color(hex: 0xFFC233))
                        .clipShape(Circle())

                    Text(situation.title.count > 24 ? "TH \(situation.id)" : situation.title)
                        .font(.appSans(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text("·")
                        .font(.appSans(size: 13, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.40))

                    Text("\(currentIndex + 1)/\(situations.count)")
                        .font(.appSans(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.70))
                        .contentTransition(.numericText())
                }
                .padding(.leading, 8)
                .padding(.trailing, 12)
                .padding(.vertical, 6)
                .background(Color(hex: 0x000000, opacity: 0.40))
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.10), lineWidth: 1))

                Spacer(minLength: 0)
            }
            .padding(.leading, leadingInset)
            .padding(.trailing, trailingInset)
            .padding(.top, topInset)
            .frame(maxHeight: .infinity, alignment: .top)

            // ── Hint card (top-left of video, below status bar) ─────────
            if !playerState.isFinished && !hasTapped {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .font(.appSans(size: 11))
                            .foregroundStyle(Color(hex: 0xFFC233))
                        Text("NHIỆM VỤ")
                            .font(.appSans(size: 9, weight: .black))
                            .foregroundStyle(Color(hex: 0xFFC233))
                            .kerning(1.5)
                    }
                    Text("Nhấn NGAY khi thấy nguy hiểm tiềm tàng.")
                        .font(.appSans(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(8)
                .frame(width: 230, alignment: .leading)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.12), lineWidth: 1))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, leadingInset)
                .padding(.top, topInset + 56)
                .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .topLeading)))
            }

            // ── Play/Pause centred overlay (shown when video is paused or loading) ──
            // (Auto-start is unchanged; this button is purely visual chrome)
            // Not rendering an explicit play/pause toggle since HazardVideoPlayer auto-plays
            // and the scoring timing must not be disturbed by any pause state here.

            // ── Bottom panel ─────────────────────────────────────────────
            if playerState.isFinished {
                // Score panel replaces the bottom controls
                VStack(spacing: 0) {
                    if scoreRevealed {
                        landscapeScorePanel(situation: situation, hasTapped: hasTapped, btnHeight: btnHeight)
                    } else {
                        VStack(spacing: 8) {
                            ProgressView().tint(.white)
                            Text("Đang tính điểm...")
                                .font(.appSans(size: 13, weight: .medium))
                                .foregroundStyle(Color.white.opacity(0.70))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                    }
                }
                .background(Color(hex: 0x000000, opacity: 0.50))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(Color.white.opacity(0.10), lineWidth: 1))
                .padding(.leading, leadingInset)
                .padding(.trailing, trailingInset)
                .padding(.bottom, bottomSafeInset)
            } else {
                // Playing bottom panel
                HazardBottomPanel(
                    situation: situation,
                    currentTime: playerState.currentTime,
                    duration: playerState.duration,
                    hasTapped: hasTapped,
                    timeText: timeText,
                    isPractice: isPractice,
                    isLast: isLast,
                    onTap: { handleTap(at: playerState.currentTime) },
                    onSkip: {
                        Haptics.selection()
                        skipVideo()
                    },
                    onRetry: {
                        Haptics.selection()
                        retryCurrent()
                    },
                    onAdvance: {
                        Haptics.selection()
                        advanceOrFinish()
                    }
                )
                .padding(.leading, leadingInset)
                .padding(.trailing, trailingInset)
                .padding(.bottom, bottomSafeInset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .id("\(currentIndex)-\(restartToken)")
        .animation(.easeOut(duration: 0.15), value: currentIndex)
    }

    // MARK: - Landscape Score Panel

    @ViewBuilder
    private func landscapeScorePanel(situation: HazardSituation, hasTapped: Bool, btnHeight: CGFloat) -> some View {
        let score = situation.score(tapTime: tapTimes[currentIndex] ?? nil)
        let scoreColor: Color = score >= 4 ? .appSuccess : score >= 2 ? .appWarning : .appError

        VStack(spacing: 0) {
            // Score summary row
            HStack(spacing: 14) {
                // Score number
                Text("\(score)")
                    .font(.appSans(size: isRegular ? 32 : 26, weight: .heavy))
                    .foregroundStyle(scoreColor)

                VStack(alignment: .leading, spacing: isRegular ? 4 : 2) {
                    Text(scoreLabelFor(score))
                        .font(.appSans(size: isRegular ? 14 : 12, weight: .bold))
                        .foregroundStyle(scoreColor)

                    HStack(spacing: isRegular ? 4 : 3) {
                        ForEach(0..<5, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i < score ? scoreColor : Color.white.opacity(0.20))
                                .frame(height: isRegular ? 5 : 4)
                        }
                    }
                }

                Spacer(minLength: 0)

                // Tap info
                if let tapTime = tapTimes[currentIndex] ?? nil {
                    Text(String(format: "Nhấn tại %.1fs", tapTime))
                        .font(.appSans(size: 11))
                        .foregroundStyle(Color.white.opacity(0.60))
                } else {
                    Text("Không nhấn")
                        .font(.appSans(size: 11))
                        .foregroundStyle(Color.appError.opacity(0.80))
                }
            }
            .padding(.horizontal, isRegular ? 16 : 12)
            .padding(.vertical, isRegular ? 10 : 8)

            Divider().overlay(Color.white.opacity(0.12))

            // Timeline
            HazardTimeline(
                situation: situation,
                tapTime: tapTimes[currentIndex] ?? nil,
                duration: playerState.duration
            )
            .padding(.horizontal, isRegular ? 16 : 12)
            .padding(.vertical, isRegular ? 10 : 8)

            Divider().overlay(Color.white.opacity(0.12))

            // Tip row
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.appSans(size: isRegular ? 12 : 10))
                    .foregroundStyle(Color(hex: 0xFFC233))
                    .padding(.top, 1)
                Text(situation.tip)
                    .font(.appSans(size: isRegular ? 12 : 10))
                    .foregroundStyle(Color.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, isRegular ? 16 : 12)
            .padding(.vertical, isRegular ? 10 : 8)

            Divider().overlay(Color.white.opacity(0.12))

            // Nav buttons row
            HStack(spacing: isRegular ? 10 : 8) {
                if isPractice && currentIndex > 0 {
                    Button {
                        Haptics.selection()
                        goToPrevious()
                    } label: {
                        HazardGhostButton(icon: "backward.fill", label: "Trước")
                    }
                }

                if isPractice {
                    Button {
                        Haptics.selection()
                        retryCurrent()
                    } label: {
                        HazardGhostButton(icon: "arrow.counterclockwise", label: "Xem lại")
                    }
                }

                Button {
                    Haptics.selection()
                    advanceOrFinish()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isLast ? "checkmark" : "chevron.right.2")
                            .font(.appSans(size: 14, weight: .semibold))
                        Text(isLast ? "Kết quả" : "Tiếp theo")
                            .font(.appSans(size: 14, weight: .black))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.appPrimary.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, isRegular ? 16 : 12)
            .padding(.vertical, isRegular ? 10 : 8)
        }
    }

    // MARK: - Shared Components

    @ViewBuilder
    private var videoErrorOverlay: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.appSans(size: 28))
                .foregroundStyle(Color.appError)
            Text("Không thể tải video")
                .font(.appSans(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
            Text("Kiểm tra kết nối mạng")
                .font(.appSans(size: 12))
                .foregroundStyle(Color.appTextMedium)

            Button {
                playerState = PlayerState()
                restartToken += 1
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.appSans(size: 13, weight: .medium))
                    Text("Thử lại")
                        .font(.appSans(size: 14, weight: .semibold))
                }
                .foregroundStyle(themeStore.primaryColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(themeStore.primaryColor.opacity(0.12))
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(16 / 9, contentMode: .fit)
        .background(Color.scaffoldBg)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var timeText: String {
        let cur = Int(playerState.currentTime)
        let dur = Int(playerState.duration)
        return String(format: "%d:%02d / %d:%02d", cur / 60, cur % 60, dur / 60, dur % 60)
    }

    private func scoreLabelFor(_ score: Int) -> String {
        switch score {
        case 5: return "Hoàn hảo!"
        case 4: return "Rất tốt"
        case 3: return "Tốt"
        case 2: return "Tạm được"
        case 1: return "Muộn"
        default: return "Không đạt"
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
        case .examSet(let setId):
            let perSet = AppConstants.Hazard.situationsPerExam
            let startIndex = (setId - 1) * perSet
            let endIndex = min(startIndex + perSet, HazardSituation.all.count)
            situations = Array(HazardSituation.all[startIndex..<endIndex])
        }
        playerState = PlayerState()
    }

    private func handleTap(at time: Double) {
        guard tapTimes[currentIndex] == nil else { return }
        tapTimes[currentIndex] = time
        Haptics.impact(.rigid)
        showTapFlash = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(200))
            showTapFlash = false
        }
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
        restartToken += 1
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

        if case .examSet(let setId) = mode {
            progressStore.addCompletedHazardSet(setId)
        }

        // Leaving the video for the portrait result screen — rotate back.
        OrientationManager.shared.lock()
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

// MARK: - Hazard Bottom Panel (landscape playing state)

private struct HazardBottomPanel: View {
    let situation: HazardSituation
    let currentTime: Double
    let duration: Double
    let hasTapped: Bool
    let timeText: String
    let isPractice: Bool
    let isLast: Bool
    let onTap: () -> Void
    let onSkip: () -> Void
    let onRetry: () -> Void
    let onAdvance: () -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isRegular: Bool { sizeClass == .regular }

    var body: some View {
        VStack(spacing: 10) {
            // Sub-layer 7a: Meta row
            metaRow

            // Sub-layer 7b: Zones timeline bar
            if duration > 0 {
                HazardZonesBar(
                    currentTime: currentTime,
                    duration: duration,
                    situation: situation,
                    hasTapped: hasTapped
                )
            }

            // Sub-layer 7c: Action row
            actionRow
        }
        .padding(8)
        .background(Color(hex: 0x000000, opacity: 0.50))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(Color.white.opacity(0.10), lineWidth: 1))
    }

    // Meta row: timestamp + title + legend dots
    @ViewBuilder
    private var metaRow: some View {
        HStack(spacing: 0) {
            // Left group
            HStack(spacing: 10) {
                // Timestamp capsule
                Text(timeText)
                    .font(.appSans(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Capsule())

                Text(situation.title)
                    .font(.appSans(size: 14, weight: .black))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text("·")
                    .font(.appSans(size: 14, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.40))

                Text("TH \(situation.id)")
                    .font(.appSans(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.70))
            }

            Spacer(minLength: 8)

            // Right group: legend dots
            HStack(spacing: 14) {
                legendDot(color: Color(hex: 0x30D158), label: "Hoàn hảo")
                legendDot(color: Color(hex: 0xFFD60A), label: "Hơi muộn")
                legendDot(color: Color(hex: 0xFF3B30), label: "Bỏ lỡ")
            }
        }
    }

    @ViewBuilder
    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(.appSans(size: 10, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.70))
        }
    }

    // Action row: ghost buttons flanking the big danger button
    @ViewBuilder
    private var actionRow: some View {
        HStack(spacing: 10) {
            // Xem lại
            if isPractice {
                Button(action: onRetry) {
                    HazardGhostButton(icon: "arrow.counterclockwise", label: "Xem lại")
                }
            }

            // Danger button (fills remaining space)
            HazardDangerButton(
                hasTapped: hasTapped,
                compact: !isRegular,
                countdown: currentTime < 3,
                countdownSeconds: max(1, 3 - Int(currentTime)),
                action: onTap
            )

            // Bỏ qua
            Button(action: onSkip) {
                HazardGhostButton(icon: "forward.fill", label: "Bỏ qua")
            }

            // Tiếp
            Button(action: onAdvance) {
                HazardGhostButton(
                    icon: isLast ? "checkmark" : "chevron.right.2",
                    label: isLast ? "Kết quả" : "Tiếp"
                )
            }
        }
        .animation(.spring(duration: 0.35, bounce: 0.15), value: hasTapped)
    }
}

// MARK: - Ghost Action Button (icon above label, dark translucent)

private struct HazardGhostButton: View {
    let icon: String
    let label: String
    var width: CGFloat = 80

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.appSans(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            Text(label)
                .font(.appSans(size: 10, weight: .bold))
                .foregroundStyle(Color.white.opacity(0.80))
        }
        .frame(width: width)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.10), lineWidth: 1))
    }
}

// MARK: - Hazard Zones Bar (bottom panel timeline, landscape)

private struct HazardZonesBar: View {
    let currentTime: Double
    let duration: Double
    let situation: HazardSituation
    let hasTapped: Bool

    private var playedFraction: Double {
        duration > 0 ? min(currentTime / duration, 1.0) : 0
    }
    private var perfectStartFrac: Double {
        duration > 0 ? situation.perfectStart / duration : 0
    }
    private var perfectEndFrac: Double {
        duration > 0 ? min(situation.perfectEnd / duration, 1.0) : 0
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let pastW = w * min(playedFraction, perfectStartFrac)
            let perfectW = hasTapped ? w * (perfectEndFrac - perfectStartFrac) : 0
            let lateW = hasTapped ? w * max(0, min(playedFraction, 1.0) - perfectEndFrac) : 0
            let missW = hasTapped ? w * max(0, 1.0 - perfectEndFrac - max(0, min(playedFraction, 1.0) - perfectEndFrac)) : 0

            ZStack(alignment: .leading) {
                // Track background
                Capsule()
                    .fill(Color.white.opacity(0.08))

                // Played-past segment
                Capsule()
                    .fill(Color.white.opacity(0.40))
                    .frame(width: max(pastW, 0))

                if hasTapped {
                    // Perfect zone segment
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(hex: 0x30D158))
                        .frame(width: max(perfectW, 0))
                        .offset(x: w * perfectStartFrac)

                    // Late zone segment
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(hex: 0xFFD60A))
                        .frame(width: max(lateW, 0))
                        .offset(x: w * perfectEndFrac)

                    // Miss segment
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(hex: 0xFF3B30))
                        .frame(width: max(missW, 0))
                        .offset(x: w * perfectEndFrac + lateW)
                } else {
                    // Live progress fill before tap
                    Capsule()
                        .fill(Color.appPrimary.opacity(0.70))
                        .frame(width: max(w * playedFraction, 0))
                        .animation(.linear(duration: 0.1), value: playedFraction)
                }
            }
        }
        .frame(height: 8)
        .clipShape(Capsule())
    }
}

// MARK: - Hazard Progress Capsule (toolbar principal)

private struct HazardProgressCapsule: View {
    @Environment(ThemeStore.self) private var themeStore
    let situationId: Int
    let current: Int
    let total: Int

    var body: some View {
        let content = HStack(spacing: 6) {
            Image(systemName: "play.rectangle.fill")
                .font(.appSans(size: 13))
                .foregroundStyle(themeStore.primaryColor)
            Text("TH \(situationId)")
                .font(.appSans(size: 15, weight: .bold))
                .foregroundStyle(Color.appTextDark)
            Text("·")
                .font(.appSans(size: 13, weight: .regular))
                .foregroundStyle(Color.appTextLight)
            Text("\(current)/\(total)")
                .font(.appSans(size: 15, weight: .bold))
                .foregroundStyle(Color.appTextMedium)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)

        content
            .background(Color.appDivider.opacity(0.3))
            .clipShape(Capsule())
    }
}

// MARK: - Hazard Danger Button

private struct HazardDangerButton: View {
    let hasTapped: Bool
    var compact: Bool = false
    var countdown: Bool = false
    var countdownSeconds: Int = 3
    let action: () -> Void

    private var isDisabled: Bool { hasTapped || countdown }

    private var buttonText: String {
        if hasTapped { return "Đã phát hiện!" }
        if countdown { return "Chuẩn bị... \(countdownSeconds)" }
        return "PHÁT HIỆN NGUY HIỂM"
    }

    private var buttonSubtitle: String {
        if hasTapped { return "Đã ghi nhận phản ứng" }
        if countdown { return "Sẵn sàng..." }
        return "Nhấn ngay khi thấy tình huống"
    }

    var body: some View {
        Button(action: action) {
            let content = HStack(spacing: 10) {
                Image(systemName: hasTapped ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.appSans(size: compact ? 18 : 20, weight: .semibold))
                    .contentTransition(.symbolEffect(.replace))

                VStack(alignment: .leading, spacing: 1) {
                    Text(buttonText)
                        .font(.appSans(size: compact ? 13 : 14, weight: .black))
                        .kerning(0.5)
                        .contentTransition(.numericText())
                    Text(buttonSubtitle)
                        .font(.appSans(size: compact ? 9 : 10, weight: .semibold))
                        .opacity(0.80)
                }
            }
            .foregroundStyle(hasTapped ? Color.appSuccess : .white)
            .opacity(countdown ? 0.5 : 1.0)
            .frame(maxWidth: .infinity)
            .frame(height: compact ? 48 : 56)

            if #available(iOS 26.0, *) {
                content
                    .glassEffect(
                        .regular.interactive().tint(hasTapped ? Color.appSuccess.opacity(0.15) : Color.appError.opacity(countdown ? 0.4 : 0.85)),
                        in: .rect(cornerRadius: 14)
                    )
            } else {
                content
                    .background(hasTapped ? Color.appSuccess.opacity(0.15) : Color.appError.opacity(countdown ? 0.4 : 1.0))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(hasTapped ? "Đã phát hiện nguy hiểm" : "Nhấn khi phát hiện nguy hiểm")
        .accessibilityHint(hasTapped ? "" : "Nhấn nhanh khi thấy tình huống nguy hiểm trong video")
        .scaleEffect(hasTapped ? 0.97 : 1.0)
        .animation(.spring(duration: 0.35, bounce: 0.3), value: hasTapped)
        .animation(.easeOut(duration: 0.3), value: countdown)
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
            .font(.appSans(size: 12))

            // Tap time info
            if let tapTime {
                let score = situation.score(tapTime: tapTime)
                Text("Nhấn tại \(String(format: "%.1f", tapTime))s — \(score)/5 điểm")
                    .font(.appSans(size: 12, weight: .medium))
                    .foregroundStyle(Color.appTextMedium)
            } else {
                Text("Không nhấn — 0/5 điểm")
                    .font(.appSans(size: 12, weight: .medium))
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

    @MainActor final class Coordinator: NSObject {
        let parent: HazardVideoPlayer
        weak var player: AVPlayer?
        var endObserver: NSObjectProtocol?
        var errorObserver: NSObjectProtocol?
        var timeObserver: Any?
        var statusObservation: NSKeyValueObservation?
        var bufferObservation: NSKeyValueObservation?
        var bufferTimeoutTask: Task<Void, Never>?

        /// How long the player may stall (no playable buffer) before we give up
        /// and show the retry overlay instead of spinning indefinitely.
        private let bufferTimeoutInterval: TimeInterval = 20

        init(parent: HazardVideoPlayer) {
            self.parent = parent
        }

        /// Arm a timer that flips to the error state if playback is still
        /// stalled after `bufferTimeoutInterval`. Re-armed whenever buffering
        /// resumes, cancelled once playback can keep up. Runs on the main actor.
        func scheduleBufferTimeout() {
            bufferTimeoutTask?.cancel()
            let interval = bufferTimeoutInterval
            bufferTimeoutTask = Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled, let self else { return }
                if self.player?.currentItem?.isPlaybackLikelyToKeepUp != true {
                    self.parent.state.hasError = true
                }
            }
        }

        func cancelBufferTimeout() {
            bufferTimeoutTask?.cancel()
            bufferTimeoutTask = nil
        }

        func setup(player: AVPlayer) {
            cleanup(player: self.player)
            self.player = player

            // Notification + periodic observers are delivered on `.main`, so it
            // is safe to assume main-actor isolation synchronously.
            endObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    self.parent.state.isFinished = true
                    self.cancelBufferTimeout()
                }
            }

            errorObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemFailedToPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    self.parent.state.hasError = true
                    self.cancelBufferTimeout()
                }
            }

            let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                MainActor.assumeIsolated {
                    guard let self else { return }
                    self.parent.state.currentTime = time.seconds
                    if let duration = self.player?.currentItem?.duration.seconds, duration.isFinite {
                        self.parent.state.duration = duration
                    }
                }
            }

            // KVO observations can fire on an arbitrary thread, so hop to the
            // main actor explicitly. `self` is a main-actor type (Sendable), so
            // no unsafe escape hatch is needed.
            bufferObservation = player.currentItem?.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] item, _ in
                let isKeepUp = item.isPlaybackLikelyToKeepUp
                Task { @MainActor in
                    guard let self else { return }
                    self.parent.state.isBuffering = !isKeepUp
                    if isKeepUp {
                        self.cancelBufferTimeout()
                    } else {
                        self.scheduleBufferTimeout()
                    }
                }
            }

            statusObservation = player.currentItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
                guard item.status == .failed else { return }
                Task { @MainActor in
                    guard let self else { return }
                    self.parent.state.hasError = true
                    self.cancelBufferTimeout()
                }
            }

            // Cover the initial-load case: if the very first buffer never
            // becomes ready (offline / dead URL), surface the retry overlay.
            scheduleBufferTimeout()
        }

        func cleanup(player: AVPlayer?) {
            cancelBufferTimeout()
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

        // Isolated to the main actor so the non-Sendable observer tokens can be
        // torn down safely (the representable lifecycle also calls `cleanup`).
        isolated deinit {
            bufferTimeoutTask?.cancel()
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
        vc.player = nil
    }
}
