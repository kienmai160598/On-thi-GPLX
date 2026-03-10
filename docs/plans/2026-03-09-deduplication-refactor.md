# Deduplication, English Naming & Core/Common Reorganization

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Eliminate ~500+ lines of duplicated code, rename Vietnamese file names to English, and reorganize Core/Common into subfolders.

**Architecture:** Extract duplicated private structs into shared components in organized Core/Common subfolders. Unify MockExamView and SimulationExamView into a single BaseExamView with a mode enum. Add `iconColor` to ListItemCard and `selectedAnswerId`/`timeUsed` to QuestionReviewRow to enable reuse.

**Tech Stack:** SwiftUI, Swift 6 (strict concurrency), iOS 18+, xcodeproj gem for pbxproj management.

---

### Task 1: Create DateFormatters utility and update models

**Files:**
- Create: `GPLX2026/Core/Common/DateFormatters.swift`
- Modify: `GPLX2026/Core/Models/ExamResult.swift`
- Modify: `GPLX2026/Core/Models/SimulationResult.swift`
- Modify: `GPLX2026/Core/Models/HazardResult.swift`

**Step 1: Create shared DateFormatters**

```swift
// GPLX2026/Core/Common/DateFormatters.swift
import Foundation

enum DateFormatters {
    nonisolated(unsafe) static let iso8601 = ISO8601DateFormatter()
}
```

**Step 2: Update ExamResult.swift**

Remove line 35 (`private nonisolated(unsafe) static let isoFormatter = ISO8601DateFormatter()`).
Replace all `Self.isoFormatter` references with `DateFormatters.iso8601`.

**Step 3: Update SimulationResult.swift**

Remove line 37 (`private nonisolated(unsafe) static let isoFormatter = ISO8601DateFormatter()`).
Replace all `Self.isoFormatter` references with `DateFormatters.iso8601`.

**Step 4: Update HazardResult.swift**

Remove line 34 (`private nonisolated(unsafe) static let isoFormatter = ISO8601DateFormatter()`).
Replace all `Self.isoFormatter` references with `DateFormatters.iso8601`.

**Step 5: Build to verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add GPLX2026/Core/Common/DateFormatters.swift GPLX2026/Core/Models/ExamResult.swift GPLX2026/Core/Models/SimulationResult.swift GPLX2026/Core/Models/HazardResult.swift
git commit -m "refactor: extract shared DateFormatters, remove 3 duplicated isoFormatter statics"
```

---

### Task 2: Extract ResultHero to shared component

**Files:**
- Create: `GPLX2026/Core/Common/ResultHero.swift`
- Modify: `GPLX2026/Features/Exam/ExamResultView.swift` — delete lines 92-150 (private ResultHero)
- Modify: `GPLX2026/Features/Simulation/SimulationResultView.swift` — delete lines 93-150 (private ResultHero)

**Step 1: Create shared ResultHero**

```swift
// GPLX2026/Core/Common/ResultHero.swift
import SwiftUI

struct ResultHero: View {
    let isPassed: Bool
    let score: Int
    let total: Int
    let subtitle: String

    @State private var animateRing = false

    private var statusColor: Color { isPassed ? .appSuccess : .appError }
    private var fraction: Double { total > 0 ? Double(score) / Double(total) : 0 }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.appDivider, lineWidth: 10)

                Circle()
                    .trim(from: 0, to: animateRing ? fraction : 0)
                    .stroke(statusColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 1.0, bounce: 0.15), value: animateRing)

                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 44, weight: .heavy).monospacedDigit())
                        .foregroundStyle(Color.appTextDark)
                        .contentTransition(.numericText())
                    Text("/\(total) câu")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appTextMedium)
                }
            }
            .frame(width: 140, height: 140)

            StatusBadge(
                text: isPassed ? "ĐẠT" : "TRƯỢT",
                color: statusColor,
                fontSize: 16
            )

            Text(subtitle)
                .font(.system(size: 15))
                .foregroundStyle(Color.appTextMedium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .glassCard()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateRing = true
            }
        }
    }
}
```

**Step 2: Delete private ResultHero from ExamResultView.swift**

Remove lines 92-150 (the `// MARK: - Result Hero` comment through the closing `}`).

**Step 3: Delete private ResultHero from SimulationResultView.swift**

Remove lines 93-150 (the `// MARK: - Result Hero` comment through the closing `}`).

**Step 4: Build to verify**

**Step 5: Commit**

```bash
git add GPLX2026/Core/Common/ResultHero.swift GPLX2026/Features/Exam/ExamResultView.swift GPLX2026/Features/Simulation/SimulationResultView.swift
git commit -m "refactor: extract shared ResultHero from ExamResultView and SimulationResultView"
```

---

### Task 3: Upgrade QuestionReviewRow to support exam result views

**Files:**
- Modify: `GPLX2026/Core/Common/QuestionReviewRow.swift` — add `selectedAnswerId` and optional `timeUsed` params, show selected wrong answer highlighting
- Modify: `GPLX2026/Features/Exam/ExamResultView.swift` — delete private ReviewRow, use QuestionReviewRow
- Modify: `GPLX2026/Features/Simulation/SimulationResultView.swift` — delete private ReviewRow, use QuestionReviewRow

**Step 1: Update QuestionReviewRow**

The existing `QuestionReviewRow` takes `status: AnswerStatus` and shows correct answers only. The result view `ReviewRow` takes `selectedAnswerId: Int?` and highlights both the selected wrong answer (red X) and the correct answer (green check). We need to add an optional `selectedAnswerId` parameter and optional `timeUsedBadge` string.

Replace the entire QuestionReviewRow struct with:

```swift
import SwiftUI

struct QuestionReviewRow: View {
    let question: Question
    let status: AnswerStatus
    var showStatusIcon: Bool = true
    var selectedAnswerId: Int? = nil
    var timeUsedBadge: String? = nil
    var onNavigate: (() -> Void)? = nil

    @State private var isExpanded = false

    private var correctAnswer: Answer {
        question.answers.first(where: \.correct) ?? question.answers.first ?? Answer(id: -1, text: "—", correct: false)
    }

    private var statusColor: Color {
        switch status {
        case .correct: Color.appSuccess
        case .wrong: Color.appError
        case .unanswered: Color.appTextLight
        }
    }

    private var statusIcon: String {
        switch status {
        case .correct: "checkmark"
        case .wrong: "xmark"
        case .unanswered: "minus"
        }
    }

    var body: some View {
        Button {
            withAnimation(.easeOut(duration: 0.25)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    if showStatusIcon {
                        Image(systemName: statusIcon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(statusColor)
                            .frame(width: 28, height: 28)
                            .background(statusColor.opacity(0.12))
                            .clipShape(Circle())
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Câu \(question.no)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.appTextMedium)

                            if question.isDiemLiet {
                                StatusBadge(text: "Điểm liệt", color: .appError, fontSize: 9, hPadding: 5, vPadding: 2)
                            }

                            if let badge = timeUsedBadge {
                                StatusBadge(text: badge, color: .appWarning, fontSize: 9, hPadding: 5, vPadding: 2)
                            }
                        }

                        Text(question.text)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appTextDark)
                            .lineLimit(isExpanded ? nil : 2)
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)

                        if !isExpanded && status == .wrong {
                            Text("Đáp án: \(correctAnswer.text)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.appSuccess)
                                .lineLimit(1)
                        }
                    }

                    Spacer(minLength: 4)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeOut(duration: 0.2), value: isExpanded)
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(question.answers, id: \.id) { answer in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: answerIcon(answer))
                                    .font(.system(size: 14))
                                    .foregroundStyle(answerColor(answer))

                                Text(answer.text)
                                    .font(.system(size: 13, weight: answer.correct ? .semibold : .regular))
                                    .foregroundStyle(answerColor(answer))
                                    .lineSpacing(2)
                                    .multilineTextAlignment(.leading)
                            }
                        }

                        if !question.tip.isEmpty {
                            ExplanationBox(content: question.tip, labelFontSize: 12, contentFontSize: 13)
                                .padding(.top, 8)
                        }

                        if let onNavigate {
                            Button(action: onNavigate) {
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil.line")
                                        .font(.system(size: 12))
                                    Text("Luyện câu này")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundStyle(Color.appPrimary)
                                .padding(.top, 4)
                            }
                        }
                    }
                    .padding(.leading, showStatusIcon ? 40 : 0)
                    .padding(.top, 10)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Answer styling

    private func answerIcon(_ answer: Answer) -> String {
        if answer.correct {
            return "checkmark.circle.fill"
        } else if selectedAnswerId == answer.id {
            return "xmark.circle.fill"
        }
        return "circle"
    }

    private func answerColor(_ answer: Answer) -> Color {
        if answer.correct {
            return .appSuccess
        } else if selectedAnswerId == answer.id {
            return .appError
        }
        return .appTextLight
    }
}
```

**Step 2: Update ExamResultView.swift review section**

Replace the ReviewRow usage (lines 64-72) with:

```swift
LazyVStack(spacing: 8) {
    ForEach(Array(questions.enumerated()), id: \.element.no) { index, question in
        let selectedId = answers[index]
        let isCorrect = selectedId != nil && question.answers.contains(where: { $0.id == selectedId && $0.correct })
        QuestionReviewRow(
            question: question,
            status: selectedId == nil ? .unanswered : isCorrect ? .correct : .wrong,
            selectedAnswerId: selectedId
        )
        .glassCard()
    }
}
```

Then delete the entire private ReviewRow struct (lines 152-267).

**Step 3: Update SimulationResultView.swift review section**

Replace the ReviewRow usage (lines 64-73) with:

```swift
LazyVStack(spacing: 8) {
    ForEach(Array(questions.enumerated()), id: \.element.no) { index, question in
        let selectedId = answers[index]
        let isCorrect = selectedId != nil && question.answers.contains(where: { $0.id == selectedId && $0.correct })
        QuestionReviewRow(
            question: question,
            status: selectedId == nil ? .unanswered : isCorrect ? .correct : .wrong,
            selectedAnswerId: selectedId,
            timeUsedBadge: selectedId == nil ? "Hết giờ" : nil
        )
        .glassCard()
    }
}
```

Then delete the entire private ReviewRow struct (lines 152-273).

**Step 4: Build to verify**

**Step 5: Commit**

```bash
git add GPLX2026/Core/Common/QuestionReviewRow.swift GPLX2026/Features/Exam/ExamResultView.swift GPLX2026/Features/Simulation/SimulationResultView.swift
git commit -m "refactor: consolidate ReviewRow into shared QuestionReviewRow with selectedAnswerId support"
```

---

### Task 4: Extract HistoryList shared component

**Files:**
- Create: `GPLX2026/Core/Common/HistoryList.swift`
- Modify: `GPLX2026/Features/Home/MockExamTab.swift` — use HistoryList
- Modify: `GPLX2026/Features/Home/SimulationTab.swift` — use HistoryList (2 occurrences)

**Step 1: Create shared HistoryList**

```swift
// GPLX2026/Core/Common/HistoryList.swift
import SwiftUI

struct HistoryList<Result: Identifiable, Destination: View>: View {
    let results: [Result]
    let scoreText: (Result) -> String
    let passed: (Result) -> Bool
    let date: (Result) -> Date
    let destination: (Result) -> Destination

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(results.prefix(10).enumerated()), id: \.element.id) { index, result in
                NavigationLink(destination: destination(result)) {
                    HistoryRow(
                        passed: passed(result),
                        scoreText: scoreText(result),
                        date: date(result)
                    )
                }
                .buttonStyle(.plain)

                if index < min(results.count, 10) - 1 {
                    Divider().padding(.leading, 60)
                }
            }
        }
        .glassCard()
    }
}
```

**Step 2: Update MockExamTab.swift**

Replace lines 109-125 (the history VStack) with:

```swift
HistoryList(
    results: progressStore.examHistory,
    scoreText: { "\($0.score)/\($0.totalQuestions) đúng" },
    passed: \.passed,
    date: \.date,
    destination: { ExamHistoryDetailView(result: $0) }
)
```

**Step 3: Update SimulationTab.swift simulation history**

Replace lines 117-133 (the simulation history VStack) with:

```swift
HistoryList(
    results: progressStore.simulationHistory,
    scoreText: { "\($0.score)/\($0.totalScenarios) đúng" },
    passed: \.passed,
    date: \.date,
    destination: { SimulationHistoryDetailView(result: $0) }
)
```

**Step 4: Update SimulationTab.swift hazard history**

Replace lines 227-243 (the hazard history VStack) with:

```swift
HistoryList(
    results: progressStore.hazardHistory,
    scoreText: { "\($0.totalScore)/\($0.maxScore) điểm" },
    passed: \.passed,
    date: \.date,
    destination: { HazardHistoryDetailView(result: $0) }
)
```

**Step 5: Build to verify**

**Step 6: Commit**

```bash
git add GPLX2026/Core/Common/HistoryList.swift GPLX2026/Features/Home/MockExamTab.swift GPLX2026/Features/Home/SimulationTab.swift
git commit -m "refactor: extract HistoryList to replace 3 duplicated history loop scaffolds"
```

---

### Task 5: Extract ExamCTACard shared component

**Files:**
- Create: `GPLX2026/Core/Common/ExamCTACard.swift`
- Modify: `GPLX2026/Features/Home/MockExamTab.swift` — use ExamCTACard
- Modify: `GPLX2026/Features/Home/SimulationTab.swift` — use ExamCTACard (2 occurrences)

**Step 1: Create shared ExamCTACard**

```swift
// GPLX2026/Core/Common/ExamCTACard.swift
import SwiftUI

struct ExamCTACard: View {
    let buttonLabel: String
    let rules: [(icon: String, text: String)]
    let tip: String
    let action: () -> Void
    var onButtonHidden: ((Bool) -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Button(action: action) {
                AppButton(icon: "play.fill", label: buttonLabel)
            }
            .buttonStyle(.plain)
            .onGeometryChange(for: Bool.self) { proxy in
                proxy.frame(in: .scrollView(axis: .vertical)).minY < 0
            } action: { hidden in
                onButtonHidden?(hidden)
            }

            HStack(spacing: 16) {
                ForEach(Array(rules.enumerated()), id: \.offset) { _, rule in
                    RulePill(icon: rule.icon, text: rule.text)
                }
            }

            Text(tip)
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextMedium)
                .lineSpacing(3)
        }
        .padding(20)
        .glassCard()
    }
}
```

**Step 2: Update MockExamTab.swift**

Replace lines 13-39 (the CTA + Rules section) with:

```swift
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
```

**Step 3: Update SimulationTab.swift simulation CTA**

Replace lines 70-96 (simulationContent CTA) with:

```swift
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
```

**Step 4: Update SimulationTab.swift hazard CTA**

Replace lines 141-160 (hazardContent CTA) with:

```swift
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
```

**Step 5: Build to verify**

**Step 6: Commit**

```bash
git add GPLX2026/Core/Common/ExamCTACard.swift GPLX2026/Features/Home/MockExamTab.swift GPLX2026/Features/Home/SimulationTab.swift
git commit -m "refactor: extract ExamCTACard to replace 3 duplicated CTA+Rules sections"
```

---

### Task 6: Extract FilterChip to shared component

**Files:**
- Create: `GPLX2026/Core/Common/FilterChip.swift`
- Modify: `GPLX2026/Features/Home/DiemLietTab.swift` — delete private FilterChip

**Step 1: Create shared FilterChip**

```swift
// GPLX2026/Core/Common/FilterChip.swift
import SwiftUI

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? Color.white : Color.appTextMedium)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.appPrimary : Color.appDivider)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
```

**Step 2: Delete private FilterChip from DiemLietTab.swift**

Remove lines 145-164 (the `// MARK: - Filter Chip` section through the closing `}`).

**Step 3: Build to verify**

**Step 4: Commit**

```bash
git add GPLX2026/Core/Common/FilterChip.swift GPLX2026/Features/Home/DiemLietTab.swift
git commit -m "refactor: move FilterChip from DiemLietTab private to shared Core/Common"
```

---

### Task 7: Add iconColor to ListItemCard, delete StudyRow

**Files:**
- Modify: `GPLX2026/Core/Common/ListItemCard.swift` — add optional `iconColor` parameter
- Modify: `GPLX2026/Features/Topics/StudyMenuView.swift` — replace StudyRow with ListItemCard, delete private StudyRow

**Step 1: Update ListItemCard to support iconColor**

Add `var iconColor: Color? = nil` parameter. In the body, use `iconColor ?? Color.primaryColor(for: primaryColorKey)`:

```swift
struct ListItemCard<Trailing: View>: View {
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    let icon: String
    let title: String
    var subtitle: String? = nil
    var iconSize: CGFloat = 36
    var iconCornerRadius: CGFloat = 9
    var iconFontSize: CGFloat = 16
    var iconColor: Color? = nil
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 12) {
            IconBox(icon: icon, color: iconColor ?? Color.primaryColor(for: primaryColorKey), size: iconSize, cornerRadius: iconCornerRadius, iconFontSize: iconFontSize)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                        .lineLimit(1)
                }
            }

            Spacer()

            trailing()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard()
    }
}

extension ListItemCard where Trailing == EmptyView {
    init(icon: String, title: String, subtitle: String? = nil, iconSize: CGFloat = 36, iconCornerRadius: CGFloat = 9, iconFontSize: CGFloat = 16, iconColor: Color? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconSize = iconSize
        self.iconCornerRadius = iconCornerRadius
        self.iconFontSize = iconFontSize
        self.iconColor = iconColor
        self.trailing = { EmptyView() }
    }
}
```

**Step 2: Update StudyMenuView.swift — replace StudyRow with ListItemCard**

Replace each `StudyRow(...)` call with a `ListItemCard(...)` call. The StudyRow uses `size: 40, cornerRadius: 10, iconFontSize: 18` — pass these as params. For the one with a trailing StatusBadge, use the trailing closure variant.

For the `DiemLietTab` navigation link that uses trailing, use:
```swift
ListItemCard(
    icon: "exclamationmark.triangle.fill",
    title: "Câu điểm liệt",
    subtitle: "\(dlMastery.correct)/\(dlMastery.total) đã đúng",
    iconSize: 40, iconCornerRadius: 10, iconFontSize: 18,
    iconColor: .appError
) {
    if dlMastery.correct == dlMastery.total && dlMastery.total > 0 {
        StatusBadge(text: "Done", color: .appSuccess, fontSize: 10)
    }
}
```

Note: ListItemCard applies `.glassCard()` internally, but in StudyMenuView the cards are grouped in a single `.glassCard()` VStack. We need to NOT use `.glassCard()` on individual items. To solve this: make `glassCard` optional on ListItemCard by adding `var applyGlassCard: Bool = true` and wrapping accordingly.

Actually, looking more carefully: StudyRow does NOT apply `.glassCard()` — the parent VStack applies it once. But ListItemCard applies `.glassCard()` internally. So we need to either:
- (a) Add a `showCard: Bool = true` param to ListItemCard, or
- (b) Keep a simplified StudyRow that wraps ListItemCard-like content without glassCard.

Option (a) is cleaner. Add `var showCard: Bool = true` to ListItemCard and conditionally apply `.glassCard()`.

**Step 3: Delete private StudyRow from StudyMenuView.swift**

Remove lines 126-162.

**Step 4: Build to verify**

**Step 5: Commit**

```bash
git add GPLX2026/Core/Common/ListItemCard.swift GPLX2026/Features/Topics/StudyMenuView.swift
git commit -m "refactor: add iconColor/showCard to ListItemCard, replace StudyRow"
```

---

### Task 8: Make BadgesView use DetailHero

**Files:**
- Modify: `GPLX2026/Features/Badges/BadgesView.swift` — replace manual hero with DetailHero

**Step 1: Replace hero section**

Replace lines 16-38 (the manual hero VStack) with:

```swift
DetailHero(
    icon: "trophy.fill",
    iconColor: .appPrimary,
    title: "\(unlocked)/\(badges.count)",
    subtitle: "thành tích đã mở khoá"
)
```

**Step 2: Build to verify**

**Step 3: Commit**

```bash
git add GPLX2026/Features/Badges/BadgesView.swift
git commit -m "refactor: use shared DetailHero in BadgesView instead of manual hero"
```

---

### Task 9: Extract shared answers helper for history detail views

**Files:**
- Modify: `GPLX2026/Features/Exam/ExamHistoryDetailView.swift`
- Modify: `GPLX2026/Features/Simulation/SimulationHistoryDetailView.swift`

**Step 1: Add a helper function**

Both views compute `answers: [Int: Int]` the same way. Since these are small views (30-40 lines each), extract a free function in one of the existing files, or just add an extension. The simplest approach: add a static helper in a small extension.

Create a tiny helper at the top of ExamHistoryDetailView.swift (or add to a utility):

Actually, both views are already very small (31 and 39 lines). The duplicated `answers` computed property is only 7 lines. The cleanest fix: add a protocol or just a free function.

Add to `ExamResult.QuestionDetail` and `SimulationResult.ScenarioDetail` a shared protocol:

```swift
// In ExamHistoryDetailView.swift, add a private helper function:
private func buildAnswersDict(from details: some Collection<(index: Int, selectedAnswerId: Int?)>) -> [Int: Int] { ... }
```

Actually, since each detail type has different property names (`questionDetails` vs `scenarioDetails`), and the computed property is only 7 lines, the duplication is minimal enough that extracting it adds more complexity than it removes. **Skip this task** — it's not worth the abstraction cost for 7 lines.

---

### Task 10: Simplify ProgressStore+ExamHistory averaging functions

**Files:**
- Modify: `GPLX2026/Core/Storage/ProgressStore+ExamHistory.swift`

**Step 1: Add private generic average helper and simplify**

```swift
import Foundation

extension ProgressStore {

    // MARK: - Helper

    private func average<T>(_ items: [T], _ value: (T) -> Double) -> Double {
        guard !items.isEmpty else { return 0 }
        return items.reduce(0.0) { $0 + value($1) } / Double(items.count)
    }

    // MARK: - Exam stats

    var averageExamScore: Double { average(examHistory, \.accuracy) }
    var bestExamScore: Double { examHistory.map(\.accuracy).max() ?? 0 }
    var examCount: Int { examHistory.count }

    // MARK: - Simulation stats

    var averageSimulationScore: Double { average(simulationHistory, \.accuracy) }
    var bestSimulationScore: Double { simulationHistory.map(\.accuracy).max() ?? 0 }
    var simulationExamCount: Int { simulationHistory.count }

    // MARK: - Hazard stats

    var averageHazardScore: Double { average(hazardHistory, \.scorePercentage) }
    var bestHazardScore: Int { hazardHistory.map(\.totalScore).max() ?? 0 }
    var hazardExamCount: Int { hazardHistory.count }
}
```

**Step 2: Build to verify**

**Step 3: Commit**

```bash
git add GPLX2026/Core/Storage/ProgressStore+ExamHistory.swift
git commit -m "refactor: simplify 3 averaging functions with generic helper"
```

---

### Task 11: Rename DiemLietTab.swift to CriticalQuestionsTab.swift

**Files:**
- Rename: `GPLX2026/Features/Home/DiemLietTab.swift` → `GPLX2026/Features/Home/CriticalQuestionsTab.swift`
- Modify: The struct name `DiemLietTab` → `CriticalQuestionsTab`
- Modify: `GPLX2026/Features/Topics/StudyMenuView.swift` — update NavigationLink destination
- Modify: `GPLX2026.xcodeproj/project.pbxproj` — update file references

**Step 1: Rename the file**

```bash
mv GPLX2026/Features/Home/DiemLietTab.swift GPLX2026/Features/Home/CriticalQuestionsTab.swift
```

**Step 2: Rename the struct inside the file**

In `CriticalQuestionsTab.swift`, replace `struct DiemLietTab: View` with `struct CriticalQuestionsTab: View`.

**Step 3: Update StudyMenuView.swift**

Replace `NavigationLink(destination: DiemLietTab())` with `NavigationLink(destination: CriticalQuestionsTab())`.

**Step 4: Update project.pbxproj**

Use the `xcodeproj` Ruby gem or manually update file references. The safest approach: `sed` the pbxproj to replace `DiemLietTab.swift` with `CriticalQuestionsTab.swift`.

**Step 5: Build to verify**

**Step 6: Commit**

```bash
git add GPLX2026/Features/Home/CriticalQuestionsTab.swift GPLX2026/Features/Topics/StudyMenuView.swift GPLX2026.xcodeproj/project.pbxproj
git rm GPLX2026/Features/Home/DiemLietTab.swift
git commit -m "refactor: rename DiemLietTab to CriticalQuestionsTab (English naming)"
```

---

### Task 12: Unify MockExamView and SimulationExamView into BaseExamView

**Files:**
- Create: `GPLX2026/Features/Exam/BaseExamView.swift`
- Modify: `GPLX2026/Features/Exam/MockExamView.swift` — thin wrapper calling BaseExamView
- Modify: `GPLX2026/Features/Simulation/SimulationExamView.swift` — thin wrapper calling BaseExamView

**Step 1: Create BaseExamView**

The two views share ~70% structure. Key differences:
- MockExam: global countdown timer, no answer confirmation, submit dialog
- Simulation: per-scenario countdown, answer confirmation + reveal, explanation shown

Create a unified view with a `Mode` enum:

```swift
// GPLX2026/Features/Exam/BaseExamView.swift
import SwiftUI

struct BaseExamView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.dismiss) private var dismiss

    let config: ExamConfig

    struct ExamConfig {
        enum Mode {
            case mockExam(examSetId: Int?)
            case simulation(SimulationExamView.Mode)
        }
        let mode: Mode
    }

    // MARK: - State

    @State private var questions: [Question] = []
    @State private var currentIndex = 0
    @State private var answers: [Int: Int] = [:]
    @State private var timePerScenario: [Int: Int] = [:]
    @State private var remainingSeconds = 0
    @State private var showSubmitDialog = false
    @State private var showExitDialog = false
    @State private var navigateToResult = false
    @State private var timer: Timer?
    @State private var selectedAnswerId: Int?
    @State private var isRevealed = false

    // Results
    @State private var examResult: ExamResult?
    @State private var simulationResult: SimulationResult?

    // MARK: - Computed

    private var isMockExam: Bool {
        if case .mockExam = config.mode { return true }
        return false
    }

    private var timerText: String {
        if isMockExam {
            let m = remainingSeconds / 60
            let s = remainingSeconds % 60
            return String(format: "%02d:%02d", m, s)
        }
        return "\(remainingSeconds)s"
    }

    private var isUrgent: Bool {
        if isMockExam {
            return remainingSeconds <= AppConstants.Exam.urgencyThresholdSeconds
        }
        return remainingSeconds <= AppConstants.Simulation.urgencyThresholdSeconds
    }

    private var isLast: Bool { currentIndex + 1 >= questions.count }

    var body: some View {
        Group {
            if questions.isEmpty {
                ExamLoadingView()
            } else {
                examContent
            }
        }
        .examToolbar(
            timerText: timerText,
            isUrgent: isUrgent,
            isBookmarked: !questions.isEmpty && progressStore.isBookmarked(questionNo: questions[currentIndex].no),
            showExitDialog: $showExitDialog,
            onToggleBookmark: { progressStore.toggleBookmark(questionNo: questions[currentIndex].no) },
            onDismiss: { dismiss() }
        )
        .task { startExam() }
        .onDisappear { timer?.invalidate() }
        .alert("Nộp bài?", isPresented: $showSubmitDialog) {
            Button("Quay lại", role: .cancel) {}
            Button("Nộp bài") { submitMockExam() }
        } message: {
            let unanswered = questions.count - answers.count
            if unanswered > 0 {
                Text("Bạn còn \(unanswered) câu chưa trả lời.\nBạn có chắc muốn nộp bài?")
            } else {
                Text("Bạn đã trả lời hết.\nNộp bài ngay?")
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            resultDestination
        }
    }

    // MARK: - Exam Content

    @ViewBuilder
    private var examContent: some View {
        let question = questions[currentIndex]
        let shuffledAnswers = question.shuffledAnswers

        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    QuestionCard(label: "Câu \(currentIndex + 1)", question: question, showDiemLietBadge: true)
                        .padding(.bottom, 20)

                    if isMockExam {
                        AnswerTileList(
                            answers: shuffledAnswers,
                            selectedAnswerId: answers[currentIndex],
                            onSelect: { answer in
                                Haptics.selection()
                                answers[currentIndex] = answer.id
                            }
                        )
                    } else {
                        AnswerTileList(
                            answers: shuffledAnswers,
                            selectedAnswerId: selectedAnswerId,
                            isConfirmed: isRevealed,
                            showCorrectness: true,
                            onSelect: { handleSimulationAnswerSelection(answer: $0, question: question) }
                        )

                        if isRevealed && !question.tip.isEmpty {
                            ExplanationBox(content: question.tip)
                                .padding(.top, 4)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .id(currentIndex)

            ExamBottomBar(
                currentIndex: currentIndex,
                totalCount: questions.count,
                answeredIndices: Set(answers.keys),
                nextLabel: nextLabel,
                isNextDisabled: !isMockExam && selectedAnswerId == nil && !isRevealed,
                onPrev: handlePrev,
                onNext: handleNext,
                onSelectIndex: { index in
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentIndex = index
                        if !isMockExam { restoreStateForCurrentIndex() }
                    }
                }
            )
        }
    }

    private var nextLabel: String {
        if isMockExam {
            return isLast ? "Nộp bài" : "Câu tiếp"
        }
        return isRevealed ? (isLast ? "Xem kết quả" : "Câu tiếp") : "Xác nhận"
    }

    @ViewBuilder
    private var resultDestination: some View {
        if let result = examResult {
            ExamResultView(
                questions: questions,
                answers: answers,
                timeUsedSeconds: result.timeUsedSeconds,
                examResult: result
            )
        } else if let result = simulationResult {
            SimulationResultView(
                questions: questions,
                answers: answers,
                timePerScenario: timePerScenario,
                simulationResult: result
            )
        }
    }

    // MARK: - Navigation

    private func handlePrev() {
        if isMockExam {
            withAnimation(.easeOut(duration: 0.25)) { currentIndex -= 1 }
        } else if currentIndex > 0 {
            withAnimation(.easeOut(duration: 0.25)) {
                currentIndex -= 1
                restoreStateForCurrentIndex()
            }
        }
    }

    private func handleNext() {
        if isMockExam {
            if isLast {
                showSubmitDialog = true
            } else {
                withAnimation(.easeOut(duration: 0.25)) { currentIndex += 1 }
            }
        } else {
            if isRevealed {
                advanceOrFinishSimulation()
            } else if let answerId = selectedAnswerId {
                confirmSimulationAnswer(answerId: answerId, question: questions[currentIndex])
            }
        }
    }

    // MARK: - Start

    private func startExam() {
        switch config.mode {
        case .mockExam(let setId):
            if let setId {
                questions = questionStore.examSetQuestions(setId: setId)
            } else {
                questions = questionStore.randomExamQuestions()
            }
            remainingSeconds = AppConstants.Exam.totalTimeSeconds
            startGlobalTimer()

        case .simulation(let simMode):
            switch simMode {
            case .random:
                questions = questionStore.randomSimulationQuestions(count: 20)
            case .fullPractice:
                questions = questionStore.allSimulationQuestions()
            }
            remainingSeconds = AppConstants.Simulation.scenarioTimeSeconds
            startScenarioTimer()
        }
    }

    // MARK: - Mock Exam Timer

    private func startGlobalTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            Task { @MainActor in
                if remainingSeconds <= 1 {
                    timer?.invalidate()
                    submitMockExam()
                } else {
                    remainingSeconds -= 1
                }
            }
        }
    }

    private func submitMockExam() {
        timer?.invalidate()
        Haptics.notification(.success)

        guard case .mockExam(let examSetId) = config.mode else { return }

        let result = ExamResult.calculate(
            questions: questions,
            answers: answers,
            timeUsedSeconds: AppConstants.Exam.totalTimeSeconds - remainingSeconds,
            examSetId: examSetId
        )
        examResult = result
        progressStore.recordExamResult(result)

        if let setId = examSetId {
            progressStore.addCompletedExamSet(setId)
        }

        for (i, q) in questions.enumerated() {
            let selectedId = answers[i]
            let correct = selectedId != nil && q.answers.contains(where: { $0.id == selectedId && $0.correct })
            let topicKey = Topic.keyForTopicId(q.topic)
            progressStore.recordQuestionAnswer(topicKey: topicKey, questionNo: q.no, correct: correct)
        }

        navigateToResult = true
    }

    // MARK: - Simulation Timer

    private func startScenarioTimer() {
        remainingSeconds = AppConstants.Simulation.scenarioTimeSeconds
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            Task { @MainActor in
                if remainingSeconds <= 1 {
                    handleSimulationTimeout()
                } else {
                    remainingSeconds -= 1
                }
            }
        }
    }

    private func handleSimulationAnswerSelection(answer: Answer, question: Question) {
        guard !isRevealed else { return }
        Haptics.selection()
        selectedAnswerId = answer.id
    }

    private func confirmSimulationAnswer(answerId: Int, question: Question) {
        guard !isRevealed else { return }

        answers[currentIndex] = answerId
        timePerScenario[currentIndex] = AppConstants.Simulation.scenarioTimeSeconds - remainingSeconds

        isRevealed = true
        timer?.invalidate()

        let isCorrect = question.answers.contains(where: { $0.id == answerId && $0.correct })
        Haptics.notification(isCorrect ? .success : .error)

        let topicKey = Topic.keyForTopicId(question.topic)
        progressStore.recordQuestionAnswer(topicKey: topicKey, questionNo: question.no, correct: isCorrect)
    }

    private func handleSimulationTimeout() {
        timer?.invalidate()
        timePerScenario[currentIndex] = AppConstants.Simulation.scenarioTimeSeconds
        Haptics.notification(.warning)

        isRevealed = true

        let question = questions[currentIndex]
        let topicKey = Topic.keyForTopicId(question.topic)
        progressStore.recordQuestionAnswer(topicKey: topicKey, questionNo: question.no, correct: false)
    }

    private func restoreStateForCurrentIndex() {
        if let savedAnswer = answers[currentIndex] {
            selectedAnswerId = savedAnswer
            isRevealed = true
            timer?.invalidate()
        } else {
            selectedAnswerId = nil
            isRevealed = false
            startScenarioTimer()
        }
    }

    private func advanceOrFinishSimulation() {
        if isLast {
            finishSimulation()
        } else {
            withAnimation(.easeOut(duration: 0.25)) {
                currentIndex += 1
                selectedAnswerId = nil
                isRevealed = false
            }
            startScenarioTimer()
        }
    }

    private func finishSimulation() {
        timer?.invalidate()
        Haptics.notification(.success)

        let result = SimulationResult.calculate(
            questions: questions,
            answers: answers,
            timePerScenario: timePerScenario
        )
        simulationResult = result
        progressStore.recordSimulationResult(result)

        navigateToResult = true
    }
}
```

**Step 2: Simplify MockExamView.swift to a thin wrapper**

```swift
import SwiftUI

struct MockExamView: View {
    let examSetId: Int?

    init(examSetId: Int? = nil) {
        self.examSetId = examSetId
    }

    var body: some View {
        BaseExamView(config: .init(mode: .mockExam(examSetId: examSetId)))
    }
}
```

**Step 3: Simplify SimulationExamView.swift to a thin wrapper**

```swift
import SwiftUI

struct SimulationExamView: View {
    let mode: Mode

    enum Mode {
        case random
        case fullPractice
    }

    var body: some View {
        BaseExamView(config: .init(mode: .simulation(mode)))
    }
}
```

**Step 4: Build to verify**

**Step 5: Commit**

```bash
git add GPLX2026/Features/Exam/BaseExamView.swift GPLX2026/Features/Exam/MockExamView.swift GPLX2026/Features/Simulation/SimulationExamView.swift
git commit -m "refactor: unify MockExamView and SimulationExamView into BaseExamView"
```

---

### Task 13: Reorganize Core/Common into subfolders

**Files:**
- Move all files in `GPLX2026/Core/Common/` into appropriate subfolders
- Update `GPLX2026.xcodeproj/project.pbxproj`

**Subfolder mapping:**

```
Core/Common/Buttons/
  - AppButton.swift
  - AppIconButton.swift
  - CloseButton.swift
  - FilterChip.swift

Core/Common/Cards/
  - QuestionCard.swift
  - ListItemCard.swift
  - AnswerOptionCard.swift
  - ExamCTACard.swift

Core/Common/Exam/
  - ExamBottomBar.swift
  - ExamLoadingView.swift
  - ExamQuestionGridSheet.swift
  - ExamStatsRow.swift
  - ExamTimerCapsule.swift
  - ExamToolbar.swift

Core/Common/Display/
  - DetailHero.swift
  - ResultHero.swift
  - EmptyState.swift
  - ExplanationBox.swift
  - IconBox.swift
  - NumberBadge.swift
  - StatusBadge.swift
  - ProgressRing.swift
  - ProgressBarView.swift

Core/Common/Lists/
  - AnswerTileList.swift
  - HistoryRow.swift
  - HistoryList.swift
  - QuestionReviewRow.swift
  - ScoreRow.swift
  - StatItem.swift

Core/Common/Layout/
  - SectionHeader.swift
  - SectionTitle.swift
  - RulePill.swift
  - QuestionGridButton.swift

Core/Common/Media/
  - QuestionImage.swift
  - AnimatedBackground.swift

Core/Common/Utilities/
  - Haptics.swift
  - DateFormatters.swift
```

**Step 1: Create subdirectories**

```bash
mkdir -p GPLX2026/Core/Common/{Buttons,Cards,Exam,Display,Lists,Layout,Media,Utilities}
```

**Step 2: Move files to subdirectories**

```bash
# Buttons
mv GPLX2026/Core/Common/AppButton.swift GPLX2026/Core/Common/Buttons/
mv GPLX2026/Core/Common/AppIconButton.swift GPLX2026/Core/Common/Buttons/
mv GPLX2026/Core/Common/CloseButton.swift GPLX2026/Core/Common/Buttons/
mv GPLX2026/Core/Common/FilterChip.swift GPLX2026/Core/Common/Buttons/

# Cards
mv GPLX2026/Core/Common/QuestionCard.swift GPLX2026/Core/Common/Cards/
mv GPLX2026/Core/Common/ListItemCard.swift GPLX2026/Core/Common/Cards/
mv GPLX2026/Core/Common/AnswerOptionCard.swift GPLX2026/Core/Common/Cards/
mv GPLX2026/Core/Common/ExamCTACard.swift GPLX2026/Core/Common/Cards/

# ... etc for all subfolders
```

**Step 3: Update project.pbxproj**

Use `xcodeproj` Ruby gem to update all file references to their new paths. This is the safest approach for pbxproj modifications.

**Step 4: Build to verify**

**Step 5: Commit**

```bash
git add -A
git commit -m "refactor: organize Core/Common into subfolders (Buttons, Cards, Exam, Display, Lists, Layout, Media, Utilities)"
```

---

### Task 14: Add all new files to Xcode project

**Important:** After each task that creates new files, they must be added to the Xcode project's `project.pbxproj`. Use the `xcodeproj` Ruby gem:

```ruby
require 'xcodeproj'
project = Xcodeproj::Project.open('GPLX2026.xcodeproj')
target = project.targets.first
group = project.main_group.find_subpath('GPLX2026/Core/Common', true)
file_ref = group.new_reference('NewFile.swift')
target.source_build_phase.add_file_reference(file_ref)
project.save
```

This should be done as part of each task, not as a separate task. The `xcodeproj` gem approach is noted in the project memory as the correct way to modify pbxproj.

---

## Summary of Changes

| Task | What | Lines Saved |
|------|------|-------------|
| 1 | DateFormatters utility | ~9 |
| 2 | Extract ResultHero | ~57 |
| 3 | Consolidate ReviewRow into QuestionReviewRow | ~226 |
| 4 | Extract HistoryList | ~36 |
| 5 | Extract ExamCTACard | ~60 |
| 6 | Extract FilterChip | ~18 |
| 7 | ListItemCard iconColor, delete StudyRow | ~35 |
| 8 | BadgesView use DetailHero | ~20 |
| 10 | Simplify averaging functions | ~18 |
| 11 | Rename DiemLietTab → CriticalQuestionsTab | 0 (rename) |
| 12 | Unify BaseExamView | ~120 |
| 13 | Reorganize Core/Common subfolders | 0 (reorg) |
| **Total** | | **~599 lines** |
