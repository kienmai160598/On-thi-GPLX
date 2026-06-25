import SwiftUI

/// One-time announcement (design YPqmZ) that the simulation/hazard test is being
/// removed from the official licence exam. Shown over the Mô phỏng tab until the
/// user dismisses it. Both actions dismiss; the caller persists that.
struct HazardDeprecationModal: View {
    @Environment(ThemeStore.self) private var themeStore
    let onAcknowledge: () -> Void
    let onContinue: () -> Void

    /// Drives the native-style open transition: the scrim fades while the dialog
    /// scales up + fades in, mirroring UIKit's `UIAlertController` presentation.
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color(hex: 0x0F0F12, opacity: 0.70)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { }   // swallow taps on the scrim
                .opacity(appeared ? 1 : 0)

            dialog
                .padding(.horizontal, 24)
                .scaleEffect(appeared ? 1 : 0.9)
                .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                appeared = true
            }
        }
    }

    private var dialog: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.appSans(size: 26, weight: .bold))
                .foregroundStyle(Color(hex: 0xB45309))
                .frame(width: 60, height: 60)
                .background(Color(hex: 0xFFF1D6), in: Circle())

            Text("THÔNG BÁO QUAN TRỌNG")
                .font(.appSans(size: 11, weight: .heavy))
                .tracking(1)
                .foregroundStyle(Color(hex: 0xB45309))

            Text("Phần thi mô phỏng sắp ngừng")
                .font(.appSans(size: 18, weight: .heavy))
                .tracking(-0.3)
                .foregroundStyle(Color.appTextDark)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("Từ ngày 1/7, phần thi mô phỏng (tình huống giao thông) sẽ được loại bỏ khỏi quy trình sát hạch giấy phép lái xe. Bạn vẫn có thể luyện tập để tham khảo.")
                .font(.appSans(size: 13.5, weight: .medium))
                .foregroundStyle(Color.appTextMedium)
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 6) {
                Button(action: onAcknowledge) {
                    Text("Đã hiểu")
                        .font(.appSans(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(themeStore.primaryColor, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
                }
                .buttonStyle(.plain)

                Button(action: onContinue) {
                    Text("Vẫn vào luyện tập")
                        .font(.appSans(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x7A7166))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(hex: 0x0F0F12, opacity: 0.25), radius: 30, y: 16)
    }
}
