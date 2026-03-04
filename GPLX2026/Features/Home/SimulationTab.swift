import SwiftUI

struct SimulationTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var showNavPlay = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Rules card
                VStack(alignment: .leading, spacing: 14) {
                    Text("Quy tắc thi mô phỏng")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)

                    SimRuleRow(icon: "photo.on.rectangle", iconColor: Color.appPrimary,
                               text: "20 tình huống ngẫu nhiên")
                    SimRuleRow(icon: "timer", iconColor: Color.appPrimary,
                               text: "60 giây mỗi tình huống")
                    SimRuleRow(icon: "arrow.right.circle.fill", iconColor: Color.appPrimary,
                               text: "Tự động chuyển sau khi trả lời")
                    SimRuleRow(icon: "checkmark.circle.fill", iconColor: Color.appPrimary,
                               text: "Đạt: \u{2265} 14/20 đúng (70%)")
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

                    Text("\u{2022} Quan sát kỹ hình ảnh trước khi trả lời\n\u{2022} Chú ý biển báo và vạch kẻ đường\n\u{2022} Không để hết thời gian")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextMedium)
                        .lineSpacing(4)
                }
                .padding(16)
                .glassCard()
                .padding(.bottom, 20)
                .staggered(1)

                // MARK: - Stats card
                if !progressStore.simulationHistory.isEmpty {
                    SimulationStatsCard()
                        .padding(.bottom, 20)
                        .staggered(2)
                }

                // MARK: - Start random exam
                NavigationLink(destination: SimulationExamView(mode: .random)) {
                    AppButton(icon: "play.fill", label: "Thi mô phỏng (20 câu)")
                }
                .buttonStyle(.plain)
                .padding(.bottom, 12)
                .staggered(3)
                .onGeometryChange(for: Bool.self) { proxy in
                    proxy.frame(in: .scrollView(axis: .vertical)).maxY < 60
                } action: { hidden in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showNavPlay = hidden
                    }
                }

                // MARK: - Full practice mode
                NavigationLink(destination: SimulationExamView(mode: .fullPractice)) {
                    AppButton(label: "Luyện tập tất cả (\(questionStore.simulationQuestions.count) câu)", style: .secondary)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)
                .staggered(4)

                // MARK: - Recent history
                if !progressStore.simulationHistory.isEmpty {
                    Text("Lịch sử")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundStyle(Color.appTextDark)
                        .padding(.bottom, 4)
                        .staggered(5)

                    Text("Kết quả gần đây")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextMedium)
                        .padding(.bottom, 12)

                    ForEach(Array(progressStore.simulationHistory.prefix(10).enumerated()), id: \.element.id) { i, result in
                        NavigationLink(destination: SimulationHistoryDetailView(result: result)) {
                            SimulationHistoryRow(result: result)
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 8)
                        .staggered(6 + i)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .screenHeader("Mô phỏng")
        .toolbar {
            if showNavPlay {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SimulationExamView(mode: .random)) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primaryColor(for: primaryColorKey))
                    }
                }
            }
        }
    }
}

// MARK: - Rule Row

private struct SimRuleRow: View {
    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            IconBox(icon: icon, color: iconColor, size: 32, cornerRadius: 8, iconFontSize: 14)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.appTextDark)
                .lineSpacing(2)
        }
    }
}

// MARK: - Stats Card

private struct SimulationStatsCard: View {
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        HStack(spacing: 0) {
            StatItem(
                value: "\(progressStore.simulationExamCount)",
                label: "Đã thi"
            )

            Rectangle()
                .fill(Color.appDivider)
                .frame(width: 1, height: 32)

            StatItem(
                value: "\(Int(progressStore.averageSimulationScore * 100))%",
                label: "TB đúng"
            )

            Rectangle()
                .fill(Color.appDivider)
                .frame(width: 1, height: 32)

            StatItem(
                value: "\(Int(progressStore.bestSimulationScore * 100))%",
                label: "Cao nhất"
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .glassCard()
    }
}

// MARK: - History Row

private struct SimulationHistoryRow: View {
    let result: SimulationResult

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM HH:mm"
        return formatter.string(from: result.date)
    }

    var body: some View {
        ListItemCard(
            icon: result.passed ? "checkmark.circle.fill" : "xmark.circle.fill",
            title: "\(result.score)/\(result.totalScenarios) đúng",
            subtitle: dateText
        ) {
            StatusBadge(
                text: result.passed ? "Đạt" : "Trượt",
                color: result.passed ? .appSuccess : .appError,
                fontSize: 10
            )
        }
    }
}
