import SwiftUI

/// Per-question answer review navigator (design dX3Sb — "Xem lại đáp án").
///
/// Steps through the exam's questions one at a time with a filter
/// (Tất cả / Câu sai / Điểm liệt). Each question shows the full answer list with
/// the correct option highlighted green and the user's wrong choice in red, the
/// explanation, and a previous/next footer.
struct ReviewQuestionView: View {

    enum Filter: CaseIterable {
        case all, wrong, diemLiet

        var label: String {
            switch self {
            case .all:      "Tất cả"
            case .wrong:    "Câu sai"
            case .diemLiet: "Điểm liệt"
            }
        }
    }

    let questions: [Question]
    /// Selected answer id keyed by the question's position in `questions`
    /// (same shape as `ExamResultView.answers`). Missing key = unanswered.
    let answers: [Int: Int]
    var initialFilter: Filter = .all

    @Environment(ThemeStore.self) private var themeStore

    @State private var filter: Filter = .all
    @State private var filteredIndices: [Int] = []
    @State private var position: Int = 0

    private static let letters = ["A", "B", "C", "D", "E", "F"]

    var body: some View {
        VStack(spacing: 0) {
            segmentedFilter
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)

            if filteredIndices.isEmpty {
                emptyState
            } else {
                questionScroll
            }
        }
        .screenHeader("Xem lại", titleDisplayMode: .inline)
        .toolbar {
            if !filteredIndices.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("Câu \(min(position, filteredIndices.count - 1) + 1)/\(filteredIndices.count)")
                        .font(.appSans(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appTextMedium)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !filteredIndices.isEmpty { footer }
        }
        .onAppear {
            filter = initialFilter
            recomputeFiltered()
        }
    }

    // MARK: - Segmented filter

    private var segmentedFilter: some View {
        HStack(spacing: 6) {
            ForEach(Filter.allCases, id: \.self) { option in
                let isSelected = filter == option
                Button {
                    guard filter != option else { return }
                    Haptics.selection()
                    withAnimation(.easeOut(duration: 0.2)) {
                        filter = option
                        recomputeFiltered()
                    }
                } label: {
                    Text(option.label)
                        .font(.appSans(size: 13, weight: .bold))
                        .foregroundStyle(isSelected ? themeStore.onPrimaryColor : Color.appTextMedium)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background {
                            if isSelected { Capsule().fill(themeStore.primaryColor) }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(Color(hex: 0x0F0F12, opacity: 0.06), in: Capsule())
    }

    // MARK: - Question

    private var questionScroll: some View {
        let safePosition = min(position, filteredIndices.count - 1)
        let questionIndex = filteredIndices[safePosition]
        let question = questions[questionIndex]
        let selectedId = answers[questionIndex]

        return ScrollView {
            questionCard(question: question, selectedId: selectedId)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .id(safePosition)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private func questionCard(question: Question, selectedId: Int?) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Text("Câu \(question.no)")
                    .font(.appSans(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextMedium)
                if question.isDiemLiet {
                    StatusBadge(text: "Điểm liệt", color: .appError, fontSize: 11, hPadding: 6, vPadding: 2)
                }
            }

            Text(question.text)
                .font(.appSans(size: 18, weight: .semibold))
                .foregroundStyle(Color.appTextDark)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !question.image.isEmpty {
                QuestionImage(imageName: question.image)
            }

            VStack(spacing: 8) {
                ForEach(Array(question.answers.enumerated()), id: \.element.id) { index, answer in
                    optionTile(letter: letter(for: index), answer: answer, selectedId: selectedId)
                }
            }

            if !question.tip.isEmpty {
                ExplanationBox(content: question.tip)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 20)
    }

    private func optionTile(letter: String, answer: Answer, selectedId: Int?) -> some View {
        let isCorrect = answer.correct
        let isWrongChoice = !answer.correct && selectedId == answer.id
        let accent: Color = isCorrect ? .appSuccess : (isWrongChoice ? .appError : Color.appDivider)
        let background: Color = isCorrect
            ? Color.appSuccess.opacity(0.12)
            : (isWrongChoice ? Color.appError.opacity(0.10) : Color.clear)

        return HStack(alignment: .top, spacing: 12) {
            Text(letter)
                .font(.appSans(size: 13, weight: .bold))
                .foregroundStyle(isCorrect || isWrongChoice ? Color.white : Color.appTextMedium)
                .frame(width: 26, height: 26)
                .background(Circle().fill(accent))

            Text(answer.text)
                .font(.appSans(size: 14, weight: isCorrect ? .semibold : .regular))
                .foregroundStyle(Color.appTextDark)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .font(.appSans(size: 16))
                    .foregroundStyle(Color.appSuccess)
            } else if isWrongChoice {
                Image(systemName: "xmark.circle.fill")
                    .font(.appSans(size: 16))
                    .foregroundStyle(Color.appError)
            }
        }
        .padding(12)
        .background(background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(accent.opacity(isCorrect || isWrongChoice ? 0.5 : 1), lineWidth: 1)
        )
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: filter == .wrong ? "checkmark.circle" : "doc.text.magnifyingglass")
                .font(.appSans(size: 44))
                .foregroundStyle(filter == .wrong ? Color.appSuccess : Color.appTextLight)
            Text(emptyMessage)
                .font(.appSans(size: 15, weight: .medium))
                .foregroundStyle(Color.appTextMedium)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyMessage: String {
        switch filter {
        case .wrong:    "Bạn không trả lời sai câu nào. Tuyệt vời!"
        case .diemLiet: "Không có câu điểm liệt nào trong bài thi này."
        case .all:      "Không có câu hỏi nào để xem lại."
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 12) {
            Button { goPrevious() } label: {
                AppButton(icon: "chevron.left", label: "Câu trước", style: .secondary, height: 50)
            }
            .disabled(position == 0)

            Button { goNext() } label: {
                AppButton(icon: "chevron.right", label: "Câu tiếp theo", style: .primary, height: 50)
            }
            .disabled(position >= filteredIndices.count - 1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    // MARK: - Logic

    private func recomputeFiltered() {
        filteredIndices = questions.indices.filter { index in
            switch filter {
            case .all:
                return true
            case .wrong:
                let selected = answers[index]
                let isCorrect = selected != nil
                    && questions[index].answers.contains { $0.id == selected && $0.correct }
                return !isCorrect
            case .diemLiet:
                return questions[index].isDiemLiet
            }
        }
        position = 0
    }

    private func goPrevious() {
        guard position > 0 else { return }
        Haptics.selection()
        withAnimation(.easeOut(duration: 0.2)) { position -= 1 }
    }

    private func goNext() {
        guard position < filteredIndices.count - 1 else { return }
        Haptics.selection()
        withAnimation(.easeOut(duration: 0.2)) { position += 1 }
    }

    private func letter(for index: Int) -> String {
        index < Self.letters.count ? Self.letters[index] : "\(index + 1)"
    }
}
