import SwiftUI

struct SimulationTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(HazardVideoCache.self) private var videoCache
    @Environment(\.openExam) private var openExam
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var showNavPlay = false
    @State private var selectedSection: SimSection = .simulation
    @State private var showClearCacheAlert = false

    private enum SimSection: String, CaseIterable {
        case simulation = "Mô phỏng"
        case hazard = "Tình huống"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Picker("", selection: $selectedSection) {
                    ForEach(SimSection.allCases, id: \.self) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)

                switch selectedSection {
                case .simulation:
                    simulationContent
                case .hazard:
                    hazardContent
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .screenHeader("Thực hành")
        .alert("Xoá cache video?", isPresented: $showClearCacheAlert) {
            Button("Huỷ", role: .cancel) {}
            Button("Xoá", role: .destructive) {
                videoCache.clearCache()
                Haptics.impact(.medium)
            }
        } message: {
            Text("Tất cả video đã tải sẽ bị xoá. Bạn có thể tải lại sau.")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if showNavPlay {
                    Button {
                        openExam(selectedSection == .simulation
                            ? .simulationExam(mode: .random)
                            : .hazardTest(mode: .exam))
                    } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primaryColor(for: primaryColorKey))
                    }
                }
            }
        }
    }

    // MARK: - Simulation Content

    @ViewBuilder
    private var simulationContent: some View {
        // CTA + Rules
        ExamCTACard(
            buttonLabel: "Thi mô phỏng (20 câu)",
            rules: [
                (icon: "photo.on.rectangle", text: "20 câu"),
                (icon: "timer", text: "60s/câu"),
                (icon: "checkmark.circle", text: "≥ 70%"),
            ],
            tip: "Quan sát kỹ hình ảnh, chú ý biển báo và vạch kẻ đường.",
            action: { openExam(.simulationExam(mode: .random)) },
            onButtonHidden: { hidden in
                withAnimation(.easeInOut(duration: 0.2)) {
                    showNavPlay = hidden
                }
            }
        )

        // Stats
        if !progressStore.simulationHistory.isEmpty {
            ExamStatsRow(items: [
                (value: "\(progressStore.simulationExamCount)", label: "Đã thi"),
                (value: "\(Int(progressStore.averageSimulationScore * 100))%", label: "TB đúng"),
                (value: "\(Int(progressStore.bestSimulationScore * 100))%", label: "Cao nhất"),
            ])
        }

        // History
        if !progressStore.simulationHistory.isEmpty {
            SectionTitle(title: "Lịch sử mô phỏng")

            HistoryList(
                results: progressStore.simulationHistory,
                scoreText: { "\($0.score)/\($0.totalScenarios) đúng" },
                passed: \.passed,
                date: \.date,
                destination: { SimulationHistoryDetailView(result: $0) }
            )
        }
    }

    // MARK: - Hazard Content

    @ViewBuilder
    private var hazardContent: some View {
        // CTA + Rules
        ExamCTACard(
            buttonLabel: "Thi tình huống (10 video)",
            rules: [
                (icon: "play.rectangle", text: "10 video"),
                (icon: "hand.tap", text: "Nhấn nhanh"),
                (icon: "star", text: "≥ 35/50"),
            ],
            tip: "Nhấn sớm khi vừa thấy nguy hiểm để đạt điểm cao nhất.",
            action: { openExam(.hazardTest(mode: .exam)) }
        )

        // Download
        HazardDownloadCard(videoCache: videoCache, showClearAlert: $showClearCacheAlert)

        // Stats
        if !progressStore.hazardHistory.isEmpty {
            ExamStatsRow(items: [
                (value: "\(progressStore.hazardExamCount)", label: "Đã thi"),
                (value: "\(Int(progressStore.averageHazardScore * 100))%", label: "TB điểm"),
                (value: "\(progressStore.bestHazardScore)", label: "Cao nhất"),
            ])
        }

        // Full practice
        Button { openExam(.hazardTest(mode: .practice)) } label: {
            AppButton(label: "Luyện tập tất cả (120 tình huống)", style: .secondary)
        }
        .buttonStyle(.plain)

        // Chapters
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

        // History
        if !progressStore.hazardHistory.isEmpty {
            SectionTitle(title: "Lịch sử tình huống")

            HistoryList(
                results: progressStore.hazardHistory,
                scoreText: { "\($0.totalScore)/\($0.maxScore) điểm" },
                passed: \.passed,
                date: \.date,
                destination: { HazardHistoryDetailView(result: $0) }
            )
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
