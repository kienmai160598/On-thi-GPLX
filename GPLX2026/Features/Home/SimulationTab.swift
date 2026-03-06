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
            VStack(alignment: .leading, spacing: 0) {
                // Section picker
                Picker("", selection: $selectedSection) {
                    ForEach(SimSection.allCases, id: \.self) { section in
                        Text(section.rawValue).tag(section)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom, 20)

                switch selectedSection {
                case .simulation:
                    simulationContent
                case .hazard:
                    hazardContent
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .screenHeader("Mô phỏng")
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
        // Rules card
        VStack(alignment: .leading, spacing: 14) {
            Text("Quy tắc thi mô phỏng")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.appTextDark)

            RuleRow(icon: "photo.on.rectangle", iconColor: Color.appPrimary,
                    text: "20 tình huống ngẫu nhiên")
            RuleRow(icon: "timer", iconColor: Color.appPrimary,
                    text: "60 giây mỗi tình huống")
            RuleRow(icon: "arrow.right.circle.fill", iconColor: Color.appPrimary,
                    text: "Tự động chuyển sau khi trả lời")
            RuleRow(icon: "checkmark.circle.fill", iconColor: Color.appPrimary,
                    text: "Đạt: \u{2265} 14/20 đúng (70%)")
        }
        .padding(16)
        .glassCard()
        .padding(.bottom, 20)

        // Tips card
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

        // Stats card
        if !progressStore.simulationHistory.isEmpty {
            ExamStatsRow(items: [
                (value: "\(progressStore.simulationExamCount)", label: "Đã thi"),
                (value: "\(Int(progressStore.averageSimulationScore * 100))%", label: "TB đúng"),
                (value: "\(Int(progressStore.bestSimulationScore * 100))%", label: "Cao nhất"),
            ])
            .padding(.bottom, 20)
        }

        // Start random exam
        Button { openExam(.simulationExam(mode: .random)) } label: {
            AppButton(icon: "play.fill", label: "Thi mô phỏng (20 câu)")
        }
        .buttonStyle(.plain)
        .padding(.bottom, 12)
        .onGeometryChange(for: Bool.self) { proxy in
            proxy.frame(in: .scrollView(axis: .vertical)).minY < 0
        } action: { hidden in
            withAnimation(.easeInOut(duration: 0.2)) {
                showNavPlay = hidden
            }
        }

        // Full practice mode
        Button { openExam(.simulationExam(mode: .fullPractice)) } label: {
            AppButton(label: "Luyện tập tất cả (\(questionStore.simulationQuestions.count) câu)", style: .secondary)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 24)

        // Recent history
        if !progressStore.simulationHistory.isEmpty {
            SectionTitle(title: "Lịch sử mô phỏng")
                .padding(.bottom, 8)

            ForEach(progressStore.simulationHistory.prefix(10), id: \.id) { result in
                NavigationLink(destination: SimulationHistoryDetailView(result: result)) {
                    HistoryRow(
                        passed: result.passed,
                        scoreText: "\(result.score)/\(result.totalScenarios) đúng",
                        date: result.date
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Hazard Content

    @ViewBuilder
    private var hazardContent: some View {
        // Rules card
        VStack(alignment: .leading, spacing: 14) {
            Text("Quy tắc thi tình huống")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color.appTextDark)

            RuleRow(icon: "play.rectangle.fill", iconColor: Color.appPrimary,
                    text: "10 tình huống video ngẫu nhiên")
            RuleRow(icon: "hand.tap.fill", iconColor: Color.appPrimary,
                    text: "Nhấn khi phát hiện nguy hiểm")
            RuleRow(icon: "star.fill", iconColor: Color.appPrimary,
                    text: "0-5 điểm mỗi tình huống")
            RuleRow(icon: "checkmark.circle.fill", iconColor: Color.appPrimary,
                    text: "Đạt: \u{2265} 35/50 điểm (70%)")
        }
        .padding(16)
        .glassCard()
        .padding(.bottom, 20)

        // Tips
        VStack(alignment: .leading, spacing: 8) {
            Text("Cách tính điểm")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.appTextDark)

            Text("\u{2022} Nhấn sớm khi vừa thấy nguy hiểm: 5 điểm\n\u{2022} Nhấn muộn: ít điểm hơn\n\u{2022} Không nhấn hoặc nhấn quá sớm: 0 điểm")
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextMedium)
                .lineSpacing(4)
        }
        .padding(16)
        .glassCard()
        .padding(.bottom, 20)

        // Download card
        HazardDownloadCard(videoCache: videoCache, showClearAlert: $showClearCacheAlert)
            .padding(.bottom, 20)

        // Stats
        if !progressStore.hazardHistory.isEmpty {
            ExamStatsRow(items: [
                (value: "\(progressStore.hazardExamCount)", label: "Đã thi"),
                (value: "\(Int(progressStore.averageHazardScore * 100))%", label: "TB điểm"),
                (value: "\(progressStore.bestHazardScore)", label: "Cao nhất"),
            ])
            .padding(.bottom, 20)
        }

        // Start exam
        Button { openExam(.hazardTest(mode: .exam)) } label: {
            AppButton(icon: "play.fill", label: "Thi tình huống (10 video)")
        }
        .buttonStyle(.plain)
        .padding(.bottom, 12)

        // Full practice
        Button { openExam(.hazardTest(mode: .practice)) } label: {
            AppButton(label: "Luyện tập tất cả (120 tình huống)", style: .secondary)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 24)

        // Chapter browser
        SectionTitle(title: "Chương trình (\(HazardSituation.all.count) tình huống)")
            .padding(.bottom, 8)

        ForEach(HazardSituation.chapters, id: \.id) { chapter in
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
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.appTextDark)
                        Text("\(chapter.name) (\(chapter.range.count) TH)")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.appTextMedium)
                    }

                    Spacer(minLength: 4)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                }
                .padding(14)
                .glassCard()
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }

        // Recent history
        if !progressStore.hazardHistory.isEmpty {
            SectionTitle(title: "Lịch sử tình huống")
                .padding(.top, 16)
                .padding(.bottom, 8)

            ForEach(progressStore.hazardHistory.prefix(10), id: \.id) { result in
                NavigationLink(destination: HazardHistoryDetailView(result: result)) {
                    HistoryRow(
                        passed: result.passed,
                        scoreText: "\(result.totalScore)/\(result.maxScore) điểm",
                        date: result.date
                    )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)
            }
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

    var body: some View {
        let cached = videoCache.cachedCount
        let total = videoCache.totalCount
        let fraction = total > 0 ? Double(cached) / Double(total) : 0
        let allComplete = cached == total

        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: allComplete ? "checkmark.icloud.fill" : "icloud.and.arrow.down")
                        .font(.system(size: 15))
                        .foregroundStyle(allComplete ? Color.appSuccess : Color.appPrimary)
                    Text("Video offline")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                    Spacer()
                    Text(String(format: "%.0f MB", videoCache.cacheSizeMB))
                        .font(.system(size: 12, weight: .medium).monospacedDigit())
                        .foregroundStyle(Color.appTextLight)
                }

                VStack(alignment: .leading, spacing: 4) {
                    ProgressBarView(
                        fraction: fraction,
                        color: allComplete ? .appSuccess : .appPrimary,
                        height: 5
                    )

                    Text("\(cached)/\(total) video đã tải")
                        .font(.system(size: 12, weight: .medium).monospacedDigit())
                        .foregroundStyle(Color.appTextMedium)
                }

                // Download all / Cancel / Clear buttons
                HStack(spacing: 10) {
                    if videoCache.isDownloadingAll {
                        Button {
                            videoCache.cancelAll()
                            Haptics.impact(.medium)
                        } label: {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .tint(Color.appPrimary)
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
                        Button {
                            showClearAlert = true
                        } label: {
                            AppButton(label: "Xoá", style: .secondary, height: 36, cornerRadius: 18)
                        }
                        .frame(width: 80)
                    }
                }
            }
            .padding(16)

            // Per-chapter download rows
            if !allComplete {
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
                                        ProgressView()
                                            .scaleEffect(0.65)
                                            .tint(Color.appPrimary)
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
