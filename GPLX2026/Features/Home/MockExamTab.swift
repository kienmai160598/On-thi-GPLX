import SwiftUI

struct MockExamTab: View {
    @Environment(ProgressStore.self) private var progressStore
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var showNavPlay = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Rules card
                VStack(alignment: .leading, spacing: 14) {
                    Text("Quy tắc thi")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)

                    RuleRow(icon: "questionmark.circle.fill", iconColor: Color.appPrimary, text: "35 câu hỏi ngẫu nhiên")
                    RuleRow(icon: "timer", iconColor: Color.appPrimary, text: "25 phút làm bài")
                    RuleRow(icon: "checkmark.circle.fill", iconColor: Color.appPrimary, text: "Đạt: \u{2265} 32 câu đúng")
                    RuleRow(icon: "exclamationmark.triangle.fill", iconColor: Color.appPrimary, text: "Sai câu điểm liệt = Trượt")
                }
                .padding(16)
                .glassCard()
                .padding(.bottom, 20)
                .staggered(0)

                // MARK: - Tips card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mẹo thi")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.appTextDark)

                    Text("\u{2022} Làm câu điểm liệt trước\n\u{2022} Không bỏ trống câu nào\n\u{2022} Quản lý thời gian tốt")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextMedium)
                        .lineSpacing(4)
                }
                .padding(16)
                .glassCard()
                .padding(.bottom, 20)
                .staggered(1)

                // MARK: - Stats card
                if !progressStore.examHistory.isEmpty {
                    ExamStatsRow(items: [
                        (value: "\(progressStore.examCount)", label: "Đã thi"),
                        (value: "\(Int(progressStore.averageExamScore * 100))%", label: "TB đúng"),
                        (value: "\(Int(progressStore.bestExamScore * 100))%", label: "Cao nhất"),
                    ])
                    .padding(.bottom, 20)
                    .staggered(2)
                }

                // MARK: - Start button
                NavigationLink(destination: MockExamView()) {
                    AppButton(label: "Bắt đầu thi thử")
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)
                .staggered(3)
                .onGeometryChange(for: Bool.self) { proxy in
                    proxy.frame(in: .scrollView(axis: .vertical)).maxY < 60
                } action: { hidden in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showNavPlay = hidden
                    }
                }

                // MARK: - Fixed exam sets
                Text("Đề thi cố định")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Color.appTextDark)
                    .padding(.bottom, 4)
                    .staggered(4)

                Text("20 đề thi giống thực tế")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextMedium)
                    .padding(.bottom, 12)

                let completedSets = progressStore.completedExamSets
                ForEach(1...20, id: \.self) { setId in
                    let isCompleted = completedSets.contains(setId)

                    NavigationLink(destination: MockExamView(examSetId: setId)) {
                        ListItemCard(icon: "doc.text", title: "Đề số \(setId)") {
                            if isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Color.appPrimary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 8)
                    .staggered(5 + setId)
                }

                // MARK: - Recent history
                if !progressStore.examHistory.isEmpty {
                    Text("Lịch sử")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)
                        .padding(.top, 16)
                        .padding(.bottom, 4)
                        .staggered(26)

                    Text("Kết quả gần đây")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextMedium)
                        .padding(.bottom, 12)

                    ForEach(Array(progressStore.examHistory.prefix(10).enumerated()), id: \.element.id) { i, result in
                        NavigationLink(destination: ExamHistoryDetailView(result: result)) {
                            HistoryRow(
                                passed: result.passed,
                                scoreText: "\(result.score)/\(result.totalQuestions) đúng",
                                date: result.date
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 8)
                        .staggered(27 + i)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .screenHeader("Thi thử")
        .toolbar {
            if showNavPlay {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: MockExamView()) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primaryColor(for: primaryColorKey))
                    }
                }
            }
        }
    }
}

