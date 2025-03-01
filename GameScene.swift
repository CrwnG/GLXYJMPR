import SpriteKit

struct PhysicsCategory {
    static let player: UInt32 = 0x1 << 0
    static let platform: UInt32 = 0x1 << 1
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var chosenImage: UIImage?
    
    //Jugador
    var player: SKSpriteNode!
    
    //Planetas circulares
    var planets: [SKShapeNode] = []
    
    //Movimiento horizontal
    var horizontalInput: CGFloat = 0.0
    
    //Cámara
    let cameraNode = SKCameraNode()
    
    //puntaje
    private(set) var score: Int = 0
    private var maxPlayerY: CGFloat = 0.0
    
    //pame Over
    var isGameOver = false
    
    //callbacks
    var onGameOver: (() -> Void)?
    var onScoreUpdate: ((Int) -> Void)?
    
    //inicializador con imagen de AI
    convenience init(size: CGSize, chosenImage: UIImage?) {
        self.init(size: size)
        self.chosenImage = chosenImage
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        //Fijar la cámara en centro horizontal desde principio
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode
        
        createPlayer()
        
        // Planeta inicial debajo del jugador
        let initialY = player.position.y - 40
        spawnPlanet(at: CGPoint(x: size.width / 2, y: initialY))
        
        // Planetas iniciales adicionales
        spawnInitialPlanets(fromY: initialY)
        
        // Impulso hacia arriba
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
    }
    
    func createPlayer() {
        let diameter: CGFloat = 60
        let headTexture: SKTexture
        if let img = chosenImage {
            //circular foto AI
            let circImg = circularImage(from: img, size: CGSize(width: diameter, height: diameter))
            headTexture = SKTexture(image: circImg)
        } else {
            //si no hay imagen, usar un círculo gris por defecto
            let shape = SKShapeNode(circleOfRadius: diameter / 2)
            shape.fillColor = .gray
            let tempView = SKView()
            headTexture = tempView.texture(from: shape) ?? SKTexture()
        }
        
        player = SKSpriteNode(texture: headTexture)
        player.size = CGSize(width: diameter, height: diameter)
        //posicionar jugador en centro horizontal y a mitad de pantalla verticalmente
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        //configurar cuerpo físico del jugador
        let body = SKPhysicsBody(circleOfRadius: diameter / 2)
        body.categoryBitMask = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.platform
        body.collisionBitMask = PhysicsCategory.platform
        body.friction = 0.0
        body.linearDamping = 0.0
        body.angularDamping = 0.0
        body.allowsRotation = false
        body.restitution = 0.0  //sin rebote automático, controlado manualmente
        
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
        planet.fillColor = .cyan
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
    
    //ajustar radio de planetas de la altura alcanzada
    func dynamicPlanetRadius() -> CGFloat {
        let baseRadius: CGFloat = 50
        let reduction = maxPlayerY / 2000
        let newRadius = baseRadius - reduction
        return max(20, newRadius)
    }
    
    //físicas
    func didBegin(_ contact: SKPhysicsContact) {
        if isGameOver { return }
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if mask == (PhysicsCategory.player | PhysicsCategory.platform) {
            //rebote solo si el jugador está cayendo sobre un planeta
            if let velocity = player.physicsBody?.velocity, velocity.dy < 0 {
                let bounceVelocity = 600 * (1 + maxPlayerY / 1000)
                player.physicsBody?.velocity.dy = bounceVelocity
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameOver { return }
        
        //movimiento horizontal del jugador 
        player.physicsBody?.velocity.dx = horizontalInput * 400
        
        //seguir al jugador solo en vertical
        let deltaY = player.position.y - cameraNode.position.y
        cameraNode.position.y += deltaY * 0.1
        
        //mantener cámara centrada horizontalmente
        cameraNode.position.x = size.width / 2
        
        //actualizar altura máxima y puntaje
        if player.position.y > maxPlayerY {
            maxPlayerY = player.position.y
            let newScore = Int(maxPlayerY)
            if newScore > score {
                score = newScore
                onScoreUpdate?(score)
            }
        }
        
        //más planetas conforme el jugador sube
        if let last = planets.last {
            if player.position.y > (last.position.y - 300) {
                let spacing = CGFloat.random(in: 120 * (1 + maxPlayerY/1000)...150 * (1 + maxPlayerY/1000))
                let newY = last.position.y + spacing
                let newX = CGFloat.random(in: 80...(size.width - 80))
                spawnPlanet(at: CGPoint(x: newX, y: newY))
            }
        }
        
        //Game Over si el jugador cae fuera de la pantalla
        let cameraBottom = cameraNode.position.y - (size.height / 2)
        if player.position.y < cameraBottom - 100 {
            triggerGameOver()
        }
    }
    
    func triggerGameOver() {
        if isGameOver { return }
        isGameOver = true
        
        //mostrar texto de Game Over en la escena
        let label = SKLabelNode(text: "Game Over")
        label.fontColor = .white
        label.fontSize = 40
        label.position = CGPoint(x: cameraNode.position.x, y: cameraNode.position.y)
        addChild(label)
        
        physicsWorld.speed = 0  //detener física del juego
        onGameOver?()           //llamar al callback de Game Over
    }
}
