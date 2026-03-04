import SwiftUI

struct DiemLietTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"

    @State private var selectedTopicKey: String? = nil
    @State private var showNavPlay = false

    var body: some View {
        let allDiemLiet = questionStore.diemLietQuestions
        let byTopic = questionStore.diemLietByTopic
        let diemLietIndexLookup = Dictionary(uniqueKeysWithValues: allDiemLiet.enumerated().map { ($1.no, $0) })

        // Load topic progress once per topic to avoid N+1 JSON decodes
        let topicProgressCache: [String: [Int: Bool]] = {
            var cache: [String: [Int: Bool]] = [:]
            for q in allDiemLiet {
                let key = TopicInfo.keyForTopicId(q.topic)
                if cache[key] == nil {
                    cache[key] = progressStore.topicProgress(for: key)
                }
            }
            return cache
        }()

        let correctCount = allDiemLiet.filter { q in
            let topicKey = TopicInfo.keyForTopicId(q.topic)
            return topicProgressCache[topicKey]?[q.no] == true
        }.count

        let displayQuestions: [Question] = {
            if let key = selectedTopicKey {
                return allDiemLiet.filter { TopicInfo.keyForTopicId($0.topic) == key }
            }
            return allDiemLiet
        }()

        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Practice all button
                NavigationLink(destination: QuestionView(topicKey: "diem_liet", startIndex: 0)) {
                    AppButton(label: "Ôn tập \(allDiemLiet.count) câu điểm liệt")
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                .onGeometryChange(for: Bool.self) { proxy in
                    proxy.frame(in: .scrollView(axis: .vertical)).maxY < 60
                } action: { hidden in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showNavPlay = hidden
                    }
                }

                // MARK: - Flat question list (Contacts style)
                    ForEach(Array(displayQuestions.enumerated()), id: \.element.no) { index, question in
                        if index > 0 {
                            Divider().padding(.leading, 60)
                        }

                        let globalIdx = diemLietIndexLookup[question.no] ?? 0
                        let topicKey = TopicInfo.keyForTopicId(question.topic)
                        let answerStatus: AnswerStatus = {
                            guard let result = topicProgressCache[topicKey]?[question.no] else { return .unanswered }
                            return result ? .correct : .wrong
                        }()

                        NavigationLink(destination: QuestionView(topicKey: "diem_liet", startIndex: globalIdx)) {
                            HStack(spacing: 12) {
                                Text("\(question.no)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.appTextMedium)
                                    .frame(width: 28, alignment: .center)

                                Text(question.text)
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.appTextDark)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(2)

                                Spacer(minLength: 8)

                                switch answerStatus {
                                case .correct:
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color.appSuccess)
                                case .wrong:
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color.appError)
                                case .unanswered:
                                    EmptyView()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer().frame(height: 20)
            }
        }
        .screenHeader("Điểm liệt")
        .toolbar {
            if showNavPlay {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: QuestionView(topicKey: "diem_liet", startIndex: 0)) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primaryColor(for: primaryColorKey))
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        selectedTopicKey = nil
                    } label: {
                        if selectedTopicKey == nil {
                            Label("Tất cả", systemImage: "checkmark")
                        } else {
                            Text("Tất cả")
                        }
                    }

                    ForEach(byTopic, id: \.topic.id) { entry in
                        Button {
                            selectedTopicKey = entry.topic.key
                        } label: {
                            if selectedTopicKey == entry.topic.key {
                                Label("\(entry.topic.shortName) (\(entry.questions.count))", systemImage: "checkmark")
                            } else {
                                Text("\(entry.topic.shortName) (\(entry.questions.count))")
                            }
                        }
                    }
                } label: {
                    Image(systemName: selectedTopicKey != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        .foregroundStyle(Color.appTextDark)
                }
            }
        }
    }
}
