import SwiftUI

struct PracticeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam
    @Environment(HazardVideoCache.self) private var videoCache
    @State private var selectedSegment = 0
    @State private var showClearCacheAlert = false

    /// Topic 6 (Sa hình)
    private var saHinhTopic: Topic? {
        questionStore.topics.first { $0.topicIds.contains(6) }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedSegment) {
                Text("Câu hỏi").tag(0)
                Text("Sa hình").tag(1)
                Text("Tình huống").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            Group {
                switch selectedSegment {
                case 1: simulationStudyContent
                case 2: hazardStudyContent
                default: questionStudyContent
                }
            }
        }
        .glassContainer()
        .screenHeader("Luyện tập")
        .alert("Xoá cache video?", isPresented: $showClearCacheAlert) {
            Button("Huỷ", role: .cancel) {}
            Button("Xoá", role: .destructive) {
                videoCache.clearCache()
                Haptics.impact(.medium)
            }
        } message: {
            Text("Tất cả video đã tải sẽ bị xoá. Bạn có thể tải lại sau.")
        }
    }

    // MARK: - Câu hỏi (Theory Topics 1-5)

    @ViewBuilder
    private var questionStudyContent: some View {
        let theoryTopics = questionStore.topics.filter { !$0.topicIds.contains(6) }
        let topicStats = progressStore.weakTopics(topics: theoryTopics)
            .sorted { $0.topic.topicIds.first ?? 0 < $1.topic.topicIds.first ?? 0 }
        let theoryCount = theoryTopics.reduce(0) { $0 + $1.questionCount }
        let totalCorrect = topicStats.reduce(0) { $0 + $1.correct }
        let overallPct = theoryCount > 0 ? Int(Double(totalCorrect) / Double(theoryCount) * 100) : 0

        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // Quick actions
                HStack(spacing: 10) {
                    Button {
                        openExam(.questionView(topicKey: AppConstants.TopicKey.allQuestions, startIndex: 0))
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "text.book.closed.fill")
                                .font(.system(size: 14))
                            Text("Tất cả (\(theoryCount))")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(Color.appPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .glassCard(cornerRadius: 22)
                    }

                    Button {
                        openExam(.flashcard(topicKey: AppConstants.TopicKey.allQuestions))
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.on.rectangle.angled")
                                .font(.system(size: 14))
                            Text("Lật thẻ")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(Color.appPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .glassCard(cornerRadius: 22)
                    }

                    // Overall progress mini
                    VStack(spacing: 2) {
                        Text("\(overallPct)%")
                            .font(.system(size: 16, weight: .heavy).monospacedDigit())
                            .foregroundStyle(overallPct >= 80 ? Color.appSuccess : overallPct >= 50 ? Color.appWarning : Color.appTextMedium)
                        Text("tổng")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.appTextLight)
                    }
                    .frame(width: 56, height: 44)
                    .glassCard(cornerRadius: 12)
                }

                // Topic list
                VStack(spacing: 0) {
                    ForEach(Array(topicStats.enumerated()), id: \.element.topic.id) { index, item in
                        PracticeTopicRow(item: item, onFlashcard: {
                            openExam(.flashcard(topicKey: item.topic.key))
                        }, onStudy: {
                            openExam(.questionView(topicKey: item.topic.key, startIndex: 0))
                        })

                        if index < topicStats.count - 1 {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
                .glassCard()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Sa hình (Topic 6 Scenarios)

    @ViewBuilder
    private var simulationStudyContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if let topic = saHinhTopic {
                    let progress = progressStore.topicProgress(for: topic.key)
                    let correctCount = progress.values.filter { $0 }.count
                    let totalCount = topic.questionCount
                    let percentage = totalCount > 0 ? Int(Double(correctCount) / Double(totalCount) * 100) : 0

                    NavigationLink(destination: TopicsView(initialTopicKey: topic.key)) {
                        HStack(spacing: 14) {
                            IconBox(
                                icon: topic.icon,
                                color: topic.color,
                                size: 44,
                                cornerRadius: 11,
                                iconFontSize: 20
                            )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(topic.name)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color.appTextDark)
                                    .lineLimit(1)

                                HStack(spacing: 6) {
                                    Text("\(correctCount)/\(totalCount)")
                                        .font(.system(size: 13, weight: .semibold).monospacedDigit())
                                        .foregroundStyle(percentage >= 80 ? Color.appSuccess : Color.appTextMedium)
                                    Text("đúng")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.appTextLight)
                                    Text("(\(percentage)%)")
                                        .font(.system(size: 13, weight: .medium).monospacedDigit())
                                        .foregroundStyle(Color.appTextMedium)
                                }
                            }

                            Spacer(minLength: 4)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .glassCard()

                    Button {
                        openExam(.questionView(topicKey: topic.key, startIndex: 0))
                    } label: {
                        ListItemCard(
                            icon: "photo.on.rectangle.angled",
                            title: "Luyện tất cả sa hình",
                            subtitle: "\(totalCount) câu hỏi",
                            iconSize: 40,
                            iconCornerRadius: 10,
                            iconFontSize: 18,
                            iconColor: .topicSaHinh
                        ) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.appTextLight)
                        }
                    }
                    .buttonStyle(.plain)
                    .glassCard()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Tình huống (Hazard Videos)

    @ViewBuilder
    private var hazardStudyContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Button { openExam(.hazardTest(mode: .practice)) } label: {
                    AppButton(label: "Luyện tập tất cả (120 tình huống)", style: .secondary)
                }
                .buttonStyle(.plain)

                SectionTitle(title: "Chương trình · \(HazardSituation.all.count) tình huống")

                VStack(spacing: 0) {
                    ForEach(Array(HazardSituation.chapters.enumerated()), id: \.element.id) { index, chapter in
                        Button { openExam(.hazardTest(mode: .chapter(chapter.id))) } label: {
                            HStack(spacing: 14) {
                                IconBox(
                                    icon: chapterIcon(chapter.id),
                                    color: .appPrimary,
                                    size: 40,
                                    cornerRadius: 10,
                                    iconFontSize: 17
                                )

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Chương \(chapter.id)")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(Color.appTextDark)
                                    Text("\(chapter.name) (\(chapter.range.count) TH)")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color.appTextMedium)
                                }

                                Spacer(minLength: 4)

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.appTextLight)
                            }
                            .padding(.horizontal, 14)
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

                HazardDownloadCard(videoCache: videoCache, showClearAlert: $showClearCacheAlert)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
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

// MARK: - Practice Topic Row

private struct PracticeTopicRow: View {
    let item: (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)
    var onFlashcard: (() -> Void)? = nil
    var onStudy: (() -> Void)? = nil

    private var statusInfo: (label: String, color: Color) {
        if item.attempted == 0 {
            return ("Chưa học", .appTextLight)
        } else if item.accuracy >= 0.8 {
            return ("Tốt", .appSuccess)
        } else if item.accuracy >= 0.5 {
            return ("Cần ôn", .appWarning)
        } else {
            return ("Yếu", .appError)
        }
    }

    var body: some View {
        let fraction = item.total > 0 ? Double(item.correct) / Double(item.total) : 0

        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.appDivider, lineWidth: 4)
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(statusInfo.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: item.topic.sfSymbol)
                    .font(.system(size: 17))
                    .foregroundStyle(statusInfo.color)
                    .symbolRenderingMode(.hierarchical)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.topic.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                        .lineLimit(1)
                    StatusBadge(text: statusInfo.label, color: statusInfo.color, fontSize: 10)
                }

                HStack(spacing: 4) {
                    Text("\(item.correct)/\(item.total)")
                        .font(.system(size: 13, weight: .semibold).monospacedDigit())
                        .foregroundStyle(statusInfo.color)
                    Text("câu đúng")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextLight)
                }
            }

            Spacer(minLength: 4)

            if let onFlashcard {
                Button {
                    Haptics.impact(.light)
                    onFlashcard()
                } label: {
                    Image(systemName: "rectangle.on.rectangle.angled")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.appPrimary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            Button {
                Haptics.impact(.light)
                onStudy?()
            } label: {
                Image(systemName: "play.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.appPrimary)
                    .frame(width: 36, height: 36)
                    .background(Color.appPrimary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Hazard Download Card

private struct HazardDownloadCard: View {
    let videoCache: HazardVideoCache
    @Binding var showClearAlert: Bool
    @State private var showChapters = false

    var body: some View {
        let cached = videoCache.cachedCount
        let total = videoCache.totalCount
        let fraction = total > 0 ? Double(cached) / Double(total) : 0
        let allComplete = cached == total

        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: allComplete ? "checkmark.icloud.fill" : "icloud.and.arrow.down")
                        .font(.system(size: 16))
                        .foregroundStyle(allComplete ? Color.appSuccess : Color.appPrimary)
                        .symbolRenderingMode(.hierarchical)
                    Text("Video offline")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                    Spacer()
                    Text(String(format: "%.0f MB", videoCache.cacheSizeMB))
                        .font(.system(size: 12, weight: .medium).monospacedDigit())
                        .foregroundStyle(Color.appTextLight)
                }

                VStack(alignment: .leading, spacing: 4) {
                    ProgressBarView(fraction: fraction, color: allComplete ? .appSuccess : .appPrimary, height: 6)
                    Text("\(cached)/\(total) video đã tải")
                        .font(.system(size: 13, weight: .medium).monospacedDigit())
                        .foregroundStyle(Color.appTextMedium)
                }

                HStack(spacing: 10) {
                    if videoCache.isDownloadingAll {
                        Button {
                            videoCache.cancelAll()
                            Haptics.impact(.medium)
                        } label: {
                            HStack(spacing: 6) {
                                ProgressView().scaleEffect(0.7).tint(Color.appPrimary)
                                Text(videoCache.downloadSpeedMBps > 0
                                     ? String(format: "%.1f MB/s (Huỷ)", videoCache.downloadSpeedMBps)
                                     : "Đang tải... (Huỷ)")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.appPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .glassCard(cornerRadius: 18)
                        }
                    } else if !allComplete {
                        Button {
                            Haptics.impact(.medium)
                            Task { await videoCache.downloadAll() }
                        } label: {
                            AppButton(icon: "icloud.and.arrow.down", label: "Tải tất cả", height: 36, cornerRadius: 18)
                        }
                    }

                    if cached > 0 && !videoCache.isDownloading {
                        Button { showClearAlert = true } label: {
                            AppButton(label: "Xoá", style: .secondary, height: 36, cornerRadius: 18)
                        }
                        .frame(width: 80)
                    }
                }

                if !allComplete {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showChapters.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(showChapters ? "Ẩn chi tiết" : "Tải theo chương")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.appPrimary)
                            Image(systemName: showChapters ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color.appPrimary)
                        }
                    }
                }
            }
            .padding(16)

            if showChapters && !allComplete {
                Divider().padding(.horizontal, 16)

                VStack(spacing: 0) {
                    ForEach(HazardSituation.chapters, id: \.id) { chapter in
                        let chCached = videoCache.cachedCount(forChapter: chapter.id)
                        let chTotal = videoCache.totalCount(forChapter: chapter.id)
                        let chComplete = chCached == chTotal
                        let isDownloading = videoCache.downloadingChapters.contains(chapter.id)

                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ch. \(chapter.id): \(chapter.name)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.appTextDark)
                                    .lineLimit(1)
                                HStack(spacing: 4) {
                                    Text("\(chCached)/\(chTotal) video")
                                        .font(.system(size: 11, weight: .medium).monospacedDigit())
                                        .foregroundStyle(chComplete ? Color.appSuccess : Color.appTextLight)
                                    if isDownloading && videoCache.downloadSpeedMBps > 0 {
                                        Text(String(format: "· %.1f MB/s", videoCache.downloadSpeedMBps))
                                            .font(.system(size: 11, weight: .medium).monospacedDigit())
                                            .foregroundStyle(Color.appPrimary)
                                    }
                                }
                            }

                            Spacer(minLength: 4)

                            Button {
                                Haptics.impact(.light)
                                if isDownloading {
                                    videoCache.cancelChapter(chapter.id)
                                } else {
                                    Task { await videoCache.downloadChapter(chapter.id) }
                                }
                            } label: {
                                Group {
                                    if isDownloading {
                                        ProgressView().scaleEffect(0.65).tint(Color.appPrimary)
                                    } else if chComplete {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color.appSuccess)
                                    } else {
                                        Image(systemName: "icloud.and.arrow.down")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(Color.appPrimary)
                                    }
                                }
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                            }
                            .disabled(chComplete && !isDownloading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                        if chapter.id < HazardSituation.chapters.last?.id ?? 0 {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
        .glassCard()
    }
}
