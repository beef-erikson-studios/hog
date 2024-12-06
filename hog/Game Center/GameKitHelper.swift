//
//  GameKitHelper.swift
//  hog
//
//  Created by Troy Martin on 11/16/24.
//
//  Copyright © 2024 Beef Erikson Studios. All rights reserved.
//

import GameKit

class GameKitHelper : NSObject {
    
    // MARK: - GAMECENTER / GAMEKIT INITIALIZATIONS
    
    // Leaderboard IDs
    static let leaderBoardIDMostWins = "beef.erikson.studios.hog.wins"
    
    // Shared GameKit Helper
    static let shared: GameKitHelper = {
        let instance = GameKitHelper()
        
        return instance
    }()
    
    // Game Center and GameKit-related view controllers
    var authenticationViewController: UIViewController?
    
    // Variable for button interaction with GameCenter
    var gameCenterViewController: GKGameCenterViewController?
    
    
    // MARK: - GAME CENTER METHODS
    
    /// Authenticates the player.
    func authenticateLocalPlayer() {
        // Prepare for new controller
        authenticationViewController = nil
        
        // Authenticate local player
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            
            // Present the view controller so the player can sign in
            if let viewController = viewController {
                self.authenticationViewController = viewController
                NotificationCenter.default.post(
                    name: .presentAuthenticationViewController,
                    object: self)
                return
            }
            
            // Player couldn't be authenticated, disable game center
            if error != nil {
                return
            }
            
            
            // MARK: - PLAYER RESTRICTIONS
            
            // Underage player
            if GKLocalPlayer.local.isUnderage {
                // Censor shit here
            }
            
            // Multiplayer restricted
            if GKLocalPlayer.local.isMultiplayerGamingRestricted {
                // Disable multiplayer
            }
            
            // Communication restricted
            if GKLocalPlayer.local.isPersonalizedCommunicationRestricted {
                // Disable communication UI
            }

            // Place the access point in the upper-left hand corner
            // GKAccessPoint.shared.location = .topLeading
            // GKAccessPoint.shared.showHighlights = true
            // GKAccessPoint.shared.isActive = true
            
            // Perform other configuations as needed here //
        }
    }
    
    /// Reports score to the Game Center Leaderboard for Most Wins.
    ///
    /// - Parameters:
    ///   - score: The score to upload to the Leaderboard.
    ///   - forLeaderboardID: ID of Leaderboard to update.
    ///   - errorHandler: Handles errors.
    func reportScore(score: Int, forLeaderboardID leaderboardID: String,
                     errorHandler: ((Error?)->Void)? = nil) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        
        // Submits score - newer devices
        if #available (iOS 14, *) {
            GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local,
                                      leaderboardIDs:  [leaderboardID],
                                      completionHandler: errorHandler ?? {
                error in print("error: \(String(describing: error))")
            })
        } else {
            let gkScore = GKScore(leaderboardIdentifier: leaderboardID)
            gkScore.value = Int64(score)
            GKScore.report([gkScore], withCompletionHandler: errorHandler)
       }
    }
    
    /// Reports the player's Achievements.
    ///
    /// - Parameters:
    ///   - achievements: Array of achievements to report.
    ///   - errorHandler: Error handler.
    func reportAchievements(achievements: [GKAchievement],
                            errorHandler: ((Error?)->Void)? = nil) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        
        GKAchievement.report(achievements, withCompletionHandler: errorHandler)
    }
}


// MARK: - DELEGATE EXTENSIONS

extension GameKitHelper: GKGameCenterControllerDelegate {
    /// Dismisses Game Center View Controller - this is required.
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
        
    /// Shows the Game Center View Controller.
    func showGKGameCenter(state: GKGameCenterViewControllerState) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
            
        // Prepare for new controller
        gameCenterViewController = nil
            
        // Create controller instance
        if #available(iOS 14, *) {
            gameCenterViewController = GKGameCenterViewController(state: state)
        } else {
            gameCenterViewController = GKGameCenterViewController()
            gameCenterViewController?.viewState = state
        }
            
        // Set the delegate
        gameCenterViewController?.gameCenterDelegate = self
            
        // Post the notification
        NotificationCenter.default.post(name: .presentGameCenterViewController, object: self)
    }
}


// MARK: - NOTIFICATION EXTENSION

// Authentication notification
extension Notification.Name {
    static let presentAuthenticationViewController =
        Notification.Name("presentAuthenticationViewController")
    
    static let presentGameCenterViewController =
        Notification.Name("presentGameCenterViewController")
}
