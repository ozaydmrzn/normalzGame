import SwiftUI
import Charts

struct ResultView: View {

    let question: Question
    let userChoice: String
    let result: GameResult

    @Binding var showingShareSheet: Bool

    let onNewGameTap: (() -> Void)

    var body: some View {
        VStack(spacing: 15) {
            Text("Results")
                .font(.custom("AvenirNext-Bold", size: 28))
                .foregroundColor(Constants.textColor)

            Chart {
                ForEach(question.options, id: \.self) { option in
                    let count = question.answerCounts[option] ?? 0
                    let percentage = Double(count) / Double(question.totalAnswers) * 100
                    BarMark(
                        x: .value("Percentage", percentage),
                        y: .value("Option", option)
                    )
                    .foregroundStyle(option == userChoice ? Color.green : Constants.buttonColor)
                    .annotation(position: .trailing) {
                        Text(String(format: "%.1f%%", percentage))
                            .font(.custom("AvenirNext-Bold", size: 14))
                            .foregroundColor(option == userChoice ? .green : Constants.textColor)
                    }
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(position: .bottom) { _ in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.3))
                    AxisTick().foregroundStyle(Color.white)
                    AxisValueLabel()
                        .foregroundStyle(Color.white)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.3))
                    AxisTick().foregroundStyle(Color.white)
                    AxisValueLabel()
                        .foregroundStyle(Color.white)
                }
            }

            Text(resultText)
                .font(.custom("AvenirNext-Bold", size: 24))
                .foregroundColor(resultColor)
                .padding(.top)

            HStack(spacing: 20) {
                Button(action: { showingShareSheet = true }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.custom("AvenirNext-DemiBold", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Button(action: onNewGameTap) {
                    Text("New Normalz")
                        .font(.custom("AvenirNext-DemiBold", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .background(Constants.buttonColor)
                        .cornerRadius(10)
                }
            }
            .padding(.top)
        }
        .padding()
        .background(Color(white: 1.0, opacity: 0.2))
        .cornerRadius(15)
    }

    private var resultColor: Color {
        switch result {
        case .win:
            return .green
        case .lose:
            return .red
        case .draw:
            return .yellow
        case .none:
            return .clear
        }
    }

    private var resultText: String {
        switch result {
        case .win:
            return "You guessed correctly! 🎉"
        case .lose:
            return "Not quite! Try again! 😊"
        case .draw:
            return "It's a tie! 🤝"
        case .none:
            return ""
        }
    }
}

#Preview {
    VStack {
        ResultView(
            question: Question(
                questionId: "",
                options: ["1", "2", "3"],
                answerCounts: [:],
                totalAnswers: 500
            ),
            userChoice: "1",
            result: .draw,
            showingShareSheet: .constant(false)
        ) {

        }
    }
    .background(Color.red)
}
