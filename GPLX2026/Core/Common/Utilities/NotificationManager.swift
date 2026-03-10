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

    static func scheduleDailyReminder(hour: Int = 20, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderID])

        let content = UNMutableNotificationContent()
        content.title = "Đến giờ ôn thi rồi!"
        content.body = reminders.randomElement() ?? "Luyện tập mỗi ngày giúp bạn tự tin hơn khi thi."
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

    private static let reminders = [
        "Luyện tập mỗi ngày giúp bạn tự tin hơn khi thi.",
        "Chỉ 10 phút mỗi ngày cũng đủ tạo sự khác biệt!",
        "Ôn lại câu điểm liệt để không bị trượt nhé.",
        "Bạn đã ôn bài hôm nay chưa? Vào luyện tập ngay!",
        "Kiên trì ôn tập, đậu bằng lái dễ dàng!",
        "Đừng quên luyện thi mỗi ngày nhé!",
    ]
}
