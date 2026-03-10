import SwiftUI

struct OnboardingView: View {
    @Environment(ThemeStore.self) private var themeStore
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage(AppConstants.StorageKey.licenseType) private var licenseType = "b2"
    @State private var currentPage = 0

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
            subtitle: ""
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

    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                if currentPage < pages.count - 1 {
                    Button("Bỏ qua") {
                        completeOnboarding()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextMedium)
                    .padding(.trailing, 24)
                    .padding(.top, 12)
                }
            }
            .frame(height: 48)

            // Pages
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
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(duration: 0.3), value: currentPage)

            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? themeStore.primaryColor : Color.appTextLight.opacity(0.4))
                        .frame(
                            width: index == currentPage ? 28 : 8,
                            height: 8
                        )
                        .animation(.spring(duration: 0.3), value: currentPage)
                }
            }
            .padding(.bottom, 32)

            // CTA button
            Button {
                if currentPage < pages.count - 1 {
                    withAnimation(.spring(duration: 0.3)) {
                        currentPage += 1
                    }
                } else {
                    completeOnboarding()
                }
            } label: {
                AppButton(
                    icon: currentPage == pages.count - 1 ? "arrow.right" : nil,
                    label: currentPage == pages.count - 1 ? "Bắt đầu ngay" : "Tiếp tục"
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .glassBackground()
    }

    private func completeOnboarding() {
        Haptics.impact(.medium)
        hasCompletedOnboarding = true
    }
}

// MARK: - License Picker Page

private struct LicensePickerPage: View {
    @Environment(ThemeStore.self) private var themeStore
    @Binding var selectedLicense: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.text.rectangle")
                .font(.system(size: 56))
                .foregroundStyle(themeStore.primaryColor)
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
                                .foregroundStyle(isSelected ? themeStore.primaryColor : Color.appTextLight)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .glassCard()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? themeStore.primaryColor : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            if let current = LicenseType(rawValue: selectedLicense) {
                Text("\(current.questionsPerExam) câu · \(current.totalTimeSeconds / 60) phút · Đạt \(current.passThreshold)")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextMedium)
            }

            Spacer()
            Spacer()
        }
    }
}
