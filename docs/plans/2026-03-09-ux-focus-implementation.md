# UX Focus Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restructure the app from 5 scattered tabs to 4 focused tabs that mirror the 3-part national driving exam, add a smart "next step" nudge on Home, and eliminate feature duplication.

**Architecture:** Replace the 5-tab layout (Home/Ôn tập/Thi thử/Thực hành/Tìm kiếm) with 4 tabs (Home/Lý thuyết/Mô phỏng/Tình huống). Each exam tab combines study + exam sections. Smart nudge is a pure function on `ProgressStore`. Search moves to a toolbar button on Home.

**Tech Stack:** SwiftUI, Swift 6 (strict concurrency), iOS 18+, `xcodeproj` Ruby gem for pbxproj management.

---

### Task 1: Add smart nudge function to ProgressStore

**Files:**
- Create: `GPLX2026/Core/Storage/ProgressStore+SmartNudge.swift`

**Step 1: Create the SmartNudge model and function**

```swift
// GPLX2026/Core/Storage/ProgressStore+SmartNudge.swift
import Foundation

extension ProgressStore {

    enum SmartNudge {
        case masterDiemLiet(remaining: Int)
        case weakTopic(topicName: String, topicKey: String, accuracy: Int)
        case takeExam
        case improveTopic(topicName: String, topicKey: String, accuracy: Int)
        case startSimulation
        case startHazard
        case testWeakestPart(partName: String)
        case examReady

        var label: String {
            switch self {
            case .masterDiemLiet(let remaining):
                return "Ôn điểm liệt — \(remaining) câu chưa thuộc"
            case .weakTopic(let name, _, let pct):
                return "Ôn chủ đề: \(name) (\(pct)%)"
            case .takeExam:
                return "Thi thử lý thuyết"
            case .improveTopic(let name, _, let pct):
                return "Cải thiện: \(name) (\(pct)%)"
            case .startSimulation:
                return "Bắt đầu ôn Mô phỏng"
            case .startHazard:
                return "Bắt đầu ôn Tình huống"
            case .testWeakestPart(let name):
                return "Thi thử \(name)"
            case .examReady:
                return "Sẵn sàng thi! Hãy thi thử lần nữa"
            }
        }

        var icon: String {
            switch self {
            case .masterDiemLiet: return "exclamationmark.triangle.fill"
            case .weakTopic: return "book.fill"
            case .takeExam: return "doc.text.fill"
            case .improveTopic: return "arrow.up.circle.fill"
            case .startSimulation: return "map.fill"
            case .startHazard: return "play.circle.fill"
            case .testWeakestPart: return "checkmark.circle.fill"
            case .examReady: return "star.fill"
            }
        }

        var color: String {
            switch self {
            case .masterDiemLiet: return "appError"
            case .weakTopic: return "appWarning"
            case .takeExam: return "appPrimary"
            case .improveTopic: return "appWarning"
            case .startSimulation: return "topicSaHinh"
            case .startHazard: return "appPrimary"
            case .testWeakestPart: return "appPrimary"
            case .examReady: return "appSuccess"
            }
        }
    }

    func smartNudge(topics: [Topic], allQuestions: [Question]) -> SmartNudge {
        // 1. Điểm liệt not mastered
        let dl = diemLietMastery(questions: allQuestions)
        if dl.correct < dl.total {
            return .masterDiemLiet(remaining: dl.total - dl.correct)
        }

        // 2. Any topic < 50%
        let theoryTopics = topics.filter { !$0.topicIds.contains(6) }
        let topicStats = weakTopics(topics: theoryTopics)
        if let weakest = topicStats.first, weakest.accuracy < 0.5 {
            let pct = weakest.attempted > 0 ? Int(weakest.accuracy * 100) : 0
            return .weakTopic(topicName: weakest.topic.shortName, topicKey: weakest.topic.key, accuracy: pct)
        }

        // 3. No mock exam in 3+ days
        if let lastExam = examHistory.first {
            let daysSince = Calendar.current.dateComponents([.day], from: lastExam.date, to: Date()).day ?? 0
            if daysSince >= 3 {
                return .takeExam
            }
        } else {
            // Never taken an exam
            let totalAttempted = totalAttemptedCount(topics: theoryTopics)
            if totalAttempted > 30 {
                return .takeExam
            }
        }

        // 4. Any topic 50-70%
        if let weakest = topicStats.first, weakest.accuracy < 0.7 {
            let pct = Int(weakest.accuracy * 100)
            return .improveTopic(topicName: weakest.topic.shortName, topicKey: weakest.topic.key, accuracy: pct)
        }

        // 5. Theory ≥70%, Simulation <50%
        let theoryAvg = theoryTopics.isEmpty ? 0 : theoryTopics.reduce(0.0) { $0 + topicAccuracy(for: $1.key) } / Double(theoryTopics.count)
        let simTopic = topics.first { $0.topicIds.contains(6) }
        let simAccuracy = simTopic.map { topicAccuracy(for: $0.key) } ?? 0
        if theoryAvg >= 0.7 && simAccuracy < 0.5 {
            return .startSimulation
        }

        // 6. Simulation ≥70%, Hazard <50%
        let hazardAvg = hazardHistory.isEmpty ? 0 : averageHazardScore
        if simAccuracy >= 0.7 && hazardAvg < 0.5 {
            return .startHazard
        }

        // 7. All parts ≥70%
        if theoryAvg >= 0.7 && simAccuracy >= 0.7 && hazardAvg < 0.9 {
            // Find weakest part
            let parts: [(name: String, score: Double)] = [
                ("Lý thuyết", theoryAvg),
                ("Mô phỏng", simAccuracy),
                ("Tình huống", hazardAvg),
            ]
            let weakest = parts.min(by: { $0.score < $1.score })!
            return .testWeakestPart(partName: weakest.name)
        }

        // 8. All ≥90%
        return .examReady
    }
}
```

**Step 2: Add file to Xcode project**

Run:
```bash
cd /Users/maitrungkien/Desktop/project/GPLX2026
ruby -e "
require 'xcodeproj'
proj = Xcodeproj::Project.open('GPLX2026.xcodeproj')
target = proj.targets.first
group = proj['GPLX2026']['Core']['Storage']
ref = group.new_file('GPLX2026/Core/Storage/ProgressStore+SmartNudge.swift')
target.source_build_phase.add_file_reference(ref)
proj.save
"
```

**Step 3: Build to verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add GPLX2026/Core/Storage/ProgressStore+SmartNudge.swift GPLX2026.xcodeproj
git commit -m "feat: add smart nudge function to ProgressStore"
```

---

### Task 2: Create TheoryTab (rename and rework MockExamTab)

**Files:**
- Modify: `GPLX2026/Features/Home/MockExamTab.swift` → rename to `TheoryTab.swift`

**Step 1: Rename MockExamTab.swift to TheoryTab.swift**

Rename the file on disk:
```bash
mv GPLX2026/Features/Home/MockExamTab.swift GPLX2026/Features/Home/TheoryTab.swift
```

Update the pbxproj reference:
```bash
cd /Users/maitrungkien/Desktop/project/GPLX2026
ruby -e "
require 'xcodeproj'
proj = Xcodeproj::Project.open('GPLX2026.xcodeproj')
proj.files.each do |f|
  if f.path&.end_with?('MockExamTab.swift')
    f.path = f.path.sub('MockExamTab.swift', 'TheoryTab.swift')
    f.name = 'TheoryTab.swift' if f.name == 'MockExamTab.swift'
  end
end
proj.save
"
```

**Step 2: Rewrite TheoryTab with study + exam sections**

Replace the entire file content of `TheoryTab.swift`:

```swift
import SwiftUI

struct TheoryTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var showNavPlay = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Study Section
                SectionTitle(title: "Ôn tập")

                theoryTopicsList

                allQuestionsButton

                // MARK: - Exam Section
                SectionTitle(title: "Thi thử")

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

                if !progressStore.examHistory.isEmpty {
                    ExamStatsRow(items: [
                        (value: "\(progressStore.examCount)", label: "Đã thi"),
                        (value: "\(Int(progressStore.averageExamScore * 100))%", label: "TB đúng"),
                        (value: "\(Int(progressStore.bestExamScore * 100))%", label: "Cao nhất"),
                    ])
                }

                fixedExamSets

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
        .screenHeader("Lý thuyết")
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

    // MARK: - Study: Topic cards (Topics 1-5 only)

    @ViewBuilder
    private var theoryTopicsList: some View {
        let theoryTopics = questionStore.topics.filter { !$0.topicIds.contains(6) }
        let topicStats = progressStore.weakTopics(topics: theoryTopics)
            .sorted { $0.topic.topicIds.first ?? 0 < $1.topic.topicIds.first ?? 0 }

        VStack(spacing: 0) {
            ForEach(Array(topicStats.enumerated()), id: \.element.topic.id) { index, item in
                NavigationLink(destination: TopicDetailView(item: item)) {
                    TheoryTopicRow(item: item)
                }
                .buttonStyle(.plain)

                if index < topicStats.count - 1 {
                    Divider().padding(.horizontal, 16)
                }
            }
        }
        .glassCard()
    }

    // MARK: - Study: All questions button

    @ViewBuilder
    private var allQuestionsButton: some View {
        let theoryTopics = questionStore.topics.filter { !$0.topicIds.contains(6) }
        let theoryCount = theoryTopics.reduce(0) { $0 + $1.questionCount }

        Button {
            openExam(.questionView(topicKey: AppConstants.TopicKey.allQuestions, startIndex: 0))
        } label: {
            ListItemCard(
                icon: "text.book.closed.fill",
                title: "Tất cả câu hỏi",
                subtitle: "\(theoryCount) câu lý thuyết",
                iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                iconColor: .appPrimary
            ) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.appTextLight)
            }
        }
        .glassCard()
    }

    // MARK: - Exam: Fixed sets (same as old MockExamTab)

    @ViewBuilder
    private var fixedExamSets: some View {
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
    }
}

// MARK: - Theory Topic Row

private struct TheoryTopicRow: View {
    let item: (topic: Topic, accuracy: Double, correct: Int, attempted: Int, total: Int)

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

        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color.appDivider, lineWidth: 4)
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(statusInfo.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: item.topic.sfSymbol)
                    .font(.system(size: 18))
                    .foregroundStyle(statusInfo.color)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 5) {
                Text(item.topic.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text("\(item.correct)/\(item.total)")
                        .font(.system(size: 13, weight: .semibold).monospacedDigit())
                        .foregroundStyle(statusInfo.color)
                    Text("câu đúng")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextLight)
                }
            }

            Spacer(minLength: 4)

            StatusBadge(text: statusInfo.label, color: statusInfo.color, fontSize: 11)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appTextLight)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
```

**Step 3: Build to verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5`
Expected: May fail because HomeView still references MockExamTab — that's OK, we fix it in Task 5.

**Step 4: Commit**

```bash
git add GPLX2026/Features/Home/TheoryTab.swift GPLX2026.xcodeproj
git add -u GPLX2026/Features/Home/MockExamTab.swift
git commit -m "feat: rename MockExamTab to TheoryTab with study + exam sections"
```

---

### Task 3: Create HazardTab (extract hazard content from SimulationTab)

**Files:**
- Create: `GPLX2026/Features/Home/HazardTab.swift`

**Step 1: Create HazardTab.swift**

```swift
import SwiftUI

struct HazardTab: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(HazardVideoCache.self) private var videoCache
    @Environment(\.openExam) private var openExam
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var showNavPlay = false
    @State private var showClearCacheAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Study Section
                SectionTitle(title: "Ôn tập")

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

                // Download management
                HazardDownloadCard(videoCache: videoCache, showClearAlert: $showClearCacheAlert)

                // MARK: - Exam Section
                SectionTitle(title: "Thi thử")

                ExamCTACard(
                    buttonLabel: "Thi tình huống (10 video)",
                    rules: [
                        (icon: "play.rectangle", text: "10 video"),
                        (icon: "hand.tap", text: "Nhấn nhanh"),
                        (icon: "star", text: "≥ 35/50"),
                    ],
                    tip: "Nhấn sớm khi vừa thấy nguy hiểm để đạt điểm cao nhất.",
                    action: { openExam(.hazardTest(mode: .exam)) },
                    onButtonHidden: { hidden in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showNavPlay = hidden
                        }
                    }
                )

                if !progressStore.hazardHistory.isEmpty {
                    ExamStatsRow(items: [
                        (value: "\(progressStore.hazardExamCount)", label: "Đã thi"),
                        (value: "\(Int(progressStore.averageHazardScore * 100))%", label: "TB điểm"),
                        (value: "\(progressStore.bestHazardScore)", label: "Cao nhất"),
                    ])
                }

                if !progressStore.hazardHistory.isEmpty {
                    SectionTitle(title: "Lịch sử")

                    HistoryList(
                        results: progressStore.hazardHistory,
                        scoreText: { "\($0.totalScore)/\($0.maxScore) điểm" },
                        passed: \.passed,
                        date: \.date,
                        destination: { HazardHistoryDetailView(result: $0) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .screenHeader("Tình huống")
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
                    Button { openExam(.hazardTest(mode: .exam)) } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primaryColor(for: primaryColorKey))
                    }
                }
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
```

**Step 2: Add file to Xcode project**

```bash
cd /Users/maitrungkien/Desktop/project/GPLX2026
ruby -e "
require 'xcodeproj'
proj = Xcodeproj::Project.open('GPLX2026.xcodeproj')
target = proj.targets.first
group = proj['GPLX2026']['Features']['Home']
ref = group.new_file('GPLX2026/Features/Home/HazardTab.swift')
target.source_build_phase.add_file_reference(ref)
proj.save
"
```

**Step 3: Commit**

```bash
git add GPLX2026/Features/Home/HazardTab.swift GPLX2026.xcodeproj
git commit -m "feat: create HazardTab with study + exam sections"
```

---

### Task 4: Repurpose SimulationTab for Part 2 only

**Files:**
- Modify: `GPLX2026/Features/Home/SimulationTab.swift`

**Step 1: Rewrite SimulationTab to show only Mô phỏng (Part 2)**

Replace the entire file content. Remove the segmented picker, hazard content, and `HazardDownloadCard`. Add Topic 6 study section at top.

```swift
import SwiftUI

struct SimulationTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var showNavPlay = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Study Section
                SectionTitle(title: "Ôn tập")

                simulationTopicCard

                allScenariosButton

                // MARK: - Exam Section
                SectionTitle(title: "Thi thử")

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

                if !progressStore.simulationHistory.isEmpty {
                    ExamStatsRow(items: [
                        (value: "\(progressStore.simulationExamCount)", label: "Đã thi"),
                        (value: "\(Int(progressStore.averageSimulationScore * 100))%", label: "TB đúng"),
                        (value: "\(Int(progressStore.bestSimulationScore * 100))%", label: "Cao nhất"),
                    ])
                }

                if !progressStore.simulationHistory.isEmpty {
                    SectionTitle(title: "Lịch sử")

                    HistoryList(
                        results: progressStore.simulationHistory,
                        scoreText: { "\($0.score)/\($0.totalScenarios) đúng" },
                        passed: \.passed,
                        date: \.date,
                        destination: { SimulationHistoryDetailView(result: $0) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
        .screenHeader("Mô phỏng")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if showNavPlay {
                    Button { openExam(.simulationExam(mode: .random)) } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primaryColor(for: primaryColorKey))
                    }
                }
            }
        }
    }

    // MARK: - Study: Topic 6 card with question grid

    @ViewBuilder
    private var simulationTopicCard: some View {
        let topic6 = questionStore.topics.first { $0.topicIds.contains(6) }
        if let topic = topic6 {
            let questions = questionStore.questionsForTopic(key: topic.key)
            NavigationLink(destination: TopicsView(initialTopicKey: topic.key)) {
                HStack(spacing: 14) {
                    IconBox(icon: topic.icon, color: topic.color, size: 40, cornerRadius: 10, iconFontSize: 18)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(topic.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.appTextDark)

                        let prog = progressStore.topicProgress(for: topic.key)
                        let correct = prog.values.filter { $0 }.count
                        Text("\(correct)/\(questions.count) câu đúng")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.appTextMedium)
                    }

                    Spacer(minLength: 4)

                    let prog = progressStore.topicProgress(for: topic.key)
                    let fraction = questions.isEmpty ? 0.0 : Double(prog.values.filter { $0 }.count) / Double(questions.count)
                    Text("\(Int(fraction * 100))%")
                        .font(.system(size: 15, weight: .bold).monospacedDigit())
                        .foregroundStyle(fraction >= 1.0 ? Color.appSuccess : Color.appTextMedium)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .glassCard()
        }
    }

    // MARK: - Study: All scenarios button

    @ViewBuilder
    private var allScenariosButton: some View {
        let topic6 = questionStore.topics.first { $0.topicIds.contains(6) }
        if let topic = topic6 {
            let questions = questionStore.questionsForTopic(key: topic.key)
            Button {
                openExam(.questionView(topicKey: topic.key, startIndex: 0))
            } label: {
                ListItemCard(
                    icon: "photo.on.rectangle.angled",
                    title: "Luyện tất cả sa hình",
                    subtitle: "\(questions.count) tình huống",
                    iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                    iconColor: .topicSaHinh
                ) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                }
            }
            .glassCard()
        }
    }
}
```

**Step 2: Commit**

```bash
git add GPLX2026/Features/Home/SimulationTab.swift
git commit -m "refactor: repurpose SimulationTab for Part 2 (Mô phỏng) only"
```

---

### Task 5: Update HomeView tab structure (5 → 4 tabs)

**Files:**
- Modify: `GPLX2026/Features/Home/HomeView.swift`

**Step 1: Replace tab definitions**

Replace the entire body of `HomeView` to use 4 tabs with the new structure:

```swift
import SwiftUI

struct HomeView: View {
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var activeExam: ExamScreen?

    private var accentColor: Color {
        Color.primaryColor(for: primaryColorKey)
    }

    var body: some View {
        TabView {
            Tab("Trang chủ", systemImage: "house") {
                NavigationStack {
                    HomeTab()
                }
                .tint(accentColor)
            }

            Tab("Lý thuyết", systemImage: "book") {
                NavigationStack {
                    TheoryTab()
                }
                .tint(accentColor)
            }

            Tab("Mô phỏng", systemImage: "map") {
                NavigationStack {
                    SimulationTab()
                }
                .tint(accentColor)
            }

            Tab("Tình huống", systemImage: "play.circle") {
                NavigationStack {
                    HazardTab()
                }
                .tint(accentColor)
            }
        }
        .tint(accentColor)
        .environment(\.openExam) { screen in activeExam = screen }
        .fullScreenCover(item: $activeExam) { exam in
            NavigationStack {
                exam.destination
            }
            .environment(\.popToRoot) { activeExam = nil }
            .environment(\.openExam) { newScreen in activeExam = newScreen }
            .tint(accentColor)
        }
    }
}
```

**Step 2: Build to verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED (StudyMenuView and QuestionSearchView are still in the project but just not used from tabs — no error)

**Step 3: Commit**

```bash
git add GPLX2026/Features/Home/HomeView.swift
git commit -m "refactor: update HomeView from 5 tabs to 4 (Home, Lý thuyết, Mô phỏng, Tình huống)"
```

---

### Task 6: Update HomeTab (add smart nudge, utilities, search, reference)

**Files:**
- Modify: `GPLX2026/Features/Home/HomeTab.swift`

**Step 1: Add smart nudge card and utility sections**

Update `HomeTab` body to include the new sections. Add `SmartNudgeCard` and utility sections. The `QuickActionsGrid` is replaced with a simpler utility grid (Flashcard, Điểm liệt, Câu sai, Đánh dấu). Add search to toolbar. Add Tra cứu section at bottom.

Replace the `HomeTab` struct's body:

```swift
struct HomeTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ProgressHeroCard()
                SmartNudgeCard()
                UtilityGrid()
                TopicProgressSection()
                RecentResultsCard()
                ReferenceSection()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .screenHeader("Trang chủ")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: BadgesView()) {
                    Image(systemName: "trophy")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.appTextDark)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    NavigationLink(destination: QuestionSearchView()) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.appTextDark)
                    }
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.appTextDark)
                    }
                }
            }
        }
    }
}
```

**Step 2: Add SmartNudgeCard**

Add this struct after the `HomeTab` struct (before `ProgressHeroCard`):

```swift
// MARK: - Smart Nudge Card

private struct SmartNudgeCard: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    var body: some View {
        let nudge = progressStore.smartNudge(
            topics: questionStore.topics,
            allQuestions: questionStore.allQuestions
        )

        Button { handleNudgeTap(nudge) } label: {
            HStack(spacing: 14) {
                Image(systemName: nudge.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(nudgeColor(nudge))
                    .frame(width: 44, height: 44)
                    .background(nudgeColor(nudge).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Tiếp theo")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                        .textCase(.uppercase)
                    Text(nudge.label)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.appTextDark)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(nudgeColor(nudge))
            }
            .padding(16)
            .glassCard()
        }
        .buttonStyle(.plain)
    }

    private func nudgeColor(_ nudge: ProgressStore.SmartNudge) -> Color {
        switch nudge {
        case .masterDiemLiet: return .appError
        case .weakTopic, .improveTopic: return .appWarning
        case .takeExam, .startHazard, .testWeakestPart: return .appPrimary
        case .startSimulation: return .topicSaHinh
        case .examReady: return .appSuccess
        }
    }

    private func handleNudgeTap(_ nudge: ProgressStore.SmartNudge) {
        switch nudge {
        case .masterDiemLiet:
            openExam(.questionView(topicKey: AppConstants.TopicKey.diemLiet, startIndex: 0))
        case .weakTopic(_, let key, _), .improveTopic(_, let key, _):
            openExam(.questionView(topicKey: key, startIndex: 0))
        case .takeExam:
            openExam(.mockExam())
        case .startSimulation:
            // Navigate to simulation — open Topic 6 study
            if let topic6 = QuestionStore().topics.first(where: { $0.topicIds.contains(6) }) {
                openExam(.questionView(topicKey: topic6.key, startIndex: 0))
            }
        case .startHazard:
            openExam(.hazardTest(mode: .practice))
        case .testWeakestPart:
            openExam(.mockExam())
        case .examReady:
            openExam(.mockExam())
        }
    }
}
```

**Step 3: Replace QuickActionsGrid with UtilityGrid**

Replace the existing `QuickActionsGrid` struct with:

```swift
// MARK: - Utility Grid

private struct UtilityGrid: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        let dlMastery = progressStore.diemLietMastery(questions: questionStore.allQuestions)
        let wrongCount = progressStore.wrongAnswers.count
        let bookmarkCount = progressStore.bookmarks.count

        LazyVGrid(columns: columns, spacing: 12) {
            QuickActionCard(
                icon: "rectangle.on.rectangle.angled",
                title: "Flashcard",
                subtitle: "Lật thẻ ôn nhanh",
                color: .topicSaHinh
            ) {
                openExam(.flashcard(topicKey: AppConstants.TopicKey.allQuestions))
            }

            QuickActionCard(
                icon: "exclamationmark.triangle.fill",
                title: "Điểm liệt",
                subtitle: "\(dlMastery.correct)/\(dlMastery.total) đã đúng",
                color: dlMastery.correct == dlMastery.total && dlMastery.total > 0 ? .appSuccess : .appError
            ) {
                openExam(.questionView(topicKey: AppConstants.TopicKey.diemLiet, startIndex: 0))
            }

            NavigationLink(destination: WrongAnswersView()) {
                QuickActionCardContent(
                    icon: "xmark.circle.fill",
                    title: "Câu sai",
                    subtitle: wrongCount > 0 ? "\(wrongCount) câu" : "Chưa có",
                    color: wrongCount > 0 ? .appWarning : .appTextLight
                )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: BookmarksView()) {
                QuickActionCardContent(
                    icon: "bookmark.fill",
                    title: "Đã đánh dấu",
                    subtitle: bookmarkCount > 0 ? "\(bookmarkCount) câu" : "Chưa có",
                    color: bookmarkCount > 0 ? .topicCauTao : .appTextLight
                )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct QuickActionCardContent: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextMedium)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassCard()
    }
}
```

**Step 4: Add ReferenceSection**

Add this at the end of the file (before the closing, after RecentResultsCard):

```swift
// MARK: - Reference Section

private struct ReferenceSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tra cứu")
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(Color.appTextDark)

            VStack(spacing: 0) {
                NavigationLink(destination: TrafficSignsReferenceView()) {
                    ListItemCard(
                        icon: "diamond.fill",
                        title: "Biển báo giao thông",
                        subtitle: "47 biển báo phổ biến",
                        iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                        iconColor: .topicBienBao,
                        showCard: false
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appTextLight)
                    }
                }

                Divider().padding(.horizontal, 16)

                NavigationLink(destination: SpeedDistanceReferenceView()) {
                    ListItemCard(
                        icon: "speedometer",
                        title: "Tốc độ & Quy tắc",
                        subtitle: "Tốc độ, khoảng cách, mức phạt",
                        iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                        iconColor: .topicSaHinh,
                        showCard: false
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appTextLight)
                    }
                }
            }
            .glassCard()
        }
    }
}
```

**Step 5: Build to verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add GPLX2026/Features/Home/HomeTab.swift
git commit -m "feat: update HomeTab with smart nudge, utility grid, search toolbar, reference section"
```

---

### Task 7: Clean up — remove StudyMenuView references and unused code

**Files:**
- Delete: `GPLX2026/Features/Topics/StudyMenuView.swift` (no longer used — was the Ôn tập tab)
- Check for any remaining references to `StudyMenuView` or `MockExamTab`

**Step 1: Search for remaining references**

```bash
grep -r "StudyMenuView\|MockExamTab" GPLX2026/ --include="*.swift" -l
```

If any files still reference these, update them.

**Step 2: Remove StudyMenuView from project**

```bash
cd /Users/maitrungkien/Desktop/project/GPLX2026
ruby -e "
require 'xcodeproj'
proj = Xcodeproj::Project.open('GPLX2026.xcodeproj')
proj.files.each do |f|
  if f.path&.end_with?('StudyMenuView.swift')
    f.build_files.each { |bf| bf.remove_from_project }
    f.remove_from_project
  end
end
proj.save
"
rm GPLX2026/Features/Topics/StudyMenuView.swift
```

**Step 3: Build to verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add -u
git add GPLX2026.xcodeproj
git commit -m "chore: remove StudyMenuView (content redistributed to new tabs)"
```

---

### Task 8: Fix SmartNudgeCard navigation for tab-switching nudges

**Files:**
- Modify: `GPLX2026/Features/Home/HomeTab.swift`

The `SmartNudgeCard.handleNudgeTap` for `.startSimulation` creates a new `QuestionStore()` which is incorrect. Fix it to use the environment store. Also, for nudges that suggest switching tabs (startSimulation, startHazard), these should use `openExam` to open the relevant study view directly.

**Step 1: Fix the handleNudgeTap method**

In `SmartNudgeCard`, update the `handleNudgeTap` to use the environment `questionStore`:

```swift
    private func handleNudgeTap(_ nudge: ProgressStore.SmartNudge) {
        switch nudge {
        case .masterDiemLiet:
            openExam(.questionView(topicKey: AppConstants.TopicKey.diemLiet, startIndex: 0))
        case .weakTopic(_, let key, _), .improveTopic(_, let key, _):
            openExam(.questionView(topicKey: key, startIndex: 0))
        case .takeExam, .testWeakestPart, .examReady:
            openExam(.mockExam())
        case .startSimulation:
            let topic6Key = questionStore.topics.first { $0.topicIds.contains(6) }?.key ?? "6"
            openExam(.questionView(topicKey: topic6Key, startIndex: 0))
        case .startHazard:
            openExam(.hazardTest(mode: .practice))
        }
    }
```

**Step 2: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add GPLX2026/Features/Home/HomeTab.swift
git commit -m "fix: use environment QuestionStore in SmartNudgeCard navigation"
```

---

### Task 9: Final build, install, and verify on device

**Step 1: Clean build**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' clean build 2>&1 | tail -10`
Expected: BUILD SUCCEEDED

**Step 2: Install on device**

Find the .app path from the build output and install:
```bash
xcrun devicectl device install app --device 00008120-0016116A1103C01E <app_path>
```

**Step 3: Verify checklist**

- [ ] App launches with 4 tabs: Trang chủ, Lý thuyết, Mô phỏng, Tình huống
- [ ] Home tab shows: ProgressHero, SmartNudge, UtilityGrid (4 items), TopicProgress, RecentResults, Reference
- [ ] Home toolbar: trophy (left), search + settings (right)
- [ ] Search button opens QuestionSearchView
- [ ] SmartNudge card shows correct recommendation and navigates on tap
- [ ] Lý thuyết tab: Topics 1-5 study section + mock exam section with fixed sets
- [ ] Mô phỏng tab: Topic 6 study + simulation exam section
- [ ] Tình huống tab: chapters + download management + hazard exam section
- [ ] No "Ôn tập" tab visible
- [ ] No "Tìm kiếm" tab visible
- [ ] All existing exam/study flows still work (mock exam, simulation, hazard)

**Step 4: Final commit (if any fixes needed)**

```bash
git add -A
git commit -m "feat: complete UX focus redesign — 4 tabs mirroring national exam structure"
```
