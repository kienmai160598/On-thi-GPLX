import SwiftUI

private enum PracticeFilter: String, CaseIterable {
    case all = "Tất cả"
    case questions = "Câu hỏi"
    case hazard = "Tình huống"
    case reference = "Tra cứu"
}

struct PracticeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam
    @State private var filter: PracticeFilter = .all

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PracticeFilter.allCases, id: \.self) { item in
                            FilterChip(label: item.rawValue, isSelected: filter == item) {
                                filter = item
                            }
                        }
                    }
                }

                if filter == .all || filter == .questions {
                    questionSection
                }
                if filter == .all || filter == .hazard {
                    hazardSection
                }
                if filter == .all || filter == .reference {
                    referenceSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .glassContainer()
        .screenHeader("Luyện tập")
    }

    // MARK: - Câu hỏi Section

    @ViewBuilder
    private var questionSection: some View {
        let allTopics = questionStore.topics
        let topicStats = progressStore.weakTopics(topics: allTopics)
            .sorted { $0.topic.topicIds.first ?? 0 < $1.topic.topicIds.first ?? 0 }
        let totalCount = allTopics.reduce(0) { $0 + $1.questionCount }
        let totalCorrect = topicStats.reduce(0) { $0 + $1.correct }
        let overallAccuracy = totalCount > 0 ? Double(totalCorrect) / Double(totalCount) : 0
        let masteredTopics = topicStats.filter { $0.total > 0 && Double($0.correct) / Double($0.total) >= 0.8 }.count

        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Câu hỏi")

            MiniMetricCard(
                fraction: overallAccuracy,
                stats: [
                    (value: "\(totalCorrect)/\(totalCount)", label: "Đã đúng"),
                    (value: "\(masteredTopics)/\(topicStats.count)", label: "Hoàn thành")
                ]
            )

            // Play All button
            Button {
                openExam(.questionView(topicKey: AppConstants.TopicKey.allQuestions, startIndex: 0))
            } label: {
                AppButton(icon: "play.fill", label: "Tất cả \(totalCount) câu", height: 48, cornerRadius: 14)
            }

            // Topic list with progress rings
            VStack(spacing: 0) {
                ForEach(Array(topicStats.enumerated()), id: \.element.topic.id) { index, item in
                    let topicAccuracy = item.total > 0 ? Double(item.correct) / Double(item.total) : 0

                    Button {
                        openExam(.questionView(topicKey: item.topic.key, startIndex: 0))
                    } label: {
                        HStack(spacing: 14) {
                            TopicIconRing(
                                icon: item.topic.icon,
                                fraction: topicAccuracy,
                                color: .appPrimary
                            )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.topic.name)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.appTextDark)
                                    .lineLimit(1)
                                Text(item.correct > 0
                                    ? "\(item.correct)/\(item.total) đúng"
                                    : "\(item.total) câu")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.appTextMedium)
                            }

                            Spacer(minLength: 4)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < topicStats.count - 1 {
                        Divider().padding(.leading, 68)
                    }
                }
            }
            .glassCard()
        }
    }

    // MARK: - Tình huống Section

    @ViewBuilder
    private var hazardSection: some View {
        let totalSituations = HazardSituation.all.count
        let practicedCount = progressStore.hazardPracticedCount
        let avgScore = progressStore.averageHazardScore

        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Tình huống nguy hiểm")

            MiniMetricCard(
                fraction: avgScore,
                stats: [
                    (value: "\(practicedCount)/\(totalSituations)", label: "Đã luyện"),
                    (value: practicedCount > 0 ? "\(Int(avgScore * 100))%" : "--", label: "Điểm TB")
                ]
            )

            // Play All button
            Button { openExam(.hazardTest(mode: .practice)) } label: {
                AppButton(icon: "play.fill", label: "Luyện tất cả (\(totalSituations) tình huống)", height: 48, cornerRadius: 14)
            }

            // Chapter list with progress rings
            VStack(spacing: 0) {
                ForEach(Array(HazardSituation.chapters.enumerated()), id: \.element.id) { index, chapter in
                    let chapterScore = progressStore.chapterAverageScore(chapterId: chapter.id)
                    let hasPractice = progressStore.chapterHasPractice(chapterId: chapter.id)

                    Button { openExam(.hazardTest(mode: .chapter(chapter.id))) } label: {
                        HStack(spacing: 14) {
                            TopicIconRing(
                                icon: chapterIcon(chapter.id),
                                fraction: chapterScore,
                                color: .appPrimary
                            )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Chương \(chapter.id)")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color.appTextDark)
                                Text(hasPractice
                                    ? "\(chapter.name) · \(Int(chapterScore * 100))%"
                                    : "\(chapter.name) (\(chapter.range.count) TH)")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.appTextMedium)
                            }

                            Spacer(minLength: 4)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < HazardSituation.chapters.count - 1 {
                        Divider().padding(.leading, 68)
                    }
                }
            }
            .glassCard()

        }
    }

    // MARK: - Tra cứu Section

    @ViewBuilder
    private var referenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Tra cứu")

            VStack(spacing: 0) {
                NavigationLink(destination: TrafficSignsReferenceView()) {
                    HStack(spacing: 14) {
                        TopicIconRing(icon: "diamond.fill", fraction: 0, color: .appPrimary)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Biển báo giao thông")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.appTextDark)
                            Text("47 biển báo phổ biến")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.appTextMedium)
                        }

                        Spacer(minLength: 4)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appTextLight)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Divider().padding(.leading, 68)

                NavigationLink(destination: SpeedDistanceReferenceView()) {
                    HStack(spacing: 14) {
                        TopicIconRing(icon: "speedometer", fraction: 0, color: .appPrimary)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Tốc độ & Quy tắc")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.appTextDark)
                            Text("Tốc độ, khoảng cách, mức phạt")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.appTextMedium)
                        }

                        Spacer(minLength: 4)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appTextLight)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .glassCard()
        }
    }

    private func chapterIcon(_ id: Int) -> String {
        switch id {
        case 1: return "building.2.fill"
        case 2: return "road.lanes"
        case 3: return "car.rear.road.lane"
        case 4: return "mountain.2.fill"
        case 5: return "car.2.fill"
        case 6: return "exclamationmark.triangle.fill"
        default: return "play.rectangle.fill"
        }
    }
}


