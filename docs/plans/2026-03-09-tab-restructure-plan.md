# 3-Tab Restructure Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Consolidate 4 tabs into 3 (Trang chủ, Luyện tập, Thi thử) with segmented sub-tabs in the latter two.

**Architecture:** Create PracticeTab and ExamTab with Picker segmented controls containing 3 segments each ("Câu hỏi", "Sa hình", "Tình huống"). Extract study content into PracticeTab, exam content into ExamTab. Remove old TheoryTab/SimulationTab/HazardTab.

**Tech Stack:** SwiftUI, iOS 18+, Swift 6

---

### Task 1: Create PracticeTab.swift

**Files:**
- Create: `GPLX2026/Features/Home/PracticeTab.swift`
- Read: `GPLX2026/Features/Home/TheoryTab.swift` (study section lines 14-128, TheoryTopicRow lines 191-254)
- Read: `GPLX2026/Features/Home/SimulationTab.swift` (study section lines 47-119)
- Read: `GPLX2026/Features/Home/HazardTab.swift` (study section lines 12-66, HazardDownloadCard lines 154-312)

**Step 1: Create PracticeTab.swift**

Structure:
```swift
import SwiftUI

struct PracticeTab: View {
    @State private var selectedSegment = 0

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
    }
}
```

Content for each segment — move directly from existing files:

- **`questionStudyContent`**: Copy `theoryTopicsList` + `allQuestionsButton` from TheoryTab.swift (lines 84-128). Also copy `TheoryTopicRow` struct (lines 191-254) into this file as a private struct.

- **`simulationStudyContent`**: Copy `studyContent` from SimulationTab.swift (lines 47-119). This includes the Topic 6 card and "Luyện tất cả sa hình" button.

- **`hazardStudyContent`**: Copy study section from HazardTab.swift (lines 14-66). This includes the "Luyện tập tất cả" button, chapter list, and download card. Also copy `HazardDownloadCard` struct (lines 154-312) and the `chapterIcon()` helper.

Each segment wraps its content in:
```swift
ScrollView {
    VStack(alignment: .leading, spacing: 14) {
        // segment content here
    }
    .padding(.horizontal, 20)
    .padding(.top, 16)
    .padding(.bottom, 32)
}
```

Required environment properties on PracticeTab:
```swift
@Environment(QuestionStore.self) private var questionStore
@Environment(ProgressStore.self) private var progressStore
@Environment(\.openExam) private var openExam
@Environment(HazardVideoCache.self) private var videoCache  // for hazard segment
@State private var showClearCacheAlert: Bool = false         // for hazard segment
```

Include the `.alert("Xoá cache video?", ...)` from HazardTab (lines 117-125) on the VStack.

**Step 2: Add to Xcode project**

```bash
ruby -e "
require 'xcodeproj'
proj = Xcodeproj::Project.open('GPLX2026.xcodeproj')
target = proj.targets.first
group = proj.main_group.find_subpath('GPLX2026/Features/Home', true)
ref = group.new_file('GPLX2026/Features/Home/PracticeTab.swift')
target.source_build_phase.add_file_reference(ref)
proj.save
"
```

**Step 3: Build**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
```
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add GPLX2026/Features/Home/PracticeTab.swift GPLX2026.xcodeproj
git commit -m "feat: create PracticeTab with segmented study content"
```

---

### Task 2: Create ExamTab.swift

**Files:**
- Create: `GPLX2026/Features/Home/ExamTab.swift`
- Read: `GPLX2026/Features/Home/TheoryTab.swift` (exam section lines 20-61, fixedExamSets lines 130-188)
- Read: `GPLX2026/Features/Home/SimulationTab.swift` (exam section lines 122-168)
- Read: `GPLX2026/Features/Home/HazardTab.swift` (exam section lines 68-109)

**Step 1: Create ExamTab.swift**

Structure mirrors PracticeTab:
```swift
import SwiftUI

struct ExamTab: View {
    @State private var selectedSegment = 0
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var showNavPlay = false

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
                case 1: simulationExamContent
                case 2: hazardExamContent
                default: questionExamContent
                }
            }
        }
        .glassContainer()
        .screenHeader("Thi thử")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if showNavPlay {
                    Button { startExamForCurrentSegment() } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primaryColor(for: primaryColorKey))
                    }
                }
            }
        }
    }

    private func startExamForCurrentSegment() {
        switch selectedSegment {
        case 1: openExam(.simulationExam(mode: .random))
        case 2: openExam(.hazardTest(mode: .exam))
        default: openExam(.mockExam())
        }
    }
}
```

Content for each segment — move from existing files:

- **`questionExamContent`**: Copy exam CTA card (lines 24-38), exam stats (lines 40-46), `fixedExamSets` (lines 130-188), and history section (lines 50-61) from TheoryTab.swift.

- **`simulationExamContent`**: Copy `examContent` from SimulationTab.swift (lines 124-168). This includes CTA, stats, and history.

- **`hazardExamContent`**: Copy exam section from HazardTab.swift (lines 68-109). This includes CTA, stats, and history.

Each segment wraps in ScrollView with same padding as PracticeTab.

Required environment properties:
```swift
@Environment(QuestionStore.self) private var questionStore
@Environment(ProgressStore.self) private var progressStore
@Environment(\.openExam) private var openExam
```

Pass `onButtonHidden` from each segment's ExamCTACard to update `showNavPlay`.

**Step 2: Add to Xcode project**

```bash
ruby -e "
require 'xcodeproj'
proj = Xcodeproj::Project.open('GPLX2026.xcodeproj')
target = proj.targets.first
group = proj.main_group.find_subpath('GPLX2026/Features/Home', true)
ref = group.new_file('GPLX2026/Features/Home/ExamTab.swift')
target.source_build_phase.add_file_reference(ref)
proj.save
"
```

**Step 3: Build**

Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add GPLX2026/Features/Home/ExamTab.swift GPLX2026.xcodeproj
git commit -m "feat: create ExamTab with segmented exam content"
```

---

### Task 3: Update HomeView.swift — 4 tabs to 3 tabs

**Files:**
- Modify: `GPLX2026/Features/Home/HomeView.swift`

**Step 1: Replace tab definitions**

Change the TabView body from:
```swift
Tab("Trang chủ", systemImage: "house") { ... HomeTab() ... }
Tab("Lý thuyết", systemImage: "book") { ... TheoryTab() ... }
Tab("Sa hình", systemImage: "map") { ... SimulationTab() ... }
Tab("Tình huống", systemImage: "play.circle") { ... HazardTab() ... }
```

To:
```swift
Tab("Trang chủ", systemImage: "house") {
    NavigationStack { HomeTab() }.tint(accentColor)
}
Tab("Luyện tập", systemImage: "book") {
    NavigationStack { PracticeTab() }.tint(accentColor)
}
Tab("Thi thử", systemImage: "pencil.and.list.clipboard") {
    NavigationStack { ExamTab() }.tint(accentColor)
}
```

**Step 2: Build**

Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add GPLX2026/Features/Home/HomeView.swift
git commit -m "feat: update HomeView to 3-tab layout"
```

---

### Task 4: Remove old tab files

**Files:**
- Delete: `GPLX2026/Features/Home/TheoryTab.swift`
- Delete: `GPLX2026/Features/Home/SimulationTab.swift`
- Delete: `GPLX2026/Features/Home/HazardTab.swift`

**Step 1: Remove files from Xcode project and filesystem**

```bash
ruby -e "
require 'xcodeproj'
proj = Xcodeproj::Project.open('GPLX2026.xcodeproj')
['TheoryTab.swift', 'SimulationTab.swift', 'HazardTab.swift'].each do |name|
  proj.files.select { |f| f.path&.end_with?(name) }.each do |ref|
    ref.build_files.each { |bf| bf.remove_from_project }
    ref.remove_from_project
  end
end
proj.save
"
rm GPLX2026/Features/Home/TheoryTab.swift
rm GPLX2026/Features/Home/SimulationTab.swift
rm GPLX2026/Features/Home/HazardTab.swift
```

**Step 2: Build**

Expected: BUILD SUCCEEDED (all references to old tabs removed in Task 3)

**Step 3: Commit**

```bash
git add -A
git commit -m "chore: remove old TheoryTab, SimulationTab, HazardTab"
```

---

### Task 5: Build, install, verify

**Step 1: Full build**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -5
```

**Step 2: Install on device**

```bash
xcrun devicectl device install app --device 00008120-0016116A1103C01E ~/Library/Developer/Xcode/DerivedData/GPLX2026-fmpweaxxkwppbcgzwsrivfciaumz/Build/Products/Debug-iphoneos/GPLX2026.app
```

**Step 3: Manual verification**

- App opens with 3 tabs: Trang chủ, Luyện tập, Thi thử
- Luyện tập: segmented picker with Câu hỏi/Sa hình/Tình huống, each shows study content
- Thi thử: same picker, each shows exam CTA + stats + history
- Trang chủ: unchanged, SmartNudge/ContinueLearning still route correctly
- All openExam routes work (topic study, flashcard, mock exam, simulation, hazard)
