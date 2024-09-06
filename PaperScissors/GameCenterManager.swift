import GameKit
import SwiftUI

class GameCenterManager: NSObject, GKGameCenterControllerDelegate, ObservableObject {
    static let shared = GameCenterManager()
    
    @Published var isAuthenticated = false
    
    private override init() {
        super.init()
    }
    
    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            if let viewController = viewController {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(viewController, animated: true)
                }
            } else if let error = error {
                print("Game Center authentication error: \(error.localizedDescription)")
            } else {
                self?.isAuthenticated = true
                print("Player authenticated in Game Center")
            }
        }
    }
    
    func submitScore(_ score: Int, leaderboardID: String) {
        guard isAuthenticated else {
            print("Player not authenticated. Cannot submit score.")
            return
        }
        
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { error in
            if let error = error {
                print("Error submitting score: \(error.localizedDescription)")
            } else {
                print("Score \(score) submitted successfully to leaderboard \(leaderboardID)")
            }
        }
    }
    
    func showLeaderboard() {
        guard isAuthenticated else {
            print("Player not authenticated. Cannot show leaderboard.")
            return
        }
        
        let viewController = GKGameCenterViewController(state: .leaderboards)
        viewController.gameCenterDelegate = self
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(viewController, animated: true)
        }
    }
    
    // MARK: - GKGameCenterControllerDelegate
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.dismiss(animated: true)
        }
    }
}
