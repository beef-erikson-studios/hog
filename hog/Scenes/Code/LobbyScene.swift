//
//  LobbyScene.swift
//  hog
//
//  Created by Tammy Coron on 10/31/2020.
//  Further edits created by Troy Martin on 12/06/24.
//
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
//  Copyright © 2024 Beef Erikson Studios. All rights reserved.
//

import SpriteKit
import GameKit

class LobbyScene: SKScene {
  
    // MARK: - PROPERTIES
  
    private lazy var playSoloButton: SKSpriteNode = {
        childNode(withName: "button_playSolo") as! SKSpriteNode
    }()
  
    private lazy var playLocalButton: SKSpriteNode = {
        childNode(withName: "button_playLocal") as! SKSpriteNode
    }()
  
    private lazy var findMatchButton: SKSpriteNode = {
        childNode(withName: "button_findMatch") as! SKSpriteNode
    }()
  
    private lazy var gameCenterButton: SKSpriteNode = {
        childNode(withName: "button_gameCenter") as! SKSpriteNode
    }()
  
    // ** TEST CODE (For Simulator Only) **
    // This code lets you easily test win/lose scene
    // without having to play the game
    #if targetEnvironment(simulator)
    private var isTest: Bool = true
  
    private lazy var chipsButton: SKSpriteNode = {
        childNode(withName: "chips") as! SKSpriteNode
    }()
    private lazy var diceButton: SKSpriteNode = {
        childNode(withName: "dice") as! SKSpriteNode
    }()
    #endif
  
    
    // MARK: - INIT METHODS
  
    /// Resets the match data and adds Game Center Observers.
    ///
    /// - Parameters:
    ///   - view: The SKView to apply initializations to.
    override func didMove(to view: SKView) {
        // Reset the match data
        GameKitHelper.shared.currentMatch = nil
        
        // Set up the Game Center Remote Game Notifications
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.processGameCenterRequest),
                                               name: .receivedTurnEvent,
                                               object: nil)
    }
    
    /// Loads the Game Center game using the notification object.
    ///
    /// - Parameters:
    ///   - notification: The Notification to use in the Game Center game.
    @objc func processGameCenterRequest(_ notification: Notification) {
        guard let match = notification.object as? GKTurnBasedMatch else { return }
        
        loadGameCenterGame(match: match)
    }
    
    // MARK: - TOUCH HANDLERS
  
    /* ############################################################ */
    /*                 TOUCH HANDLERS STARTS HERE                   */
    /* ############################################################ */
  
    func touchDown(atPoint pos : CGPoint) {
        let nodeAtPoint = atPoint(pos)
    
        if playSoloButton.contains(nodeAtPoint) {
            loadGameScene(gameType: GameType.soloMatch)
        } else if playLocalButton.contains(nodeAtPoint) {
            loadGameScene(gameType: GameType.localMatch)
        } else if findMatchButton.contains(nodeAtPoint) {
            // Opens matchmaking
            GameKitHelper.shared.findMatch()
        } else if gameCenterButton.contains(nodeAtPoint) {
            // Shows the Game Center
            GameKitHelper.shared.showGKGameCenter(state: .dashboard)
    }
    
    // ** TEST CODE (For Simulator Only) **
    // This code lets you easily test win/lose scene
    // without having to play the game
    #if targetEnvironment(simulator)
    if chipsButton.contains(nodeAtPoint) {
      loadGameOverScene(isWinner: false)
    }
    else if diceButton.contains(nodeAtPoint) {
      loadGameOverScene(isWinner: true)
    }
    #endif
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches {self.touchDown(atPoint: t.location(in: self))}
  }
}
