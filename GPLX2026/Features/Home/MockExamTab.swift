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
                VStack(alignment: .leading, spacing: 14) {
                    Text("Đề thi cố định")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)

                    Text("20 đề thi giống thực tế")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextMedium)

                    let completedSets = progressStore.completedExamSets
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(1...20, id: \.self) { setId in
                            let isCompleted = completedSets.contains(setId)

                            Button { openExam(.mockExam(examSetId: setId)) } label: {
                                VStack(spacing: 4) {
                                    Text("\(setId)")
                                        .font(.system(size: 17, weight: .bold).monospacedDigit())
                                        .foregroundStyle(isCompleted ? Color.appPrimary : Color.appTextDark)

                                    if isCompleted {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(Color.appSuccess)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(isCompleted ? Color.appPrimary.opacity(0.08) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(isCompleted ? Color.appPrimary.opacity(0.3) : Color.appDivider, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // MARK: - History
                if !progressStore.examHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Lịch sử")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundStyle(Color.appTextDark)

                        ForEach(progressStore.examHistory.prefix(10), id: \.id) { result in
                            NavigationLink(destination: ExamHistoryDetailView(result: result)) {
                                HistoryRow(
                                    passed: result.passed,
                                    scoreText: "\(result.score)/\(result.totalQuestions) đúng",
                                    date: result.date
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
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

