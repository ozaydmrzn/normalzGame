import SwiftUI
import UIKit
import Charts

struct ContentView: View {
    @StateObject private var gameService = GameService()
    @StateObject private var gameCenterManager = GameCenterManager.shared
    @State private var currentQuestion: Question?
    @State private var userChoice: String = ""
    @State private var currentStreak: Int = 0
    @AppStorage("allTimeHighScore") private var allTimeHighScore: Int = 0
    @AppStorage("dailyHighScore") private var dailyHighScore: Int = 0
    @AppStorage("weeklyHighScore") private var weeklyHighScore: Int = 0
    @State private var result: GameResult = .none
    @State private var showingResults: Bool = false
    @State private var isAnimating: Bool = false
    @State private var showingAchievement: Bool = false
    @State private var currentAchievement: Achievement?
    @State private var showingLeaderboard: Bool = false
    @State private var showingShareSheet = false
    @State private var errorMessage: String?
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var showOnboarding = false
    @State private var isLoading = false
    @State private var feedbackGenerator = UINotificationFeedbackGenerator()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showingNetworkAlert = false
    
    let backgroundColor = Color(red: 0.1, green: 0.1, blue: 0.3)
    let buttonColor = Color(red: 0.2, green: 0.5, blue: 0.8)
    let textColor = Color.white
    
    var body: some View {
        ZStack {
            
            gameView
                            .blur(radius: showOnboarding ? 5 : 0)
                            .allowsHitTesting(!showOnboarding)
                            .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
                                if !newValue {
                                    showingNetworkAlert = true
                                }
                            }
                            .alert(isPresented: $showingNetworkAlert) {
                                Alert(
                                    title: Text("Network Error"),
                                    message: Text("Please check your internet connection and try again."),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
            
            if showOnboarding {
                            Color.black.opacity(0.4)
                                .edgesIgnoringSafeArea(.all)
                                .allowsHitTesting(false)
                        }
            
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .transition(.opacity)
                    .zIndex(1)
            }}
        .onAppear {
            if !hasSeenOnboarding {
                showOnboarding = true
                hasSeenOnboarding = true
            }
            fetchNewQuestion()
            gameCenterManager.authenticatePlayer()
            resetDailyAndWeeklyScoresIfNeeded()
            feedbackGenerator.prepare()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = createShareImage() {
                ActivityViewController(activityItems: [createShareText(), image])
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            resetDailyAndWeeklyScoresIfNeeded()
        }
    }
    
    private var gameView: some View {
        ZStack {
                    backgroundColor.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        appTitleView.frame(maxWidth: .infinity, alignment: .center)
                        HStack {
                            bestStreakView
                            Spacer()
                            currentStreakView
                            Spacer()
                            Button(action: {
                                    if gameCenterManager.isAuthenticated {
                                        gameCenterManager.showLeaderboard()
                                    }
                                }) {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(gameCenterManager.isAuthenticated ? .white : .gray)
                                        .frame(width: 44, height: 44)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(15)
                                }
                                .disabled(!gameCenterManager.isAuthenticated)
                        }
                        .foregroundColor(textColor)
                        .padding(.top)
                        
                        if isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle())
                                        } else if let question = currentQuestion {
                            if showingResults {
                                resultView(for: question)
                                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                            } else {
                                questionView(for: question)
                                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                            }
                        } else if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            ProgressView()
                        }
                    }
                    .padding()
                    
                    if showingAchievement {
                        achievementView
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
        }
    
    private func questionView(for question: Question) -> some View {
        VStack(spacing: 20) {
            ForEach(question.options, id: \.self) { option in
                Button(action: { playGame(option) }) {
                    Text(option)
                        .font(.custom("AvenirNext-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(buttonColor)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func resultView(for question: Question) -> some View {
        VStack(spacing: 15) {
            Text("Results")
                .font(.custom("AvenirNext-Bold", size: 28))
                .foregroundColor(textColor)
            
            Chart {
                ForEach(question.options, id: \.self) { option in
                    let count = question.answerCounts[option] ?? 0
                    let percentage = Double(count) / Double(question.totalAnswers) * 100
                    BarMark(
                        x: .value("Percentage", percentage),
                        y: .value("Option", option)
                    )
                    .foregroundStyle(option == userChoice ? Color.green : buttonColor)
                    .annotation(position: .trailing) {
                        Text(String(format: "%.1f%%", percentage))
                            .font(.custom("AvenirNext-Bold", size: 14))
                            .foregroundColor(option == userChoice ? .green : textColor)
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
                
                Button(action: fetchNewQuestion) {
                    Text("New Normalz")
                        .font(.custom("AvenirNext-DemiBold", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .background(buttonColor)
                        .cornerRadius(10)
                }
            }
            .padding(.top)
        }
        .padding()
        .background(Color(white: 1.0, opacity: 0.2))
        .cornerRadius(15)
    }
    
    private func createShareImage() -> UIImage? {
        guard let question = currentQuestion else { return nil }
        
        let resultViewToRender = resultView(for: question)
            .frame(width: 300, height: 400)
            .background(backgroundColor)
        
        let renderer = ImageRenderer(content: resultViewToRender)
        renderer.scale = UIScreen.main.scale
        
        return renderer.uiImage
    }
    
    private func createShareText() -> String {
        return "I just played Normalz! My current streak is \(currentStreak) and my all-time best is \(allTimeHighScore)!"
    }
    
    private func fetchNewQuestion() {
        withAnimation {
                    isLoading = true
                    currentQuestion = nil
                    showingResults = false
                }
        guard networkMonitor.isConnected else {
                   withAnimation {
                       isLoading = false
                       errorMessage = "No internet connection. Please check your network and try again."
                   }
                   return
               }
        
        gameService.fetchQuestion { result in
                    withAnimation {
                        isLoading = false
                        switch result {
                        case .success(let question):
                            self.currentQuestion = question
                        case .failure(let error):
                            self.errorMessage = error.localizedDescription
                            print("Error fetching question: \(error.localizedDescription)")
                        }
                    }
        }
    }
    
    private func playGame(_ choice: String) {
        guard let question = currentQuestion, !isAnimating else { return }
        isAnimating = true
        
        userChoice = choice
        
        gameService.submitAnswer(questionId: question.questionId, selectedOption: choice) { result in
            switch result {
            case .success(let message):
                print("Answer submitted successfully: \(message)")
                self.updateGameState(for: choice)
                
                // Provide haptic feedback based on the result
                DispatchQueue.main.async {
                    if self.result == .win {
                        self.feedbackGenerator.notificationOccurred(.success)
                    } else {
                        self.feedbackGenerator.notificationOccurred(.error)
                    }
                }
                
            case .failure(let error):
                print("Failed to submit answer: \(error.localizedDescription)")
                self.errorMessage = "Failed to submit answer: \(error.localizedDescription)"
                
                // Provide error feedback
                DispatchQueue.main.async {
                    self.feedbackGenerator.notificationOccurred(.error)
                }
            }
            self.isAnimating = false
        }
    }
    
    private func updateGameState(for choice: String) {
        guard let question = currentQuestion else { return }
        
        let newAnswerCounts = question.answerCounts.merging([choice: (question.answerCounts[choice] ?? 0) + 1]) { (_, new) in new }
        let newTotalAnswers = question.totalAnswers + 1
        
        currentQuestion?.answerCounts = newAnswerCounts
        currentQuestion?.totalAnswers = newTotalAnswers
        
        let mostPopular = question.options.max(by: { (newAnswerCounts[$0] ?? 0) < (newAnswerCounts[$1] ?? 0) })
        self.result = (choice == mostPopular) ? .win : .lose
        
        switch self.result {
        case .win:
            currentStreak += 1
            updateHighScores()
            checkAchievements()
        case .lose:
            currentStreak = 0
        case .draw, .none:
            break
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            self.showingResults = true
        }
    }
    
    private func updateHighScores() {
        if currentStreak > allTimeHighScore {
            allTimeHighScore = currentStreak
            gameCenterManager.submitScore(allTimeHighScore, leaderboardID: "allTimeLeaderboardID")
        }
        
        if currentStreak > dailyHighScore {
            dailyHighScore = currentStreak
            gameCenterManager.submitScore(dailyHighScore, leaderboardID: "dailyLeaderboardID")
        }
        
        if currentStreak > weeklyHighScore {
            weeklyHighScore = currentStreak
            gameCenterManager.submitScore(weeklyHighScore, leaderboardID: "weeklyLeaderboardID")
        }
    }
    
    private func resetDailyAndWeeklyScoresIfNeeded() {
        let calendar = Calendar.current
        let timeZone = TimeZone(secondsFromGMT: 2 * 3600)! // GMT+2
        let now = Date()
        
        // Configure date components for GMT+2 at 12 AM
        var dateComponents = calendar.dateComponents(in: timeZone, from: now)
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        
        guard let todayMidnight = calendar.date(from: dateComponents) else {
            print("Failed to create date")
            return
        }
        
        // Daily reset
        if let lastDailyReset = UserDefaults.standard.object(forKey: "lastDailyResetDate") as? Date {
            if lastDailyReset < todayMidnight {
                dailyHighScore = 0
                gameCenterManager.submitScore(dailyHighScore, leaderboardID: "dailyLeaderboardID")
                UserDefaults.standard.set(todayMidnight, forKey: "lastDailyResetDate")
            }
        } else {
            UserDefaults.standard.set(todayMidnight, forKey: "lastDailyResetDate")
        }
        
        // Weekly reset (Sunday)
        if let lastWeeklyReset = UserDefaults.standard.object(forKey: "lastWeeklyResetDate") as? Date {
            let weekday = calendar.component(.weekday, from: todayMidnight)
            if weekday == 1 && lastWeeklyReset < todayMidnight {
                weeklyHighScore = 0
                gameCenterManager.submitScore(weeklyHighScore, leaderboardID: "weeklyLeaderboardID")
                UserDefaults.standard.set(todayMidnight, forKey: "lastWeeklyResetDate")
            }
        } else {
            UserDefaults.standard.set(todayMidnight, forKey: "lastWeeklyResetDate")
        }
    }
    
    private func checkAchievements() {
        if currentStreak == 3 {
            unlockAchievement(.threeStreak)
        } else if currentStreak == 5 {
            unlockAchievement(.fiveStreak)
        } else if currentStreak == 10 {
            unlockAchievement(.tenStreak)
        }
    }
    
    private func unlockAchievement(_ achievement: Achievement) {
        currentAchievement = achievement
        withAnimation(.spring()) {
            showingAchievement = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeOut) {
                showingAchievement = false
            }
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
    
    private var achievementView: some View {
        VStack {
            Text("Achievement Unlocked!")
                .font(.custom("AvenirNext-Bold", size: 24))
                .foregroundColor(.white)
            Text(currentAchievement?.title ?? "")
                .font(.custom("AvenirNext-Medium", size: 18))
                .foregroundColor(.white)
            Text(currentAchievement?.emoji ?? "")
                .font(.system(size: 50))
        }
        .padding()
        .background(buttonColor)
        .cornerRadius(15)
        .shadow(radius: 10)
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
    private var bestStreakView: some View {
            HStack(spacing: 5) {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                Text("\(allTimeHighScore)")
                    .font(.custom("AvenirNext-Bold", size: 18))
                    .foregroundColor(textColor)
            }
            .padding(8)
            .background(Color(white: 1.0, opacity: 0.2))
            .cornerRadius(15)
        }
        
        private var currentStreakView: some View {
            HStack(spacing: 5) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(currentStreak)")
                    .font(.custom("AvenirNext-Bold", size: 20))
                    .foregroundColor(textColor)
            }
            .padding(10)
            .background(Color(white: 1.0, opacity: 0.2))
            .cornerRadius(20)
        }
    private var appTitleView: some View {
        Text("Normalz!")
            .font(.custom("AvenirNext-Bold", size: 42))
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 1, y: 1)
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

enum GameResult {
    case win, lose, draw, none
}

enum Achievement {
    case threeStreak, fiveStreak, tenStreak
    
    var title: String {
        switch self {
        case .threeStreak:
            return "3 Correct Predictions Streak"
        case .fiveStreak:
            return "5 Correct Predictions Streak"
        case .tenStreak:
            return "10 Correct Predictions Streak"
        }
    }
    
    var emoji: String {
        switch self {
        case .threeStreak:
            return "🔥"
        case .fiveStreak:
            return "🏆"
        case .tenStreak:
            return "🎖"
        }
    }
}
