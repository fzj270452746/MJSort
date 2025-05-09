import SpriteKit

class CardNode: SKNode {
    // Card model
    let card: Card
    
    // Visual elements
    private let cardSprite: SKSpriteNode
    private let borderNode: SKShapeNode
    private let shadowNode: SKEffectNode
    
    // Constants
    static let cardSize = CGSize(width: 60, height: 80)
    private let cornerRadius: CGFloat = 8.0
    private let selectedYOffset: CGFloat = 15.0
    
    // State
    var isSelected: Bool = false {
        didSet {
            if isSelected != oldValue {
                updateSelectionState()
            }
        }
    }
    
    // Touch tracking
    private var initialTouchPosition: CGPoint = .zero
    var touchMoved: Bool = false  // 改为公开，以便滚动视图可以设置它
    private static let touchMovementThreshold: CGFloat = 5.0
    
    // 卡牌可动态调整大小
    private var cardScale: CGFloat = 1.0
    
    // MARK: - Initialization
    
    init(card: Card) {
        self.card = card
        
        // Load card image with correct path
        let imageName = "\(card.suit.rawValue.lowercased())_\(card.value)"
        
        let cardTexture = SKTexture(imageNamed: imageName)
        cardSprite = SKSpriteNode(texture: cardTexture, size: CardNode.cardSize)
        
        // Create border node for highlighting
        borderNode = SKShapeNode(rectOf: CardNode.cardSize, cornerRadius: cornerRadius)
        borderNode.fillColor = .clear
        borderNode.strokeColor = UIColor.black.withAlphaComponent(0.2)
        borderNode.lineWidth = 1
        
        // Create shadow effect node
        shadowNode = SKEffectNode()
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(6, forKey: "inputRadius")
        shadowNode.filter = filter
        shadowNode.shouldRasterize = true
        
        // Create shadow sprite with card back texture - use correct path
        let shadowTexture = SKTexture(imageNamed: "card_back")
        let shadowSprite = SKSpriteNode(texture: shadowTexture, size: CardNode.cardSize)
        shadowSprite.color = .black
        shadowSprite.colorBlendFactor = 1.0
        shadowSprite.alpha = 0.3
        shadowSprite.position = CGPoint(x: 3, y: -3)
        
        super.init()
        
        // Setup shadow
        shadowNode.addChild(shadowSprite)
        addChild(shadowNode)
        
        // Add card components
        addChild(cardSprite)
        addChild(borderNode)
        
        // Enable user interaction
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 根据卡牌数量调整大小
    func adjustSize(forCardCount count: Int) {
        // 当卡牌数量超过一定阈值时，动态缩小卡牌
        if count > 30 {
            cardScale = 0.9  // 超过30张，缩小到90%
        } else if count > 25 {
            cardScale = 0.95  // 25-30张，缩小到95%
        } else {
            cardScale = 1.0  // 少于25张，使用正常大小
        }
        
        // 应用缩放
        self.setScale(cardScale)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Store initial touch position for determining if this is a tap or a scroll
        initialTouchPosition = touch.location(in: self.parent!)
        touchMoved = false
        
        // Scale down slightly to show press, but don't do full selection yet
        let scaleDown = SKAction.scale(to: 0.95 * cardScale, duration: 0.1)
        run(scaleDown)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Calculate how far the touch has moved
        let currentPosition = touch.location(in: self.parent!)
        let distance = hypot(currentPosition.x - initialTouchPosition.x, 
                            currentPosition.y - initialTouchPosition.y)
        
        // If the touch has moved beyond our threshold, mark it as a scroll, not a tap
        if distance > CardNode.touchMovementThreshold {
            touchMoved = true
            
            // If we're now in "scroll mode", scale back up immediately
            if self.xScale < cardScale {
                let scaleUp = SKAction.scale(to: cardScale, duration: 0.05)
                run(scaleUp)
            }
            
            // 将触摸事件传递给父节点（滚动视图）
            parent?.touchesMoved(touches, with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Scale back up
        let scaleUp = SKAction.scale(to: cardScale, duration: 0.1)
        run(scaleUp)
        
        // Only process taps (not scrolls)
        if !touchMoved {
            // 不在这里切换选择状态，而是通知GameScene处理选择逻辑
            // 这样可以避免选择后立即验证，保持对GameScene的控制
            
            // 直接通知GameScene处理卡牌点击
            if let scene = scene as? GameScene {
                scene.cardWasTapped(self)
            } else {
                // 如果无法直接访问场景，则尝试通过滚动视图通知
                findScrollView()?.delegate?.cardScrollViewDidSelectCard(findScrollView()!, cardNode: self)
            }
        } else {
            // 将触摸事件传递给父节点（滚动视图）
            parent?.touchesEnded(touches, with: event)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let scaleUp = SKAction.scale(to: cardScale, duration: 0.1)
        run(scaleUp)
        touchMoved = false
        
        // 将触摸事件传递给父节点（滚动视图）
        parent?.touchesCancelled(touches, with: event)
    }
    
    // 查找所属的滚动视图
    private func findScrollView() -> CardScrollView? {
        var currentNode: SKNode? = self
        while currentNode != nil {
            if let scrollView = currentNode as? CardScrollView {
                return scrollView
            }
            currentNode = currentNode?.parent
        }
        return nil
    }
    
    // MARK: - Visual States
    
    func updateSelectionState() {
        if isSelected {
            // Highlight the card
            highlight()
        } else {
            // Remove highlight
            unhighlight()
        }
    }
    
    func highlight() {
        // 移除任何现有的动画
        removeAllActions()
        
        // 使用动画移动卡牌向上
        let moveUp = SKAction.moveTo(y: selectedYOffset, duration: 0.2)
        moveUp.timingMode = .easeOut
        run(moveUp)
        
        // Add green border
        borderNode.strokeColor = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0)
        borderNode.lineWidth = 3
        
        // Enhance shadow
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(10, forKey: "inputRadius")
        shadowNode.filter = filter
        shadowNode.alpha = 0.5
    }
    
    func unhighlight() {
        // 移除任何现有的动画
        removeAllActions()
        
        // 使用动画移动卡牌回原位
        let moveDown = SKAction.moveTo(y: 0, duration: 0.2)
        moveDown.timingMode = .easeIn
        run(moveDown)
        
        // Remove border
        borderNode.strokeColor = UIColor.black.withAlphaComponent(0.2)
        borderNode.lineWidth = 1
        
        // Reset shadow
        let filter = CIFilter(name: "CIGaussianBlur")!
        filter.setValue(6, forKey: "inputRadius")
        shadowNode.filter = filter
        shadowNode.alpha = 0.3
    }
    
    // MARK: - Animations
    
    func animateDeal(to position: CGPoint, delay: TimeInterval, completion: @escaping () -> Void) {
        // Start position (off screen)
        self.position = CGPoint(x: -100, y: 0)
        self.setScale(0.8 * cardScale)
        self.alpha = 0
        
        // Animate to final position
        let moveAction = SKAction.move(to: position, duration: 0.5)
        moveAction.timingMode = .easeOut
        
        let scaleAction = SKAction.scale(to: cardScale, duration: 0.5)
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        
        let dealSequence = SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.group([moveAction, scaleAction, fadeInAction]),
            SKAction.run(completion)
        ])
        
        run(dealSequence)
    }
    
    func animateRemove(completion: @escaping () -> Void) {
        // Animate card removal
        let scaleUp = SKAction.scale(to: 1.2 * cardScale, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        
        let removeSequence = SKAction.sequence([
            scaleUp,
            fadeOut,
            SKAction.run(completion),
            SKAction.removeFromParent()
        ])
        
        run(removeSequence)
    }
    
    // For displaying combo highlighting (when system suggests a combo)
    func pulse() {
        let pulseAction = SKAction.sequence([
            SKAction.scale(to: 1.1 * cardScale, duration: 0.2),
            SKAction.scale(to: cardScale, duration: 0.2)
        ])
        
        run(SKAction.repeat(pulseAction, count: 2))
    }
} 
