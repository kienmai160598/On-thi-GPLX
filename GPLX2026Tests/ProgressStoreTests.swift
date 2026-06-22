import XCTest
@testable import GPLX2026

final class ProgressStoreTests: XCTestCase {

    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: ProgressStore!

    override func setUp() {
        super.setUp()
        suiteName = "ProgressStoreTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        store = ProgressStore(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        store = nil
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    // MARK: - Study activity (totalActivity rewrite)

    func testTotalActivityStartsAtZero() {
        XCTAssertEqual(store.totalActivity(lastDays: 30), 0)
        XCTAssertEqual(store.totalActivity(lastDays: 1), 0)
    }

    func testRecordStudyActivityCountsTowardTotal() {
        store.recordStudyActivity()
        store.recordStudyActivity()
        store.recordStudyActivity()

        XCTAssertEqual(store.activityCount(for: Date()), 3)
        XCTAssertEqual(store.totalActivity(lastDays: 1), 3)
        XCTAssertEqual(store.totalActivity(lastDays: 30), 3)
    }

    func testTotalActivityWithNonPositiveDaysIsZero() {
        store.recordStudyActivity()
        XCTAssertEqual(store.totalActivity(lastDays: 0), 0)
    }

    // MARK: - Wrong answers

    func testAddAndRemoveWrongAnswer() {
        XCTAssertTrue(store.wrongAnswers.isEmpty)
        store.addWrongAnswer(101)
        store.addWrongAnswer(102)
        XCTAssertEqual(store.wrongAnswers, [101, 102])
        store.removeWrongAnswer(101)
        XCTAssertEqual(store.wrongAnswers, [102])
    }

    // MARK: - Bookmarks

    func testToggleBookmark() {
        XCTAssertFalse(store.isBookmarked(questionNo: 5))
        store.toggleBookmark(questionNo: 5)
        XCTAssertTrue(store.isBookmarked(questionNo: 5))
        store.toggleBookmark(questionNo: 5)
        XCTAssertFalse(store.isBookmarked(questionNo: 5))
    }

    // MARK: - Topic progress / answer status

    func testAnswerStatusReflectsSavedResults() {
        let key = "1"
        XCTAssertEqual(store.answerStatus(topicKey: key, questionNo: 1), .unanswered)

        store.saveQuestionResult(topicKey: key, questionNo: 1, correct: true)
        store.saveQuestionResult(topicKey: key, questionNo: 2, correct: false)

        XCTAssertEqual(store.answerStatus(topicKey: key, questionNo: 1), .correct)
        XCTAssertEqual(store.answerStatus(topicKey: key, questionNo: 2), .wrong)
        XCTAssertTrue(store.isCorrect(topicKey: key, questionNo: 1))
        XCTAssertFalse(store.isCorrect(topicKey: key, questionNo: 2))
    }
}
