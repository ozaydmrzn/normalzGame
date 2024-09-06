import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentTab = 0
    
    let backgroundColor = Color(red: 0.1, green: 0.1, blue: 0.3) // Dark blue background
    let accentColor = Color(red: 0.2, green: 0.5, blue: 0.8) // Light blue accent
    
    var body: some View {
        TabView(selection: $currentTab) {
            OnboardingPageView(
                title: "Welcome to normalz!",
                description: "Predict what most people would choose in various scenarios.",
                imageName: "person.3.fill",
                buttonText: "Next",
                action: { currentTab = 1 }
            )
            .tag(0)
            
            OnboardingPageView(
                title: "How to Play",
                description: "Choose one of three options. The most popular answer wins!",
                imageName: "hand.tap.fill",
                buttonText: "Next",
                action: { currentTab = 2 }
            )
            .tag(1)
            
            OnboardingPageView(
                title: "Track Your Progress",
                description: "Build your streak and compete on the leaderboard!",
                imageName: "chart.line.uptrend.xyaxis",
                buttonText: "Get Started!",
                action: { showOnboarding = false }
            )
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
    }
}

struct OnboardingPageView: View {
    let title: String
    let description: String
    let imageName: String
    let buttonText: String
    let action: () -> Void
    
    let accentColor = Color(red: 0.2, green: 0.5, blue: 0.8) // Light blue accent
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.white)
            
            Text(title)
                .font(.custom("Futura-Bold", size: 32))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.custom("AvenirNext-Regular", size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: action) {
                Text(buttonText)
                    .font(.custom("AvenirNext-DemiBold", size: 18))
                    .foregroundColor(.white)
                    .frame(minWidth: 200)
                    .padding()
                    .background(accentColor)
                    .cornerRadius(15)
            }
            
            Spacer()
        }
        .padding()
    }
}

// Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showOnboarding: .constant(true))
    }
}
