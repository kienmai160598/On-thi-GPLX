import Foundation
import StoreKit
import UIKit

// MARK: - AppConstants

enum AppConstants {

    // MARK: - Mock Exam

    enum Exam {
        static var totalTimeSeconds: Int { LicenseType.current.totalTimeSeconds }
        static var questionsPerExam: Int { LicenseType.current.questionsPerExam }
        static var passThreshold: Int { LicenseType.current.passThreshold }
        static let diemLietPerExam = 1
        static let urgencyThresholdSeconds = 300
    }

    // MARK: - Simulation Exam

    enum Simulation {
        static let scenarioTimeSeconds = 60
        static let passRate = 0.7
        static let urgencyThresholdSeconds = 10
    }

    // MARK: - Readiness

    enum Readiness {
        static var attemptedGoal: Int { LicenseType.current == .b1 ? 200 : 400 }
        static var totalQuestionsGoal: Int { LicenseType.current.totalQuestions }
        static let readyPercentage = 80
        static let intermediatePercentage = 50
    }

    // MARK: - Hazard Perception

    enum Hazard {
        static let situationsPerExam = 10
        static let maxScorePerSituation = 5
        static let passScore = 35
        static let maxTotalScore = situationsPerExam * maxScorePerSituation
    }

    // MARK: - Daily Challenge

    enum DailyChallenge {
        static let questionsCount = 10
        static let totalTimeSeconds = 600  // 10 minutes
        static let urgencyThresholdSeconds = 120
        static let passRate = 0.8
    }

    // MARK: - Storage

    enum Storage {
        static let historyLimit = 50
    }

    // MARK: - AppStorage Keys

    enum StorageKey {
        static let themeMode = "appThemeMode"
        static let fontSize = "appFontSize"
        static let primaryColor = "appPrimaryColor"
        static let hapticsEnabled = "hapticsEnabled"
        static let backgroundAnimation = "backgroundAnimation"
        static let backgroundSpeed = "backgroundSpeed"
        static let dailyReminderEnabled = "dailyReminderEnabled"
        static let dailyReminderHour = "dailyReminderHour"
        static let examCountdownEnabled = "examCountdownEnabled"
        static let dailyGoalNudgeEnabled = "dailyGoalNudgeEnabled"
        static let licenseType = "licenseType"
        static let experienceLevel = "experienceLevel"
        static let hasRequestedReview = "hasRequestedReview"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }

    // MARK: - Special Topic Keys

    enum TopicKey {
        static let diemLiet = "diem_liet"
        static let bookmarks = "bookmarks"
        static let wrongAnswers = "wrong_answers"
        static let allQuestions = "all_questions"
        /// The full question set for the active license (B1 = filtered subset, B2 = all).
        static let currentLicense = "current_license"
        /// Wrong answers ordered by spaced-repetition priority (never-reviewed first, then oldest).
        static let wrongAnswersPriority = "wrong_answers_priority"
    }
}

// MARK: - Review Helper

enum ReviewHelper {
    static func requestIfFirstPass(passed: Bool) {
        guard passed else { return }
        let key = AppConstants.StorageKey.hasRequestedReview
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            guard let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            else { return }
            AppStore.requestReview(in: scene)
        }
    }
}
