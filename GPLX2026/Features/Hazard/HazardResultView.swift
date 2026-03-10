import SwiftUI

struct HazardResultView: View {
    @Environment(ThemeStore.self) private var themeStore
    @Environment(\.popToRoot) private var popToRoot
    @Environment(\.openExam) private var openExam

    let situations: [HazardSituation]
    let tapTimes: [Int: Double?]
    let result: HazardResult
    var isFromHistory: Bool = false
    var retryMode: HazardTestView.Mode? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 16)

                // MARK: - Hero with score ring
                HazardResultHero(result: result)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // MARK: - Score details
                VStack(spacing: 0) {
                    ScoreRow(label: "Tổng điểm", value: "\(result.totalScore)/\(result.maxScore)", color: themeStore.primaryColor)
                    Divider().padding(.horizontal, 16)

                    let avg = result.situationCount > 0
                        ? String(format: "%.1f", Double(result.totalScore) / Double(result.situationCount))
                        : "0"
                    ScoreRow(label: "Điểm trung bình", value: avg, color: Color.appTextMedium)
                    Divider().padding(.horizontal, 16)

                    let goodCount = result.details.filter { $0.score >= 3 }.count
                    ScoreRow(label: "Đạt điểm tốt (\u{2265} 3)", value: "\(goodCount)", color: Color.appSuccess)
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
                .glassCard()
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                // MARK: - Score distribution
                ScoreDistributionChart(details: result.details)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // MARK: - Review
                SectionTitle(title: "Chi tiết tình huống")
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)

                LazyVStack(spacing: 8) {
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
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

                Spacer().frame(height: 32)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !isFromHistory {
                VStack(spacing: 10) {
                    if let retryMode {
                        HStack(spacing: 10) {
                            Button {
                                openExam(.hazardTest(mode: retryMode))
                            } label: {
                                AppButton(icon: "arrow.counterclockwise", label: "Làm lại", style: .secondary, height: 48)
                            }

                            Button { popToRoot() } label: {
                                AppButton(icon: "checkmark", label: "Hoàn thành", height: 48)
                            }
                        }
                    } else {
                        Button { popToRoot() } label: {
                            AppButton(icon: "checkmark", label: "Hoàn thành", height: 48)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
        }
        .navigationBarBackButtonHidden(!isFromHistory)
        .screenHeader(isFromHistory ? "Chi tiết tình huống" : "Kết quả tình huống")
        .onAppear {
            if !isFromHistory {
                ReviewHelper.requestIfFirstPass(passed: result.passed)
            }
        }
    }
}

// MARK: - Hero with Animated Score Ring

private struct HazardResultHero: View {
    let result: HazardResult
    @State private var animateRing = false

    private var ringColor: Color {
        result.passed ? .appSuccess : .appError
    }

    var body: some View {
        VStack(spacing: 16) {
            // Score ring
            ZStack {
                Circle()
                    .stroke(Color.appDivider, lineWidth: 8)

                Circle()
                    .trim(from: 0, to: animateRing ? result.scorePercentage : 0)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 1.0, bounce: 0.15), value: animateRing)

                VStack(spacing: 2) {
                    Text("\(result.totalScore)")
                        .font(.system(size: 40, weight: .heavy).monospacedDigit())
                        .foregroundStyle(Color.appTextDark)
                        .contentTransition(.numericText())

                    Text("/\(result.maxScore) điểm")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextMedium)
                }
            }
            .frame(width: 132, height: 132)

            StatusBadge(
                text: result.passed ? "ĐẠT" : "TRƯỢT",
                color: ringColor,
                fontSize: 15
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .glassCard()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateRing = true
            }
        }
    }
}

// MARK: - Score Distribution Chart

private struct ScoreDistributionChart: View {
    @Environment(ThemeStore.self) private var themeStore
    let details: [HazardResult.SituationDetail]
    @State private var animate = false

    private var distribution: [Int] {
        var counts = [Int](repeating: 0, count: 6) // 0-5
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
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.appTextDark)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<6, id: \.self) { score in
                    VStack(spacing: 4) {
                        if dist[score] > 0 {
                            Text("\(dist[score])")
                                .font(.system(size: 11, weight: .bold).monospacedDigit())
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
                            .font(.system(size: 12, weight: .medium).monospacedDigit())
                            .foregroundStyle(Color.appTextMedium)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 90)
        }
        .padding(12)
        .glassCard()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animate = true
            }
        }
    }
}

// MARK: - Review Row (Expandable)

private struct HazardReviewRow: View {
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
                // Summary
                HStack(spacing: 12) {
                    Image(systemName: score > 0 ? "checkmark" : "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(statusColor)
                        .frame(width: 28, height: 28)
                        .background(statusColor.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("TH \(situation.id)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.appTextMedium)

                            Text(situation.chapterName)
                                .font(.system(size: 11))
                                .foregroundStyle(Color.appTextLight)
                        }

                        if let tapTime {
                            Text(String(format: "Nhấn tại %.1fs", tapTime))
                                .font(.system(size: 12))
                                .foregroundStyle(Color.appTextMedium)
                        } else {
                            Text("Không nhấn")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.appError)
                        }
                    }

                    Spacer(minLength: 4)

                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { i in
                            Circle()
                                .fill(i < score ? themeStore.primaryColor : Color.appDivider)
                                .frame(width: 8, height: 8)
                        }
                    }

                    Text("\(score)")
                        .font(.system(size: 15, weight: .bold).monospacedDigit())
                        .foregroundStyle(statusColor)
                        .frame(width: 20)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }

                // Expanded detail
                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        // Timing window visualization
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

                        // Tip
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.appWarning)
                                .padding(.top, 1)
                            Text(situation.tip)
                                .font(.system(size: 12))
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
        .glassCard()
    }
}

// MARK: - Timing Bar Visualization

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
                // Track
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.appDivider)
                    .frame(height: 6)

                // Scoring window
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.appSuccess.opacity(0.3))
                    .frame(width: width * (endFrac - startFrac), height: 6)
                    .offset(x: width * startFrac)

                // Tap marker
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
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.appTextLight)
            Text(value)
                .font(.system(size: 12, weight: .semibold).monospacedDigit())
                .foregroundStyle(Color.appTextMedium)
        }
    }
}
