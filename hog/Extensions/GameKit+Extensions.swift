//
//  GameKit+Extensions.swift
//  hog
//
//  Created by Troy Martin on 12/6/24.
//
//  Copyright © 2024 Beef Erikson Studios. All rights reserved.
//

import GameKit

// Local player and opponents-filtered variables
extension GKTurnBasedMatch {
    
    var localPlayer: GKTurnBasedParticipant? {
        return participants.filter({ $0.player == GKLocalPlayer.local}).first
    }
    
    var opponents: [GKTurnBasedParticipant] {
        return participants.filter { return $0.player != GKLocalPlayer.local }
    }
}
