import SwiftUI

struct LeaderboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var timeFrame: TimeFrame = .daily
    @State private var leaderboardData: [LeaderboardEntry] = []
    @State private var userRank: Int = 0
    
    let backgroundColor = Color(red: 0.1, green: 0.1, blue: 0.3)
    let accentColor = Color(red: 0.2, green: 0.5, blue: 0.8)
    let textColor = Color.white
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(textColor)
                            .font(.system(size: 20, weight: .bold))
                    }
                    Spacer()
                    Text("Leaderboard")
                        .font(.custom("Futura-Bold", size: 28))
                        .foregroundColor(textColor)
                    Spacer()
                }
                .padding()
                
                // Time Frame Picker
                Picker("Time Frame", selection: $timeFrame) {
                    ForEach(TimeFrame.allCases, id: \.self) { frame in
                        Text(frame.rawValue.capitalized).tag(frame)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: timeFrame) { _ in
                    fetchLeaderboardData()
                }
                
                // Leaderboard List
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(Array(leaderboardData.enumerated()), id: \.element.id) { index, entry in
                            LeaderboardRow(rank: index + 1, entry: entry)
                        }
                    }
                    .padding()
                }
                
                // User's Rank
                if userRank > 0 {
                    HStack {
                        Text("Your Rank:")
                            .font(.custom("AvenirNext-DemiBold", size: 18))
                        Text("#\(userRank)")
                            .font(.custom("AvenirNext-Bold", size: 24))
                            .foregroundColor(accentColor)
                    }
                    .foregroundColor(textColor)
                    .padding()
                    .background(Color(white: 1.0, opacity: 0.1))
                    .cornerRadius(15)
                }
            }
        }
        .onAppear(perform: fetchLeaderboardData)
    }
    
    private func fetchLeaderboardData() {
        // Simulating API call with dummy data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch timeFrame {
            case .daily:
                leaderboardData = [
                    LeaderboardEntry(name: "Alice", streak: 10, avatarName: "person.crop.circle.fill"),
                    LeaderboardEntry(name: "Bob", streak: 8, avatarName: "person.crop.circle.fill"),
                    LeaderboardEntry(name: "Charlie", streak: 5, avatarName: "person.crop.circle.fill"),
                    LeaderboardEntry(name: "David", streak: 3, avatarName: "person.crop.circle.fill")
                ]
                userRank = 31
            case .monthly:
                leaderboardData = [
                    LeaderboardEntry(name: "Eve", streak: 20, avatarName: "person.crop.circle.fill"),
                    LeaderboardEntry(name: "Frank", streak: 15, avatarName: "person.crop.circle.fill"),
                    LeaderboardEntry(name: "Grace", streak: 10, avatarName: "person.crop.circle.fill"),
                    LeaderboardEntry(name: "Henry", streak: 5, avatarName: "person.crop.circle.fill")
                ]
                userRank = 26
            case .allTime:
                leaderboardData = [
                    LeaderboardEntry(name: "Ivy", streak: 50, avatarName: "person.crop.circle.fill"),
                    LeaderboardEntry(name: "Jack", streak: 30, avatarName: "person.crop.circle.fill"),
                    LeaderboardEntry(name: "Kate", streak: 20, avatarName: "person.crop.circle.fill"),
                    LeaderboardEntry(name: "Liam", streak: 10, avatarName: "person.crop.circle.fill")
                ]
                userRank = 101
            }
        }
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .font(.custom("AvenirNext-Bold", size: 18))
                .foregroundColor(.gray)
                .frame(width: 40, alignment: .leading)
            
            Image(systemName: entry.avatarName)
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            
            Text(entry.name)
                .font(.custom("AvenirNext-Medium", size: 18))
            
            Spacer()
            
            HStack(spacing: 5) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(entry.streak)")
                    .font(.custom("AvenirNext-Bold", size: 18))
            }
        }
        .padding()
        .background(Color(white: 1.0, opacity: 0.05))
        .cornerRadius(10)
    }
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let name: String
    let streak: Int
    let avatarName: String
}

enum TimeFrame: String, CaseIterable {
    case daily, monthly, allTime = "all time"
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
