//
//  TitleView.swift
//  PaperScissors
//
//  Created by Pavel Alekseev on 10.09.2024.
//

import SwiftUI

struct TitleView: View {
    @StateObject private var gameCenterManager = GameCenterManager.shared

    @AppStorage("allTimeHighScore") private var allTimeHighScore: Int = 0
    @AppStorage("dailyHighScore") private var dailyHighScore: Int = 0
    @AppStorage("weeklyHighScore") private var weeklyHighScore: Int = 0

    let currentStreak: Int

    var body: some View {
        VStack(spacing: 20) {
            appTitleView
                .frame(maxWidth: .infinity, alignment: .center)

            currentStreakView
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    bestStreakView
                }
                .overlay(alignment: .trailing) {
                    leaderboardButton
                }
                .foregroundColor(Constants.textColor)
                .padding(.top)
        }
    }

    private var leaderboardButton: some View {
        Button(action: {
            if gameCenterManager.isAuthenticated {
                gameCenterManager.showLeaderboard()
            }
        }) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 24))
                .foregroundColor(gameCenterManager.isAuthenticated ? .white : .gray)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
        }
        .disabled(!gameCenterManager.isAuthenticated)
    }

    private var bestStreakView: some View {
        HStack(spacing: 5) {
            Image(systemName: "crown.fill")
                .foregroundColor(.yellow)
            Text("\(allTimeHighScore)")
                .font(.custom("AvenirNext-Bold", size: 18))
                .foregroundColor(Constants.textColor)
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
                .foregroundColor(Constants.textColor)
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

#Preview {
    TitleView(currentStreak: 50)
        .background(Constants.backgroundColor)
}
