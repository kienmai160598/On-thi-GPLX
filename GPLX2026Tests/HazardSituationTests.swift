import XCTest
@testable import GPLX2026

final class HazardSituationTests: XCTestCase {

    private func situation(id: Int, start: Double = 10, end: Double = 15) -> HazardSituation {
        HazardSituation(id: id, title: "T", chapter: 1, perfectStart: start, perfectEnd: end, tip: "")
    }

    // MARK: - Video URL (regression for the gmec.vn → GitHub host fix)

    func testVideoFileNameIsUnpadded() {
        XCTAssertEqual(situation(id: 1).videoFileName, "th1")
        XCTAssertEqual(situation(id: 10).videoFileName, "th10")
        XCTAssertEqual(situation(id: 120).videoFileName, "th120")
    }

    func testVideoURLPointsAtLiveHostWithUnpaddedName() {
        XCTAssertEqual(
            situation(id: 1).videoURL.absoluteString,
            "https://raw.githubusercontent.com/quanvn1206/atgt1/main/video/th1.mp4"
        )
        XCTAssertEqual(
            situation(id: 120).videoURL.absoluteString,
            "https://raw.githubusercontent.com/quanvn1206/atgt1/main/video/th120.mp4"
        )
        // The dead host must not reappear.
        XCTAssertFalse(situation(id: 5).videoURL.absoluteString.contains("gmec.vn"))
    }

    // MARK: - Tap scoring (timing window)

    func testPerfectStartScoresFive() {
        XCTAssertEqual(situation(id: 1, start: 10, end: 15).score(tapTime: 10), 5)
    }

    func testPerfectEndScoresZero() {
        XCTAssertEqual(situation(id: 1, start: 10, end: 15).score(tapTime: 15), 0)
    }

    func testLinearInterpolationWithinWindow() {
        let s = situation(id: 1, start: 10, end: 15) // range 5
        XCTAssertEqual(s.score(tapTime: 11), 4)   // fraction 0.2 -> 4
        XCTAssertEqual(s.score(tapTime: 13), 2)   // fraction 0.6 -> 2
    }

    func testTapBeforeOrAfterWindowScoresZero() {
        let s = situation(id: 1, start: 10, end: 15)
        XCTAssertEqual(s.score(tapTime: 9), 0)
        XCTAssertEqual(s.score(tapTime: 16), 0)
    }

    func testNoTapScoresZero() {
        XCTAssertEqual(situation(id: 1).score(tapTime: nil), 0)
    }
}
