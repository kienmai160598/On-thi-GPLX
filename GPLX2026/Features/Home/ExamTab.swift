import SwiftUI

struct ExamTab: View {
    @Environment(QuestionStore.self) private var questionStore
    @Environment(ProgressStore.self) private var progressStore
    @Environment(\.openExam) private var openExam
    @AppStorage("appPrimaryColor") private var primaryColorKey = "default"
    @State private var selectedSegment = 0
    @State private var showNavPlay = false
    @State private var showAllExamSets = false

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedSegment) {
                Text("Câu hỏi").tag(0)
                Text("Sa hình").tag(1)
                Text("Tình huống").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            Group {
                switch selectedSegment {
                case 1: simulationExamContent
                case 2: hazardExamContent
                default: questionExamContent
                }
            }
        }
        .onChange(of: selectedSegment) { _, _ in showNavPlay = false }
        .glassContainer()
        .screenHeader("Thi thử")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if showNavPlay {
                    Button { startExamForCurrentSegment() } label: {
                        Image(systemName: "play.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primaryColor(for: primaryColorKey))
                    }
                }
            }
        }
    }

    private func startExamForCurrentSegment() {
        switch selectedSegment {
        case 1: openExam(.simulationExam(mode: .random))
        case 2: openExam(.hazardTest(mode: .exam))
        default: openExam(.mockExam())
        }
    }

    // MARK: - Câu hỏi (Mock Exam)

    @ViewBuilder
    private var questionExamContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ExamCTACard(
                    buttonLabel: "Bắt đầu thi thử",
                    rules: [
                        (icon: "questionmark.circle", text: "30 câu"),
                        (icon: "timer", text: "22 phút"),
                        (icon: "checkmark.circle", text: "≥ 28 đạt"),
                    ],
                    tip: "Sai câu điểm liệt = Trượt. Làm câu điểm liệt trước, không bỏ trống câu nào.",
                    action: { openExam(.mockExam()) },
                    onButtonHidden: { hidden in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showNavPlay = hidden
                        }
                    }
                )

                if !progressStore.examHistory.isEmpty {
                    ExamStatsRow(items: [
                        (value: "\(progressStore.examCount)", label: "Đã thi"),
                        (value: "\(Int(progressStore.averageExamScore * 100))%", label: "TB đúng"),
                        (value: "\(Int(progressStore.bestExamScore * 100))%", label: "Cao nhất"),
                    ])
                }

                fixedExamSets
                    .padding(.top, 4)

                if !progressStore.examHistory.isEmpty {
                    SectionTitle(title: "Lịch sử")
                        .padding(.top, 6)

                    HistoryList(
                        results: progressStore.examHistory,
                        scoreText: { "\($0.score)/\($0.totalQuestions) đúng" },
                        passed: \.passed,
                        date: \.date,
                        destination: { ExamHistoryDetailView(result: $0) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Fixed Exam Sets

    @ViewBuilder
    private var fixedExamSets: some View {
        let completedSets = progressStore.completedExamSets
        let completedCount = completedSets.count
        let visibleSets = showAllExamSets ? 20 : 6

        VStack(spacing: 0) {
            // Header (tappable to expand/collapse)
            Button {
                withAnimation(.easeOut(duration: 0.25)) {
                    showAllExamSets.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Text("ĐỀ THI CỐ ĐỊNH")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.appTextMedium)
                        .tracking(0.5)

                    if completedCount > 0 {
                        Text("\(completedCount)/20")
                            .font(.system(size: 12, weight: .semibold).monospacedDigit())
                            .foregroundStyle(Color.appSuccess)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.appSuccess.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    Spacer()

                    Image(systemName: showAllExamSets ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.appTextLight)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider().padding(.horizontal, 16)

            // Grid of exam sets
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 0),
                GridItem(.flexible(), spacing: 0),
            ], spacing: 0) {
                ForEach(1...visibleSets, id: \.self) { setId in
                    let isCompleted = completedSets.contains(setId)
                    let latestResult = isCompleted ? progressStore.latestResult(forExamSet: setId) : nil

                    Button { openExam(.mockExam(examSetId: setId)) } label: {
                        HStack(spacing: 8) {
                            Text("Đề \(setId)")
                                .font(.system(size: 15, weight: .semibold).monospacedDigit())
                                .foregroundStyle(Color.appTextDark)

                            Spacer()

                            if isCompleted {
                                if let result = latestResult {
                                    Text("\(result.score)/\(result.totalQuestions)")
                                        .font(.system(size: 12, weight: .medium).monospacedDigit())
                                        .foregroundStyle(result.passed ? Color.appSuccess : Color.appError)
                                }
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.appSuccess)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(Color.appTextLight)
                            }
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .overlay {
                // Grid dividers
                VStack(spacing: 0) {
                    ForEach(0..<(visibleSets / 2), id: \.self) { row in
                        if row > 0 {
                            Divider().padding(.horizontal, 16)
                        }
                        Spacer().frame(height: 48)
                    }
                }
            }

            if !showAllExamSets {
                Divider().padding(.horizontal, 16)
                Button {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showAllExamSets = true
                    }
                } label: {
                    Text("Xem tất cả 20 đề")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .glassCard()
    }

    // MARK: - Sa hình (Simulation Exam)

    @ViewBuilder
    private var simulationExamContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ExamCTACard(
                    buttonLabel: "Thi mô phỏng (20 câu)",
                    rules: [
                        (icon: "photo.on.rectangle", text: "20 câu"),
                        (icon: "timer", text: "60s/câu"),
                        (icon: "checkmark.circle", text: "≥ 70%"),
                    ],
                    tip: "Quan sát kỹ hình ảnh, chú ý biển báo và vạch kẻ đường.",
                    action: { openExam(.simulationExam(mode: .random)) },
                    onButtonHidden: { hidden in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showNavPlay = hidden
                        }
                    }
                )

                if !progressStore.simulationHistory.isEmpty {
                    ExamStatsRow(items: [
                        (value: "\(progressStore.simulationExamCount)", label: "Đã thi"),
                        (value: "\(Int(progressStore.averageSimulationScore * 100))%", label: "TB đúng"),
                        (value: "\(Int(progressStore.bestSimulationScore * 100))%", label: "Cao nhất"),
                    ])
                }

                if !progressStore.simulationHistory.isEmpty {
                    SectionTitle(title: "Lịch sử")
                        .padding(.top, 10)

                    HistoryList(
                        results: progressStore.simulationHistory,
                        scoreText: { "\($0.score)/\($0.totalScenarios) đúng" },
                        passed: \.passed,
                        date: \.date,
                        destination: { SimulationHistoryDetailView(result: $0) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Tình huống (Hazard Exam)

    @ViewBuilder
    private var hazardExamContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ExamCTACard(
                    buttonLabel: "Thi tình huống (10 video)",
                    rules: [
                        (icon: "play.rectangle", text: "10 video"),
                        (icon: "hand.tap", text: "Nhấn nhanh"),
                        (icon: "star", text: "≥ 35/50"),
                    ],
                    tip: "Nhấn sớm khi vừa thấy nguy hiểm để đạt điểm cao nhất.",
                    action: { openExam(.hazardTest(mode: .exam)) },
                    onButtonHidden: { hidden in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showNavPlay = hidden
                        }
                    }
                )

                if !progressStore.hazardHistory.isEmpty {
                    ExamStatsRow(items: [
                        (value: "\(progressStore.hazardExamCount)", label: "Đã thi"),
                        (value: "\(Int(progressStore.averageHazardScore * 100))%", label: "TB điểm"),
                        (value: "\(progressStore.bestHazardScore)", label: "Cao nhất"),
                    ])
                }

                if !progressStore.hazardHistory.isEmpty {
                    SectionTitle(title: "Lịch sử")
                        .padding(.top, 10)

                    HistoryList(
                        results: progressStore.hazardHistory,
                        scoreText: { "\($0.totalScore)/\($0.maxScore) điểm" },
                        passed: \.passed,
                        date: \.date,
                        destination: { HazardHistoryDetailView(result: $0) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 32)
        }
    }
}
