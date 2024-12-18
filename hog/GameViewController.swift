//
//  GameViewController.swift
//  hog
//
//  Created by Tammy Coron on 10/31/2020.
//  Further code edits created by Troy Martin on 12/06/24.
//
//  Copyright © 2020 Just Write Code LLC. All rights reserved.
//  Copyright © 2024 Beef Erikson Studios. All rights reserved.
//

import GameKit


class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        
        // MARK: -  GAME CENTER OBSERVERS
        
        // Authentication
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.showAuthenticationViewController),
            name: .presentAuthenticationViewController, object: nil)
        
        // Game Center
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.showGameCenterViewController),
            name: .presentGameCenterViewController, object: nil)
        
        // Matchmaker
        NotificationCenter.default.addObserver(
            self,
            selector:  #selector(self.showTurnBasedMatchmakerViewController),
            name: .presentTurnBasedGameCenterViewController, object: nil)
    
        // Authenticate the Local GC player
        GameKitHelper.shared.authenticateLocalPlayer()
    
        // Create the view
        if let view = self.view as! SKView? {
      
            // Create the scene
            let scene = LobbyScene(fileNamed: "LobbyScene")
      
            // Set the scale mode to scale to fill the view window
            scene?.scaleMode = .aspectFill
      
            // Present the scene
            view.presentScene(scene)
      
            // Set the view options
            view.ignoresSiblingOrder = false
            view.showsPhysics = false
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }
  
    override var shouldAutorotate: Bool {
      return true
    }
  
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
      if UIDevice.current.userInterfaceIdiom == .phone {
        return .allButUpsideDown
        } else {
            return .all
        }
    }
  
    override var prefersStatusBarHidden: Bool {
        return true
    }


    // MARK: - GAME CENTER NOTIFICATION HANDLERS
  
    /// Presents the shared view controller.
    @objc func showAuthenticationViewController() {
        if let viewController = GameKitHelper.shared.authenticationViewController {
            present(viewController, animated: true, completion: nil)
        }
    }
    
    /// Presents the game center view controller.
    @objc func showGameCenterViewController() {
        if let viewController = GameKitHelper.shared.gameCenterViewController {
            present(viewController, animated: true, completion: nil)
        }
    }
    
    /// Presents the matchmaking view controller.
    @objc func showTurnBasedMatchmakerViewController() {
        if let viewController = GameKitHelper.shared.matchmakerViewController {
            present(viewController, animated: true, completion: nil)
        }
    }
}
