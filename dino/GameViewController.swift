import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var sceneShown = false

    override func loadView() {
        view = SKView(frame: UIScreen.main.bounds)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if sceneShown {
            return
        }

        let skView = view as! SKView
        let width = max(skView.bounds.width, skView.bounds.height)
        let height = min(skView.bounds.width, skView.bounds.height)

        if width == 0 || height == 0 {
            return
        }

        sceneShown = true

        let scene = GameScene(size: CGSize(width: width, height: height))
        scene.scaleMode = .aspectFill
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

