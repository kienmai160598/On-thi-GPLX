import SwiftUI

/// The 4-step onboarding flow (Welcome → Experience → Study plan → Ready),
/// matching the design. Navigation is button-only (no swipe) so the study-plan
/// step's persistence + notification request always run before the summary.
struct OnboardingView: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(ThemeStore.self) private var themeStore

    @AppStorage(AppConstants.StorageKey.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(AppConstants.StorageKey.licenseType) private var licenseType = "b2"
    @AppStorage(AppConstants.StorageKey.experienceLevel) private var experienceLevelRaw = ExperienceLevel.partial.rawValue
    @AppStorage(AppConstants.StorageKey.dailyReminderEnabled) private var dailyReminderEnabled = false
    @AppStorage(AppConstants.StorageKey.dailyReminderHour) private var dailyReminderHour = 20
    @AppStorage(AppConstants.StorageKey.examCountdownEnabled) private var examCountdownEnabled = false
    @AppStorage(AppConstants.StorageKey.dailyGoalNudgeEnabled) private var dailyGoalNudgeEnabled = false

    @State private var step = 1
    @State private var examDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @State private var dailyGoal = 30
    @State private var notificationsEnabled = true
    @State private var didLoad = false

    private var experienceBinding: Binding<ExperienceLevel> {
        Binding(
            get: { ExperienceLevel(rawValue: experienceLevelRaw) ?? .partial },
            set: { experienceLevelRaw = $0.rawValue }
        )
    }

    var body: some View {
        ZStack {
            ScaffoldBackground(glow: themeStore.primaryColor)
            currentStep
                .id(step)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        }
        .animation(.spring(duration: 0.4), value: step)
        .onAppear(perform: loadFromStore)
    }

    @ViewBuilder
    private var currentStep: some View {
        switch step {
        case 1:
            OnboardingWelcomeStep(onSkip: complete, onContinue: advance)
        case 2:
            OnboardingExperienceStep(selected: experienceBinding, onSkip: complete, onContinue: advance)
        case 3:
            OnboardingStudyPlanStep(
                license: $licenseType,
                examDate: $examDate,
                dailyGoal: $dailyGoal,
                notificationsEnabled: $notificationsEnabled,
                onSkip: complete,
                onContinue: persistPlanThenAdvance
            )
        default:
            OnboardingReadyStep(license: licenseType, examDate: examDate, dailyGoal: dailyGoal, onFinish: complete)
        }
    }

    // MARK: - Flow

    private func loadFromStore() {
        guard !didLoad else { return }
        didLoad = true
        if let saved = progressStore.examDate { examDate = saved }
        dailyGoal = progressStore.dailyGoal
    }

    private func advance() {
        Haptics.impact(.light)
        step = min(4, step + 1)
    }

    /// Step 3 CTA: persist the chosen plan, optionally request notification
    /// permission, then advance to the summary.
    private func persistPlanThenAdvance() {
        progressStore.setExamDate(examDate)
        progressStore.setDailyGoal(dailyGoal)
        Task {
            if notificationsEnabled, await NotificationManager.requestAuthorization() {
                dailyReminderEnabled = true
                examCountdownEnabled = true
                await NotificationManager.syncReminders(
                    dailyEnabled: true,
                    hour: dailyReminderHour,
                    examCountdownEnabled: true,
                    dailyGoalNudgeEnabled: dailyGoalNudgeEnabled,
                    progressStore: progressStore,
                    questionStore: questionStore
                )
            }
            advance()
        }
    }

    private func complete() {
        // Persist whatever the user configured on step 3 so nothing is lost on skip.
        progressStore.setExamDate(examDate)
        progressStore.setDailyGoal(dailyGoal)
        Haptics.impact(.medium)
        hasCompletedOnboarding = true
    }
}
