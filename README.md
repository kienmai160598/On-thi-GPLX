# GPLX B 2026 — Vietnamese Driving License Exam Prep (Class B)

A native iOS app for preparing the Vietnamese class B (B1/B2) driving license theory exam, built entirely with SwiftUI and aligned with the latest 2026 exam format from the Ministry of Transport (Bo GTVT).

## Features

### Study
- **600 official questions** across 5 topics — regulations, techniques, vehicle structure, traffic signs, and road scenarios
- **Study by topic** with per-topic accuracy tracking and weak-topic detection
- **Critical questions (Diem Liet)** — dedicated focus on instant-fail questions
- **Flashcards** — quick review with swipe-based card interface
- **Memory tips** — curated mnemonics for each topic

### Exams
- **Mock exams** — 35 questions, 22-minute timer, auto-graded with detailed results
- **20 fixed exam sets** matching the real test format
- **Exam history** with pass rate, score trends, and per-question review

### Hazard Perception
- **Simulation practice** — 20 scenario-based questions with 60s per scenario
- **120 video situations** across 6 chapters (urban, rural, highway, mountain, national road, real accidents)
- **Tap-to-react scoring** — linear interpolation from perfect to late response
- **Offline video caching** with per-chapter downloads and speed tracking

### Tools & Reference
- **Traffic sign reference** — searchable catalog with categories
- **Question search** — full-text search across all 600 questions
- **Bookmarks & wrong answers** — saved for targeted review
- **Readiness score** — weighted metric combining accuracy, coverage, critical mastery, and pass rate

### Customization
- **Theme modes** — light, dark, or follow system
- **10 accent colors** with live preview
- **Adjustable font size** — small, medium, large with preview
- **iOS 26 Liquid Glass** support with graceful fallback to iOS 18

## Requirements

| Requirement | Version |
|-------------|---------|
| iOS         | 18.0+   |
| Xcode       | 16.0+   |
| Swift       | 6.0 (strict concurrency) |

## Getting Started

```bash
git clone https://github.com/kienmai160598/On-thi-GPLX.git
cd On-thi-GPLX
open GPLX2026.xcodeproj
```

Or build and install directly to a connected iPhone:

```bash
make install
```

### Available Make Commands

| Command         | Description                          |
|-----------------|--------------------------------------|
| `make install`  | Build, sign, and install on iPhone   |
| `make build`    | Archive and export signed .ipa       |
| `make clean`    | Remove build artifacts               |
| `make device`   | List connected devices               |

## Architecture

```
GPLX2026/
├── Core/
│   ├── Common/         # Shared UI components (AppButton, ExamBottomBar, QuestionCard, ...)
│   ├── Models/         # Data models (Question, Topic, ExamResult, HazardSituation, ...)
│   ├── Storage/        # QuestionStore, ProgressStore, HazardVideoCache (@Observable)
│   └── Theme/          # Colors, glass card modifier, screen header, typography
├── Features/
│   ├── Home/           # Dashboard, tab views (home, study, exam, practice)
│   ├── Learn/          # Question practice, memory tips
│   ├── Exam/           # Mock exam flow, results, history
│   ├── Simulation/     # Scenario-based simulation exam
│   ├── Hazard/         # Video hazard perception test
│   ├── Topics/         # Topic browser, weak topics
│   ├── Search/         # Full-text question search
│   ├── Badges/         # Achievement badges
│   ├── Bookmarks/      # Bookmarked & wrong questions
│   ├── Flashcard/      # Flashcard review
│   ├── Reference/      # Traffic signs & rules reference
│   ├── Settings/       # Theme, color, font, data management
│   └── Onboarding/     # First-launch walkthrough
└── Resources/
    ├── Data/           # questions.json, memory_tips.json
    └── Images/         # 270+ question illustrations
```

## Tech Stack

- **SwiftUI** — 100% declarative UI, no UIKit
- **Observation framework** — `@Observable` macro for reactive state
- **Swift 6 strict concurrency** — `Sendable`, `@MainActor`, structured concurrency
- **UserDefaults** — offline progress persistence (no server required)
- **URLSession** — delegate-based video downloads with progress tracking
- **iOS 26 Liquid Glass** — native glass effects with iOS 18 material fallback

## Data Sources

- **Exam question bank** — Ministry of Transport (Bo GTVT), 2026 edition
- **Hazard perception videos** — [gmec.vn](https://gmec.vn)

## License

MIT License — see [LICENSE](LICENSE).
