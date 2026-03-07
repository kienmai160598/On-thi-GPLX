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
                VStack(spacing: 16) {
                    Button { openExam(.mockExam()) } label: {
                        AppButton(icon: "play.fill", label: "Bắt đầu thi thử")
                    }
                    .buttonStyle(.plain)
                    .onGeometryChange(for: Bool.self) { proxy in
                        proxy.frame(in: .scrollView(axis: .vertical)).minY < 0
                    } action: { hidden in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showNavPlay = hidden
                        }
                    }

                    // Rules summary
                    HStack(spacing: 16) {
                        RulePill(icon: "questionmark.circle", text: "35 câu")
                        RulePill(icon: "timer", text: "25 phút")
                        RulePill(icon: "checkmark.circle", text: "≥ 32 đạt")
                    }

                    Text("Sai câu điểm liệt = Trượt. Làm câu điểm liệt trước, không bỏ trống câu nào.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextMedium)
                        .lineSpacing(3)
                }
                .padding(20)
                .glassCard()

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

                                Button { openExam(.mockExam(examSetId: setId)) } label: {
                                    HStack(spacing: 10) {
                                        Text("Đề \(setId)")
                                            .font(.system(size: 15, weight: .semibold).monospacedDigit())
                                            .foregroundStyle(Color.appTextDark)

                                        Spacer()

                                        if isCompleted {
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

                    VStack(spacing: 0) {
                        ForEach(Array(progressStore.examHistory.prefix(10).enumerated()), id: \.element.id) { index, result in
                            NavigationLink(destination: ExamHistoryDetailView(result: result)) {
                                HistoryRow(
                                    passed: result.passed,
                                    scoreText: "\(result.score)/\(result.totalQuestions) đúng",
                                    date: result.date
                                )
                            }
                            .buttonStyle(.plain)

                            if index < min(progressStore.examHistory.count, 10) - 1 {
                                Divider().padding(.leading, 60)
                            }
                        }
                    }
                    .glassCard()
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

