# Priority 3: Business Features Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add B1/B2 license type selection with correct exam rules per type, and App Store review prompt after first exam pass.

**Architecture:** New `LicenseType` enum centralizes all license-specific config (questions, time, pass threshold). Stored in `@AppStorage("licenseType")`. `QuestionStore` filters questions through this. All exam flows read rules from `LicenseType.current` instead of hardcoded constants.

**Tech Stack:** SwiftUI, `@AppStorage`, `@Observable`, `StoreKit` (SKStoreReviewController)

---

### Task 1: Add `LicenseType` enum and `licenseType` storage key

**Files:**
- Create: `GPLX2026/Core/Models/LicenseType.swift`
- Modify: `GPLX2026/Core/Common/Utilities/AppConstants.swift:52-61`

**Step 1: Create `LicenseType.swift`**

```swift
import Foundation

enum LicenseType: String, CaseIterable, Codable {
    case b1 = "b1"
    case b2 = "b2"

    var displayName: String {
        switch self {
        case .b1: return "B1"
        case .b2: return "B2"
        }
    }

    var description: String {
        switch self {
        case .b1: return "Xe ô tô chở người đến 9 chỗ (không kinh doanh)"
        case .b2: return "Xe ô tô chở người đến 9 chỗ, xe tải dưới 3.5 tấn"
        }
    }

    // MARK: - Exam rules

    var questionsPerExam: Int {
        switch self {
        case .b1: return 30
        case .b2: return 35
        }
    }

    var totalTimeSeconds: Int {
        switch self {
        case .b1: return 20 * 60  // 20 minutes
        case .b2: return 22 * 60  // 22 minutes
        }
    }

    var passThreshold: Int {
        switch self {
        case .b1: return 26
        case .b2: return 32
        }
    }

    var diemLietPerExam: Int { 1 }

    var urgencyThresholdSeconds: Int { 300 }

    var totalExamSets: Int {
        switch self {
        case .b1: return 10   // 300 / 30
        case .b2: return 17   // 600 / 35 ≈ 17
        }
    }

    // MARK: - Current

    static var current: LicenseType {
        let raw = UserDefaults.standard.string(forKey: AppConstants.StorageKey.licenseType) ?? "b2"
        return LicenseType(rawValue: raw) ?? .b2
    }
}
```

**Step 2: Add storage key to `AppConstants.StorageKey`**

In `AppConstants.swift`, add inside `enum StorageKey` (after line 60):

```swift
static let licenseType = "licenseType"
```

**Step 3: Add this file to the Xcode project**

Run: `ruby add_file.rb` or manually add to pbxproj.

**Step 4: Build to verify**

Run: `xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build 2>&1 | tail -3`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add GPLX2026/Core/Models/LicenseType.swift GPLX2026/Core/Common/Utilities/AppConstants.swift
git commit -m "feat: add LicenseType enum with B1/B2 exam rules"
```

---

### Task 2: Add `b1` field to `Question` model for license filtering

**Files:**
- Modify: `GPLX2026/Core/Models/Question.swift:13-48`

**Step 1: Add `b1Position` field to Question struct**

Add after line 26 (`let required3: Int`):

```swift
let b1Position: Int  // 0 = not in B1 pool, 1-300 = position in B1 exam bank
```

**Step 2: Add to CodingKeys**

Change line 31 to:

```swift
case no, text, tip, answers, topic, image
case required1, required2, required3
case b1Position = "b1"
```

**Step 3: Add to custom decoder**

Add after line 47 (`required3 = ...`):

```swift
b1Position = try c.decodeIfPresent(Int.self, forKey: .b1Position) ?? 0
```

**Step 4: Add to memberwise init**

Add parameter after `required3`:

```swift
b1Position: Int = 0
```

And in the body:

```swift
self.b1Position = b1Position
```

**Step 5: Add computed property**

After `isDiemLiet` (line 80):

```swift
/// Whether this question is in the B1 question pool.
var isB1: Bool { b1Position > 0 }
```

**Step 6: Build to verify**

Expected: BUILD SUCCEEDED

**Step 7: Commit**

```bash
git add GPLX2026/Core/Models/Question.swift
git commit -m "feat: add b1Position field to Question for license filtering"
```

---

### Task 3: Update `QuestionStore` to filter by license type

**Files:**
- Modify: `GPLX2026/Core/Storage/QuestionStore.swift:10-205`

**Step 1: Add license-filtered question pool**

Add after `_simulationCache` (line 21):

```swift
private var _b1Cache: [Question]?
```

**Step 2: Add `questionsForCurrentLicense` computed property**

Add after `diemLietQuestions` (after line 69):

```swift
/// Questions filtered for the current license type.
var questionsForCurrentLicense: [Question] {
    switch LicenseType.current {
    case .b1:
        if let cached = _b1Cache { return cached }
        let result = allQuestions.filter(\.isB1).sorted { $0.b1Position < $1.b1Position }
        _b1Cache = result
        return result
    case .b2:
        return allQuestions
    }
}
```

**Step 3: Update `randomExamQuestions()` to use license pool**

Replace lines 135-143:

```swift
func randomExamQuestions() -> [Question] {
    let license = LicenseType.current
    let pool = questionsForCurrentLicense
    let diemLiet = pool.filter(\.isDiemLiet)
    let normal = pool.filter { !$0.isDiemLiet }
    let dlCount = license.diemLietPerExam
    let normalCount = license.questionsPerExam - dlCount
    let selectedDL = Array(diemLiet.shuffled().prefix(dlCount))
    let selectedNormal = Array(normal.shuffled().prefix(normalCount))
    return (selectedDL + selectedNormal).shuffled()
}
```

**Step 4: Update `examSetQuestions(setId:)` to use license pool**

Replace lines 146-152:

```swift
func examSetQuestions(setId: Int) -> [Question] {
    let license = LicenseType.current
    let pool = questionsForCurrentLicense
    let perSet = license.questionsPerExam
    let startIndex = (setId - 1) * perSet
    let endIndex = min(startIndex + perSet, pool.count)
    guard startIndex < pool.count else { return [] }
    return Array(pool[startIndex..<endIndex])
}
```

**Step 5: Update `rebuildCaches()` to include B1 cache**

Add to `rebuildCaches()` (after line 204):

```swift
_b1Cache = allQuestions.filter(\.isB1).sorted { $0.b1Position < $1.b1Position }
```

**Step 6: Build to verify**

Expected: BUILD SUCCEEDED

**Step 7: Commit**

```bash
git add GPLX2026/Core/Storage/QuestionStore.swift
git commit -m "feat: filter exam questions by license type"
```

---

### Task 4: Update `ExamResult.calculate()` and `BaseExamView` to use `LicenseType`

**Files:**
- Modify: `GPLX2026/Core/Models/ExamResult.swift:112`
- Modify: `GPLX2026/Features/Exam/BaseExamView.swift:219,263`

**Step 1: Fix `ExamResult.calculate()` pass threshold**

Change line 112 from:

```swift
let passed = correctCount >= AppConstants.Exam.passThreshold && wrongDiemLietCount == 0
```

To:

```swift
let passed = correctCount >= LicenseType.current.passThreshold && wrongDiemLietCount == 0
```

**Step 2: Fix `BaseExamView` timer initialization**

Change line 219 from:

```swift
remainingSeconds = AppConstants.Exam.totalTimeSeconds
```

To:

```swift
remainingSeconds = LicenseType.current.totalTimeSeconds
```

**Step 3: Fix `BaseExamView` time used calculation**

Change line 263 from:

```swift
timeUsedSeconds: AppConstants.Exam.totalTimeSeconds - remainingSeconds,
```

To:

```swift
timeUsedSeconds: LicenseType.current.totalTimeSeconds - remainingSeconds,
```

**Step 4: Build to verify**

Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add GPLX2026/Core/Models/ExamResult.swift GPLX2026/Features/Exam/BaseExamView.swift
git commit -m "feat: use LicenseType for pass threshold and timer"
```

---

### Task 5: Update `ExamResultView` and `ExamTab` to use `LicenseType`

**Files:**
- Modify: `GPLX2026/Features/Exam/ExamResultView.swift:55`
- Modify: `GPLX2026/Features/Home/ExamTab.swift:156,171,240`

**Step 1: Fix pass condition display in ExamResultView**

Change line 55 from:

```swift
value: "≥ \(AppConstants.Exam.passThreshold) & 0 ĐL sai",
```

To:

```swift
value: "≥ \(LicenseType.current.passThreshold) & 0 ĐL sai",
```

**Step 2: Fix exam sets count in ExamTab**

Change line 156 from:

```swift
let visibleSets = showAllExamSets ? AppConstants.Storage.totalExamSets : 6
```

To:

```swift
let visibleSets = showAllExamSets ? LicenseType.current.totalExamSets : 6
```

Change line 171 from:

```swift
Text("\(completedCount)/\(AppConstants.Storage.totalExamSets)")
```

To:

```swift
Text("\(completedCount)/\(LicenseType.current.totalExamSets)")
```

Change line 240 from:

```swift
Text("Xem tất cả \(AppConstants.Storage.totalExamSets) đề")
```

To:

```swift
Text("Xem tất cả \(LicenseType.current.totalExamSets) đề")
```

**Step 3: Build to verify**

Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add GPLX2026/Features/Exam/ExamResultView.swift GPLX2026/Features/Home/ExamTab.swift
git commit -m "feat: display license-specific exam rules in UI"
```

---

### Task 6: Add license type picker to Onboarding

**Files:**
- Modify: `GPLX2026/Features/Onboarding/OnboardingView.swift`

**Step 1: Add license storage and new page**

Add after line 4:

```swift
@AppStorage(AppConstants.StorageKey.licenseType) private var licenseType = "b2"
```

**Step 2: Insert license selection page at index 1**

Replace the `pages` array (lines 7-38). Insert a new page after the welcome:

```swift
private let pages = [
    OnboardingPage(
        id: 0,
        icon: "car.fill",
        title: "Chào mừng đến với\nGPLX 2026",
        subtitle: "Ôn thi giấy phép lái xe\nTheo đề thi mới nhất 2026 của Bộ GTVT"
    ),
    OnboardingPage(
        id: 1,
        icon: "person.text.rectangle",
        title: "Chọn hạng bằng lái",
        subtitle: ""  // custom content below
    ),
    OnboardingPage(
        id: 2,
        icon: "list.clipboard.fill",
        title: "Kỳ thi gồm 3 phần",
        subtitle: "Bạn phải đạt cả 3 phần mới được cấp bằng"
    ),
    OnboardingPage(
        id: 3,
        icon: "book.fill",
        title: "Mọi thứ bạn cần",
        subtitle: "Từ lý thuyết đến thực hành, từ ôn luyện\nđến kiểm tra — tất cả trong một ứng dụng"
    ),
    OnboardingPage(
        id: 4,
        icon: "paintpalette.fill",
        title: "Tuỳ chỉnh giao diện",
        subtitle: "Chọn màu sắc, cỡ chữ và chế độ sáng/tối\ntrong phần Cài đặt theo sở thích của bạn"
    ),
    OnboardingPage(
        id: 5,
        icon: "flag.checkered",
        title: "Sẵn sàng rồi!",
        subtitle: "Bắt đầu hành trình chinh phục\nbằng lái xe của bạn"
    ),
]
```

**Step 3: Add custom license picker content for page 1**

In the `TabView`'s `ForEach`, replace the simple `OnboardingPageView` with a conditional that shows the license picker for page 1:

```swift
TabView(selection: $currentPage) {
    ForEach(pages) { page in
        if page.id == 1 {
            LicensePickerPage(selectedLicense: $licenseType)
                .tag(page.id)
        } else {
            OnboardingPageView(page: page)
                .tag(page.id)
        }
    }
}
```

**Step 4: Create `LicensePickerPage` as a private view in the same file**

Add before the closing `}` of `OnboardingView`:

```swift
private struct LicensePickerPage: View {
    @Binding var selectedLicense: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.text.rectangle")
                .font(.system(size: 56))
                .foregroundStyle(Color.appPrimary)
                .padding(.bottom, 8)

            Text("Chọn hạng bằng lái")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                ForEach(LicenseType.allCases, id: \.self) { type in
                    let isSelected = selectedLicense == type.rawValue
                    Button {
                        Haptics.impact(.light)
                        selectedLicense = type.rawValue
                    } label: {
                        HStack(spacing: 14) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hạng \(type.displayName)")
                                    .font(.system(size: 18, weight: .bold))
                                Text(type.description)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.appTextMedium)
                            }
                            Spacer()
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 24))
                                .foregroundStyle(isSelected ? Color.appPrimary : Color.appTextLight)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassCard()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.appPrimary : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Text("\(LicenseType(rawValue: selectedLicense)?.questionsPerExam ?? 35) câu · \((LicenseType(rawValue: selectedLicense)?.totalTimeSeconds ?? 1320) / 60) phút · Đạt \(LicenseType(rawValue: selectedLicense)?.passThreshold ?? 32)")
                .font(.system(size: 13))
                .foregroundStyle(Color.appTextMedium)

            Spacer()
            Spacer()
        }
    }
}
```

**Step 5: Build to verify**

Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add GPLX2026/Features/Onboarding/OnboardingView.swift
git commit -m "feat: add license type picker to onboarding flow"
```

---

### Task 7: Add license type picker to Settings

**Files:**
- Modify: `GPLX2026/Features/Settings/SettingsView.swift`

**Step 1: Add `@AppStorage` for license type**

Add alongside other `@AppStorage` declarations at the top of `SettingsView`:

```swift
@AppStorage(AppConstants.StorageKey.licenseType) private var licenseType = "b2"
```

**Step 2: Add license picker row**

Add a new section at the top of the settings list (before the appearance section). Use a `Picker`:

```swift
settingsSection("Hạng bằng lái") {
    VStack(spacing: 0) {
        HStack {
            Image(systemName: "person.text.rectangle")
                .font(.system(size: 16))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 28)
            Text("Hạng bằng")
                .font(.system(size: 15))
            Spacer()
            Picker("", selection: $licenseType) {
                ForEach(LicenseType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 120)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    .glassCard()

    let current = LicenseType(rawValue: licenseType) ?? .b2
    Text("\(current.questionsPerExam) câu · \(current.totalTimeSeconds / 60) phút · Đạt \(current.passThreshold)")
        .font(.system(size: 12))
        .foregroundStyle(Color.appTextLight)
        .lineSpacing(3)
}
```

**Step 3: Build to verify**

Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add GPLX2026/Features/Settings/SettingsView.swift
git commit -m "feat: add license type picker to settings"
```

---

### Task 8: Add App Store review prompt (F4)

**Files:**
- Modify: `GPLX2026/Features/Exam/ExamResultView.swift`
- Modify: `GPLX2026/Features/Simulation/SimulationResultView.swift`
- Modify: `GPLX2026/Features/Hazard/HazardResultView.swift`
- Modify: `GPLX2026/Core/Common/Utilities/AppConstants.swift:52-61`

**Step 1: Add storage key**

In `AppConstants.StorageKey`, add:

```swift
static let hasRequestedReview = "hasRequestedReview"
```

**Step 2: Add review request helper**

Create a small helper to avoid repeating logic in 3 views. Add to a new file or as an extension. Simplest: add directly in each view. But to keep DRY, add at the bottom of `AppConstants.swift`:

```swift
import StoreKit

enum ReviewHelper {
    static func requestIfFirstPass(passed: Bool) {
        guard passed else { return }
        let key = AppConstants.StorageKey.hasRequestedReview
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            guard let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            else { return }
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
```

Note: Add `import StoreKit` and `import UIKit` at the top of `AppConstants.swift`.

**Step 3: Call from ExamResultView**

In `ExamResultView`, add an `.onAppear` to the outermost view:

```swift
.onAppear {
    if !isFromHistory {
        ReviewHelper.requestIfFirstPass(passed: examResult.passed)
    }
}
```

**Step 4: Call from SimulationResultView**

Add `.onAppear` similarly:

```swift
.onAppear {
    if !isFromHistory {
        ReviewHelper.requestIfFirstPass(passed: simulationResult.passed)
    }
}
```

**Step 5: Call from HazardResultView**

Add `.onAppear`:

```swift
.onAppear {
    ReviewHelper.requestIfFirstPass(passed: result.passed)
}
```

**Step 6: Build to verify**

Expected: BUILD SUCCEEDED

**Step 7: Commit**

```bash
git add GPLX2026/Core/Common/Utilities/AppConstants.swift \
    GPLX2026/Features/Exam/ExamResultView.swift \
    GPLX2026/Features/Simulation/SimulationResultView.swift \
    GPLX2026/Features/Hazard/HazardResultView.swift
git commit -m "feat: add App Store review prompt after first exam pass"
```

---

### Task 9: Update Readiness constants and HomeTab for license type

**Files:**
- Modify: `GPLX2026/Core/Common/Utilities/AppConstants.swift:27-32`
- Check: Any views that display "600 câu" or similar hardcoded totals

**Step 1: Make Readiness reflect license pool size**

The `Readiness` constants reference 600 total questions. Update to be dynamic. In any view that shows "X/600", replace with:

```swift
LicenseType.current == .b1 ? 300 : 600
```

Or add to `LicenseType`:

```swift
var totalQuestions: Int {
    switch self {
    case .b1: return 300
    case .b2: return 600
    }
}
```

**Step 2: Search for hardcoded "600" references**

Run: `grep -rn "600" GPLX2026/Features/ --include="*.swift"` and fix any that reference total question count.

**Step 3: Build and verify**

Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git commit -am "feat: update readiness and totals for license type"
```

---

### Task 10: Build, install, and smoke test

**Step 1: Full build**

```bash
xcodebuild -project GPLX2026.xcodeproj -scheme GPLX2026 -destination 'id=00008120-0016116A1103C01E' build
```

**Step 2: Install to device**

```bash
xcrun devicectl device install app --device 00008120-0016116A1103C01E <app_path>
```

**Step 3: Smoke test checklist**

- [ ] Onboarding shows license picker page
- [ ] Selecting B1 vs B2 persists
- [ ] B1 exam: 30 questions, 20 min timer, pass at 26
- [ ] B2 exam: 35 questions, 22 min timer, pass at 32
- [ ] Exam sets count: B1=10, B2=17
- [ ] Settings shows license picker with correct rules
- [ ] Switching license type in settings updates exam tab
- [ ] First exam pass triggers App Store review prompt
