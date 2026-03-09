import SwiftUI

struct MockExamTab: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var showNavPlay = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - CTA + Rules
                ExamCTACard(
                    buttonLabel: "Bắt đầu thi thử",
                    rules: [
                        (icon: "questionmark.circle", text: "35 câu"),
                        (icon: "timer", text: "25 phút"),
                        (icon: "checkmark.circle", text: "≥ 32 đạt"),
                    ],
                    tip: "Sai câu điểm liệt = Trượt. Làm câu điểm liệt trước, không bỏ trống câu nào.",
                    action: { openExam(.mockExam()) },
                    onButtonHidden: { hidden in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showNavPlay = hidden
                        }
                    }
                )

                // MARK: - Stats
                if !progressStore.examHistory.isEmpty {
                    ExamStatsRow(items: [
                        (value: "\(progressStore.examCount)", label: "Đã thi"),
                        (value: "\(Int(progressStore.averageExamScore * 100))%", label: "TB đúng"),
                        (value: "\(Int(progressStore.bestExamScore * 100))%", label: "Cao nhất"),
                    ])
                }

                // MARK: - Fixed exam sets
                SectionTitle(title: "Đề thi cố định")

                VStack(spacing: 0) {
                    let completedSets = progressStore.completedExamSets

                    ForEach(Array(stride(from: 1, through: 20, by: 2)), id: \.self) { rowStart in
                        if rowStart > 1 {
                            Divider().padding(.horizontal, 16)
                        }

                        HStack(spacing: 0) {
                            ForEach([rowStart, rowStart + 1], id: \.self) { setId in
                                if setId > rowStart {
                                    Divider().frame(height: 56)
                                }

                                let isCompleted = completedSets.contains(setId)
                                let latestResult = isCompleted ? progressStore.latestResult(forExamSet: setId) : nil

                                Button { openExam(.mockExam(examSetId: setId)) } label: {
                                    HStack(spacing: 10) {
                                        Text("Đề \(setId)")
                                            .font(.system(size: 15, weight: .semibold).monospacedDigit())
                                            .foregroundStyle(Color.appTextDark)

                                        Spacer()

                                        if isCompleted {
                                            if let result = latestResult {
                                                Text("\(result.score)/\(result.totalQuestions)")
                                                    .font(.system(size: 13, weight: .medium).monospacedDigit())
                                                    .foregroundStyle(result.passed ? Color.appSuccess : Color.appError)
                                            }
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(Color.appSuccess)
                                        } else {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundStyle(Color.appTextLight)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(height: 56)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .glassCard()

                // MARK: - History
                if !progressStore.examHistory.isEmpty {
                    SectionTitle(title: "Lịch sử")

                    HistoryList(
                        results: progressStore.examHistory,
                        scoreText: { "\($0.score)/\($0.totalQuestions) đúng" },
                        passed: \.passed,
                        date: \.date,
                        destination: { ExamHistoryDetailView(result: $0) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .screenHeader("Thi thử")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if showNavPlay {
                    Button { openExam(.mockExam()) } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primaryColor(for: primaryColorKey))
                    }
                }
            }
        }
    }
}

