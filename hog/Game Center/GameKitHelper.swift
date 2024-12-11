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
    var gameCenterViewController: GKGameCenterViewController?
    var matchmakerViewController: GKTurnBasedMatchmakerViewController?
    
    // Multiplayer match properties
    var currentMatch: GKTurnBasedMatch?
    
    
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
            // Register the local player if authenticated
            else if GKLocalPlayer.local.isAuthenticated {
                GKLocalPlayer.local.register(self)
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
    
    
    // MARK: - GAME CENTER REPORTING
    
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


// MARK: - TURN BASED MULTIPLAYER EXTENSIONS

extension GameKitHelper: GKTurnBasedMatchmakerViewControllerDelegate {
    
    /// Closes view controller when cancelled - required by protocol.
    ///
    /// - Parameters:
    ///   - viewController: View controller to close.
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    /// Error handling - required by protocol.
    ///
    /// - Parameters:
    ///   - viewController: View Controller for error handling.
    ///   - error: Error produced from failure.
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController,
                                           didFailWithError error: Error) {
        print("MatchmakerViewController failed with error: \(error)")
    }
    
    /// Shows the matchmaking View Controller.
    func findMatch() {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        
        // Multiplayer settings
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        request.defaultNumberOfPlayers = 2
        
        request.inviteMessage = "Invite your friends to play dice!"
        
        // Sets up view controller
        matchmakerViewController = nil
        
        matchmakerViewController = GKTurnBasedMatchmakerViewController(matchRequest: request)
        matchmakerViewController?.turnBasedMatchmakerDelegate = self
        
        NotificationCenter.default.post(name: .presentTurnBasedGameCenterViewController, object: nil)
    }
}

extension GameKitHelper: GKLocalPlayerListener {
    
    /// Replaces default view controller with a custom one.
    ///
    /// - Parameters:
    ///   - player: GKPlayer object of the player to post.
    ///   - match: GKTurnBasedMatch object to post.
    ///   - didBecomeActive: Bool of wheter object is active.
    func player(_ player: GKPlayer, receivedTurnEventFor match: GKTurnBasedMatch, didBecomeActive: Bool) {
        
        matchmakerViewController?.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: .receivedTurnEvent, object: match)
    }
    
    /// Check if player can take turn.
    func canTakeTurn() -> Bool {
        guard let match = currentMatch else { return false }
        return match.currentParticipant?.player == GKLocalPlayer.local
    }
    
    /// Ends the players turn and sends data.
    ///
    /// - Parameters:
    ///   - gameCenterDataModel: The data to send to the opponent.
    ///   - errorHandler: Used for error handling / reporting.
    func endTurn(_ gameCenterDataModel: GameCenterData,
                 errorHandler: ((Error?)->Void)? = nil) {
        guard let match = currentMatch else { return }
        
        do {
            match.message = nil
            match.endTurn(withNextParticipants: match.opponents,
                          turnTimeout: GKExchangeTimeoutDefault,
                          match: try JSONEncoder().encode(gameCenterDataModel))
            print("Game Center Data has been sent.")
        } catch {
            print("There was an error sending the data: \(error)")
        }
    }
    
    /// The player has won the game, send loss to opponents and end the game.
    ///
    /// - Parameters:
    ///   - gameCenterDataModel: The data to send to the server.
    ///   - errorHandler: Used for error handling / reporting.
    func winGame(_ gameCenterDataModel: GameCenterData,
                 errorHandler: ((Error?)->Void)? = nil) {
        guard let match = currentMatch else { return }
        
        // Current player won
        match.currentParticipant?.matchOutcome = .won
        
        // Set all opponents (only 1 in this game) to lost state
        match.opponents.forEach {  participant in
            participant.matchOutcome = .lost
        }
        
        // End the match
        match.endMatchInTurn(withMatch: match.matchData ?? Data(),
                             completionHandler: {error in })
    }
    
    /// Player lost the game, set win and loss states and end match.
    ///
    /// - Parameters:
    ///   - gameCenterDataModel: The data to send to the server/opponents.
    ///   - errorHandler: Used for error handling/reporting.
    func lostGame(_ gameCenterDataModel: GameCenterData,
                  errorHandler: ((Error?)->Void)? = nil) {
        guard let match = currentMatch else { return }
        
        // Current player lost
        match.currentParticipant?.matchOutcome = .lost
        
        // Set all opponents (only 1 in this game) to win state
        match.opponents.forEach { participant in
            participant.matchOutcome = .won
        }
        
        // End the match
        match.endMatchInTurn(withMatch: match.matchData ?? Data(),
                             completionHandler: {error in })
    }
}


// MARK: - NOTIFICATION EXTENSION

extension Notification.Name {
    
    // Authentication view controller
    static let presentAuthenticationViewController =
        Notification.Name("presentAuthenticationViewController")
    
    // Game Center view controller
    static let presentGameCenterViewController =
        Notification.Name("presentGameCenterViewController")
    
    // Multiplayer view controller
    static let presentTurnBasedGameCenterViewController =
        Notification.Name("presentTurnBasedGameCenterViewController")
    
    // Received Turn event
    static let receivedTurnEvent = Notification.Name("receivedTurnEvent")
}
