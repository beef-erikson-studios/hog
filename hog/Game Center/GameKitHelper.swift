//
//  GameKitHelper.swift
//  hog
//
//  Created by Troy Martin on 11/16/24.
//

import GameKit

class GameKitHelper : NSObject {
    
    // MARK: - GAMECENTER / GAMEKIT INITIALIZATIONS
    
    // Shared GameKit Helper
    static let shared: GameKitHelper = {
        let instance = GameKitHelper()
        
        return instance
    }()
    
    // Game Center and GameKit-related view controllers
    var authenticationViewController: UIViewController?
    
    
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
            
            // Player the access point in the upper-right hand corner
            // GKAccessPoint.shared.location = .topLeading
            // GKAccessPoint.shared.showHightlights = true
            // GKAccessPoint.shared.isActive = true
            
            // Perform other configuations as needed here
        }
    }
}


// MARK: - NOTIFICATION EXTENSION

// Authentication notification
extension Notification.Name {
    static let presentAuthenticationViewController =
        Notification.Name("presentAuthenticationViewController")
}
