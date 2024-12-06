//
//  GameCenterPlayer.swift
//  hog
//
//  Created by Troy Martin on 12/6/24.
//
//  Copyright © 2024 Beef Erikson Studios. All rights reserved.
//

import GameKit

class GameCenterPlayer: Codable, Equatable {
    
    // Sets up variables to track during multiplayer
    var playerId: String
    var playerName: String
    
    var isLocalPlayer: Bool = false
    var isWinner: Bool = false
    
    var totalPoints: Int = 0
    
    /// Required by protocol - sets defaults for playerId and playerName.
    static func == (lhs: GameCenterPlayer, rhs: GameCenterPlayer) -> Bool {
        return lhs.playerId == rhs.playerId && lhs.playerName == rhs.playerName
    }
    
    /// Required by protocol - Initialized playerId and playerName with self values.
    init(playerId: String, playerName: String) {
        self.playerId = playerId
        self.playerName = playerName
    }
}
