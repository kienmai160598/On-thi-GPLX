import Foundation
import UserNotifications
import os

/// Schedules and manages the app's local study reminders.
///
/// Design: one idempotent `syncReminders(...)` entry point is the single source
/// of truth — it cancels every reminder we own and reschedules from the current
/// settings. It is safe to call on every launch, foreground, and settings
/// change, and no-ops scheduling when notifications aren't authorized.
enum NotificationManager {

    private static let logger = Logger(subsystem: "com.gplx2026", category: "Notifications")

    // MARK: - Identifiers

    private static let dailyReminderID = "daily-practice-reminder"
    static let goalNudgeID = "daily-goal-nudge"
    private static let examCountdownOffsets = [7, 3, 1, 0]   // days before exam
    private static func examCountdownID(_ offset: Int) -> String { "exam-countdown-\(offset)" }

    /// `userInfo` key carrying the deep-link destination (a `NotificationDestination` raw value).
    static let routeKey = "route"

    /// Every identifier this type schedules — removed up-front on each sync.
    private static var managedIdentifiers: [String] {
        [dailyReminderID, goalNudgeID] + examCountdownOffsets.map(examCountdownID)
    }

    // MARK: - Authorization

    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Request notification permission. Returns `true` if granted.
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            logger.error("requestAuthorization failed: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Sync (single source of truth)

    /// Cancel every reminder we manage, then reschedule from the supplied
    /// settings. Idempotent. Scheduling is skipped (but cancellation still
    /// happens) when notifications aren't authorized.
    @MainActor
    static func syncReminders(
        dailyEnabled: Bool,
        hour: Int,
        examCountdownEnabled: Bool,
        dailyGoalNudgeEnabled: Bool,
        progressStore: ProgressStore,
        questionStore: QuestionStore
    ) async {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: managedIdentifiers)

        let status = await authorizationStatus()
        guard status == .authorized || status == .provisional else {
            return
        }

        if dailyEnabled {
            await scheduleDailyReminder(hour: hour, progressStore: progressStore, questionStore: questionStore)
        }
        if examCountdownEnabled {
            await scheduleExamCountdown(examDate: progressStore.examDate)
        }
        if dailyGoalNudgeEnabled {
            await scheduleDailyGoalNudge(progressStore: progressStore)
        }
    }

    /// Remove all reminders this type manages.
    static func cancelAll() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: managedIdentifiers)
    }

    /// Cancel only the daily-goal nudge — call when the goal is met intra-session.
    static func cancelGoalNudge() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [goalNudgeID])
    }

    // MARK: - Schedulers

    /// Daily repeating reminder whose copy reflects current progress.
    @MainActor
    private static func scheduleDailyReminder(
        hour: Int,
        minute: Int = 0,
        progressStore: ProgressStore,
        questionStore: QuestionStore
    ) async {
        let content = UNMutableNotificationContent()
        let message = smartMessage(progressStore: progressStore, questionStore: questionStore)
        content.title = message.title
        content.body = message.body
        content.sound = .default
        content.userInfo = [routeKey: NotificationDestination.practice.rawValue]

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        await add(id: dailyReminderID, content: content, trigger: trigger)
    }

    /// A bounded set of one-shot reminders as the exam approaches (T-7, T-3,
    /// T-1, and the morning of). Well within the 64 pending-notification cap.
    private static func scheduleExamCountdown(examDate: Date?) async {
        guard let examDate else { return }
        let calendar = Calendar.current

        for offset in examCountdownOffsets {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: examDate) else { continue }
            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = offset == 0 ? 7 : 9   // morning of exam vs. lead-up days
            components.minute = 0
            guard let fireDate = calendar.date(from: components), fireDate > Date() else { continue }

            let copy = examCountdownCopy(offset: offset)
            let content = UNMutableNotificationContent()
            content.title = copy.title
            content.body = copy.body
            content.sound = .default
            content.userInfo = [routeKey: NotificationDestination.exam.rawValue]

            let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            await add(id: examCountdownID(offset), content: content, trigger: trigger)
        }
    }

    /// Evening nudge scheduled only when today's goal isn't met yet. A single
    /// one-shot, refreshed on every sync — if the goal is already met (or the
    /// evening has passed) it's aimed at tomorrow instead.
    @MainActor
    private static func scheduleDailyGoalNudge(
        progressStore: ProgressStore,
        hour: Int = 20,
        minute: Int = 30
    ) async {
        let calendar = Calendar.current
        let now = Date()
        var todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        todayComponents.hour = hour
        todayComponents.minute = minute
        guard let todayFire = calendar.date(from: todayComponents) else { return }

        let (done, goal) = progressStore.todayProgress
        let fireDate: Date
        if done < goal && now < todayFire {
            fireDate = todayFire
        } else {
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: todayFire) else { return }
            fireDate = tomorrow
        }

        let content = UNMutableNotificationContent()
        content.title = "Mục tiêu hôm nay"
        content.body = "Bạn đặt mục tiêu \(goal) câu/ngày. Dành vài phút ôn nốt nhé!"
        content.sound = .default
        content.userInfo = [routeKey: NotificationDestination.practice.rawValue]

        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        await add(id: goalNudgeID, content: content, trigger: trigger)
    }

    private static func add(id: String, content: UNNotificationContent, trigger: UNNotificationTrigger) async {
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            logger.error("Failed to schedule \(id): \(error.localizedDescription)")
        }
    }

    private static func examCountdownCopy(offset: Int) -> Message {
        switch offset {
        case 7:  return Message(title: "Còn 7 ngày đến ngày thi 📅", body: "Tăng tốc ôn tập tuần này nhé!")
        case 3:  return Message(title: "Còn 3 ngày đến ngày thi ⏳", body: "Ôn kỹ câu điểm liệt và làm thử vài đề.")
        case 1:  return Message(title: "Ngày mai là ngày thi! 🚗", body: "Xem lại câu hay sai rồi nghỉ ngơi sớm nhé.")
        default: return Message(title: "Hôm nay là ngày thi! 🍀", body: "Bình tĩnh, tự tin. Chúc bạn thi đậu!")
        }
    }

    // MARK: - Smart Messages

    private struct Message {
        let title: String
        let body: String
    }

    @MainActor
    private static func smartMessage(progressStore: ProgressStore?, questionStore: QuestionStore?) -> Message {
        guard let progress = progressStore, let questions = questionStore else {
            return fallbackMessage()
        }

        let topics = questions.topics
        let allQuestions = questions.allQuestions
        let totalQuestions = allQuestions.count
        let status = progress.readinessStatus(topics: topics, allQuestions: allQuestions)
        let mastery = totalQuestions > 0 ? Double(status.totalCorrect) / Double(totalQuestions) : 0
        let wrongCount = progress.wrongAnswers.count
        let streak = progress.streakCount
        let examsTaken = progress.examHistory.count
        let dlDone = status.diemLiet.correct == status.diemLiet.total && status.diemLiet.total > 0

        // Build a pool of relevant messages and pick one
        var candidates: [Message] = []

        // Streak-based
        if streak >= 7 {
            candidates.append(Message(
                title: "🔥 \(streak) ngày liên tục!",
                body: "Giữ vững phong độ — vào ôn tập để không đứt chuỗi nhé."
            ))
        } else if streak >= 3 {
            candidates.append(Message(
                title: "💪 Chuỗi \(streak) ngày!",
                body: "Đang tiến bộ tốt! Vào luyện thêm để giữ chuỗi."
            ))
        } else if streak == 0 {
            candidates.append(Message(
                title: "Hôm nay chưa ôn bài",
                body: "Chỉ 5 phút thôi — mở app luyện vài câu nhé!"
            ))
        }

        // Wrong answers
        if wrongCount > 10 {
            candidates.append(Message(
                title: "Còn \(wrongCount) câu sai",
                body: "Ôn lại câu sai sẽ giúp tăng điểm nhanh nhất. Vào luyện ngay!"
            ))
        } else if wrongCount > 0 {
            candidates.append(Message(
                title: "\(wrongCount) câu cần ôn lại",
                body: "Sửa hết câu sai là gần đậu rồi. Vào luyện nhé!"
            ))
        }

        // Điểm liệt
        if !dlDone {
            let remaining = status.diemLiet.total - status.diemLiet.correct
            candidates.append(Message(
                title: "Câu điểm liệt: \(status.diemLiet.correct)/\(status.diemLiet.total)",
                body: "Còn \(remaining) câu điểm liệt chưa thuộc. Sai 1 câu = trượt!"
            ))
        }

        // Mastery-based
        if mastery < 0.3 {
            candidates.append(Message(
                title: "Mới thuộc \(Int(mastery * 100))% câu hỏi",
                body: "Vào ôn thêm mỗi ngày — mục tiêu 80% là an toàn."
            ))
        } else if mastery < 0.6 {
            candidates.append(Message(
                title: "Đã thuộc \(status.totalCorrect)/\(totalQuestions) câu",
                body: "Tiến bộ tốt! Cố thêm chút nữa để chắc đậu nhé."
            ))
        } else if mastery < 0.8 {
            candidates.append(Message(
                title: "Gần đạt mục tiêu: \(Int(mastery * 100))%",
                body: "Ôn thêm \(totalQuestions - status.totalCorrect) câu nữa là sẵn sàng thi."
            ))
        } else if mastery >= 0.8 {
            candidates.append(Message(
                title: "Sẵn sàng thi: \(Int(mastery * 100))%!",
                body: dlDone
                    ? "Kiến thức vững rồi. Thử đề thi để kiểm tra nhé!"
                    : "Nhớ ôn kỹ câu điểm liệt trước khi thi nhé."
            ))
        }

        // Exam-based
        if examsTaken == 0 && mastery > 0.4 {
            candidates.append(Message(
                title: "Đã sẵn sàng thử đề thi?",
                body: "Bạn đã thuộc \(Int(mastery * 100))% câu hỏi. Thử thi thử 1 lần xem sao!"
            ))
        } else if examsTaken > 0 {
            let lastExam = progress.examHistory.first
            if let exam = lastExam, !exam.passed {
                candidates.append(Message(
                    title: "Lần thi trước: \(exam.score)/\(exam.totalQuestions)",
                    body: "Ôn lại câu sai rồi thử lại — lần này chắc đậu!"
                ))
            }
        }

        return candidates.randomElement() ?? fallbackMessage()
    }

    private static func fallbackMessage() -> Message {
        let bodies = [
            "Luyện tập mỗi ngày giúp bạn tự tin hơn khi thi.",
            "Chỉ 10 phút mỗi ngày cũng đủ tạo sự khác biệt!",
            "Kiên trì ôn tập, đậu bằng lái dễ dàng!",
        ]
        return Message(
            title: "Đến giờ ôn thi rồi!",
            body: bodies.randomElement() ?? bodies[0]
        )
    }
}
