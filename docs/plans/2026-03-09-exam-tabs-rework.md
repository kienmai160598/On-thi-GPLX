# Exam Tabs Rework Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Reorganize the app's 5 tabs to mirror the 3-part Vietnamese B2 national driving exam: Lý thuyết (theory), Mô phỏng (scenario simulation), Tình huống (video hazard perception).

**Architecture:** Replace "Ôn tập" and "Thực hành" tabs with "Lý thuyết" and "Mô phỏng" tabs. Each exam-part tab contains both study and exam modes. Utility features (flashcard, bookmarks, wrong answers, reference) move to Home tab. "Tình huống" tab is the old hazard section extracted standalone.

**Tech Stack:** SwiftUI, iOS 18+, `@Observable` stores, existing `ExamScreen` routing via `openExam` environment action, shared UI components (`ExamCTACard`, `ExamStatsRow`, `HistoryList`, `SectionTitle`, `ListItemCard`, `TopicCard`).

---

## Key Reference

| File | Role |
|------|------|
| `Features/Home/HomeView.swift` | TabView with 5 tabs — update tab definitions |
| `Features/Home/HomeTab.swift` | Dashboard — add utility sections |
| `Features/Home/MockExamTab.swift` | Theory exam tab — expand to include study mode |
| `Features/Home/SimulationTab.swift` | Current combined tab — extract hazard, remove simulation |
| `Features/Topics/StudyMenuView.swift` | Current study menu — will be deleted |
| `Features/Topics/TopicsView.swift` | Topic grid with question numbers — reused in Lý thuyết and Mô phỏng |
| `Core/Models/Topic.swift` | 5 topics: 1+2, 3, 4, 5, 6 — Topic 6 goes to Mô phỏng |
| `Core/Theme/AppTheme.swift:159-186` | `ExamScreen` enum + `openExam` routing — unchanged |
| `Core/Common/Utilities/AppConstants.swift` | Exam configs — unchanged |
| `Core/Storage/QuestionStore.swift` | `questionsForTopic(key:)`, `topics` — unchanged |
| `Core/Storage/ProgressStore.swift` | All history/progress data — unchanged |

## Shared UI Components (all in `Core/Common/`)
- `ExamCTACard` — big CTA button with rules/tip
- `ExamStatsRow` — horizontal stats (exam count, average, best)
- `HistoryList` — generic history list with navigation
- `SectionTitle` — section header text
- `ListItemCard` — icon + title + subtitle row
- `AppButton` — styled button
- `TopicCard` — topic header + question number grid (in `TopicsView.swift`)

---

### Task 1: Create LyThuyetTab (Theory — Exam Part 1)

New file combining Topics 1-5 study + 35-question mock exam.

**Files:**
- Create: `GPLX2026/Features/Home/LyThuyetTab.swift`
- Reference: `Features/Home/MockExamTab.swift` (exam section to move here)
- Reference: `Features/Topics/TopicsView.swift` (TopicCard to reuse for study)

**Step 1: Create `LyThuyetTab.swift`**

This tab has a segmented picker: "Ôn tập" (study) / "Thi thử" (exam).

```swift
import SwiftUI

struct LyThuyetTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var selectedSection: Section = .study
    @State private var showNavPlay = false

    private enum Section: String, CaseIterable {
        case study = "Ôn tập"
        case exam = "Thi thử"
    }

    /// Topics 1-5 only (exclude Topic 6 which belongs to Mô phỏng tab)
    private var theoryTopics: [Topic] {
        questionStore.topics.filter { $0.topicIds.first != 6 }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Picker("", selection: $selectedSection) {
                    ForEach(Section.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                switch selectedSection {
                case .study: studyContent
                case .exam: examContent
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

    // MARK: - Study Content

    @ViewBuilder
    private var studyContent: some View {
        // All theory questions button
        let theoryCount = theoryTopics.reduce(0) { $0 + questionStore.questionsForTopic(key: $1.key).count }

        VStack(spacing: 0) {
            Button {
                openExam(.questionView(topicKey: AppConstants.TopicKey.allQuestions, startIndex: 0))
            } label: {
                ListItemCard(
                    icon: "text.book.closed.fill",
                    title: "Tất cả câu hỏi lý thuyết",
                    subtitle: "\(theoryCount) câu theo thứ tự",
                    iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                    iconColor: .appPrimary,
                    showCard: false
                ) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                }
            }
        }
        .glassCard()

        // Topic cards with question grids
        ForEach(theoryTopics, id: \.id) { topic in
            let questions = questionStore.questionsForTopic(key: topic.key)
            if !questions.isEmpty {
                TopicCard(
                    topic: topic,
                    questions: questions,
                    progressStore: progressStore,
                    onTapQuestion: { openExam(.questionView(topicKey: topic.key, startIndex: $0)) }
                )
            }
        }
    }

    // MARK: - Exam Content (moved from MockExamTab)

    @ViewBuilder
    private var examContent: some View {
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
                withAnimation(.easeInOut(duration: 0.2)) { showNavPlay = hidden }
            }
        )

        if !progressStore.examHistory.isEmpty {
            ExamStatsRow(items: [
                (value: "\(progressStore.examCount)", label: "Đã thi"),
                (value: "\(Int(progressStore.averageExamScore * 100))%", label: "TB đúng"),
                (value: "\(Int(progressStore.bestExamScore * 100))%", label: "Cao nhất"),
            ])
        }

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
}
```

**Step 2: Make `TopicCard` accessible from outside `TopicsView.swift`**

Currently `TopicCard` is `private` inside `TopicsView.swift`. Change its access to `internal` (remove `private`).

In `GPLX2026/Features/Topics/TopicsView.swift`, change line 86:
```
private struct TopicCard: View {
```
to:
```
struct TopicCard: View {
```

Also change line 174 (`QuestionNumberCell`):
```
private struct QuestionNumberCell: View {
```
to:
```
struct QuestionNumberCell: View {
```

**Step 3: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016106A1103C01E' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add GPLX2026/Features/Home/LyThuyetTab.swift GPLX2026/Features/Topics/TopicsView.swift
git commit -m "feat: add LyThuyetTab with theory study (Topics 1-5) + mock exam"
```

---

### Task 2: Create MoPhongTab (Scenario Simulation — Exam Part 2)

New file for Topic 6 study + 20-question simulation exam.

**Files:**
- Create: `GPLX2026/Features/Home/MoPhongTab.swift`
- Reference: `Features/Home/SimulationTab.swift` (simulation section to move here)
- Reference: `Features/Topics/TopicsView.swift` (TopicCard for Topic 6 study)

**Step 1: Create `MoPhongTab.swift`**

```swift
import SwiftUI

struct MoPhongTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var selectedSection: Section = .study
    @State private var showNavPlay = false

    private enum Section: String, CaseIterable {
        case study = "Ôn tập"
        case exam = "Thi thử"
    }

    /// Topic 6 only
    private var saHinhTopic: Topic? {
        questionStore.topics.first { $0.topicIds.contains(6) }
    }

    private var saHinhQuestions: [Question] {
        questionStore.questionsForTopic(key: "6")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Picker("", selection: $selectedSection) {
                    ForEach(Section.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                switch selectedSection {
                case .study: studyContent
                case .exam: examContent
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

    // MARK: - Study Content

    @ViewBuilder
    private var studyContent: some View {
        if let topic = saHinhTopic {
            // Topic description
            VStack(alignment: .leading, spacing: 8) {
                Text(topic.topicDescription)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appTextMedium)
            }

            // Topic card with question number grid
            TopicCard(
                topic: topic,
                questions: saHinhQuestions,
                progressStore: progressStore,
                onTapQuestion: { openExam(.questionView(topicKey: "6", startIndex: $0)) }
            )
        }
    }

    // MARK: - Exam Content (moved from SimulationTab)

    @ViewBuilder
    private var examContent: some View {
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
                withAnimation(.easeInOut(duration: 0.2)) { showNavPlay = hidden }
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
}
```

**Step 2: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016106A1103C01E' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add GPLX2026/Features/Home/MoPhongTab.swift
git commit -m "feat: add MoPhongTab with Topic 6 study + simulation exam"
```

---

### Task 3: Create TinhHuongTab (Video Hazard Perception — Exam Part 3)

Extract the hazard section from SimulationTab into its own standalone tab.

**Files:**
- Create: `GPLX2026/Features/Home/TinhHuongTab.swift`
- Reference: `Features/Home/SimulationTab.swift` (hazard section to extract)

**Step 1: Create `TinhHuongTab.swift`**

This is the `hazardContent` from `SimulationTab.swift` extracted into its own view, plus the `HazardDownloadCard` and `chapterIcon` helper. No segmented picker needed.

```swift
import SwiftUI

struct TinhHuongTab: View {
    @Environment(ProgressStore.self) private var progressStore
    @Environment(HazardVideoCache.self) private var videoCache
    @Environment(\.openExam) private var openExam
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var showNavPlay = false
    @State private var showClearCacheAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // CTA + Rules
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
                        withAnimation(.easeInOut(duration: 0.2)) { showNavPlay = hidden }
                    }
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
```

**Step 2: Make `HazardDownloadCard` accessible**

`HazardDownloadCard` is currently `private` in `SimulationTab.swift`. Move it to its own file or make it `internal`. Since we'll delete `SimulationTab.swift` later, for now just mark it — it will be moved in a later task.

Actually, since `TinhHuongTab.swift` will replace `SimulationTab.swift`, we need to include `HazardDownloadCard` in `TinhHuongTab.swift`. Copy the `HazardDownloadCard` struct into `TinhHuongTab.swift` (after the main struct). It's ~155 lines from `SimulationTab.swift` lines 216-371.

**Step 3: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016106A1103C01E' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add GPLX2026/Features/Home/TinhHuongTab.swift
git commit -m "feat: add TinhHuongTab with hazard perception study + exam"
```

---

### Task 4: Add Utility Sections to HomeTab

Move flashcard, critical questions, wrong answers, bookmarks, and reference sections from `StudyMenuView` into `HomeTab`.

**Files:**
- Modify: `GPLX2026/Features/Home/HomeTab.swift`
- Reference: `Features/Topics/StudyMenuView.swift` (sections to move)

**Step 1: Add utility sections to HomeTab**

In `HomeTab.swift`, add new sections after `RecentResultsCard()` inside the VStack (after line 15). Add these new section views:

```swift
// Inside HomeTab body VStack, after RecentResultsCard():
UtilitySection()
ReferenceSection()
```

**Step 2: Create the UtilitySection and ReferenceSection private structs**

Add at the bottom of `HomeTab.swift`:

```swift
// MARK: - Utility Section

private struct UtilitySection: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam

    var body: some View {
        let dlMastery = progressStore.diemLietMastery(questions: questionStore.allQuestions)
        let wrongCount = progressStore.wrongAnswers.count
        let bookmarkCount = progressStore.bookmarks.count

        VStack(alignment: .leading, spacing: 14) {
            Text("Công cụ")
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(Color.appTextDark)

            VStack(spacing: 0) {
                Button { openExam(.flashcard(topicKey: AppConstants.TopicKey.allQuestions)) } label: {
                    ListItemCard(
                        icon: "rectangle.on.rectangle.angled",
                        title: "Flashcard",
                        subtitle: "Lật thẻ ôn nhanh",
                        iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                        iconColor: .topicSaHinh,
                        showCard: false
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appTextLight)
                    }
                }

                Divider().padding(.horizontal, 16)

                NavigationLink(destination: CriticalQuestionsTab()) {
                    ListItemCard(
                        icon: "exclamationmark.triangle.fill",
                        title: "Câu điểm liệt",
                        subtitle: "\(dlMastery.correct)/\(dlMastery.total) đã đúng",
                        iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                        iconColor: .appError,
                        showCard: false
                    ) {
                        if dlMastery.correct == dlMastery.total && dlMastery.total > 0 {
                            StatusBadge(text: "Done", color: .appSuccess, fontSize: 10)
                        }
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appTextLight)
                    }
                }

                Divider().padding(.horizontal, 16)

                NavigationLink(destination: WrongAnswersView()) {
                    ListItemCard(
                        icon: "xmark.circle.fill",
                        title: "Câu trả lời sai",
                        subtitle: wrongCount > 0 ? "\(wrongCount) câu cần ôn lại" : "Chưa có câu sai",
                        iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                        iconColor: wrongCount > 0 ? .appWarning : .appTextLight,
                        showCard: false
                    ) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.appTextLight)
                    }
                }

                Divider().padding(.horizontal, 16)

                NavigationLink(destination: BookmarksView()) {
                    ListItemCard(
                        icon: "bookmark.fill",
                        title: "Đã đánh dấu",
                        subtitle: bookmarkCount > 0 ? "\(bookmarkCount) câu đã lưu" : "Chưa đánh dấu câu nào",
                        iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
                        iconColor: bookmarkCount > 0 ? .topicCauTao : .appTextLight,
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

**Step 3: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016106A1103C01E' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add GPLX2026/Features/Home/HomeTab.swift
git commit -m "feat: add utility and reference sections to HomeTab"
```

---

### Task 5: Update HomeView TabView + Delete Old Files

Wire up the new tabs and remove the old ones.

**Files:**
- Modify: `GPLX2026/Features/Home/HomeView.swift`
- Delete: `GPLX2026/Features/Home/SimulationTab.swift`
- Delete: `GPLX2026/Features/Home/MockExamTab.swift`
- Delete: `GPLX2026/Features/Topics/StudyMenuView.swift`

**Step 1: Update `HomeView.swift`**

Replace the TabView contents. The new tab order is:
1. Trang chủ (house)
2. Lý thuyết (book)
3. Mô phỏng (map)
4. Tình huống (play.circle)
5. Search

```swift
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
                LyThuyetTab()
            }
            .tint(accentColor)
        }

        Tab("Mô phỏng", systemImage: "map") {
            NavigationStack {
                MoPhongTab()
            }
            .tint(accentColor)
        }

        Tab("Tình huống", systemImage: "play.circle") {
            NavigationStack {
                TinhHuongTab()
            }
            .tint(accentColor)
        }

        Tab(role: .search) {
            NavigationStack {
                QuestionSearchView()
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
```

**Step 2: Delete old files**

```bash
git rm GPLX2026/Features/Home/SimulationTab.swift
git rm GPLX2026/Features/Home/MockExamTab.swift
git rm GPLX2026/Features/Topics/StudyMenuView.swift
```

**Step 3: Remove references to deleted types**

Search for any remaining references to `StudyMenuView`, `SimulationTab`, or `MockExamTab` across the codebase and remove them. The main reference is in `HomeView.swift` which we already updated.

Check Xcode project file — the deleted `.swift` files may still be referenced in `GPLX2026.xcodeproj/project.pbxproj`. If using `xcodeproj` gem, remove file references. Otherwise Xcode should handle missing files gracefully with a warning.

**Step 4: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016106A1103C01E' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: wire new exam-focused tabs, remove old Ôn tập/Thực hành tabs"
```

---

### Task 6: Update TopicsView Filter for Lý thuyết Navigation

The `TopicsView` is still used when navigating from HomeTab's topic progress section. Update it to only show Topics 1-5 (theory) since Topic 6 now lives in MoPhongTab. Also remove the `WeakTopicsView` navigation link dependency on Topic 6 if needed.

**Files:**
- Modify: `GPLX2026/Features/Topics/TopicsView.swift` (filter to Topics 1-5 by default)

**Step 1: Check if TopicsView is still used anywhere**

Search for `TopicsView()` references. It was used in `StudyMenuView` (now deleted) and potentially in `TopicDetailView`. If no longer referenced, it can stay as-is since `LyThuyetTab` has its own topic rendering.

If still used (e.g., from `WeakTopicsView` or `TopicProgressSection` in HomeTab), add a parameter to filter topics:

```swift
struct TopicsView: View {
    var excludeTopicIds: Set<Int> = []
    // ... existing code ...

    // In body, filter topics:
    let filteredTopics = questionStore.topics.filter { topic in
        excludeTopicIds.isEmpty || !topic.topicIds.contains(where: { excludeTopicIds.contains($0) })
    }
```

**Step 2: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016106A1103C01E' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add GPLX2026/Features/Topics/TopicsView.swift
git commit -m "refactor: filter TopicsView to support theory-only mode"
```

---

### Task 7: Add New Files to Xcode Project

Since this project uses `.xcodeproj` (not SPM), new files must be registered in `project.pbxproj`.

**Files:**
- Modify: `GPLX2026.xcodeproj/project.pbxproj`

**Step 1: Add files using xcodeproj gem**

```bash
ruby -e '
require "xcodeproj"
proj = Xcodeproj::Project.open("GPLX2026.xcodeproj")
target = proj.targets.first
group = proj.main_group.find_subpath("GPLX2026/Features/Home", true)

["LyThuyetTab.swift", "MoPhongTab.swift", "TinhHuongTab.swift"].each do |name|
  path = "GPLX2026/Features/Home/#{name}"
  ref = group.new_file(path)
  target.source_build_phase.add_file_reference(ref)
end

proj.save
'
```

Note: If `xcodeproj` gem is not available, open the project in Xcode and add the files manually, or add them via the pbxproj directly.

**Step 2: Also remove deleted files from pbxproj**

The `git rm` in Task 5 removes the files but pbxproj may still reference them. The build should still work (Xcode skips missing files), but clean up references if needed.

**Step 3: Build and verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016106A1103C01E' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add GPLX2026.xcodeproj/project.pbxproj
git commit -m "chore: update Xcode project file with new tab files"
```

---

### Task 8: Final Verification + Cleanup

**Step 1: Full build**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016106A1103C01E' build
```

**Step 2: Check for dead references**

Search for any remaining references to deleted types:
- `StudyMenuView`
- `SimulationTab`
- `MockExamTab`
- `SimSection`

Remove any stale references found.

**Step 3: Install and test on device**

```bash
xcrun devicectl device install app --device 00008120-0016106A1103C01E <app_path>
```

Verify:
- [ ] Home tab shows dashboard + utility sections (flashcard, điểm liệt, wrong answers, bookmarks, reference)
- [ ] Lý thuyết tab has "Ôn tập"/"Thi thử" segments — study shows Topics 1-5, exam shows 35-question mock
- [ ] Mô phỏng tab has "Ôn tập"/"Thi thử" segments — study shows Topic 6, exam shows 20-question simulation
- [ ] Tình huống tab shows hazard perception (download, chapters, practice, exam, history)
- [ ] Search tab unchanged
- [ ] All exam modes launch correctly via fullScreenCover
- [ ] All history sections show correct data
- [ ] Navigation back/forward works in all tabs

**Step 4: Final commit**

```bash
git add -A
git commit -m "fix: cleanup dead references after tab rework"
```
