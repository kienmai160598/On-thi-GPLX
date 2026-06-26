import SwiftUI

// MARK: - HazardResultView

struct HazardResultView: View {
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(ThemeStore.self) private var themeStore
    @Environment(\.popToRoot) private var popToRoot
    @Environment(\.openExam) private var openExam

    let situations: [HazardSituation]
    let tapTimes: [Int: Double?]
    let result: HazardResult
    var isFromHistory: Bool = false
    var retryMode: HazardTestView.Mode? = nil

    // MARK: - Derived values

    private var lastSituation: HazardSituation? {
        situations.last
    }

    private var lastTapTime: Double? {
        guard let idx = situations.indices.last else { return nil }
        return tapTimes[idx] ?? nil
    }

    private var heroLabel: String {
        result.passed ? "Tốt lắm!" : "Cố lên!"
    }

    private var heroSubtitle: String {
        "Tình huống \(situations.count)/\(result.situationCount)"
    }

    // MARK: - Score details card

    private var hazardScoreDetails: some View {
        VStack(spacing: 0) {
            ScoreRow(label: "Tổng điểm", value: "\(result.totalScore)/\(result.maxScore)", color: themeStore.primaryColor)
            Divider().padding(.horizontal, 16)

            let avg = result.situationCount > 0
                ? String(format: "%.1f", Double(result.totalScore) / Double(result.situationCount))
                : "0"
            ScoreRow(label: "Điểm trung bình", value: avg, color: Color.appTextMedium)
            Divider().padding(.horizontal, 16)

            let goodThreshold = AppConstants.Hazard.maxScorePerSituation * 3 / 5
            let goodCount = result.details.filter { $0.score >= goodThreshold }.count
            ScoreRow(label: "Đạt điểm tốt (\u{2265} \(goodThreshold))", value: "\(goodCount)", color: Color.appSuccess)
            Divider().padding(.horizontal, 16)

            let missedCount = result.details.filter { $0.score == 0 }.count
            ScoreRow(label: "Không đạt điểm", value: "\(missedCount)", color: missedCount > 0 ? Color.appError : Color.appSuccess)
            Divider().padding(.horizontal, 16)

            ScoreRow(
                label: "Yêu cầu đạt",
                value: "\u{2265} \(AppConstants.Hazard.passScore)/\(result.maxScore)",
                color: Color.appTextMedium
            )
        }
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Summary Card (header + quality pill + 3 stats, design p1cOS)

    private var summaryCard: some View {
        let quality = HistoryQuality.hazard(result.scorePercentage)
        let avgReflex = result.situationCount > 0
            ? Int(round(Double(result.totalScore) / Double(result.situationCount)))
            : 0
        let detected = result.details.filter { $0.score > 0 }.count
        return VStack(spacing: 14) {
            HStack(spacing: 10) {
                IconBox(
                    icon: result.passed ? "party.popper.fill" : "arrow.clockwise",
                    color: quality.color,
                    size: 36, cornerRadius: 10, iconFontSize: 16, iconWeight: .semibold
                )
                Text(heroLabel)
                    .font(.appSans(size: 18, weight: .heavy))
                    .foregroundStyle(Color.appTextDark)
                    .kerning(-0.3)
                Spacer(minLength: 8)
                Text(quality.label.uppercased())
                    .font(.appSans(size: 12, weight: .heavy))
                    .foregroundStyle(.white)
                    .kerning(1)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 12)
                    .background(quality.color, in: Capsule())
            }

            Rectangle()
                .fill(Color.appDivider.opacity(0.6))
                .frame(height: 1)

            HStack(spacing: 0) {
                StatItem(value: "\(avgReflex)/\(AppConstants.Hazard.maxScorePerSituation)", label: "Điểm phản xạ", valueColor: quality.color, valueFontSize: 22)
                StatItem(value: "\(detected)/\(result.situationCount)", label: "Tình huống", valueFontSize: 22)
                StatItem(value: "\(result.totalScore)/\(result.maxScore)", label: "Điểm phiên", valueFontSize: 22)
            }
        }
        .padding(20)
        .glassCard(cornerRadius: 22)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Design-spec mint-to-neutral gradient background (adaptive for dark mode)
            LinearGradient(
                stops: [
                    .init(color: Color.adaptive(light: 0xDFF1E6, dark: 0x1A2E1F), location: 0.0),
                    .init(color: Color.adaptive(light: 0xEBECEF, dark: 0x1C1C20), location: 0.55),
                    .init(color: Color.adaptive(light: 0xE6E4DF, dark: 0x1A1916), location: 1.0),
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    Spacer().frame(height: 4)

                    // C1: Score hero group
                    VStack(spacing: 12) {
                        // Summary card (header + quality pill + 3 stats) · design p1cOS
                        summaryCard

                        // Recent situation card (only if we have a last situation)
                        if let lastSituation {
                            RecentSituationCard(
                                index: situations.count,
                                totalCount: result.situationCount,
                                situation: lastSituation
                            )
                        }

                        // C1d: Timeline reaction card (only if we have tap data for last situation)
                        if let lastSituation {
                            HazardTimelineCard(
                                situation: lastSituation,
                                tapTime: lastTapTime
                            )
                        }
                    }
                    .padding(.horizontal, metrics.contentPadding)

                    // Score distribution chart
                    ScoreDistributionChart(details: result.details)
                        .padding(.horizontal, metrics.contentPadding)

                    // Score breakdown (the C1a hero card above already covers all
                    // size classes, so no separate iPad hero here).
                    hazardScoreDetails
                        .padding(.horizontal, metrics.contentPadding)

                    // Review section
                    SectionTitle(title: "Chi tiết tình huống")
                        .padding(.horizontal, metrics.contentPadding)

                    AdaptiveGrid {
                        ForEach(Array(situations.enumerated()), id: \.element.id) { index, situation in
                            let detail = index < result.details.count ? result.details[index] : nil
                            let score = detail?.score ?? 0
                            let tapTime = tapTimes[index] ?? nil

                            HazardReviewRow(
                                index: index,
                                situation: situation,
                                score: score,
                                tapTime: tapTime
                            )
                        }
                    }
                    .padding(.horizontal, metrics.contentPadding)
                }
                .padding(.bottom, 32)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !isFromHistory {
                VStack(spacing: 12) {
                    Button {
                        openExam(.hazardTest(mode: retryMode ?? .practice))
                    } label: {
                        AppButton(icon: "arrow.counterclockwise", label: "Làm lại", style: .secondary, height: 52)
                    }

                    Button { popToRoot() } label: {
                        AppButton(icon: "checkmark", label: "Hoàn thành", height: 52)
                    }
                }
                .padding(.horizontal, metrics.contentPadding)
                .padding(.bottom, 4)
            }
        }
        .screenHeader(isFromHistory ? "Chi tiết tình huống" : "Kết quả tình huống", hideBackButton: !isFromHistory)
        .onAppear {
            // The result is a portrait screen; the hazard player forced landscape,
            // so rotate back when leaving the video.
            OrientationManager.shared.lock()
            if !isFromHistory {
                ReviewHelper.requestIfFirstPass(passed: result.passed)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareResultButton(text: shareText)
            }
        }
    }

    private var shareText: String {
        let status = result.passed ? "ĐẠT ✅" : "CHƯA ĐẠT"
        let detected = result.details.filter { $0.score > 0 }.count
        return """
        Kết quả tình huống (mô phỏng) GPLX 2026: \(status)
        \(result.totalScore)/\(result.maxScore) điểm · \(detected)/\(result.situationCount) tình huống
        — Ôn Thi Lái Xe 2026
        """
    }
}

// MARK: - Recent Situation Card (Design C1c)

private struct RecentSituationCard: View {
    let index: Int
    let totalCount: Int
    let situation: HazardSituation

    var body: some View {
        VStack(spacing: 8) {
            // Head
            HStack {
                Text("Tình huống vừa xử lý")
                    .font(.appSans(size: 14, weight: .bold))
                    .foregroundStyle(Color.appTextDark)

                Spacer()

                HStack(spacing: 3) {
                    Text("Xem lại")
                        .font(.appSans(size: 12, weight: .bold))
                        .foregroundStyle(Color(hex: 0x7A7166))
                    Image(systemName: "chevron.right")
                        .font(.appSans(size: 12, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x7A7166))
                }
            }
            .padding(.bottom, 2)

            // Divider
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 1)

            // Situation row
            HStack(alignment: .center, spacing: 10) {
                // Number badge (amber)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: 0xFFC233))
                        .frame(width: 30, height: 30)
                    Text("\(index)")
                        .font(.appSans(size: 15, weight: .bold))
                        .foregroundStyle(Color(hex: 0x7A4A00))
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(situation.title)
                        .font(.appSans(size: 14, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                        .lineLimit(1)
                    Text("\(situation.chapterName) · Tình huống \(index)/\(totalCount)")
                        .font(.appSans(size: 11.5, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x7A7166))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 2)
        }
        .padding(12)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

// MARK: - Timeline Reaction Card (Design C1d)

private struct HazardTimelineCard: View {
    let situation: HazardSituation
    let tapTime: Double?

    /// Total bar duration: window end + a small buffer
    private var totalDuration: Double {
        situation.perfectEnd + 3.0
    }

    /// Fraction of timeline where "early" ends (= perfectStart)
    private var earlyEnd: Double {
        situation.perfectStart / totalDuration
    }

    /// Fraction where perfect zone ends
    private var perfectZoneEnd: Double {
        // score≥4 requires fraction <= 0.3 of the scoring window
        let perfectBoundary = situation.perfectStart + 0.3 * (situation.perfectEnd - situation.perfectStart)
        return perfectBoundary / totalDuration
    }

    /// Fraction where good zone ends (= perfectEnd)
    private var goodZoneEnd: Double {
        situation.perfectEnd / totalDuration
    }

    /// Tap position fraction (clamped 0–1)
    private var tapFraction: Double? {
        guard let t = tapTime else { return nil }
        return min(max(t / totalDuration, 0), 1)
    }

    private var tapLabel: String {
        guard let t = tapTime else { return "Không bấm" }
        return String(format: "Giây %.1f", t)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Head
            HStack {
                Text("THỜI ĐIỂM BẠN BẤM")
                    .font(.appSans(size: 10, weight: .bold))
                    .foregroundStyle(Color(hex: 0x7A7166))
                    .tracking(1.2)

                Spacer()

                Text(tapLabel)
                    .font(.appSans(size: 15, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
            }

            // Timeline bar with tap marker
            ReactionTimingBar(
                earlyEnd: earlyEnd,
                perfectEnd: perfectZoneEnd,
                goodEnd: goodZoneEnd,
                tapFraction: tapFraction
            )

            // Legend
            HStack(spacing: 14) {
                LegendDot(color: Color(hex: 0xC9C4BC), label: "Sớm")
                LegendDot(color: Color.appSuccess, label: "Hoàn hảo")
                LegendDot(color: Color(hex: 0xFFD60A), label: "Tốt")
                LegendDot(color: Color.appError, label: "Bỏ lỡ")
                Spacer()
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Reaction Timing Bar (color-zone bar + marker)

private struct ReactionTimingBar: View {
    /// Fractions (0–1) defining colour zone boundaries
    let earlyEnd: Double      // early zone occupies [0 … earlyEnd]
    let perfectEnd: Double    // perfect zone occupies [earlyEnd … perfectEnd]
    let goodEnd: Double       // good zone occupies [perfectEnd … goodEnd]; miss = rest
    let tapFraction: Double?  // where marker sits; nil = no tap

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let barH: CGFloat = 14
            let markerH: CGFloat = 26
            let markerW: CGFloat = 4

            ZStack(alignment: .leading) {
                // Early (Sớm) — left-rounded
                UnevenRoundedRectangle(
                    topLeadingRadius: 7, bottomLeadingRadius: 7,
                    bottomTrailingRadius: 0, topTrailingRadius: 0
                )
                .fill(Color(hex: 0xC9C4BC))
                .frame(width: w * earlyEnd, height: barH)

                // Perfect (Hoàn hảo)
                Rectangle()
                    .fill(Color.appSuccess)
                    .frame(width: w * (perfectEnd - earlyEnd), height: barH)
                    .offset(x: w * earlyEnd)

                // Good (Tốt — left half)
                Rectangle()
                    .fill(Color(hex: 0xFFD60A))
                    .frame(width: w * (goodEnd - perfectEnd), height: barH)
                    .offset(x: w * perfectEnd)

                // Miss (Bỏ lỡ) — right-rounded
                UnevenRoundedRectangle(
                    topLeadingRadius: 0, bottomLeadingRadius: 0,
                    bottomTrailingRadius: 7, topTrailingRadius: 7
                )
                .fill(Color.appError)
                .frame(width: w * (1.0 - goodEnd), height: barH)
                .offset(x: w * goodEnd)

                // Tap marker
                if let frac = tapFraction {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: 0x0F0F12))
                        .frame(width: markerW, height: markerH)
                        .offset(x: w * frac - markerW / 2, y: -(markerH - barH) / 2)
                }
            }
        }
        .frame(height: 26) // accommodate marker overflow
    }
}

// MARK: - Legend Dot

private struct LegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.appSans(size: 11, weight: .semibold))
                .foregroundStyle(Color(hex: 0x7A7166))
        }
    }
}

// MARK: - Score Distribution Chart

private struct ScoreDistributionChart: View {
    @Environment(ThemeStore.self) private var themeStore
    let details: [HazardResult.SituationDetail]
    @State private var animate = false

    private var distribution: [Int] {
        var counts = [Int](repeating: 0, count: 6)
        for d in details {
            let s = min(max(d.score, 0), 5)
            counts[s] += 1
        }
        return counts
    }

    private func barColor(_ score: Int) -> Color {
        switch score {
        case 5: return .appSuccess
        case 3...4: return themeStore.primaryColor
        case 1...2: return .appWarning
        default: return .appError
        }
    }

    var body: some View {
        let dist = distribution
        let maxCount = max(dist.max() ?? 1, 1)

        VStack(alignment: .leading, spacing: 8) {
            Text("Phân bố điểm")
                .font(.appSans(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextDark)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<6, id: \.self) { score in
                    VStack(spacing: 4) {
                        if dist[score] > 0 {
                            Text("\(dist[score])")
                                .font(.appSans(size: 12))
                                .foregroundStyle(barColor(score))
                        }

                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor(score))
                            .frame(height: animate ? max(CGFloat(dist[score]) / CGFloat(maxCount) * 60, dist[score] > 0 ? 4 : 2) : 2)
                            .animation(
                                .spring(duration: 0.5, bounce: 0.2).delay(Double(score) * 0.06),
                                value: animate
                            )

                        Text("\(score)")
                            .font(.appSans(size: 12, weight: .medium))
                            .foregroundStyle(Color.appTextMedium)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 108)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(200))
                animate = true
            }
        }
    }
}

// MARK: - Review Row (Expandable)

private struct HazardReviewRow: View {
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(ThemeStore.self) private var themeStore
    let index: Int
    let situation: HazardSituation
    let score: Int
    let tapTime: Double?

    @State private var isExpanded = false

    private var statusColor: Color {
        if score >= 4 { return Color.appSuccess }
        if score >= 2 { return Color.appWarning }
        return Color.appError
    }

    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 0.25)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: score > 0 ? "checkmark" : "xmark")
                        .font(.appSans(size: 12, weight: .medium))
                        .foregroundStyle(statusColor)
                        .frame(width: 28, height: 28)
                        .background(statusColor.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("TH \(situation.id)")
                                .font(.appSans(size: 13, weight: .medium))
                                .foregroundStyle(Color.appTextMedium)

                            Text(situation.chapterName)
                                .font(.appSans(size: 12))
                                .foregroundStyle(Color.appTextLight)
                        }

                        if let tapTime {
                            Text(String(format: "Nhấn tại %.1fs", tapTime))
                                .font(.appSans(size: 12))
                                .foregroundStyle(Color.appTextMedium)
                        } else {
                            Text("Không nhấn")
                                .font(.appSans(size: 12))
                                .foregroundStyle(Color.appError)
                        }
                    }

                    Spacer(minLength: 4)

                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { i in
                            Circle()
                                .fill(i < score ? themeStore.primaryColor : Color.appDivider)
                                .frame(width: metrics.isIPadLayout ? 10 : 8, height: metrics.isIPadLayout ? 10 : 8)
                        }
                    }

                    Text("\(score)")
                        .font(.appSans(size: 15, weight: .bold))
                        .foregroundStyle(statusColor)
                        .frame(width: 20)

                    Image(systemName: "chevron.right")
                        .font(.appSans(size: 12, weight: .medium))
                        .foregroundStyle(Color.appTextLight)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))

                    if metrics.isIPadLayout {
                        Text(isExpanded ? "Thu gọn" : "Xem chi tiết")
                            .font(.appSans(size: 13, weight: .medium))
                            .foregroundStyle(Color.appTextLight)
                    }
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        TimingBar(
                            duration: situation.perfectEnd + 3,
                            windowStart: situation.perfectStart,
                            windowEnd: situation.perfectEnd,
                            tapTime: tapTime
                        )

                        HStack(spacing: 16) {
                            TimingDetail(label: "Vùng điểm", value: String(format: "%.1f – %.1fs", situation.perfectStart, situation.perfectEnd))
                            if let tapTime {
                                TimingDetail(label: "Bạn nhấn", value: String(format: "%.1fs", tapTime))
                            }
                        }

                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.appSans(size: 12))
                                .foregroundStyle(Color.appWarning)
                                .padding(.top, 1)
                            Text(situation.tip)
                                .font(.appSans(size: 12))
                                .foregroundStyle(Color.appTextMedium)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 2)
                    }
                    .padding(.leading, 40)
                    .padding(.top, 10)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Timing Bar Visualization (in-row expanded detail)

private struct TimingBar: View {
    @Environment(ThemeStore.self) private var themeStore
    let duration: Double
    let windowStart: Double
    let windowEnd: Double
    let tapTime: Double?

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let startFrac = windowStart / duration
            let endFrac = windowEnd / duration

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.appDivider)
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.appSuccess.opacity(0.3))
                    .frame(width: width * (endFrac - startFrac), height: 6)
                    .offset(x: width * startFrac)

                if let tapTime {
                    let tapFrac = tapTime / duration
                    Circle()
                        .fill(themeStore.primaryColor)
                        .frame(width: 10, height: 10)
                        .offset(x: width * tapFrac - 5)
                }
            }
        }
        .frame(height: 10)
    }
}

private struct TimingDetail: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.appSans(size: 12))
                .foregroundStyle(Color.appTextLight)
            Text(value)
                .font(.appSans(size: 13, weight: .medium))
                .foregroundStyle(Color.appTextMedium)
        }
    }
}
