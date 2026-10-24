import SpriteKit
 
class GameScene: SKScene {
 
    var player = SKSpriteNode()
    var bg1 = SKSpriteNode(imageNamed: "Backgrounds")
    var bg2 = SKSpriteNode(imageNamed: "Backgrounds")
    var ground1 = SKSpriteNode(imageNamed: "Ground")
    var ground2 = SKSpriteNode(imageNamed: "Ground")
 
    var scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var livesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var shieldLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var messageLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
 
    var obstacles: [SKSpriteNode] = []
    var shields: [SKLabelNode] = []
 
    var runFrames: [SKTexture] = []
    var jumpTexture = SKTexture()
    var music: SKAudioNode?
 
    var score = 0
    var lives = 3
    var hasShield = false
    var isStarted = false
    var isGameOver = false
    var autoStart = false
 
    var velocityY: CGFloat = 0
    var isOnGround = true
    var gameSpeed: CGFloat = 300
 
    var lastTime: TimeInterval = 0
    var overTime: TimeInterval = 0
    var hitUntil: TimeInterval = 0
    var obstacleTimer: TimeInterval = 1.5
    var shieldTimer: TimeInterval = 8
 
    var groundY: CGFloat = 0
 
    override func didMove(to view: SKView) {
        removeAllChildren()
        groundY = size.height * 0.2
 
        setupBackground()
        setupGround()
        setupPlayer()
        setupLabels()
 
        if let musicNode = SKAudioNode(fileNamed: "music.wav") {
            musicNode.autoplayLooped = true
            music = musicNode
            addChild(musicNode)
        } else {
            print("Не удалось найти файл music.wav в бандле приложения")
        }
 
        if autoStart {
            isStarted = true
            messageLabel.text = ""
        }
    }
 
    func playSound(_ name: String) {
        run(SKAction.playSoundFileNamed(name, waitForCompletion: false))
    }
 
    func setupBackground() {
        bg1.anchorPoint = CGPoint(x: 0, y: 0)
        bg2.anchorPoint = CGPoint(x: 0, y: 0)
        bg1.size = CGSize(width: size.width + 2, height: size.height)
        bg2.size = CGSize(width: size.width + 2, height: size.height)
        bg1.position = CGPoint(x: 0, y: 0)
        bg2.position = CGPoint(x: size.width, y: 0)
        bg1.zPosition = -10
        bg2.zPosition = -10
        addChild(bg1)
        addChild(bg2)
    }
 
    func setupGround() {
        ground1.anchorPoint = CGPoint(x: 0, y: 0)
        ground2.anchorPoint = CGPoint(x: 0, y: 0)
        ground1.size = CGSize(width: size.width + 2, height: groundY)
        ground2.size = CGSize(width: size.width + 2, height: groundY)
        ground1.position = CGPoint(x: 0, y: 0)
        ground2.position = CGPoint(x: size.width, y: 0)
        ground1.zPosition = 2
        ground2.zPosition = 2
        addChild(ground1)
        addChild(ground2)
    }
 
    func cutFrames(name: String, count: Int) -> [SKTexture] {
        let sheet = SKTexture(imageNamed: name)
        var frames: [SKTexture] = []
        for i in 0..<count {
            let rect = CGRect(x: CGFloat(i) / CGFloat(count), y: 0, width: 1 / CGFloat(count), height: 1)
            frames.append(SKTexture(rect: rect, in: sheet))
        }
        return frames
    }
 
    func setupPlayer() {
        runFrames = cutFrames(name: "OstrichRun", count: 4)
        jumpTexture = cutFrames(name: "OstrichJump", count: 2)[0]
 
        player.texture = runFrames[0]
        player.size = CGSize(width: 80, height: 80)
        player.anchorPoint = CGPoint(x: 0.5, y: 0)
        player.position = CGPoint(x: size.width * 0.2, y: groundY)
        player.zPosition = 5
        addChild(player)
 
        runAnimation()
    }
 
    func runAnimation() {
        let animation = SKAction.animate(with: runFrames, timePerFrame: 0.09)
        player.run(SKAction.repeatForever(animation), withKey: "run")
    }
 
    func makeLabel(_ label: SKLabelNode, fontSize: CGFloat, x: CGFloat, y: CGFloat, align: SKLabelHorizontalAlignmentMode) {
        label.fontSize = fontSize
        label.fontColor = .white
        label.horizontalAlignmentMode = align
        label.position = CGPoint(x: x, y: y)
        label.zPosition = 20
        addChild(label)
    }
 
    func setupLabels() {
        makeLabel(scoreLabel, fontSize: 20, x: size.width - 24, y: size.height - 40, align: .right)
        makeLabel(livesLabel, fontSize: 22, x: 24, y: size.height - 40, align: .left)
        makeLabel(shieldLabel, fontSize: 15, x: 24, y: size.height - 66, align: .left)
        makeLabel(messageLabel, fontSize: 27, x: size.width / 2, y: size.height / 2, align: .center)
 
        messageLabel.numberOfLines = 0
        messageLabel.verticalAlignmentMode = .center
        messageLabel.zPosition = 30
        messageLabel.text = "OSTRICH RUN\nTap to Start"
 
        updateLabels()
    }
 
    func updateLabels() {
        scoreLabel.text = "SCORE: \(score)"
        livesLabel.text = String(repeating: "❤️", count: lives)
        if hasShield {
            shieldLabel.text = "🛡 SHIELD ACTIVE"
        } else {
            shieldLabel.text = ""
        }
    }
 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isStarted {
            isStarted = true
            messageLabel.text = ""
            return
        }
 
        if isGameOver {
            if lastTime - overTime > 0.5 {
                restartGame()
            }
            return
        }
 
        if isOnGround {
            isOnGround = false
            velocityY = 850
            playSound("jump.wav")
            player.removeAction(forKey: "run")
            player.texture = jumpTexture
        }
    }
 
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isOnGround && velocityY > 400 {
            velocityY = 400
        }
    }
 
    override func update(_ currentTime: TimeInterval) {
        var dt = currentTime - lastTime
        lastTime = currentTime
        if dt > 0.05 {
            dt = 0.05
        }
 
        if !isStarted || isGameOver {
            return
        }
 
        let d = CGFloat(dt)
 
        if gameSpeed < 600 {
            gameSpeed += 4 * d
        }
 
        movePlayer(d)
        moveBackground(d)
        moveObjects(d)
        spawnThings(dt)
        checkHits(currentTime)
 
        if currentTime < hitUntil {
            player.alpha = 0.4
        } else {
            player.alpha = 1
        }
    }
 
    func movePlayer(_ d: CGFloat) {
        if isOnGround {
            return
        }
 
        if velocityY < 0 {
            velocityY -= 2900 * d
        } else {
            velocityY -= 2300 * d
        }
        player.position.y += velocityY * d
 
        if player.position.y <= groundY {
            player.position.y = groundY
            velocityY = 0
            isOnGround = true
            runAnimation()
        }
    }
 
    func moveBackground(_ d: CGFloat) {
        ground1.position.x -= gameSpeed * d
        ground2.position.x -= gameSpeed * d
        bg1.position.x -= gameSpeed * 0.25 * d
        bg2.position.x -= gameSpeed * 0.25 * d
 
        if ground1.position.x <= -size.width {
            ground1.position.x += size.width * 2
        }
        if ground2.position.x <= -size.width {
            ground2.position.x += size.width * 2
        }
        if bg1.position.x <= -size.width {
            bg1.position.x += size.width * 2
        }
        if bg2.position.x <= -size.width {
            bg2.position.x += size.width * 2
        }
    }
 
    func moveObjects(_ d: CGFloat) {
        for obstacle in obstacles {
            obstacle.position.x -= gameSpeed * d
 
            if obstacle.name == "new" && obstacle.position.x < player.position.x - 20 {
                obstacle.name = "passed"
                score += 1
                playSound("point.wav")
                updateLabels()
            }
 
            if obstacle.position.x < -80 {
                obstacle.removeFromParent()
            }
        }
        obstacles.removeAll { $0.parent == nil }
 
        for shield in shields {
            shield.position.x -= gameSpeed * d
            if shield.position.x < -80 {
                shield.removeFromParent()
            }
        }
        shields.removeAll { $0.parent == nil }
    }
 
    func spawnThings(_ dt: TimeInterval) {
        obstacleTimer -= dt
        if obstacleTimer <= 0 {
            spawnObstacle()
            obstacleTimer = Double.random(in: 1.1...2.2)
        }
 
        shieldTimer -= dt
        if shieldTimer <= 0 {
            spawnShield()
            shieldTimer = Double.random(in: 9...14)
        }
    }
 
    func spawnObstacle() {
        let names = ["Rock1", "Rock2", "Rock3", "Tree1", "Tree2"]
        let obstacle = SKSpriteNode(imageNamed: names.randomElement()!)
        obstacle.size = CGSize(width: 46, height: 46)
        obstacle.anchorPoint = CGPoint(x: 0.5, y: 0)
        obstacle.position = CGPoint(x: size.width + 50, y: groundY - 4)
        obstacle.zPosition = 4
        obstacle.name = "new"
        addChild(obstacle)
        obstacles.append(obstacle)
    }
 
    func spawnShield() {
        let shield = SKLabelNode(text: "🛡️")
        shield.fontSize = 32
        shield.verticalAlignmentMode = .center
        shield.position = CGPoint(x: size.width + 40, y: groundY + 105)
        shield.zPosition = 8
        addChild(shield)
        shields.append(shield)
    }
 
    func checkHits(_ currentTime: TimeInterval) {
        let playerRect = CGRect(x: player.position.x - 16, y: player.position.y + 6, width: 32, height: 54)
 
        for shield in shields {
            let shieldRect = CGRect(x: shield.position.x - 18, y: shield.position.y - 18, width: 36, height: 36)
            if shieldRect.intersects(playerRect) {
                hasShield = true
                playSound("shield.wav")
                shield.removeFromParent()
                updateLabels()
            }
        }
        shields.removeAll { $0.parent == nil }
 
        if currentTime < hitUntil {
            return
        }
 
        for obstacle in obstacles {
            let obstacleRect = CGRect(x: obstacle.position.x - 14, y: obstacle.position.y, width: 28, height: 32)
            if obstacleRect.intersects(playerRect) {
                obstacle.removeFromParent()
                playSound("hit.wav")
 
                if hasShield {
                    hasShield = false
                } else {
                    lives -= 1
                    hitUntil = currentTime + 1.2
                }
 
                updateLabels()
 
                if lives <= 0 {
                    gameOver()
                }
                break
            }
        }
        obstacles.removeAll { $0.parent == nil }
    }
 
    func gameOver() {
        isGameOver = true
        overTime = lastTime
        player.removeAllActions()
        player.alpha = 1
        music?.run(SKAction.stop())
        playSound("gameover.wav")
        messageLabel.text = "GAME OVER\nScore: \(score)\nTap to Restart"
    }
 
    func restartGame() {
        let newScene = GameScene(size: size)
        newScene.scaleMode = scaleMode
        newScene.autoStart = true
        view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.3))
    }
}
