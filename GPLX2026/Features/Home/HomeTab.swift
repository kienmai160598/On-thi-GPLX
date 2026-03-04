import SwiftUI

struct HomeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    
    @Namespace private var heroNS

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Readiness card
                ReadinessCard()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                // MARK: - Stats row
                StatsRow()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // MARK: - Badges preview
                let badges = progressStore.badgeStatuses
                let unlocked = badges.filter(\.isUnlocked).count
                let nextBadge = badges.first(where: { !$0.isUnlocked })
                
                NavigationLink {
                    BadgesView()
                        .navigationTransition(.zoom(sourceID: "badges", in: heroNS))
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.appPrimary.opacity(0.12))
                                .frame(width: 44, height: 44)
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.appPrimary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text("\(unlocked)/\(badges.count) thành tích")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.appTextDark)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.appTextLight)
                            }

                            if let next = nextBadge {
                                HStack(spacing: 6) {
                                    Image(systemName: next.badge.sfSymbol)
                                        .font(.system(size: 11))
                                        .foregroundStyle(next.badge.color)

                                    Text("Tiếp: \(next.badge.title)")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.appTextMedium)

                                    Spacer()

                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.appDivider)
                                                .frame(height: 4)
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(next.badge.color)
                                                .frame(width: geo.size.width * next.fraction, height: 4)
                                        }
                                    }
                                    .frame(width: 60, height: 4)

                                    Text("\(next.progress)/\(next.target)")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(Color.appTextLight)
                                }
                            } else {
                                Text("Đã mở khoá tất cả!")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.appSuccess)
                            }
                        }
                    }
                    .padding(14)
                    .glassCard()
                }
                .matchedTransitionSource(id: "badges", in: heroNS)
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // MARK: - Topic analysis
                SectionTitle(title: "Phân tích chủ đề")
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)

                let topicStats = progressStore.weakTopics(topics: questionStore.topics)
                    .sorted { $0.topic.topicIds.first ?? 0 < $1.topic.topicIds.first ?? 0 }
                
                VStack(spacing: 8) {
                    ForEach(topicStats, id: \.topic.id) { item in
                        NavigationLink {
                            TopicDetailView(item: item)
                                .navigationTransition(.zoom(sourceID: item.topic.key, in: heroNS))
                        } label: {
                            let accentColor = if item.attempted == 0 {
                                Color.appTextLight
                            } else if item.accuracy < 0.5 {
                                Color.appError
                            } else if item.accuracy < 0.8 {
                                Color.appWarning
                            } else {
                                Color.appSuccess
                            }

                            let statusText = if item.attempted == 0 {
                                "Chưa học"
                            } else if item.accuracy >= 0.8 {
                                "Tốt"
                            } else {
                                "Cần ôn"
                            }

                            HStack(spacing: 12) {
                                IconBox(
                                    icon: item.topic.sfSymbol,
                                    color: accentColor,
                                    size: 36,
                                    cornerRadius: 9,
                                    iconFontSize: 15
                                )

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(item.topic.shortName)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(Color.appTextDark)

                                        Spacer()

                                        Text(item.attempted > 0 ? "\(item.correct)/\(item.total) • \(Int(item.accuracy * 100))%" : statusText)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(accentColor)
                                    }

                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2.5)
                                            .fill(Color.appDivider)
                                            .frame(height: 5)
                                            .frame(maxWidth: .infinity)

                                        if item.total > 0 {
                                            RoundedRectangle(cornerRadius: 2.5)
                                                .fill(accentColor)
                                                .frame(height: 5)
                                                .frame(maxWidth: .infinity)
                                                .scaleEffect(x: Double(item.correct) / Double(item.total), y: 1, anchor: .leading)
                                        }
                                    }
                                    .clipped()
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .glassCard()
                        }
                        .matchedTransitionSource(id: item.topic.key, in: heroNS)
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .screenHeader("Trang chủ")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.appTextDark)
                }
            }
        }
    }
}

// MARK: - Subviews (kept exactly as you had them)

private struct StatsRow: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        let progress = progressStore.overallProgress(topics: questionStore.topics)
        let correctCount = progressStore.totalCorrectCount(topics: questionStore.topics)
        let totalQuestions = questionStore.topics.reduce(0) { $0 + $1.questionCount }
        let streak = progressStore.streakCount

        HStack(spacing: 10) {
            MiniStatCard(
                icon: "chart.pie.fill",
                iconColor: .appPrimary,
                value: "\(Int(progress * 100))%",
                label: "Tiến độ"
            )

            MiniStatCard(
                icon: "checkmark.circle.fill",
                iconColor: .appSuccess,
                value: "\(correctCount)/\(totalQuestions)",
                label: "Đã đúng"
            )

            MiniStatCard(
                icon: "flame.fill",
                iconColor: Color(hex: 0xFF6B35),
                value: "\(streak)",
                label: "Chuỗi ngày"
            )
        }
    }
}

private struct MiniStatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(iconColor)

            Text(value)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.appTextDark)

            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.appTextMedium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassCard()
    }
}

// MARK: - Topic Detail View (fullscreen zoom)

private struct TopicDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let item: (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)

    private var accentColor: Color {
        if item.attempted == 0 { return .appTextLight }
        return item.accuracy < 0.5 ? .appError : item.accuracy < 0.8 ? .appWarning : .appSuccess
    }

    private var statusLabel: String {
        if item.attempted == 0 { return "Chưa học" }
        if item.accuracy >= 0.8 { return "Tốt" }
        if item.accuracy >= 0.5 { return "Cần ôn" }
        return "Yếu"
    }

    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - Hero image
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.1))
                        .frame(width: 120, height: 120)
                    Image(systemName: item.topic.sfSymbol)
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(accentColor)
                }
                .padding(.top, 20)

                // MARK: - Title & Description
                VStack(spacing: 8) {
                    Text(item.topic.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                        .multilineTextAlignment(.center)

                    Text(item.topic.topicDescription)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextMedium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    StatusBadge(text: statusLabel, color: accentColor, fontSize: 12)
                }

                // MARK: - Accuracy card
                VStack(spacing: 16) {
                    if item.attempted > 0 {
                        Text("\(Int(item.accuracy * 100))%")
                            .font(.system(size: 56, weight: .heavy).monospacedDigit())
                            .foregroundStyle(accentColor)
                    } else {
                        Text("—")
                            .font(.system(size: 56, weight: .heavy))
                            .foregroundStyle(Color.appTextLight)
                    }

                    VStack(spacing: 8) {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.appDivider)
                                .frame(height: 10)
                                .frame(maxWidth: .infinity)

                            if item.total > 0 {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(accentColor)
                                    .frame(height: 10)
                                    .frame(maxWidth: .infinity)
                                    .scaleEffect(x: Double(item.correct) / Double(item.total), y: 1, anchor: .leading)
                            }
                        }
                        .clipped()

                        Text("\(item.correct)/\(item.total) câu đúng")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.appTextMedium)
                    }
                }
                .padding(20)
                .glassCard()

                // MARK: - Stats grid (2×2)
                LazyVGrid(columns: gridColumns, spacing: 10) {
                    GridStatCell(icon: "checkmark.circle.fill", value: "\(item.correct)", label: "Đúng", color: .appSuccess)
                    GridStatCell(icon: "xmark.circle.fill", value: "\(max(item.attempted - item.correct, 0))", label: "Sai", color: .appError)
                    GridStatCell(icon: "questionmark.circle", value: "\(item.total - item.attempted)", label: "Chưa làm", color: .appTextLight)
                    GridStatCell(icon: "list.number", value: "\(item.total)", label: "Tổng câu hỏi", color: .appTextDark)
                }

                // MARK: - Action button
                Button {
                    // TODO: Navigate to QuestionView(topicKey: item.topic.key, startIndex: 0)
                } label: {
                    AppButton(icon: "play.fill", label: "Ôn tập chủ đề này", style: .secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.secondary, Color(.systemFill))
            }
            .padding(16)
        }
        .background(Color.scaffoldBg.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
    }
}

private struct GridStatCell: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .heavy).monospacedDigit())
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.appTextMedium)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .glassCard()
    }
}

// MARK: - Readiness Card

private struct ReadinessCard: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        let score = progressStore.readinessScore(
            topics: questionStore.topics,
            allQuestions: questionStore.allQuestions
        )
        let pct = Int(score * 100)
        let dl = progressStore.diemLietMastery(questions: questionStore.allQuestions)
        let totalAttempted = progressStore.totalAttemptedCount(topics: questionStore.topics)

        let isReady = pct >= 80 && dl.correct == dl.total && totalAttempted >= 400
        let statusColor = isReady ? Color.appSuccess : pct >= 50 ? Color.appWarning : Color.appError
        let statusIcon = isReady ? "checkmark.shield.fill" : "exclamationmark.triangle.fill"
        let statusText = isReady ? "Sẵn sàng thi" : pct >= 50 ? "Cần ôn thêm" : "Chưa sẵn sàng"

        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: statusIcon)
                    .font(.system(size: 28))
                    .foregroundStyle(statusColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(statusText)
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(statusColor)
                    Text("Độ sẵn sàng: \(pct)%")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextMedium)
                }

                Spacer()
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.appDivider)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(statusColor)
                        .frame(width: geo.size.width * score, height: 8)
                }
            }
            .frame(height: 8)

            // Detail rows
            HStack(spacing: 0) {
                ReadinessDetail(
                    label: "Điểm liệt",
                    value: "\(dl.correct)/\(dl.total)",
                    color: dl.correct == dl.total && dl.total > 0 ? .appSuccess : .appError
                )

                Rectangle().fill(Color.appDivider).frame(width: 1, height: 24)

                ReadinessDetail(
                    label: "Đã làm",
                    value: "\(totalAttempted)/600",
                    color: totalAttempted >= 400 ? .appSuccess : .appTextMedium
                )

                Rectangle().fill(Color.appDivider).frame(width: 1, height: 24)

                let passRate = progressStore.examHistory.isEmpty ? 0 :
                    Double(progressStore.examHistory.filter(\.passed).count) / Double(progressStore.examHistory.count)
                ReadinessDetail(
                    label: "Tỉ lệ đậu",
                    value: progressStore.examHistory.isEmpty ? "--" : "\(Int(passRate * 100))%",
                    color: passRate >= 0.8 ? .appSuccess : .appTextMedium
                )
            }
        }
        .padding(16)
        .glassCard()
    }
}

private struct ReadinessDetail: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.appTextMedium)
        }
        .frame(maxWidth: .infinity)
    }
}
