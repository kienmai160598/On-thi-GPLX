import SwiftUI

// MARK: - ExamResultView

struct ExamResultView: View {
    @Environment(LayoutMetrics.self) private var metrics
    @Environment(\.popToRoot) private var popToRoot
    @Environment(\.openExam) private var openExam

    let questions: [Question]
    let answers: [Int: Int]
    let timeUsedSeconds: Int
    let examResult: ExamResult
    var isFromHistory: Bool = false

    private var correctCount: Int { examResult.score }
    private var wrongDiemLietCount: Int { examResult.wrongDiemLiet }
    private var isPassed: Bool { examResult.passed }

    // MARK: - Gradient background (pass = green-tinted, fail = red-tinted)

    private var backgroundGradient: LinearGradient {
        let stops: [Gradient.Stop] = isPassed
            ? [
                .init(color: Color.adaptive(light: 0xDFF1E6, dark: 0x0E1F13), location: 0.00),
                .init(color: Color.adaptive(light: 0xEBECEF, dark: 0x1A1A1E), location: 0.55),
                .init(color: Color.adaptive(light: 0xE6E4DF, dark: 0x16150F), location: 1.00)
              ]
            : [
                .init(color: Color.adaptive(light: 0xF8E6E6, dark: 0x1F0E0E), location: 0.00),
                .init(color: Color.adaptive(light: 0xEBECEF, dark: 0x1A1A1E), location: 0.55),
                .init(color: Color.adaptive(light: 0xE6E4DF, dark: 0x16150F), location: 1.00)
              ]
        return LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom)
    }

    // MARK: - State

    @State private var statsExpanded = true
    @State private var topicsExpanded = false
    @State private var topicStats: [ExamTopicStat] = []

    private func computeTopicStats() -> [ExamTopicStat] {
        var buckets: [String: (correct: Int, total: Int, name: String)] = [:]
        for (index, question) in questions.enumerated() {
            let key = Topic.keyForTopicId(question.topic)
            let topicName = Topic.all.first(where: { $0.topicIds.contains(question.topic) })?.shortName ?? "Khác"
            let selectedId = answers[index]
            let isCorrect = selectedId != nil && question.answers.contains(where: { $0.id == selectedId && $0.correct })
            var bucket = buckets[key] ?? (correct: 0, total: 0, name: topicName)
            bucket.total += 1
            if isCorrect { bucket.correct += 1 }
            buckets[key] = bucket
        }
        return buckets.map { key, val in
            ExamTopicStat(id: key, name: val.name, correct: val.correct, total: val.total)
        }.sorted { $0.fraction < $1.fraction }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // ── Meta row ──────────────────────────────────────────
                    metaRow

                    // ── Inline title ──────────────────────────────────────
                    Text("Kết quả thi thử")
                        .font(.appSans(size: 22, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)
                        .kerning(-0.5)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // ── Hero card ─────────────────────────────────────────
                    resultHeroCard

                    // ── Tổng quan ─────────────────────────────────────────
                    statsCard

                    // ── Theo chủ đề ───────────────────────────────────────
                    topicsCard

                    // ── Answer review ─────────────────────────────────────
                    SectionTitle(title: "Xem lại đáp án")
                        .id("answerReview")

                    AdaptiveGrid {
                        ForEach(Array(questions.enumerated()), id: \.offset) { index, question in
                            let selectedId = answers[index]
                            let isCorrect = selectedId != nil && question.answers.contains(where: { $0.id == selectedId && $0.correct })
                            QuestionReviewRow(
                                question: question,
                                status: selectedId == nil ? .unanswered : isCorrect ? .correct : .wrong,
                                selectedAnswerId: selectedId
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, metrics.contentPadding)
                .padding(.top, 12)
                .padding(.bottom, isFromHistory ? 32 : 120)
            }
            .safeAreaInset(edge: .bottom) {
                if !isFromHistory {
                    actionButtons
                }
            }
        }
        .screenHeader(isFromHistory ? "Chi tiết bài thi" : "Kết quả thi", hideBackButton: !isFromHistory)
        .onAppear {
            topicStats = computeTopicStats()
            if !isFromHistory {
                ReviewHelper.requestIfFirstPass(passed: examResult.passed)
            }
        }
        .toolbar {
            if !isFromHistory {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { popToRoot() } label: {
                        Image(systemName: "checkmark")
                            .font(.appSans(size: 15, weight: .semibold))
                    }
                    .accessibilityLabel("Hoàn thành")
                }
            }
        }
    }

    // MARK: - Meta Row helpers

    private static let metaDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "vi_VN")
        df.dateFormat = "d 'thg' M"
        return df
    }()

    private static let metaTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()

    private var metaDateString: String {
        Self.metaDateFormatter.string(from: examResult.date)
    }

    private var metaTimeString: String {
        Self.metaTimeFormatter.string(from: examResult.date)
    }

    private var metaRow: some View {
        HStack(spacing: 8) {
            Text(metaDateString)
                .font(.appSans(size: 11.5, weight: .semibold))
                .foregroundStyle(Color.appTextMedium)

            Circle()
                .fill(Color.appTextDark.opacity(0.15))
                .frame(width: 3, height: 3)

            Text(metaTimeString)
                .font(.appSans(size: 11.5, weight: .semibold))
                .foregroundStyle(Color.appTextMedium)

            if let setId = examResult.examSetId {
                Circle()
                    .fill(Color.appTextDark.opacity(0.15))
                    .frame(width: 3, height: 3)

                Text("Đề số \(String(format: "%02d", setId))")
                    .font(.appSans(size: 11.5, weight: .semibold))
                    .foregroundStyle(Color.appTextMedium)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Result Hero Card (horizontal layout per design VVIdQ)

    private var resultHeroCard: some View {
        // Use the stored result's own totals — the reconstructed `questions`
        // array can be shorter than the exam if the question bank changed.
        let fraction = examResult.accuracy
        let pct = Int(round(fraction * 100))

        return HStack(alignment: .center, spacing: 14) {
            // Left column: badge + headings
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: isPassed ? "checkmark" : "xmark")
                        .font(.appSans(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                    Text(isPassed ? "ĐẠT" : "TRƯỢT")
                        .font(.appSans(size: 12, weight: .heavy))
                        .foregroundStyle(.white)
                        .kerning(1)
                }
                .padding(.vertical, 5)
                .padding(.leading, 10)
                .padding(.trailing, 12)
                .background(isPassed ? Color.appSuccess : Color.appError)
                .clipShape(Capsule())

                VStack(alignment: .leading, spacing: 2) {
                    Text(isPassed ? "Chúc mừng!" : "Cố lên!")
                        .font(.appSans(size: 24, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)
                        .kerning(-0.5)
                    Text(isPassed ? "Bạn đã vượt qua bài thi thử" : "Hãy ôn tập thêm và thử lại nhé")
                        .font(.appSans(size: 12.5, weight: .medium))
                        .foregroundStyle(isPassed ? Color(hex: 0x5E7A66) : Color.appTextMedium)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right column: percentage + score fraction
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(pct)%")
                    .font(.appSans(size: 48, weight: .bold))
                    .foregroundStyle(isPassed ? Color.appSuccess : Color.appError)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("\(correctCount)/\(questions.count) câu đúng")
                    .font(.appSans(size: 12, weight: .medium))
                    .foregroundStyle(Color.appTextMedium)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(isPassed ? Color(hex: 0xE7F5EC) : Color(hex: 0xFCE4E2))
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    // MARK: - Stats Card (Tổng quan)

    private var statsCard: some View {
        let minutes = timeUsedSeconds / 60
        let seconds = timeUsedSeconds % 60
        let timeStr = String(format: "%02d:%02d", minutes, seconds)

        return VStack(spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    statsExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Tổng quan")
                        .font(.appSans(size: 14, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)
                        .kerning(-0.2)
                    Spacer()
                    Image(systemName: statsExpanded ? "chevron.up" : "chevron.down")
                        .font(.appSans(size: 14, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(statsExpanded ? "Đang mở" : "Đã đóng")

            if statsExpanded {
                VStack(spacing: 10) {
                    ExamStatIconRow(
                        iconName: "checkmark.circle.fill",
                        iconBgColor: Color(hex: 0xE7F5EC),
                        iconColor: Color(hex: 0x1F7A3D),
                        label: "Câu đúng",
                        value: "\(correctCount)",
                        valueColor: Color.appTextDark
                    )
                    ExamStatIconRow(
                        iconName: "xmark.circle.fill",
                        iconBgColor: Color(hex: 0xFCE4E2),
                        iconColor: Color(hex: 0xB3261E),
                        label: "Câu sai",
                        value: "\(max(0, examResult.totalQuestions - examResult.score))",
                        valueColor: Color.appTextDark
                    )
                    ExamStatIconRow(
                        iconName: wrongDiemLietCount == 0 ? "checkmark.shield.fill" : "exclamationmark.shield.fill",
                        iconBgColor: wrongDiemLietCount == 0 ? Color(hex: 0xE7F5EC) : Color(hex: 0xFCE4E2),
                        iconColor: wrongDiemLietCount == 0 ? Color(hex: 0x1F7A3D) : Color(hex: 0xB3261E),
                        label: "Điểm liệt",
                        value: wrongDiemLietCount == 0 ? "Đạt" : "Không đạt",
                        valueColor: wrongDiemLietCount == 0 ? Color(hex: 0x1F5A2A) : Color.appError
                    )
                    ExamStatIconRow(
                        iconName: "timer",
                        iconBgColor: Color(hex: 0xF0EEE9),
                        iconColor: Color(hex: 0x6B6B6B),
                        label: "Thời gian",
                        value: timeStr,
                        valueColor: Color.appTextDark
                    )
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.appDivider.opacity(0.5), lineWidth: 1)
        )
    }

    // MARK: - Topics Card (Theo chủ đề)

    private var topicsCard: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    topicsExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Theo chủ đề")
                        .font(.appSans(size: 14, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)
                        .kerning(-0.2)
                    Spacer()
                    Image(systemName: topicsExpanded ? "chevron.up" : "chevron.down")
                        .font(.appSans(size: 14, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(topicsExpanded ? "Đang mở" : "Đã đóng")

            if topicsExpanded {
                VStack(spacing: 10) {
                    ForEach(topicStats) { stat in
                        ExamTopicStatRow(stat: stat)
                    }
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.appDivider.opacity(0.5), lineWidth: 1)
        )
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Xem lại bài (secondary) — open the per-question review navigator.
            NavigationLink {
                ReviewQuestionView(questions: questions, answers: answers)
            } label: {
                AppButton(label: "Xem lại bài", style: .secondary, height: 50)
            }

            // Thi lại (primary)
            Button {
                openExam(.mockExam(examSetId: examResult.examSetId))
            } label: {
                AppButton(icon: "play.circle", label: "Thi lại", style: .primary, height: 50)
            }

            // Về trang chủ (ghost link)
            Button { popToRoot() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "house")
                        .font(.appSans(size: 14, weight: .medium))
                    Text("Về trang chủ")
                        .font(.appSans(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color.appTextMedium)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, metrics.contentPadding)
        .padding(.top, 6)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
}

// MARK: - ExamTopicStat (file-private model)

private struct ExamTopicStat: Identifiable {
    let id: String
    let name: String
    let correct: Int
    let total: Int
    var fraction: Double { total > 0 ? Double(correct) / Double(total) : 0 }
}

// MARK: - ExamStatIconRow (file-private subview)

private struct ExamStatIconRow: View {
    let iconName: String
    let iconBgColor: Color
    let iconColor: Color
    let label: String
    let value: String
    let valueColor: Color

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconBgColor)
                    .frame(width: 32, height: 32)
                Image(systemName: iconName)
                    .font(.appSans(size: 15, weight: .medium))
                    .foregroundStyle(iconColor)
            }
            Text(label)
                .font(.appSans(size: 13.5, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(value)
                .font(.appSans(size: 18, weight: .bold))
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.cardBg.opacity(0.5))
        )
    }
}

// MARK: - ExamTopicStatRow (file-private subview)

private struct ExamTopicStatRow: View {

    let stat: ExamTopicStat

    private struct RowStyle {
        let iconName: String
        let iconBgColor: Color
        let accentColor: Color
        let statusLabel: String
    }

    private var rowStyle: RowStyle {
        switch stat.fraction {
        case 1.0:
            return RowStyle(
                iconName: "checkmark",
                iconBgColor: Color(hex: 0xD9F0DA),
                accentColor: Color(hex: 0x1F5A2A),
                statusLabel: "Vững vàng"
            )
        case 0.8...:
            return RowStyle(
                iconName: "checkmark",
                iconBgColor: Color(hex: 0xD9F0DA),
                accentColor: Color(hex: 0x1F5A2A),
                statusLabel: "Tốt"
            )
        case 0.6...:
            return RowStyle(
                iconName: "arrow.up.right",
                iconBgColor: Color(hex: 0xFFE9B0),
                accentColor: Color(hex: 0x7A4A00),
                statusLabel: "Khá — nên ôn thêm"
            )
        default:
            return RowStyle(
                iconName: "exclamationmark.triangle",
                iconBgColor: Color(hex: 0xFFD7CF),
                accentColor: Color(hex: 0x8A2A1F),
                statusLabel: "Cần ôn ngay"
            )
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(rowStyle.iconBgColor)
                    .frame(width: 30, height: 30)
                Image(systemName: rowStyle.iconName)
                    .font(.appSans(size: 13, weight: .semibold))
                    .foregroundStyle(rowStyle.accentColor)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(stat.name)
                    .font(.appSans(size: 13, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                Text(rowStyle.statusLabel)
                    .font(.appSans(size: 10.5, weight: .semibold))
                    .foregroundStyle(rowStyle.accentColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(stat.correct)/\(stat.total)")
                .font(.appSans(size: 16, weight: .bold))
                .foregroundStyle(rowStyle.accentColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.cardBg.opacity(0.5))
        )
    }
}
