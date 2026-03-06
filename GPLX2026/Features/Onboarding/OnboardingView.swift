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
            icon: "book.fill",
            title: "Mọi thứ bạn cần",
            subtitle: "Từ lý thuyết đến thực hành, từ ôn luyện\nđến kiểm tra — tất cả trong một ứng dụng"
        ),
        OnboardingPage(
            id: 2,
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
                if currentPage < 2 {
                    Button("Bỏ qua") {
                        completeOnboarding()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.appTextMedium)
                    .padding(.trailing, 20)
                    .padding(.top, 8)
                }
            }
            .frame(height: 44)

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
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? Color.appPrimary : Color.appTextLight)
                        .frame(
                            width: index == currentPage ? 24 : 8,
                            height: 8
                        )
                        .animation(.spring(duration: 0.3), value: currentPage)
                }
            }
            .padding(.bottom, 24)

            // CTA button
            Button {
                if currentPage < 2 {
                    withAnimation(.spring(duration: 0.3)) {
                        currentPage += 1
                    }
                } else {
                    completeOnboarding()
                }
            } label: {
                AppButton(
                    icon: currentPage == 2 ? "arrow.right" : nil,
                    label: currentPage == 2 ? "Bắt đầu ngay" : "Tiếp tục"
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .glassBackground()
    }

    private func completeOnboarding() {
        Haptics.impact(.medium)
        hasCompletedOnboarding = true
    }
}
