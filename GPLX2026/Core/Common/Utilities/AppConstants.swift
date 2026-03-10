import Foundation
import StoreKit
import UIKit

// MARK: - AppConstants

enum AppConstants {

    // MARK: - Mock Exam

    enum Exam {
        static let totalTimeSeconds = 22 * 60
        static let questionsPerExam = 30
        static let passThreshold = 28
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

    // MARK: - Storage

    enum Storage {
        static let historyLimit = 50
        static let totalExamSets = 20
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
        static let licenseType = "licenseType"
        static let hasRequestedReview = "hasRequestedReview"
    }

    // MARK: - Special Topic Keys

    enum TopicKey {
        static let diemLiet = "diem_liet"
        static let bookmarks = "bookmarks"
        static let wrongAnswers = "wrong_answers"
        static let allQuestions = "all_questions"
    }
}

// MARK: - Review Helper

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
