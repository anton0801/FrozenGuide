import SwiftUI

struct QuizView: View {
    @State private var selectedAnswers: [Int?] = Array(repeating: nil, count: questions.count)
    @State private var showScore = false
    @State private var score = 0
    @AppStorage("highScore") private var highScore = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(questions.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(questions[index].text)
                                .font(.headline)
                                .foregroundColor(.iceWhiteGlow)
                            
                            ForEach(questions[index].options.indices, id: \.self) { optionIndex in
                                Button(action: {
                                    selectedAnswers[index] = optionIndex
                                }) {
                                    Text(questions[index].options[optionIndex])
                                        .foregroundColor(.iceWhiteGlow)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(selectedAnswers[index] == optionIndex ? Color.lightCyan.opacity(0.3) : Color.frostedBlue.opacity(0.8))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                        .background(Color.frostedBlue.opacity(0.6))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 5)
                    }
                    
                    Button("Submit Quiz") {
                        calculateScore()
                        showScore = true
                    }
                    .font(.headline)
                    .foregroundColor(.midnightIce)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.lightCyan)
                    .cornerRadius(12)
                    .shadow(color: .iceWhiteGlow.opacity(0.5), radius: 4)
                    .padding(.top, 24)
                }
                .padding()
            }
            .background(Color.midnightIce.ignoresSafeArea())
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showScore) {
                Alert(title: Text("Your Score"), message: Text("\(score) out of \(questions.count)\nHigh Score: \(highScore)"), dismissButton: .default(Text("OK")) {
                    resetQuiz()
                })
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func calculateScore() {
        score = 0
        for (index, answer) in selectedAnswers.enumerated() {
            if answer == questions[index].correctIndex {
                score += 1
            }
        }
        if score > highScore {
            highScore = score
        }
    }
    
    private func resetQuiz() {
        selectedAnswers = Array(repeating: nil, count: questions.count)
    }
}

#Preview {
    QuizView()
}
