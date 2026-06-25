import SwiftUI

// MARK: - HistoryItemRow
//
// Shared row for the dedicated history screens (design component "HistoryItem"):
// a colored icon box, a title + meta line, a right-aligned score value + status
// label (both share `valueColor`), and a trailing chevron — wrapped in a glass card.

struct HistoryItemRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let meta: String
    let value: String
    let valueColor: Color
    let status: String

    var body: some View {
        HStack(spacing: 12) {
            IconBox(icon: icon, color: iconColor, size: 40, cornerRadius: 10, iconFontSize: 18, iconWeight: .semibold)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.appSans(size: 15, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                    .lineLimit(1)
                Text(meta)
                    .font(.appSans(size: 12, weight: .semibold))
                    .foregroundStyle(Color.appTextMedium)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.appSans(size: 16, weight: .heavy))
                    .foregroundStyle(valueColor)
                Text(status)
                    .font(.appSans(size: 11, weight: .bold))
                    .foregroundStyle(valueColor)
            }

            Image(systemName: "chevron.right")
                .font(.appSans(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextLight)
        }
        .padding(12)
        .contentShape(Rectangle())
        .glassCard(cornerRadius: 22)
    }
}

// MARK: - HistorySummaryCard
//
// The three-stat strip at the top of every history screen (design "Summary").

struct HistorySummaryCard: View {
    struct Stat {
        let value: String
        let label: String
        var color: Color = .appTextDark
    }

    let stats: [Stat]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(stats.enumerated()), id: \.offset) { _, stat in
                StatItem(value: stat.value, label: stat.label, valueColor: stat.color, valueFontSize: 22)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .glassCard()
    }
}

// MARK: - Helpers

/// Relative-day + time label for a history entry, e.g. "Hôm nay · 14:20",
/// "Hôm qua · 19:40", "23/06 · 21:10". Formatters are cached (see CLAUDE.md:
/// no per-render DateFormatter allocation).
enum HistoryDate {
    private static let calendar = Calendar.current

    private static let time: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "HH:mm"
        return f
    }()

    private static let dayMonth: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "dd/MM"
        return f
    }()

    static func string(from date: Date) -> String {
        let t = time.string(from: date)
        if calendar.isDateInToday(date) { return "Hôm nay · \(t)" }
        if calendar.isDateInYesterday(date) { return "Hôm qua · \(t)" }
        return "\(dayMonth.string(from: date)) · \(t)"
    }
}

/// Quality bands (label + color) for a 0…1 score, shared by the hazard and
/// practice history screens. Exam/simulation use a plain Đạt/Trượt instead.
enum HistoryQuality {
    static func hazard(_ fraction: Double) -> (label: String, color: Color) {
        switch fraction {
        case 0.9...:     return ("Xuất sắc", .appSuccess)
        case 0.7..<0.9:  return ("Tốt", .appSuccess)
        case 0.5..<0.7:  return ("Khá", .appWarning)
        default:         return ("Cần cố gắng", .appError)
        }
    }

    static func practice(_ fraction: Double) -> (label: String, color: Color) {
        switch fraction {
        case 0.85...:    return ("Tốt", .appSuccess)
        case 0.7..<0.85: return ("Khá", .appSuccess)
        case 0.5..<0.7:  return ("Trung bình", .appWarning)
        default:         return ("Yếu", .appError)
        }
    }
}
