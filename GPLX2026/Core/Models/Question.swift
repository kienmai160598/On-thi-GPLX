import Foundation

// MARK: - Answer

struct Answer: Codable, Identifiable, Hashable {
    let id: Int
    let text: String
    let correct: Bool
}

// MARK: - Question

struct Question: Codable, Identifiable, Hashable {

    // Use `no` as the stable identity.
    var id: Int { no }

    let no: Int
    let text: String
    let tip: String
    let answers: [Answer]
    let topic: Int
    let image: String
    let required1: Int
    let required2: Int
    let required3: Int
    let b1Position: Int  // 0 = not in B1 pool, 1-300 = position in B1 exam bank

    // MARK: Coding keys

    enum CodingKeys: String, CodingKey {
        case no, text, tip, answers, topic, image
        case required1, required2, required3
        case b1Position = "b1"
    }

    // MARK: Custom decoding (handle optional / missing fields)

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        no        = try c.decode(Int.self, forKey: .no)
        text      = try c.decode(String.self, forKey: .text)
        tip       = try c.decodeIfPresent(String.self, forKey: .tip) ?? ""
        answers   = try c.decode([Answer].self, forKey: .answers)
        topic     = try c.decode(Int.self, forKey: .topic)
        image     = try c.decodeIfPresent(String.self, forKey: .image) ?? ""
        required1 = try c.decodeIfPresent(Int.self, forKey: .required1) ?? 0
        required2 = try c.decodeIfPresent(Int.self, forKey: .required2) ?? 0
        required3 = try c.decodeIfPresent(Int.self, forKey: .required3) ?? 0
        b1Position = try c.decodeIfPresent(Int.self, forKey: .b1Position) ?? 0
    }

    // MARK: Memberwise init (for previews / tests)

    init(
        no: Int,
        text: String,
        tip: String = "",
        answers: [Answer] = [],
        topic: Int = 1,
        image: String = "",
        required1: Int = 0,
        required2: Int = 0,
        required3: Int = 0,
        b1Position: Int = 0
    ) {
        self.no = no
        self.text = text
        self.tip = tip
        self.answers = answers
        self.topic = topic
        self.image = image
        self.required1 = required1
        self.required2 = required2
        self.required3 = required3
        self.b1Position = b1Position
    }

    // MARK: Computed properties

    /// Whether the question has an associated image.
    var hasImage: Bool { !image.isEmpty }

    /// Whether this is a "diem liet" (critical / disqualifying) question.
    var isDiemLiet: Bool { required1 != 0 || required2 != 0 || required3 != 0 }

    /// Whether this question is in the B1 question pool.
    var isB1: Bool { b1Position > 0 }

    /// Shuffled copy of the answers array, deterministic per question number.
    var shuffledAnswers: [Answer] {
        var gen = SeededRandomNumberGenerator(seed: UInt64(no))
        return answers.shuffled(using: &gen)
    }

    // MARK: Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(no)
    }

    static func == (lhs: Question, rhs: Question) -> Bool {
        lhs.no == rhs.no
    }
}

// MARK: - Seeded RNG (deterministic shuffle)

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        // xorshift64 produces all zeros when state is 0; use a constant fallback
        state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func next() -> UInt64 {
        // xorshift64
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
