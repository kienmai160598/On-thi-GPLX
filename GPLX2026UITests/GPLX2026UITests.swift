import XCTest

/// Drives the app to each marketing screen and attaches a native-resolution
/// screenshot per screen. Run on a specific simulator to get App Store sizes:
///   - iPhone 11 Pro Max  -> 1242 x 2688  (iPhone 6.5")
///   - iPhone 16 Pro Max  -> 1320 x 2868  (iPhone 6.9")
///   - iPad Pro 13"       -> 2064 x 2752  (iPad 13")
///
/// Attachments are named `NN-screen.png`; extract them from the result bundle
/// with `xcrun xcresulttool export attachments`.
final class GPLX2026UITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = true
    }

    func testCaptureScreenshots() {
        // 1) Onboarding — force the welcome screen via the argument domain.
        let onboarding = XCUIApplication()
        onboarding.launchArguments = ["-hasCompletedOnboarding", "NO"]
        onboarding.launch()
        // Welcome step shows the app name + a "Bắt đầu" CTA, behind the splash.
        _ = onboarding.staticTexts["Ôn Thi Lái Xe 2026"].waitForExistence(timeout: 40)
        waitForSplashToClear()
        capture("01-onboarding")
        onboarding.terminate()

        // 2) Main app — skip onboarding and the hazard-deprecation modal.
        let app = XCUIApplication()
        app.launchArguments = [
            "-hasCompletedOnboarding", "YES",
            "-hazardDeprecationSeen", "YES",
        ]
        app.launch()

        // Home tab is the default landing screen. Anchor on a detail-only
        // subtitle (NOT the tab name, which also lives in the iPad sidebar and
        // would pass before the detail pane actually switches).
        _ = app.staticTexts["Sẵn sàng ôn tập hôm nay chưa?"].waitForExistence(timeout: 40)
        waitForSplashToClear()
        capture("02-home")

        // 3) Mô phỏng (simulation)
        show(app, tab: "Mô phỏng", detailAnchor: "TIẾN ĐỘ CỦA BẠN", file: "03-mophong")

        // 4) Thi thử (mock exam)
        show(app, tab: "Thi thử", detailAnchor: "Kiểm tra kiến thức tổng hợp", file: "04-thithu")

        // 5) Luyện tập (practice)
        show(app, tab: "Luyện tập", detailAnchor: "Chọn phần để bắt đầu ôn", file: "05-luyentap")

        // 6) A real question — open the "Đề tổng hợp" practice session.
        let cta = app.buttons
            .matching(NSPredicate(format: "label CONTAINS %@", "Đề tổng hợp"))
            .firstMatch
        if cta.waitForExistence(timeout: 10) {
            if !cta.isHittable { app.swipeUp() }
            cta.tap()
            _ = app.buttons["Xác nhận"].waitForExistence(timeout: 15)
            settle()
            capture("06-question")
        } else {
            XCTFail("Could not find the 'Đề tổng hợp' practice button")
        }
    }

    // MARK: - Navigation helpers

    /// Selects a tab on both iPhone (tab bar) and iPad (split-view sidebar).
    private func selectTab(_ app: XCUIApplication, _ name: String) {
        let tab = app.tabBars.buttons[name]
        if tab.waitForExistence(timeout: 3) {
            tab.tap()
            return
        }
        // iPad sidebar (NavigationSplitView list rows)
        let cellText = app.cells.staticTexts[name]
        if cellText.waitForExistence(timeout: 3) {
            cellText.tap()
            return
        }
        if app.buttons[name].waitForExistence(timeout: 3) {
            app.buttons[name].tap()
            return
        }
        if app.staticTexts[name].waitForExistence(timeout: 3) {
            app.staticTexts[name].tap()
        }
    }

    /// Selects `tab`, waits for a detail-pane-only anchor (so the iPad split
    /// view has actually switched), then captures. Retries the tap once if the
    /// first selection didn't register in time.
    private func show(_ app: XCUIApplication, tab: String, detailAnchor: String, file: String) {
        selectTab(app, tab)
        let anchor = app.staticTexts[detailAnchor]
        if !anchor.waitForExistence(timeout: 15) {
            selectTab(app, tab)
            XCTAssertTrue(anchor.waitForExistence(timeout: 15),
                          "Detail pane for '\(tab)' never showed '\(detailAnchor)'")
        }
        settle()
        capture(file)
    }

    // MARK: - Capture

    /// The splash overlay fades out (~0.3s) once question data finishes loading.
    /// Give it room so screenshots never catch the splash mid-fade.
    private func waitForSplashToClear() {
        Thread.sleep(forTimeInterval: 3.0)
    }

    /// Small settle for tab transitions / layout before capture.
    private func settle() {
        Thread.sleep(forTimeInterval: 1.2)
    }

    private func capture(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(
            uniformTypeIdentifier: "public.png",
            name: "\(name).png",
            payload: shot.pngRepresentation,
            userInfo: nil
        )
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
