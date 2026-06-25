import XCTest
@testable import GPLX2026

@MainActor
final class ProgressStoreTests: XCTestCase {

    private var suiteName: String!
    private var defaults: UserDefaults!
    private var store: ProgressStore!

    override func setUp() async throws {
        suiteName = "ProgressStoreTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        store = ProgressStore(defaults: defaults)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suiteName)
        store = nil
        defaults = nil
        suiteName = nil
    }

    // MARK: - Spaced repetition (prioritized review)

    func testPrioritizedWrongAnswersReflectsWrongAnswerSet() {
        store.recordQuestionAnswer(topicKey: "t", questionNo: 7, correct: false)
        store.recordQuestionAnswer(topicKey: "t", questionNo: 3, correct: false)
        store.recordQuestionAnswer(topicKey: "t", questionNo: 12, correct: false)

        let prioritized = store.prioritizedWrongAnswers()
        XCTAssertEqual(Set(prioritized), store.wrongAnswers)
        XCTAssertEqual(prioritized.count, 3, "No drops or duplicates")

        // Answering one correctly removes it from the prioritized review list.
        store.recordQuestionAnswer(topicKey: "t", questionNo: 7, correct: true)
        XCTAssertFalse(store.prioritizedWrongAnswers().contains(7))
        XCTAssertEqual(store.prioritizedWrongAnswers().count, 2)
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

    // MARK: - License-scoped mastery (correctCount(in:))

    func testCorrectCountInQuestionsCountsOnlyCorrectAnswers() {
        let questions = [
            Question(no: 1, text: "", topic: 1),
            Question(no: 2, text: "", topic: 1),
            Question(no: 3, text: "", topic: 3),
        ]
        // Nothing answered yet.
        XCTAssertEqual(store.correctCount(in: questions), 0)

        for q in questions {
            let key = Topic.keyForTopicId(q.topic)
            store.saveQuestionResult(topicKey: key, questionNo: q.no, correct: q.no != 2)
        }
        // q1 + q3 correct, q2 wrong → 2.
        XCTAssertEqual(store.correctCount(in: questions), 2)
    }

    func testCorrectCountInQuestionsIgnoresUnlistedQuestions() {
        // A correct answer to a question NOT in the passed pool must not count —
        // this is what scopes the Home progress card to the active license set.
        let key = Topic.keyForTopicId(1)
        store.saveQuestionResult(topicKey: key, questionNo: 50, correct: true)

        XCTAssertEqual(store.correctCount(in: [Question(no: 1, text: "", topic: 1)]), 0)
        XCTAssertEqual(store.correctCount(in: [Question(no: 50, text: "", topic: 1)]), 1)
    }

    // MARK: - Exam-date countdown

    func testDaysUntilExamHidesAfterExamDatePasses() throws {
        XCTAssertNil(store.daysUntilExam, "No exam date → no countdown")

        let cal = Calendar.current
        let future = try XCTUnwrap(cal.date(byAdding: .day, value: 5, to: Date()))
        store.setExamDate(future)
        XCTAssertEqual(store.daysUntilExam, 5)

        // Exam day itself still surfaces (drives the "Hôm nay thi!" chip).
        store.setExamDate(Date())
        XCTAssertEqual(store.daysUntilExam, 0)

        // A date in the past returns nil so the countdown UI hides instead of
        // pinning to "Hôm nay thi!" forever.
        let past = try XCTUnwrap(cal.date(byAdding: .day, value: -3, to: Date()))
        store.setExamDate(past)
        XCTAssertNil(store.daysUntilExam)
    }
}
