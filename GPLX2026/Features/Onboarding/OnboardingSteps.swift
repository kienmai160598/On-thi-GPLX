import SwiftUI

// MARK: - Shared onboarding chrome

/// The common onboarding step layout: a "BƯỚC x / 4" indicator + optional skip
/// at the top, scrollable content in the middle, and a charcoal "ink" CTA pinned
/// to the bottom. The warm gradient background is supplied by the container
/// (`OnboardingView`), not here.
struct OnboardingStepScaffold<Content: View>: View {
    @Environment(ThemeStore.self) private var themeStore
    let step: Int
    var totalSteps: Int = 4
    var showSkip: Bool = true
    let ctaTitle: String
    var ctaIcon: String? = "arrow.right"
    var onSkip: (() -> Void)? = nil
    let onContinue: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("BƯỚC \(step) / \(totalSteps)")
                    .font(.appSans(size: 10, weight: .heavy))
                    .tracking(1.5)
                    .foregroundStyle(Color.appTextMedium)
                Spacer()
                if showSkip, let onSkip {
                    Button("Bỏ qua", action: onSkip)
                        .font(.appSans(size: 13, weight: .bold))
                        .foregroundStyle(Color.appTextMedium)
                        .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 16)

            ScrollView {
                content()
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)
            }
            .scrollIndicators(.hidden)

            Button(action: onContinue) {
                HStack(spacing: 8) {
                    Text(ctaTitle)
                        .font(.appSans(size: 15, weight: .bold))
                    if let ctaIcon {
                        Image(systemName: ctaIcon)
                            .font(.appSans(size: 16, weight: .bold))
                    }
                }
                .foregroundStyle(themeStore.onPrimaryColor)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(themeStore.primaryColor, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .shadow(color: themeStore.primaryColor.opacity(0.28), radius: 9, y: 6)
            .padding(.top, 12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
}

extension View {
    /// Onboarding's card surface: an opaque card fill plus a hairline border over
    /// the warm gradient. Pass `elevated` for the soft warm drop shadow used on
    /// the welcome/experience cards (the study-plan & summary cards stay flat).
    func onboardingCard(cornerRadius: CGFloat = 20, elevated: Bool = false) -> some View {
        self
            .background(Color.cardBg, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.cardBorder, lineWidth: 1)
            )
            .shadow(color: Color(hex: 0x8A7B58, opacity: elevated ? 0.16 : 0),
                    radius: elevated ? 10 : 0, x: 0, y: elevated ? 5 : 0)
    }
}

/// A 96×96 rounded-square hero badge with a centered symbol, on a tinted wash
/// with a hairline border and a soft warm shadow.
struct OnboardingBadge: View {
    let icon: String
    let tint: Color
    let bg: Color
    var iconSize: CGFloat = 44

    var body: some View {
        Image(systemName: icon)
            .font(.appSans(size: iconSize, weight: .bold))
            .foregroundStyle(tint)
            .frame(width: 96, height: 96)
            .background(bg, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.cardBorder, lineWidth: 1)
            )
            .shadow(color: Color(hex: 0x8A7B58, opacity: 0.18), radius: 11, x: 0, y: 6)
    }
}

/// The welcome hero badge rendered as the actual app icon (96×96, rounded like an
/// app icon) with the same hairline border + soft shadow as `OnboardingBadge`.
/// Falls back to the amber car badge if the icon image can't be resolved.
struct OnboardingAppIconBadge: View {
    private var appIcon: UIImage? {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String],
           let last = files.last,
           let image = UIImage(named: last) {
            return image
        }
        return UIImage(named: "AppIcon")
    }

    var body: some View {
        Group {
            if let appIcon {
                Image(uiImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "car.fill")
                    .font(.appSans(size: 44, weight: .bold))
                    .foregroundStyle(Color.amberInk)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.amberWash)
            }
        }
        .frame(width: 96, height: 96)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.cardBorder, lineWidth: 1)
        )
        .shadow(color: Color(hex: 0x8A7B58, opacity: 0.18), radius: 11, x: 0, y: 6)
        .accessibilityHidden(true)
    }
}

/// A feature highlight row on the welcome step (icon box + title + subtitle).
/// `amber` switches the icon box to the warm accent style; otherwise it uses the
/// neutral charcoal style.
struct OnboardingFeatureRow: View {
    @Environment(ThemeStore.self) private var themeStore
    let icon: String
    var amber: Bool = false
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            IconBox(icon: icon,
                    color: amber ? themeStore.primaryColor : .appTextDark,
                    size: 42, cornerRadius: 10, iconFontSize: 21,
                    background: amber ? themeStore.primaryColor.opacity(0.14) : .neutralWash)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appSans(size: 14.5, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                Text(subtitle)
                    .font(.appSans(size: 11.5, weight: .semibold))
                    .foregroundStyle(Color.appTextMedium)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onboardingCard(elevated: true)
    }
}

// MARK: - Step 1 · Welcome

struct OnboardingWelcomeStep: View {
    let onSkip: () -> Void
    let onContinue: () -> Void

    var body: some View {
        OnboardingStepScaffold(step: 1, ctaTitle: "Bắt đầu", onSkip: onSkip, onContinue: onContinue) {
            VStack(spacing: 20) {
                OnboardingAppIconBadge()
                    .padding(.top, 16)

                VStack(spacing: 8) {
                    Text("Ôn Thi Lái Xe 2026")
                        .font(.appSans(size: 26, weight: .heavy))
                        .tracking(-0.5)
                        .foregroundStyle(Color.appTextDark)
                        .multilineTextAlignment(.center)
                    Text("Người bạn đồng hành giúp bạn tự tin vượt qua kỳ thi lý thuyết.")
                        .font(.appSans(size: 14, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }

                VStack(spacing: 12) {
                    OnboardingFeatureRow(icon: "book.fill", amber: true,
                                         title: "600+ câu hỏi", subtitle: "Đầy đủ bộ đề thi mới nhất 2026")
                    OnboardingFeatureRow(icon: "list.clipboard.fill", amber: true,
                                         title: "Thi thử sát đề thật", subtitle: "Mô phỏng đúng cấu trúc đề thi")
                    OnboardingFeatureRow(icon: "video.fill", amber: true,
                                         title: "Mô phỏng tình huống", subtitle: "120 tình huống giao thông thực tế")
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Step 2 · Experience level

struct OnboardingExperienceStep: View {
    @Binding var selected: ExperienceLevel
    let onSkip: () -> Void
    let onContinue: () -> Void

    var body: some View {
        OnboardingStepScaffold(step: 2, ctaTitle: "Tiếp tục", onSkip: onSkip, onContinue: onContinue) {
            VStack(alignment: .leading, spacing: 16) {
                OnboardingHeader(
                    title: "Bạn đã ôn tới đâu rồi?",
                    subtitle: "Chọn mức độ để chúng tôi gợi ý nội dung phù hợp với bạn."
                )
                VStack(spacing: 12) {
                    ForEach(ExperienceLevel.allCases, id: \.self) { level in
                        ExperienceLevelCard(level: level, isSelected: selected == level) {
                            Haptics.impact(.light)
                            selected = level
                        }
                    }
                }
            }
        }
    }
}

struct ExperienceLevelCard: View {
    @Environment(ThemeStore.self) private var themeStore
    let level: ExperienceLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let accent = themeStore.primaryColor
        Button(action: action) {
            HStack(spacing: 14) {
                IconBox(icon: level.icon,
                        color: isSelected ? accent : .appTextDark,
                        size: 46, cornerRadius: 10, iconFontSize: 22,
                        background: isSelected ? .cardBg : .neutralWash)
                VStack(alignment: .leading, spacing: 3) {
                    Text(level.title)
                        .font(.appSans(size: 15.5, weight: .bold))
                        .foregroundStyle(isSelected ? accent : Color.appTextDark)
                    Text(level.subtitle)
                        .font(.appSans(size: 12, weight: .semibold))
                        .foregroundStyle(isSelected ? accent.opacity(0.85) : Color.appTextMedium)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? accent.opacity(0.14) : Color.cardBg,
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(isSelected ? accent.opacity(0.55) : Color.cardBorder,
                                  lineWidth: isSelected ? 1.5 : 1)
            )
            .shadow(color: Color(hex: 0x8A7B58, opacity: 0.14), radius: 10, x: 0, y: 5)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityValue(isSelected ? "Đã chọn" : "")
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Step 3 · Study plan setup

struct OnboardingStudyPlanStep: View {
    @Environment(ThemeStore.self) private var themeStore
    @Binding var license: String
    @Binding var examDate: Date
    @Binding var dailyGoal: Int
    @Binding var notificationsEnabled: Bool
    let onSkip: () -> Void
    let onContinue: () -> Void

    @State private var showDatePicker = false
    @State private var daysUntilExam: Int = 0

    private static let longDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "d 'tháng' M, yyyy"
        return f
    }()

    private static func computeDaysUntilExam(from examDate: Date) -> Int {
        let cal = Calendar.current
        let from = cal.startOfDay(for: Date())
        let to = cal.startOfDay(for: examDate)
        return max(0, cal.dateComponents([.day], from: from, to: to).day ?? 0)
    }

    var body: some View {
        OnboardingStepScaffold(step: 3, ctaTitle: "Bắt đầu ôn thi", onSkip: onSkip, onContinue: onContinue) {
            VStack(alignment: .leading, spacing: 16) {
                OnboardingHeader(
                    title: "Thiết lập lộ trình ôn thi",
                    subtitle: "Cá nhân hoá lịch ôn để bạn sẵn sàng đúng ngày thi."
                )
                examDateCard
                licenceCard
                goalCard
                notificationCard
            }
        }
        .sheet(isPresented: $showDatePicker) { examDateSheet }
        .onAppear { daysUntilExam = Self.computeDaysUntilExam(from: examDate) }
        .onChange(of: examDate) { daysUntilExam = Self.computeDaysUntilExam(from: examDate) }
    }

    private var examDateCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            OnboardingEyebrow("NGÀY THI DỰ KIẾN")
            Button {
                Haptics.impact(.light); showDatePicker = true
            } label: {
                HStack(spacing: 12) {
                    IconBox(icon: "calendar", color: themeStore.primaryColor, size: 40, cornerRadius: 10, iconFontSize: 18, background: themeStore.primaryColor.opacity(0.14))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Self.longDateFormatter.string(from: examDate))
                            .font(.appSans(size: 15, weight: .heavy))
                            .foregroundStyle(Color.appTextDark)
                        Text("Còn \(daysUntilExam) ngày nữa")
                            .font(.appSans(size: 12, weight: .semibold))
                            .foregroundStyle(daysUntilExam < 3 ? Color.appError : Color.appTextMedium)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.appSans(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                }
                .padding(.horizontal, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .onboardingCard()
    }

    private var licenceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            OnboardingEyebrow("HẠNG GIẤY PHÉP")
            HStack(spacing: 8) {
                LicenceOptionTile(code: "B1", subtitle: "Xe số tự động", isSelected: license == "b1") {
                    Haptics.impact(.light); license = "b1"
                }
                LicenceOptionTile(code: "B2", subtitle: "Xe số sàn & dịch vụ", isSelected: license == "b2") {
                    Haptics.impact(.light); license = "b2"
                }
            }
        }
        .padding(8)
        .onboardingCard()
    }

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                OnboardingEyebrow("MỤC TIÊU MỖI NGÀY")
                Spacer()
                Text("\(dailyGoal) câu / ngày")
                    .font(.appSans(size: 12, weight: .heavy))
                    .foregroundStyle(themeStore.primaryColor)
            }
            HStack(spacing: 8) {
                DailyGoalTile(count: 15, label: "Nhẹ nhàng", isSelected: dailyGoal == 15) {
                    Haptics.impact(.light); dailyGoal = 15
                }
                DailyGoalTile(count: 30, label: "Vừa phải", isSelected: dailyGoal == 30) {
                    Haptics.impact(.light); dailyGoal = 30
                }
                DailyGoalTile(count: 50, label: "Quyết tâm", isSelected: dailyGoal == 50) {
                    Haptics.impact(.light); dailyGoal = 50
                }
            }
        }
        .padding(12)
        .onboardingCard()
    }

    private var notificationCard: some View {
        HStack(spacing: 12) {
            IconBox(icon: "bell.fill", color: themeStore.primaryColor, size: 42, cornerRadius: 10, iconFontSize: 20, background: themeStore.primaryColor.opacity(0.14))
            VStack(alignment: .leading, spacing: 2) {
                Text("Nhắc nhở ôn tập")
                    .font(.appSans(size: 14.5, weight: .bold))
                    .foregroundStyle(Color.appTextDark)
                Text("Gửi thông báo nhắc bạn ôn mỗi ngày")
                    .font(.appSans(size: 11.5, weight: .semibold))
                    .foregroundStyle(Color.appTextMedium)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Toggle("", isOn: $notificationsEnabled)
                .labelsHidden()
                .tint(themeStore.primaryColor)
                .accessibilityLabel("Nhắc nhở ôn tập")
                .accessibilityValue(notificationsEnabled ? "Bật" : "Tắt")
        }
        .padding(12)
        .onboardingCard()
    }

    private var examDateSheet: some View {
        NavigationStack {
            DatePicker("Ngày thi", selection: $examDate, in: Date()..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "vi_VN"))
                .padding()
                .navigationTitle("Ngày thi dự kiến")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Xong") { showDatePicker = false }
                    }
                }
        }
        .presentationDetents([.medium, .large])
    }
}

struct LicenceOptionTile: View {
    @Environment(ThemeStore.self) private var themeStore
    let code: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let accent = themeStore.primaryColor
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(code)
                    .font(.appSans(size: 20, weight: .bold))
                    .foregroundStyle(isSelected ? accent : Color.appTextDark)
                Text(subtitle)
                    .font(.appSans(size: 11.5, weight: .semibold))
                    .foregroundStyle(isSelected ? accent.opacity(0.9) : Color.appTextMedium)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? accent.opacity(0.14) : Color.neutralWash,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(isSelected ? accent.opacity(0.55) : .clear, lineWidth: 1.5)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityValue(isSelected ? "Đã chọn" : "")
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct DailyGoalTile: View {
    @Environment(ThemeStore.self) private var themeStore
    let count: Int
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let accent = themeStore.primaryColor
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.appSans(size: 24, weight: .bold))
                    .foregroundStyle(isSelected ? accent : Color.appTextDark)
                Text("câu / ngày")
                    .font(.appSans(size: 10, weight: .semibold))
                    .foregroundStyle(isSelected ? accent.opacity(0.85) : Color.appTextMedium)
                Text(label)
                    .font(.appSans(size: 10, weight: .bold))
                    .tracking(0.3)
                    .foregroundStyle(isSelected ? accent : Color.appTextMedium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(isSelected ? accent.opacity(0.14) : Color.neutralWash,
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(isSelected ? accent.opacity(0.55) : Color.cardBorder,
                                  lineWidth: isSelected ? 1.5 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityValue(isSelected ? "Đã chọn" : "")
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Step 4 · Ready

struct OnboardingReadyStep: View {
    @Environment(ThemeStore.self) private var themeStore
    let license: String
    let examDate: Date
    let dailyGoal: Int
    let onFinish: () -> Void

    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()

    var body: some View {
        OnboardingStepScaffold(step: 4, showSkip: false, ctaTitle: "Vào ứng dụng", onContinue: onFinish) {
            VStack(spacing: 16) {
                OnboardingBadge(icon: "party.popper.fill", tint: themeStore.primaryColor, bg: themeStore.primaryColor.opacity(0.14), iconSize: 46)
                    .padding(.top, 16)

                VStack(spacing: 8) {
                    Text("Tất cả đã sẵn sàng!")
                        .font(.appSans(size: 26, weight: .heavy))
                        .tracking(-0.5)
                        .foregroundStyle(Color.appTextDark)
                        .multilineTextAlignment(.center)
                    Text("Lộ trình ôn thi của bạn đã được thiết lập. Cùng bắt đầu nào!")
                        .font(.appSans(size: 14, weight: .medium))
                        .foregroundStyle(Color.appTextMedium)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }

                summaryCard.padding(.top, 8)
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            OnboardingEyebrow("LỘ TRÌNH CỦA BẠN")
            VStack(spacing: 0) {
                OnboardingSummaryRow(icon: "rosette", amber: true,
                                     label: "Hạng giấy phép",
                                     value: (LicenseType(rawValue: license) ?? .b2).displayName)
                onboardingDivider
                OnboardingSummaryRow(icon: "calendar", amber: true,
                                     label: "Ngày thi dự kiến",
                                     value: Self.shortDateFormatter.string(from: examDate))
                onboardingDivider
                OnboardingSummaryRow(icon: "target", amber: true,
                                     label: "Mục tiêu mỗi ngày",
                                     value: "\(dailyGoal) câu")
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .onboardingCard()
    }

    private var onboardingDivider: some View {
        Rectangle().fill(Color.cardBorder).frame(height: 1)
    }
}

struct OnboardingSummaryRow: View {
    @Environment(ThemeStore.self) private var themeStore
    let icon: String
    var amber: Bool = false
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            IconBox(icon: icon, color: amber ? themeStore.primaryColor : .appTextDark,
                    size: 38, cornerRadius: 10, iconFontSize: 18,
                    background: amber ? themeStore.primaryColor.opacity(0.14) : .neutralWash)
            Text(label)
                .font(.appSans(size: 13, weight: .semibold))
                .foregroundStyle(Color.appTextMedium)
            Spacer(minLength: 8)
            Text(value)
                .font(.appSans(size: 14, weight: .heavy))
                .foregroundStyle(Color.appTextDark)
        }
        .padding(.vertical, 14)
    }
}

// MARK: - Small shared bits

/// Left-aligned screen header (title + subtitle) used on steps 2 and 3.
struct OnboardingHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.appSans(size: 26, weight: .heavy))
                .tracking(-0.5)
                .foregroundStyle(Color.appTextDark)
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(.appSans(size: 14, weight: .medium))
                .foregroundStyle(Color.appTextMedium)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Uppercase eyebrow label used above card sections.
struct OnboardingEyebrow: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.appSans(size: 10, weight: .heavy))
            .tracking(1.2)
            .foregroundStyle(Color.appTextMedium)
            .padding(.leading, 4)
            .padding(.top, 2)
    }
}
