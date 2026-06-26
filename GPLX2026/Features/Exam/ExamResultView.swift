import SwiftUI

// MARK: - ExamResultView (design VVIdQ)
//
// Focused result screen: a centered nav title with a Share action, a summary
// card (greeting + Đạt/Trượt pill + 3 stats), a "CHI TIẾT" detail list, and the
// action buttons. Per-question review opens from "Xem lại bài"; wrong answers
// from the "Câu sai" row — so the screen stays scannable with no inline grid.

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

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    // ── Summary card (greeting + pass pill + 3 stats) ─────
                    summaryCard

                    // ── Chi tiết (eyebrow + detail list) ──────────────────
                    Text("CHI TIẾT")
                        .font(.appSans(size: 10, weight: .heavy))
                        .tracking(1.2)
                        .foregroundStyle(Color.appTextMedium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 2)

                    chiTietList
                }
                .padding(.horizontal, metrics.contentPadding)
                .padding(.top, 8)
                .padding(.bottom, isFromHistory ? 32 : 24)
            }
            .safeAreaInset(edge: .bottom) {
                if !isFromHistory {
                    actionButtons
                }
            }
        }
        .screenHeader(
            isFromHistory ? "Chi tiết bài thi" : "Kết quả thi thử",
            titleDisplayMode: .inline,
            hideBackButton: !isFromHistory
        )
        .onAppear {
            if !isFromHistory {
                ReviewHelper.requestIfFirstPass(passed: examResult.passed)
            }
        }
        .toolbar {
            // Live result: a leading "finish" chevron — going back to the just-
            // submitted exam makes no sense, so it pops the whole flow to root.
            if !isFromHistory {
                ToolbarItem(placement: .topBarLeading) {
                    Button { popToRoot() } label: {
                        Image(systemName: "chevron.left")
                            .font(.appSans(size: 16, weight: .semibold))
                            .foregroundStyle(Color.appTextDark)
                    }
                    .accessibilityLabel("Xong")
                }
            }
        }
    }

    // MARK: - Summary Card (header + 3 stats, design VVIdQ)

    private var summaryCard: some View {
        let pct = Int(round(examResult.accuracy * 100))
        let passDiemLiet = wrongDiemLietCount == 0
        return VStack(spacing: 14) {
            HStack(spacing: 10) {
                IconBox(
                    icon: isPassed ? "party.popper.fill" : "arrow.clockwise",
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

    private var chiTietList: some View {
        let pct = Int(round(examResult.accuracy * 100))
        let wrong = max(0, examResult.totalQuestions - examResult.score)
        let passDiemLiet = wrongDiemLietCount == 0
        let withinTime = timeUsedSeconds <= LicenseType.current.totalTimeSeconds
        let diemLietTotal = questions.filter(\.isDiemLiet).count
        return VStack(alignment: .leading, spacing: 10) {
            // Câu đúng → review of correctly answered questions
            let cauDungRow = HistoryItemRow(
                icon: "checkmark.circle.fill", iconColor: .appSuccess,
                title: "Câu đúng", meta: "Trên tổng số \(examResult.totalQuestions) câu",
                value: "\(correctCount)", valueColor: .appSuccess, status: "\(pct)%",
                showsChevron: correctCount > 0, showsIcon: false
            )
            if correctCount > 0 {
                NavigationLink {
                    AnswerReviewView(questions: questions, answers: answers, mode: .correct)
                } label: { cauDungRow }
                .buttonStyle(.plain)
            } else {
                cauDungRow
            }

            // Câu sai → review of wrong / skipped questions
            let cauSaiRow = HistoryItemRow(
                icon: "xmark.circle.fill", iconColor: .appError,
                title: "Câu sai", meta: wrong > 0 ? "Nhấn để xem lại các câu này" : "Không có câu sai",
                value: "\(wrong)", valueColor: .appError, status: "\(max(0, 100 - pct))%",
                showsChevron: wrong > 0, showsIcon: false
            )
            if wrong > 0 {
                NavigationLink {
                    AnswerReviewView(questions: questions, answers: answers, mode: .wrong)
                } label: { cauSaiRow }
                .buttonStyle(.plain)
            } else {
                cauSaiRow
            }

            // Điểm liệt → review of the điểm-liệt questions
            let diemLietRow = HistoryItemRow(
                icon: passDiemLiet ? "checkmark.shield.fill" : "exclamationmark.shield.fill",
                iconColor: passDiemLiet ? .appSuccess : .appError,
                title: "Điểm liệt",
                meta: passDiemLiet ? "Không sai câu điểm liệt" : "\(wrongDiemLietCount) câu điểm liệt bị sai",
                value: passDiemLiet ? "Đạt" : "Trượt", valueColor: passDiemLiet ? .appSuccess : .appError,
                status: passDiemLiet ? "An toàn" : "Nguy hiểm",
                showsChevron: diemLietTotal > 0, showsIcon: false
            )
            if diemLietTotal > 0 {
                NavigationLink {
                    AnswerReviewView(questions: questions, answers: answers, mode: .diemLiet)
                } label: { diemLietRow }
                .buttonStyle(.plain)
            } else {
                diemLietRow
            }

            // Thời gian làm bài → not clickable, so no trailing chevron
            HistoryItemRow(
                icon: "timer", iconColor: .appTextMedium,
                title: "Thời gian làm bài", meta: "Giới hạn \(formatTime(LicenseType.current.totalTimeSeconds))",
                value: formatTime(timeUsedSeconds), valueColor: .appTextDark,
                status: withinTime ? "Còn dư" : "Hết giờ",
                showsChevron: false, showsIcon: false
            )
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Về trang chủ — compact home-icon button on the left (design VVIdQ).
            Button { popToRoot() } label: {
                let icon = Image(systemName: "house")
                    .font(.appSans(size: 16, weight: .semibold))
                    .foregroundStyle(Color.appTextMedium)
                    .frame(width: 50, height: 50)
                if #available(iOS 26.0, *) {
                    icon
                        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 25))
                        .contentShape(Rectangle())
                } else {
                    icon
                        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 25, style: .continuous).strokeBorder(Color.cardBorder, lineWidth: 1))
                        .contentShape(Rectangle())
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Về trang chủ")

            // Xem lại bài (secondary) — open the per-question review navigator.
            NavigationLink {
                ReviewQuestionView(questions: questions, answers: answers)
            } label: {
                AppButton(icon: "checkmark.circle", label: "Xem lại bài", style: .secondary, height: 50)
            }

            // Thi lại (primary)
            Button {
                openExam(.mockExam(examSetId: examResult.examSetId))
            } label: {
                AppButton(icon: "play.circle", label: "Thi lại", style: .primary, height: 50)
            }
        }
        .padding(.horizontal, metrics.contentPadding)
        .padding(.top, 6)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }
}
