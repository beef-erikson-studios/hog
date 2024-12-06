//
//  GameCenterData.swift
//  hog
//
//  Created by Troy Martin on 12/6/24.
//
//  Copyright © 2024 Beef Erikson Studios. All rights reserved.
//

import GameKit

class GameCenterData: Codable {
    var players: [GameCenterPlayer] = []
    
    /// Adds a player to the session.
    ///
    /// - Parameters:
    ///   - player: GameCenterPlayer object to add.
    func addPlayer(_ player: GameCenterPlayer) {
        if let p = getPlayer(withName: player.playerName) {
            p.isLocalPlayer = player.isLocalPlayer
            p.isWinner = player.isWinner
        } else {
            players.append(player)
        }
    }
    
    /// Returns the GameCenterPlayer object of the local player.
    func getLocalPlayer() -> GameCenterPlayer? {
        return players.filter( { $0.isLocalPlayer == true}).first
    }
    
    /// Returns the GameCenterPlayer object for the remote player.
    func getRemotePlayer() -> GameCenterPlayer? {
        return players.filter( { $0.isLocalPlayer == false}).first
    }
    
    /// Returns the game object of the player.
    ///
    /// - Parameters:
    ///   - playerName: String of player to retrieve an object from.
    func getPlayer(withName playerName: String) -> GameCenterPlayer? {
        return players.first(where: {$0.playerName == playerName})
    }
    
    /// Return the game object of the player's index.
    ///
    /// - Parameters:
    ///   - player: GameCenterPlayer object to retrieve index of.
    func getPlayerIndex(for player: GameCenterPlayer) -> Int? {
        return players.firstIndex(of: player)
    }
}
