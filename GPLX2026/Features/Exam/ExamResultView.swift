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

                    // ── Summary card (header + 3 stats) ───────────────────
                    summaryCard

                    // ── Chi tiết ──────────────────────────────────────────
                    chiTietSection

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

    // MARK: - Summary Card (header + 3 stats, design VVIdQ)

    private var summaryCard: some View {
        let pct = Int(round(examResult.accuracy * 100))
        let passDiemLiet = wrongDiemLietCount == 0
        return VStack(spacing: 14) {
            HStack(spacing: 10) {
                IconBox(
                    icon: isPassed ? "hand.thumbsup.fill" : "arrow.clockwise",
                    color: isPassed ? .appSuccess : .appError,
                    size: 36, cornerRadius: 10, iconFontSize: 16, iconWeight: .semibold
                )
                Text(isPassed ? "Chúc mừng!" : "Cố lên!")
                    .font(.appSans(size: 18, weight: .heavy))
                    .foregroundStyle(Color.appTextDark)
                    .kerning(-0.3)
                Spacer(minLength: 8)
                Text(isPassed ? "ĐẠT" : "TRƯỢT")
                    .font(.appSans(size: 12, weight: .heavy))
                    .foregroundStyle(.white)
                    .kerning(1)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 12)
                    .background(isPassed ? Color.appSuccess : Color.appError, in: Capsule())
            }

            Rectangle()
                .fill(Color.appDivider.opacity(0.6))
                .frame(height: 1)

            HStack(spacing: 0) {
                StatItem(value: "\(pct)%", label: "Chính xác", valueColor: isPassed ? .appSuccess : .appError, valueFontSize: 22)
                StatItem(value: "\(correctCount)/\(examResult.totalQuestions)", label: "Câu đúng", valueFontSize: 22)
                StatItem(value: passDiemLiet ? "Đạt" : "Trượt", label: "Điểm liệt", valueColor: passDiemLiet ? .appSuccess : .appError, valueFontSize: 22)
            }
        }
        .padding(20)
        .glassCard(cornerRadius: 22)
    }

    // MARK: - Chi tiết (detail list, design VVIdQ)

    private var chiTietSection: some View {
        let pct = Int(round(examResult.accuracy * 100))
        let wrong = max(0, examResult.totalQuestions - examResult.score)
        let passDiemLiet = wrongDiemLietCount == 0
        let withinTime = timeUsedSeconds <= LicenseType.current.totalTimeSeconds
        return VStack(alignment: .leading, spacing: 10) {
            SectionTitle(title: "Chi tiết")

            HistoryItemRow(
                icon: "checkmark.circle.fill", iconColor: .appSuccess,
                title: "Câu đúng", meta: "Trên tổng số \(examResult.totalQuestions) câu",
                value: "\(correctCount)", valueColor: .appSuccess, status: "\(pct)%"
            )
            let cauSaiRow = HistoryItemRow(
                icon: "xmark.circle.fill", iconColor: .appError,
                title: "Câu sai", meta: wrong > 0 ? "Nhấn để xem lại các câu này" : "Không có câu sai",
                value: "\(wrong)", valueColor: .appError, status: "\(max(0, 100 - pct))%"
            )
            if wrong > 0 {
                NavigationLink {
                    WrongAnswerReviewView(questions: questions, answers: answers)
                } label: {
                    cauSaiRow
                }
                .buttonStyle(.plain)
            } else {
                cauSaiRow
            }
            HistoryItemRow(
                icon: passDiemLiet ? "checkmark.shield.fill" : "exclamationmark.shield.fill",
                iconColor: passDiemLiet ? .appSuccess : .appError,
                title: "Điểm liệt",
                meta: passDiemLiet ? "Không sai câu điểm liệt" : "\(wrongDiemLietCount) câu điểm liệt bị sai",
                value: passDiemLiet ? "Đạt" : "Trượt", valueColor: passDiemLiet ? .appSuccess : .appError,
                status: passDiemLiet ? "An toàn" : "Nguy hiểm"
            )
            HistoryItemRow(
                icon: "timer", iconColor: .appTextMedium,
                title: "Thời gian làm bài", meta: "Giới hạn \(formatTime(LicenseType.current.totalTimeSeconds))",
                value: formatTime(timeUsedSeconds), valueColor: .appTextDark,
                status: withinTime ? "Còn dư" : "Hết giờ"
            )
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
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
