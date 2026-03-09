import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0

    private let pages = [
        OnboardingPage(
            id: 0,
            icon: "car.fill",
            title: "Chào mừng đến với\nGPLX B 2026",
            subtitle: "Ôn thi giấy phép lái xe bằng B\nTheo đề thi mới nhất 2026 của Bộ GTVT"
        ),
        OnboardingPage(
            id: 1,
            icon: "list.clipboard.fill",
            title: "Kỳ thi gồm 3 phần",
            subtitle: "Bạn phải đạt cả 3 phần mới được cấp bằng"
        ),
        OnboardingPage(
            id: 2,
            icon: "book.fill",
            title: "Mọi thứ bạn cần",
            subtitle: "Từ lý thuyết đến thực hành, từ ôn luyện\nđến kiểm tra — tất cả trong một ứng dụng"
        ),
        OnboardingPage(
            id: 3,
            icon: "paintpalette.fill",
            title: "Tuỳ chỉnh giao diện",
            subtitle: "Chọn màu sắc, cỡ chữ và chế độ sáng/tối\ntrong phần Cài đặt theo sở thích của bạn"
        ),
        OnboardingPage(
            id: 4,
            icon: "flag.checkered",
            title: "Sẵn sàng rồi!",
            subtitle: "Bắt đầu hành trình chinh phục\nbằng lái xe B2 của bạn"
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
                    OnboardingPageView(page: page)
                        .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(duration: 0.3), value: currentPage)

            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? Color.appPrimary : Color.appTextLight.opacity(0.4))
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
