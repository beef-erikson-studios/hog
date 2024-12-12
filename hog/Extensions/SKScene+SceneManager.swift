//
//  SKScene+SceneManager.swift
//  hog
//
//  Created by Tammy Coron on 10/31/2020.
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
//
//  Further edits by Troy Martin on 12/11/2024
//  Copyright © 2024 Beef Erikson Studios. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

extension SKScene {
  
    func loadGameScene(gameType: GameType,
                       matchData: GameCenterData? = nil,
                       matchID: String? = nil) {
        print("Attempting to load the game scene.")
    
        // Create actions to load the next scene
        let wait = SKAction.wait(forDuration: 0.50)
        let block = SKAction.run {
      
            // Load 'GameScene.sks' as a GKScene
            if let scene = GKScene(fileNamed: "GameScene") {
        
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! GameScene? {
          
                    // Copy gameplay related content over to the scene
                    sceneNode.entities = scene.entities
                    sceneNode.graphs = scene.graphs
          
                    // Populate the Game Center match data
                    sceneNode.gameCenterData = matchData
                    sceneNode.gameCenterMatchID = matchID
          
                    // Set up match game type (Solo, Local, Remote)
                    sceneNode.gameType = gameType
          
                    // Set the scale mode to scale to fit the window
                    sceneNode.scaleMode = .aspectFill
          
                    // Present the scene
                    self.view?.presentScene(sceneNode,
                                            transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
                }
            } else {
                print("Can't load game scene.")
            }
        }
    
        // Run the actions in sequence
        run(SKAction.sequence([wait, block]))
    }
  
    func loadGameOverScene(isWinner: Bool) {
        print("Attempting to load the game over scene.")
    
        // Create actions to load the game over scene
        let wait = SKAction.wait(forDuration: 0.50)
        let block = SKAction.run {
            if let scene = GameOverScene(fileNamed: "GameOverScene") {
                scene.scaleMode = .aspectFill
                scene.isWinner = isWinner
        
                self.view?.presentScene(scene,
                                        transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
            } else {
                print("Can't load game over scene.")
            }
        }
    
        // Run the actions in sequence
        run(SKAction.sequence([wait, block]))
    }
  
    func loadLobbyScene() {
        print("Attempting to load the lobby scene.")
    
        // Create actions to load the game over scene
        let wait = SKAction.wait(forDuration: 0.50)
        let block = SKAction.run {
            if let scene = LobbyScene(fileNamed: "LobbyScene") {
                scene.scaleMode = .aspectFill
        
                self.view?.presentScene(scene,
                                        transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
            } else {
                print("Can't load lobby scene.")
            }
        }
    
        // Run the actions in sequence
        run(SKAction.sequence([wait, block]))
    }
  
    /// This function is ran when the player launches a multiplayer game.
    ///
    /// - Parameters:
    ///   - match: The GKTurnBasedMatch object to use.
    func loadGameCenterGame(match: GKTurnBasedMatch) {
        print("Attempting to load the game scene using Game Center match data. . .")
        
        // Fetches match data for the match
        match.loadMatchData(completionHandler: {(data, error) in
            // Set the current match data
            GameKitHelper.shared.currentMatch = match
            
            // Set up the Game Center Data model
            var gameCenterDataModel: GameCenterData
            
            // Uses the match data to set up the model, if available. Instantiate new otherwise
            if let data = data {
                do {
                    gameCenterDataModel = try JSONDecoder().decode(GameCenterData.self, from: data)
                } catch {
                    gameCenterDataModel = GameCenterData()
                }
            } else {
                gameCenterDataModel = GameCenterData()
            }
            
            // Set up the players and mark the local player
            for participant in match.participants {
                if let player = participant.player {
                    let gameCenterPlayer = GameCenterPlayer(playerId: player.gamePlayerID,
                                                            playerName: player.displayName)
                    
                    // Check for local player
                    if player == GKLocalPlayer.local {
                        gameCenterPlayer.isLocalPlayer = true
                    }
                    
                    // Check for a winner
                    if participant.matchOutcome == .won {
                        gameCenterPlayer.isWinner = true
                    }
                    
                    // Add Game Center player to the Game Center model
                    gameCenterDataModel.addPlayer(gameCenterPlayer)
                }
            }
            
            // Load the game scene
            self.loadGameScene(gameType: .remoteMatch,
                               matchData: gameCenterDataModel,
                               matchID: match.matchID)
        })
    }
}
