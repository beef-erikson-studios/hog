//
//  AchievementsHelper.swift
//  hog
//
//  Created by Troy Martin on 12/6/24.
//

import GameKit

class AchievementsHelper {
    
    static let achievementIdFirstWin = "beef.erikson.studios.hog.first.win"
    
    /// Registers achievement for player's First Win.
    ///
    /// - Parameters:
    ///   - didWin: Bool if player won or not.
    class func firstWinAchievement(didWin: Bool) -> GKAchievement {
        let achievement = GKAchievement(identifier: AchievementsHelper.achievementIdFirstWin)
        
        if didWin {
            achievement.percentComplete = 100
            achievement.showsCompletionBanner = true
        }
        
        return achievement
    }
}
