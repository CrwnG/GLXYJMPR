import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var chosenImage: UIImage?
    var stickman: SKNode!
    var planet: SKShapeNode!
    var isOnGround = true
    
    // Inicializador que acepta la foto
    convenience init(size: CGSize, chosenImage: UIImage?) {
        self.init(size: size)
        self.chosenImage = chosenImage
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        createPlanet()
        createStickman()
    }
    
    func createPlanet() {
        let planetDiameter: CGFloat = 200
        let planetNode = SKShapeNode(circleOfRadius: planetDiameter/2)
        planetNode.fillColor = .purple
        planetNode.strokeColor = .white
        planetNode.lineWidth = 4
        planetNode.position = CGPoint(x: size.width / 2, y: planetDiameter/2 + 40)
        
        planetNode.physicsBody = SKPhysicsBody(circleOfRadius: planetDiameter/2)
        planetNode.physicsBody?.isDynamic = false
        
        planetNode.physicsBody?.categoryBitMask = 0x1 << 1
        planetNode.physicsBody?.contactTestBitMask = 0x1 << 0
        planetNode.physicsBody?.collisionBitMask = 0x1 << 0
        
        self.planet = planetNode
        addChild(planetNode)
    }
    
    func createStickman() {
        let stickmanNode = SKNode()
        
        let headDiameter: CGFloat = 80
        let bodyLength: CGFloat = 80
        let armLength: CGFloat = 40
        let legLength: CGFloat = 40
        
        // Cabeza con la foto
        let headTexture: SKTexture
        if let img = chosenImage {
            let circImg = circularImage(from: img, size: CGSize(width: headDiameter, height: headDiameter))
            headTexture = SKTexture(image: circImg)
        } else {
            let shape = SKShapeNode(circleOfRadius: headDiameter/2)
            shape.fillColor = .gray
            let tempView = SKView()
            headTexture = tempView.texture(from: shape) ?? SKTexture()
        }
        
        let head = SKSpriteNode(texture: headTexture)
        head.size = CGSize(width: headDiameter, height: headDiameter)
        head.position = CGPoint(x: 0, y: headDiameter/2)
        
        // Cuerpo
        let bodyPath = CGMutablePath()
        bodyPath.move(to: .zero)
        bodyPath.addLine(to: CGPoint(x: 0, y: -bodyLength))
        let bodyLine = SKShapeNode(path: bodyPath)
        bodyLine.strokeColor = .white
        bodyLine.lineWidth = 4
        
        // Brazos
        let armY = -bodyLength / 2
        let leftArmPath = CGMutablePath()
        leftArmPath.move(to: CGPoint(x: 0, y: armY))
        leftArmPath.addLine(to: CGPoint(x: -armLength, y: armY - armLength/2))
        let leftArm = SKShapeNode(path: leftArmPath)
        leftArm.strokeColor = .white
        leftArm.lineWidth = 4
        
        let rightArmPath = CGMutablePath()
        rightArmPath.move(to: CGPoint(x: 0, y: armY))
        rightArmPath.addLine(to: CGPoint(x: armLength, y: armY - armLength/2))
        let rightArm = SKShapeNode(path: rightArmPath)
        rightArm.strokeColor = .white
        rightArm.lineWidth = 4
        
        // Piernas
        let leftLegPath = CGMutablePath()
        leftLegPath.move(to: CGPoint(x: 0, y: -bodyLength))
        leftLegPath.addLine(to: CGPoint(x: -legLength/2, y: -bodyLength - legLength))
        let leftLeg = SKShapeNode(path: leftLegPath)
        leftLeg.strokeColor = .white
        leftLeg.lineWidth = 4
        
        let rightLegPath = CGMutablePath()
        rightLegPath.move(to: CGPoint(x: 0, y: -bodyLength))
        rightLegPath.addLine(to: CGPoint(x: legLength/2, y: -bodyLength - legLength))
        let rightLeg = SKShapeNode(path: rightLegPath)
        rightLeg.strokeColor = .white
        rightLeg.lineWidth = 4
        
        // Agregar las partes al nodo
        stickmanNode.addChild(head)
        stickmanNode.addChild(bodyLine)
        stickmanNode.addChild(leftArm)
        stickmanNode.addChild(rightArm)
        stickmanNode.addChild(leftLeg)
        stickmanNode.addChild(rightLeg)
        
        // Posicionarlo sobre el planeta
        stickmanNode.position = CGPoint(x: size.width / 2, y: planet.frame.maxY + 10)
        
        // Cuerpo físico
        let bodyRect = CGRect(x: -headDiameter/2, y: -bodyLength - legLength,
                              width: headDiameter, height: headDiameter + bodyLength + legLength)
        stickmanNode.physicsBody = SKPhysicsBody(rectangleOf: bodyRect.size,
                                                 center: CGPoint(x: 0, y: bodyRect.midY))
        stickmanNode.physicsBody?.categoryBitMask = 0x1 << 0
        stickmanNode.physicsBody?.contactTestBitMask = 0x1 << 1
        stickmanNode.physicsBody?.collisionBitMask = 0x1 << 1
        stickmanNode.physicsBody?.restitution = 0.0
        stickmanNode.physicsBody?.allowsRotation = false
        
        self.stickman = stickmanNode
        addChild(stickmanNode)
    }
    
    // Quitar 'override' porque es un método de SKPhysicsContactDelegate, no de la superclase
    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        let planetMask = (0x1 << 0) | (0x1 << 1)
        if mask == planetMask {
            isOnGround = true
        }
    }
    
    func jump() {
        if isOnGround {
            isOnGround = false
            SoundManager.shared.playSound("jump.wav")
            
            stickman.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
            
            // Mover el planeta a la izquierda y luego reposicionarlo
            let moveLeft = SKAction.moveBy(x: -size.width, y: 0, duration: 0.5)
            let reposition = SKAction.run { [weak self] in
                guard let self = self else { return }
                self.planet.position.x += self.size.width * 2
            }
            let sequence = SKAction.sequence([.wait(forDuration: 0.2), moveLeft, reposition])
            planet.run(sequence)
        }
    }
}
