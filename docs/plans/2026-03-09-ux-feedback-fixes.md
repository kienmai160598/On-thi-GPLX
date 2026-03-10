# UX Feedback Fixes Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix the top UX issues identified by 6 mock user personas (ages 18-40), focusing on: simplifying the Home tab, improving onboarding, clarifying terminology, adding safety confirmations, and softening emotional design for new users.

**Architecture:** Modify existing views in-place — no new files needed. Changes are UI-only with no model/store changes. Each task is independent and can be verified with a build.

**Tech Stack:** SwiftUI, iOS 18+, existing design system (glassCard, screenHeader, AppTheme)

---

### Task 1: Add confirmation dialogs to all Settings reset buttons

**Severity:** HIGH — accidental tap = permanent data loss (raised by Minh 18, Hùng 22)

**Files:**
- Modify: `GPLX2026/Features/Settings/SettingsView.swift:357-387`

**Step 1: Add state for tracking which reset to confirm**

At the top of `SettingsView` (around line 13), add:

```swift
@State private var resetConfirmation: ResetAction?

private enum ResetAction: Identifiable {
    case topicProgress, examHistory, simulationHistory, hazardHistory, bookmarks, wrongAnswers
    var id: Self { self }

    var title: String {
        switch self {
        case .topicProgress: return "Xoá tiến độ học?"
        case .examHistory: return "Xoá lịch sử thi thử?"
        case .simulationHistory: return "Xoá lịch sử mô phỏng?"
        case .hazardHistory: return "Xoá lịch sử tình huống?"
        case .bookmarks: return "Xoá tất cả đánh dấu?"
        case .wrongAnswers: return "Xoá danh sách câu sai?"
        }
    }

    var message: String {
        switch self {
        case .topicProgress: return "Tiến độ tất cả chủ đề sẽ bị xoá vĩnh viễn."
        case .examHistory: return "Toàn bộ kết quả thi thử sẽ bị xoá vĩnh viễn."
        case .simulationHistory: return "Toàn bộ kết quả mô phỏng sẽ bị xoá vĩnh viễn."
        case .hazardHistory: return "Toàn bộ kết quả tình huống sẽ bị xoá vĩnh viễn."
        case .bookmarks: return "Tất cả câu hỏi đã đánh dấu sẽ bị xoá."
        case .wrongAnswers: return "Danh sách câu sai sẽ bị xoá."
        }
    }
}
```

**Step 2: Update resetRow to show confirmation instead of executing immediately**

Replace the `resetRow` function (lines 357-387) with:

```swift
@ViewBuilder
private func resetRow(icon: String, title: String, subtitle: String, action: ResetAction) -> some View {
    Button {
        resetConfirmation = action
    } label: {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextLight)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.appTextDark)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.appTextLight)
            }
            Spacer()
            Image(systemName: "trash")
                .font(.system(size: 12))
                .foregroundStyle(Color.appError.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
}
```

**Step 3: Update all resetRow call sites**

Replace the 6 `resetRow` calls (lines 161-183) to pass enum cases instead of closures:

```swift
resetRow(icon: "book.closed", title: "Tiến độ học", subtitle: "Xoá tiến độ tất cả chủ đề", action: .topicProgress)
Divider().padding(.horizontal, 16)
resetRow(icon: "doc.text", title: "Lịch sử thi thử", subtitle: "Xoá kết quả thi thử", action: .examHistory)
Divider().padding(.horizontal, 16)
resetRow(icon: "photo.on.rectangle", title: "Lịch sử mô phỏng", subtitle: "Xoá kết quả mô phỏng", action: .simulationHistory)
Divider().padding(.horizontal, 16)
resetRow(icon: "play.rectangle", title: "Lịch sử tình huống", subtitle: "Xoá kết quả tình huống", action: .hazardHistory)
Divider().padding(.horizontal, 16)
resetRow(icon: "bookmark", title: "Đánh dấu", subtitle: "Xoá tất cả đánh dấu", action: .bookmarks)
Divider().padding(.horizontal, 16)
resetRow(icon: "xmark.circle", title: "Câu sai", subtitle: "Xoá danh sách câu sai", action: .wrongAnswers)
```

**Step 4: Add the confirmation alert**

After the existing `.alert("Xoá tất cả dữ liệu?"...)` (around line 282), add:

```swift
.alert(
    resetConfirmation?.title ?? "",
    isPresented: Binding(
        get: { resetConfirmation != nil },
        set: { if !$0 { resetConfirmation = nil } }
    )
) {
    Button("Huỷ", role: .cancel) { resetConfirmation = nil }
    Button("Xoá", role: .destructive) {
        if let action = resetConfirmation {
            performReset(action)
        }
        resetConfirmation = nil
    }
} message: {
    Text(resetConfirmation?.message ?? "")
}
```

**Step 5: Add the performReset helper**

```swift
private func performReset(_ action: ResetAction) {
    switch action {
    case .topicProgress: progressStore.clearTopicProgress()
    case .examHistory: progressStore.clearExamHistory()
    case .simulationHistory: progressStore.clearSimulationHistory()
    case .hazardHistory: progressStore.clearHazardHistory()
    case .bookmarks: progressStore.clearBookmarks()
    case .wrongAnswers: progressStore.clearWrongAnswers()
    }
    Haptics.notification(.success)
    showToast("Đã xoá \(action.title.lowercased().replacingOccurrences(of: "?", with: ""))")
}
```

**Step 6: Build and commit**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
git add GPLX2026/Features/Settings/SettingsView.swift
git commit -m "fix: add confirmation dialogs to all Settings reset buttons"
```

---

### Task 2: Soften emotional design for new users

**Severity:** MEDIUM — "Chưa sẵn sàng" in red scares new users (raised by Thảo 32, Hoa 40)

**Files:**
- Modify: `GPLX2026/Features/Home/HomeTab.swift:68-77`

**Step 1: Change "Chưa sẵn sàng" to "Đang bắt đầu" with neutral color**

In `ProgressHeroCard`, find the status mapping (lines 68-77):

```swift
let statusColor: Color = switch status.level {
case .ready: .appSuccess
case .needsWork: .appWarning
case .notReady: .appError
}
let statusText: String = switch status.level {
case .ready: "Sẵn sàng thi"
case .needsWork: "Cần ôn thêm"
case .notReady: "Chưa sẵn sàng"
}
```

Change `.notReady` to use neutral color and encouraging text:

```swift
let statusColor: Color = switch status.level {
case .ready: .appSuccess
case .needsWork: .appWarning
case .notReady: .appTextMedium
}
let statusText: String = switch status.level {
case .ready: "Sẵn sàng thi"
case .needsWork: "Cần ôn thêm"
case .notReady: "Đang bắt đầu"
}
```

**Step 2: Soften ExamCountdownCard red urgency**

In `GPLX2026/Core/Common/Display/ExamCountdownCard.swift`, find the color for days remaining. Change from red to orange when ≤7 days, and add encouraging subtext.

Read the file first, then find where `daysLeft <= 7 ? Color.appError` is used and change `Color.appError` to `Color.appWarning`.

**Step 3: Build and commit**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
git add GPLX2026/Features/Home/HomeTab.swift GPLX2026/Core/Common/Display/ExamCountdownCard.swift
git commit -m "fix: soften emotional design — neutral status for new users, orange countdown"
```

---

### Task 3: Improve onboarding with exam structure explanation

**Severity:** HIGH — no exam structure explanation (raised by 5/6 personas)

**Files:**
- Modify: `GPLX2026/Features/Onboarding/OnboardingView.swift`
- Modify: `GPLX2026/Features/Onboarding/OnboardingPageView.swift`

**Step 1: Replace onboarding page 2 with exam structure page**

In `OnboardingView.swift`, replace the 3 pages array (lines 7-26) with 4 pages that include exam structure:

```swift
private let pages = [
    OnboardingPage(
        id: 0,
        icon: "car.fill",
        title: "Chào mừng đến với\nGPLX B 2026",
        subtitle: "Ôn thi giấy phép lái xe bằng B\nTheo đề thi mới nhất 2026 của Bộ GTVT"
    ),
    OnboardingPage(
        id: 1,
        icon: "list.clipboard.fill",
        title: "Kỳ thi gồm 3 phần",
        subtitle: "Bạn phải đạt cả 3 phần mới được cấp bằng"
    ),
    OnboardingPage(
        id: 2,
        icon: "book.fill",
        title: "Mọi thứ bạn cần",
        subtitle: "Từ lý thuyết đến thực hành, từ ôn luyện\nđến kiểm tra — tất cả trong một ứng dụng"
    ),
    OnboardingPage(
        id: 3,
        icon: "flag.checkered",
        title: "Sẵn sàng rồi!",
        subtitle: "Bắt đầu hành trình chinh phục\nbằng lái xe B2 của bạn"
    ),
]
```

**Step 2: Update page count references**

In `OnboardingView.swift`, update all references from `2` to `pages.count - 1`:
- Line 33: `if currentPage < 2` → `if currentPage < pages.count - 1`
- Line 57: `ForEach(0..<3` → `ForEach(0..<pages.count`
- Line 71: `if currentPage < 2` → `if currentPage < pages.count - 1`
- Line 80: `currentPage == 2` → `currentPage == pages.count - 1` (both occurrences on that line)

**Step 3: Add exam structure hero to OnboardingPageView**

In `OnboardingPageView.swift`, update `heroArea` (lines 42-49) to handle the new page id 1:

```swift
@ViewBuilder
private var heroArea: some View {
    switch page.id {
    case 1:
        examStructureHero
    case 2:
        featureIconsHero
    default:
        singleIconHero
    }
}
```

Add the `examStructureHero` view:

```swift
private var examStructureHero: some View {
    VStack(spacing: 12) {
        examPartRow(icon: "doc.text.fill", part: "Phần 1", name: "Lý thuyết", detail: "30 câu · 22 phút · ≥28 đạt", color: .topicQuyDinh)
        examPartRow(icon: "photo.fill", part: "Phần 2", name: "Mô phỏng", detail: "20 sa hình · 60s/câu · ≥70%", color: .topicSaHinh)
        examPartRow(icon: "play.circle.fill", part: "Phần 3", name: "Tình huống", detail: "10 video · ≥35/50 điểm", color: .topicBienBao)

        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundStyle(Color.appError)
            Text("Sai câu điểm liệt = Trượt ngay")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appError)
        }
        .padding(.top, 4)
    }
}

private func examPartRow(icon: String, part: String, name: String, detail: String, color: Color) -> some View {
    HStack(spacing: 14) {
        Image(systemName: icon)
            .font(.system(size: 22))
            .foregroundStyle(color)
            .frame(width: 44, height: 44)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))

        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Text(part)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextMedium)
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
            }
            Text(detail)
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextLight)
        }

        Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 14))
}
```

**Step 4: Build and commit**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
git add GPLX2026/Features/Onboarding/OnboardingView.swift GPLX2026/Features/Onboarding/OnboardingPageView.swift
git commit -m "feat: onboarding explains 3-part exam structure and điểm liệt"
```

---

### Task 4: Clarify tab names with subtitles

**Severity:** HIGH — "Mô phỏng" vs "Tình huống" confusing (raised by 4/6 personas)

**Files:**
- Modify: `GPLX2026/Features/Home/HomeView.swift:27,34`

**Step 1: Add subtitle text to tab labels**

SwiftUI's `Tab` doesn't support subtitles, but we can clarify the tab names themselves. In `HomeView.swift`, change the tab labels:

```swift
Tab("Mô phỏng", systemImage: "map") {
```
→
```swift
Tab("Sa hình", systemImage: "map") {
```

```swift
Tab("Tình huống", systemImage: "play.circle") {
```
→
```swift
Tab("Video TH", systemImage: "play.circle") {
```

Note: Keep screen headers as "Mô phỏng" and "Tình huống" inside the tabs themselves — only the tab bar labels change to be shorter and clearer.

**Step 2: Build and commit**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
git add GPLX2026/Features/Home/HomeView.swift
git commit -m "fix: clarify tab names — Sa hình and Video TH for clarity"
```

---

### Task 5: Simplify Home tab for new users

**Severity:** HIGH — 8 sections, too much scrolling (raised by all 6 personas)

**Files:**
- Modify: `GPLX2026/Features/Home/HomeTab.swift`

**Step 1: Collapse TopicProgressSection behind a "Xem tất cả" toggle**

Replace the `TopicProgressSection` struct (lines 392-480) to show only the 2 weakest topics by default, with a "Xem tất cả" link to expand or navigate:

In the body of `TopicProgressSection`, change the ForEach to only show the first 3 topics, and add a NavigationLink to the full list:

```swift
var body: some View {
    let topicStats = progressStore.weakTopics(topics: questionStore.topics)
        .sorted { $0.topic.topicIds.first ?? 0 < $1.topic.topicIds.first ?? 0 }

    VStack(alignment: .leading, spacing: 14) {
        HStack {
            Text("Chủ đề")
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(Color.appTextDark)
            Spacer()
            NavigationLink(destination: WeakTopicsView()) {
                Text("Xem tất cả")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appPrimary)
            }
        }

        ForEach(topicStats.prefix(3), id: \.topic.id) { item in
            NavigationLink(destination: TopicDetailView(item: item)) {
                topicRow(item: item)
            }
            .buttonStyle(.plain)
        }
    }
}
```

**Step 2: Move StudyHeatMap after RecentResultsCard**

In `HomeTab.body`, reorder the VStack children:

```swift
VStack(spacing: 24) {
    ProgressHeroCard()
    ExamCountdownCard()
    SmartNudgeCard()
    UtilityGrid()
    TopicProgressSection()
    RecentResultsCard()
    StudyHeatMap()
    ReferenceSection()
}
```

**Step 3: Build and commit**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
git add GPLX2026/Features/Home/HomeTab.swift
git commit -m "fix: simplify Home tab — show top 3 topics, move heatmap lower"
```

---

### Task 6: Add điểm liệt explanation and SmartNudge context

**Severity:** MEDIUM — jargon unexplained (raised by 4/6 personas)

**Files:**
- Modify: `GPLX2026/Core/Storage/ProgressStore+SmartNudge.swift`
- Modify: `GPLX2026/Features/Home/HomeTab.swift`

**Step 1: Add subtitle to SmartNudge enum**

In `ProgressStore+SmartNudge.swift`, add a `subtitle` computed property to the `SmartNudge` enum (after the `icon` property, around line 57):

```swift
var subtitle: String? {
    switch self {
    case .masterDiemLiet:
        return "Sai 1 câu điểm liệt = Trượt ngay"
    case .weakTopic:
        return "Chủ đề cần ôn nhiều hơn"
    case .takeExam:
        return "Kiểm tra kiến thức tổng hợp"
    case .improveTopic:
        return "Nâng cao độ chính xác"
    case .startSimulation:
        return "Lý thuyết đã ổn, chuyển sang sa hình"
    case .startHazard:
        return "Sa hình đã ổn, chuyển sang video"
    case .testWeakestPart:
        return "Tìm điểm yếu còn lại"
    case .examReady:
        return "Tất cả phần đều ≥90%"
    }
}
```

**Step 2: Show subtitle in SmartNudgeCard**

In `HomeTab.swift`, find the `SmartNudgeCard` (around line 218-226). Add the subtitle below the label:

Replace:
```swift
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
```

With:
```swift
VStack(alignment: .leading, spacing: 3) {
    Text("Tiếp theo")
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(Color.appTextLight)
        .textCase(.uppercase)
    Text(nudge.label)
        .font(.system(size: 16, weight: .bold))
        .foregroundStyle(Color.appTextDark)
        .lineLimit(1)
    if let subtitle = nudge.subtitle {
        Text(subtitle)
            .font(.system(size: 13))
            .foregroundStyle(Color.appTextMedium)
            .lineLimit(1)
    }
}
```

Note: Also bumped "Tiếp theo" from 12pt to 13pt (font size fix from persona feedback).

**Step 3: Build and commit**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
git add GPLX2026/Core/Storage/ProgressStore+SmartNudge.swift GPLX2026/Features/Home/HomeTab.swift
git commit -m "feat: add context subtitles to SmartNudge — explain điểm liệt and why"
```

---

### Task 7: Bump minimum font sizes

**Severity:** MEDIUM — 9-12pt labels hard to read (raised by Minh 18, Thảo 32, Hoa 40)

**Files:**
- Modify: `GPLX2026/Features/Home/HomeTab.swift`
- Modify: `GPLX2026/Core/Common/Display/StudyHeatMap.swift`

**Step 1: Bump StatusBadge font size in HomeTab**

In `HomeTab.swift`, search for `fontSize: 11` in StatusBadge calls. Change all instances from `11` to `12`:

- In `topicRow` (around line 459): `StatusBadge(text: statusInfo.label, color: statusInfo.color, fontSize: 12)`
- In `RecentResultRow` (around line 583): `StatusBadge(text: passed ? "Đạt" : "Trượt", color: passed ? .appSuccess : .appError, fontSize: 12)`

**Step 2: Bump MiniStat label from 12pt to 13pt**

In `HomeTab.swift`, find `MiniStat` (around line 188):

```swift
Text(label)
    .font(.system(size: 12, weight: .medium))
```
→
```swift
Text(label)
    .font(.system(size: 13, weight: .medium))
```

**Step 3: Bump heatmap labels**

In `StudyHeatMap.swift`:
- Day labels (line ~287): change `size: 9` → `size: 10`
- Legend text (lines ~303, 311): change `size: 10` → `size: 11`

**Step 4: Build and commit**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
git add GPLX2026/Features/Home/HomeTab.swift GPLX2026/Core/Common/Display/StudyHeatMap.swift
git commit -m "fix: bump minimum font sizes — StatusBadge 12pt, MiniStat 13pt, heatmap 10-11pt"
```

---

### Task 8: Final build, install, and verify

**Step 1: Clean build**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' clean build 2>&1 | tail -10
```

**Step 2: Install on device**

```bash
xcrun devicectl device install app --device 00008120-0016116A1103C01E <app_path>
```

**Step 3: Verify checklist**

- [ ] Settings: each reset button shows confirmation dialog before deleting
- [ ] Settings: "Xoá tất cả" still has its own separate confirmation
- [ ] Home: new users see "Đang bắt đầu" in gray, not "Chưa sẵn sàng" in red
- [ ] Home: ExamCountdownCard uses orange (not red) when ≤7 days
- [ ] Onboarding: 4 pages, page 2 shows 3-part exam structure with rules
- [ ] Onboarding: điểm liệt warning shown on exam structure page
- [ ] Tab bar: "Sa hình" and "Video TH" labels (not "Mô phỏng" / "Tình huống")
- [ ] Home: only 3 topics shown, "Xem tất cả" link visible
- [ ] Home: StudyHeatMap appears after RecentResultsCard
- [ ] Home: SmartNudge shows subtitle explaining "why"
- [ ] Home: SmartNudge "Tiếp theo" label is 13pt (not 12pt)
- [ ] Home: StatusBadge text is readable (12pt)
- [ ] Home: MiniStat labels are readable (13pt)
- [ ] Home: Heatmap day labels are readable (10pt)
