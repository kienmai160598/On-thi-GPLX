import UserNotifications

enum NotificationManager {
    private static let dailyReminderID = "daily-practice-reminder"

    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Schedule a daily reminder with content based on actual learning progress.
    @MainActor
    static func scheduleDailyReminder(hour: Int = 20, minute: Int = 0, progressStore: ProgressStore? = nil, questionStore: QuestionStore? = nil) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderID])

        let content = UNMutableNotificationContent()
        let message = smartMessage(progressStore: progressStore, questionStore: questionStore)
        content.title = message.title
        content.body = message.body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderID, content: content, trigger: trigger)

        center.add(request)
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyReminderID])
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
