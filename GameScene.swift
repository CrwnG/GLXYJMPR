import SpriteKit

struct PhysicsCategory {
    static let player: UInt32 = 0x1 << 0
    static let platform: UInt32 = 0x1 << 1
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var chosenImage: UIImage?
    
    // Jugador
    var player: SKSpriteNode!
    
    // Planetas circulares
    var planets: [SKShapeNode] = []
    
    // Movimiento horizontal
    var horizontalInput: CGFloat = 0.0
    
    // Cámara
    let cameraNode = SKCameraNode()
    
    // Puntaje
    private(set) var score: Int = 0
    private var maxPlayerY: CGFloat = 0.0
    
    // Game Over
    var isGameOver = false
    
    // Callbacks
    var onGameOver: (() -> Void)?
    var onScoreUpdate: ((Int) -> Void)?
    
    // Inicializador
    convenience init(size: CGSize, chosenImage: UIImage?) {
        self.init(size: size)
        self.chosenImage = chosenImage
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        // Ajuste: Fijar la cámara en el centro horizontal desde el principio
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode
        
        createPlayer()
        
        // Planeta inicial debajo del jugador
        let initialY = player.position.y - 40
        spawnPlanet(at: CGPoint(x: size.width / 2, y: initialY))
        
        // Planetas iniciales
        spawnInitialPlanets(fromY: initialY)
        
        // Impulso inicial
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
    }
    
    func createPlayer() {
        let diameter: CGFloat = 60
        let headTexture: SKTexture
        if let img = chosenImage {
            let circImg = circularImage(from: img, size: CGSize(width: diameter, height: diameter))
            headTexture = SKTexture(image: circImg)
        } else {
            let shape = SKShapeNode(circleOfRadius: diameter / 2)
            shape.fillColor = .gray
            let tempView = SKView()
            headTexture = tempView.texture(from: shape) ?? SKTexture()
        }
        
        player = SKSpriteNode(texture: headTexture)
        player.size = CGSize(width: diameter, height: diameter)
        // Centrar horizontalmente
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        let body = SKPhysicsBody(circleOfRadius: diameter / 2)
        body.categoryBitMask = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.platform
        body.collisionBitMask = PhysicsCategory.platform
        
        // Quitar fricción
        body.friction = 0.0
        body.linearDamping = 0.0
        body.angularDamping = 0.0
        
        body.allowsRotation = false
        body.restitution = 0.0
        
        player.physicsBody = body
        addChild(player)
    }
    
    func spawnInitialPlanets(fromY startY: CGFloat) {
        let numPlanets = 10
        var currentY = startY
        for _ in 0..<numPlanets {
            let spacing = CGFloat.random(in: 120...150)
            currentY += spacing
            let xPos = CGFloat.random(in: 80...(size.width - 80)) // margen horizontal
            spawnPlanet(at: CGPoint(x: xPos, y: currentY))
        }
    }
    
    func spawnPlanet(at position: CGPoint) {
        let radius = dynamicPlanetRadius()
        let planet = SKShapeNode(circleOfRadius: radius)
        planet.fillColor = .green
        planet.strokeColor = .white
        planet.lineWidth = 2
        planet.position = position
        
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.platform
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.player
        body.friction = 0.0
        
        planet.physicsBody = body
        
        addChild(planet)
        planets.append(planet)
    }
    
    // Planetas más pequeños con la altura
    func dynamicPlanetRadius() -> CGFloat {
        let baseRadius: CGFloat = 50
        let reduction = maxPlayerY / 2000
        let newRadius = baseRadius - reduction
        return max(20, newRadius)
    }
    
    // Rebote
    func didBegin(_ contact: SKPhysicsContact) {
        if isGameOver { return }
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if mask == (PhysicsCategory.player | PhysicsCategory.platform) {
            if let velocity = player.physicsBody?.velocity, velocity.dy < 0 {
                let bounceVelocity = 600 * (1 + maxPlayerY / 1000)
                player.physicsBody?.velocity.dy = bounceVelocity
                SoundManager.shared.playSound("jump.wav")
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameOver { return }
        
        // Movimiento horizontal
        player.physicsBody?.velocity.dx = horizontalInput * 400
        
        // Solo seguimos vertical
        let deltaY = player.position.y - cameraNode.position.y
        cameraNode.position.y += deltaY * 0.1
        
        // Mantener la cámara centrada horizontalmente
        cameraNode.position.x = size.width / 2
        
        // Actualizar altura y puntaje
        if player.position.y > maxPlayerY {
            maxPlayerY = player.position.y
            let newScore = Int(maxPlayerY)
            if newScore > score {
                score = newScore
                onScoreUpdate?(score)
            }
        }
        
        // Generar más planetas
        if let last = planets.last {
            if player.position.y > (last.position.y - 300) {
                let spacing = CGFloat.random(in: 120*(1 + maxPlayerY/1000)...150*(1 + maxPlayerY/1000))
                let newY = last.position.y + spacing
                let newX = CGFloat.random(in: 80...(size.width - 80))
                spawnPlanet(at: CGPoint(x: newX, y: newY))
            }
        }
        
        // Game Over si cae
        let cameraBottom = cameraNode.position.y - (size.height / 2)
        if player.position.y < cameraBottom - 100 {
            triggerGameOver()
        }
    }
    
    func triggerGameOver() {
        if isGameOver { return }
        isGameOver = true
        
        let label = SKLabelNode(text: "Game Over")
        label.fontColor = .white
        label.fontSize = 40
        label.position = CGPoint(x: cameraNode.position.x, y: cameraNode.position.y)
        addChild(label)
        
        physicsWorld.speed = 0
        onGameOver?()
    }
}
