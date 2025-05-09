import SpriteKit
import GameplayKit
import AVFoundation
import UIKit

class GameScene: SKScene {
    // MARK: - Properties
    
    // Game delegate
    weak var gameDelegate: GameSceneDelegate?
    
    // Sound manager
    private var soundManager = SoundManager.shared
    
    // Game settings
    private let sequenceScore = 200
    private let tripletScore = 300
    
    // Game state
    private var deck: [Card] = []
    private var playerHand: [Card] = []
    private var computerHand: [Card] = []
    private var playerScore: Int = 0
    private var computerScore: Int = 0
    private var isPlayerTurn: Bool = true
    private var gameActive: Bool = false
    private var comboCheckInProgress: Bool = false
    private var isSelectionEnabled: Bool = false // Track if player can select cards
    
    // 轮次控制
    private var playerDealsCount: Int = 0
    private var computerDealsCount: Int = 0
    private var roundNumber: Int = 1
    private var needsBalancing: Bool = false // 标记是否需要强制平衡发牌
    
    // Card nodes
    private var playerCardNodes: [CardNode] = []
    private var computerCardNodes: [CardNode] = []
    
    // Card layout
    private var cardSpacing: CGFloat = 5.0 // 默认间距
    private let handPadding: CGFloat = 40.0
    
    // Areas
    private var playerHandArea: SKNode!
    private var computerHandArea: SKNode!
    private var deckArea: SKNode!
    
    // 使用更可靠的滚动视图实现
    private var playerScrollView: CardScrollView!
    private var computerScrollView: CardScrollView!
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        setupScene()
    }
    
    // MARK: - Setup
    
    private func setupScene() {
        // Set background
        backgroundColor = .clear
        
        // 添加背景图片
//        addBackgroundImage()
        
        // Create areas
        setupAreas()
        
        // Start new game
        startNewGame()
    }
    
    // 添加背景图片
    private func addBackgroundImage() {
        // 使用麻将主题背景图片
        let backgroundTexture = SKTexture(imageNamed: "mahjong_bg")
        let backgroundNode = SKSpriteNode(texture: backgroundTexture)
        
        // 设置背景图片尺寸以覆盖整个场景
        backgroundNode.size = CGSize(width: size.width, height: size.height)
        backgroundNode.position = CGPoint(x: size.width/2, y: size.height/2)
        backgroundNode.zPosition = -100 // 确保背景在最底层
        
        // 设置透明度，让游戏元素更加突出
        backgroundNode.alpha = 0.4
        
        // 如果需要背景效果，可以添加模糊效果
        let effectNode = SKEffectNode()
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(5.0, forKey: "inputRadius")
        effectNode.filter = filter
        effectNode.addChild(backgroundNode)
        effectNode.zPosition = -100
        
        addChild(effectNode)
    }
    
    private func setupAreas() {
        // 计算可用宽度
        let availableWidth = size.width - 2 * handPadding
        
        // 玩家手牌区域（底部）- 添加半透明背景
        playerHandArea = SKNode()
        playerHandArea.position = CGPoint(x: size.width / 2, y: size.height * 0.2)
        addChild(playerHandArea)
        
        // 为玩家区域添加半透明背景
//        let playerAreaBg = SKShapeNode(rect: CGRect(x: -availableWidth/2 - 20, y: -80, width: availableWidth + 40, height: 160), cornerRadius: 15)
//        playerAreaBg.fillColor = UIColor.white.withAlphaComponent(0.2)
//        playerAreaBg.strokeColor = UIColor.white.withAlphaComponent(0.3)
//        playerAreaBg.lineWidth = 2
//        playerAreaBg.zPosition = -1
//        playerHandArea.addChild(playerAreaBg)

        // 为玩家创建滚动视图
        playerScrollView = CardScrollView(size: CGSize(width: availableWidth, height: 120))
        playerScrollView.position = CGPoint(x: 0, y: 0)
        playerScrollView.delegate = self
        
        // 设置初始内容大小，确保可以滚动
        let initialContentWidth = availableWidth * 4.0
        playerScrollView.contentSize = CGSize(width: initialContentWidth, height: 120)
        
        playerHandArea.addChild(playerScrollView)
        
        // 添加玩家区域标签
        let playerLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        playerLabel.text = "Player Cards"
        playerLabel.fontSize = 14
        playerLabel.fontColor = .white
        playerLabel.position = CGPoint(x: 0, y: -80)
        playerHandArea.addChild(playerLabel)
        
        // 电脑手牌区域（顶部）- 添加半透明背景
        computerHandArea = SKNode()
        computerHandArea.position = CGPoint(x: size.width / 2, y: size.height * 0.75)
        addChild(computerHandArea)
        
        // 为电脑区域添加半透明背景
//        let computerAreaBg = SKShapeNode(rect: CGRect(x: -availableWidth/2 - 20, y: -80, width: availableWidth + 40, height: 160), cornerRadius: 15)
//        computerAreaBg.fillColor = UIColor.white.withAlphaComponent(0.2)
//        computerAreaBg.strokeColor = UIColor.white.withAlphaComponent(0.3)
//        computerAreaBg.lineWidth = 2
//        computerAreaBg.zPosition = -1
//        computerHandArea.addChild(computerAreaBg)
        
        // 为电脑创建滚动视图
        computerScrollView = CardScrollView(size: CGSize(width: availableWidth, height: 120))
        computerScrollView.position = CGPoint(x: 0, y: 0)
        computerScrollView.delegate = self
        computerScrollView.isComputerView = true
        
        // 设置初始内容大小，确保可以滚动
        computerScrollView.contentSize = CGSize(width: initialContentWidth, height: 120)
        
        computerHandArea.addChild(computerScrollView)
        
        // 添加电脑区域标签
        let computerLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        computerLabel.text = "Computer Cards"
        computerLabel.fontSize = 14
        computerLabel.fontColor = .white
        computerLabel.position = CGPoint(x: 0, y: -80)
        computerHandArea.addChild(computerLabel)
        
        // 牌堆区域（中心）
        deckArea = SKNode()
        deckArea.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(deckArea)
        
        // Create deck visual with card back image
//        let deckBackTexture = SKTexture(imageNamed: "card_back")
//        let deckBack = SKSpriteNode(texture: deckBackTexture, size: CardNode.cardSize)
//        deckBack.name = "deckBack"
//        deckBack.alpha = 0
        
        // Add shadow to deck
//        deckBack.shadowCastBitMask = 0
        
        // Create stacked deck appearance with multiple cards
//        let deckStack = SKNode()
        
        // Add multiple cards with slight offset for stack appearance
//        for i in 0..<5 {
//            let stackCard = SKSpriteNode(texture: deckBackTexture, size: CardNode.cardSize)
//            stackCard.position = CGPoint(x: Double(i) * 0.5, y: -Double(i) * 0.5)
//            stackCard.zPosition = CGFloat(i)
//            deckStack.addChild(stackCard)
//        }
//        
//        deckArea.addChild(deckStack)
        
        // Deck counter label
//        let deckCountLabel = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
//        deckCountLabel.text = "108"
//        deckCountLabel.fontSize = 20
//        deckCountLabel.fontColor = .white
//        deckCountLabel.position = CGPoint(x: 0, y: -CardNode.cardSize.height/2 - 15)
//        deckCountLabel.name = "deckCountLabel"
//        deckArea.addChild(deckCountLabel)
        
        // Add decorative cards around the deck
        addDecorativeCards()
    }
    
    // Add some decorative scattered cards on the table
    private func addDecorativeCards() {
        let decorativePositions = [
            CGPoint(x: size.width * 0.15, y: size.height * 0.5),
            CGPoint(x: size.width * 0.36, y: size.height * 0.7),
            CGPoint(x: size.width * 0.85, y: size.height * 0.5),
            CGPoint(x: size.width * 0.3, y: size.height * 0.4),
            CGPoint(x: size.width * 0.6, y: size.height * 0.23),
            CGPoint(x: size.width * 0.7, y: size.height * 0.6),
            CGPoint(x: size.width * 0.52, y: size.height * 0.36)
        ]
        
        
        var cards: [String] = []
        
        for i in 0...8 {
            cards.append("wan_\(i+1)")
            cards.append("tiao_\(i+1)")
            cards.append("tong_\(i+1)")
        }
        
        for position in decorativePositions {
            
            let cardBackTexture = SKTexture(imageNamed: cards.randomElement()!)
            let decorativeCard = SKSpriteNode(texture: cardBackTexture, size: CardNode.cardSize)
            decorativeCard.position = position
            decorativeCard.zPosition = -1  // Behind other game elements
            decorativeCard.alpha = 0.4     // Semi-transparent
            
            // Add random rotation
            let randomAngle = CGFloat.random(in: -0.3...0.3)
            decorativeCard.zRotation = randomAngle
            
            addChild(decorativeCard)
        }
    }
    
    // MARK: - Game Logic
    
    private func startNewGame() {
        // Reset state
        resetGameState()
        
        // Create and shuffle deck
        createDeck()
        
        // Notify delegate
        gameDelegate?.gameDidStart()
        
        // Start first round
        gameActive = true
        
        // 初始化玩家回合
        isPlayerTurn = true
        comboCheckInProgress = false
        isSelectionEnabled = false
        
        // First deal - 先给玩家发第一张牌
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.dealCard()
        }
    }
    
    private func resetGameState() {
        // Clear hands
        playerHand.removeAll()
        computerHand.removeAll()
        
        // Remove card nodes
        playerCardNodes.forEach { $0.removeFromParent() }
        computerCardNodes.forEach { $0.removeFromParent() }
        playerCardNodes.removeAll()
        computerCardNodes.removeAll()
        
        // Reset scores
        playerScore = 0
        computerScore = 0
        
        // Reset game state
        comboCheckInProgress = false
        isSelectionEnabled = false
        
        // 重置回合计数
        playerDealsCount = 0
        computerDealsCount = 0
        roundNumber = 1
    }
    
    private func createDeck() {
        deck.removeAll()
        
        // 创建各花色1-9的牌，每种牌4张
        for suit in CardSuit.allCases {
            for value in 1...9 {
                for _ in 1...4 {
                    deck.append(Card(suit: suit, value: value))
                }
            }
        }
        
        // 洗牌
        deck.shuffle()
        
        // 更新牌组计数标签
        updateDeckCountLabel()
    }
    
    private func updateDeckCountLabel() {
        if let label = deckArea.childNode(withName: "deckCountLabel") as? SKLabelNode {
            label.text = "\(deck.count)"
        }
        
        // Update delegate
        gameDelegate?.updateRemainingCards(count: deck.count)
    }
    
    // MARK: - Dealing Cards
    
    private func dealCard() {
        if !gameActive || deck.isEmpty {
            endGame()
            return
        }
        
        if comboCheckInProgress {
            return
        }
        
        // 发牌阶段禁用选牌逻辑状态
        isSelectionEnabled = false
        comboCheckInProgress = false
        
        // 确保所有卡牌都不可选
        updateAllCardsInteractionState(enabled: false)
        
        // 强制平衡逻辑
        if needsBalancing {
            // 如果玩家牌比电脑多，轮到电脑发牌
            if playerDealsCount > computerDealsCount {
                isPlayerTurn = false
            } 
            // 如果电脑牌比玩家多，轮到玩家发牌
            else if computerDealsCount > playerDealsCount {
                isPlayerTurn = true
            }
            // 牌数相等，重置平衡标记
            else {
                needsBalancing = false
            }
        }
        
        // 关键修复：确保第三轮及以后电脑能接收到牌
        // 如果是第三轮及以后且电脑没有收到过牌，强制设置为电脑回合
        if roundNumber >= 3 && computerDealsCount == 0 {
            isPlayerTurn = false
        }
        
        // 确保回合平衡 - 如果玩家已经连续发了两张牌，切换到电脑回合
        if playerDealsCount > computerDealsCount + 1 {
            isPlayerTurn = false
            needsBalancing = true;
        }
        
        // 确保回合平衡 - 如果电脑已经连续发了两张牌，切换到玩家回合
        if computerDealsCount > playerDealsCount + 1 {
            isPlayerTurn = true
            needsBalancing = true;
        }
        
        // Get card from deck
        guard let card = deck.popLast() else { 
            return 
        }
        
        // Play card deal sound
        soundManager.playSound(.cardDeal)
        
        // Update deck count
        updateDeckCountLabel()
        
        if isPlayerTurn {
            // 玩家回合处理
            playerDealsCount += 1
            
            // Add to player's hand
            playerHand.append(card)
            
            // Create and position card node
            let cardNode = createCardNode(for: card, in: playerHandArea)
            playerCardNodes.append(cardNode)
            
            // Position cards
            positionPlayerCards()
            
            // Animate dealing
            cardNode.animateDeal(to: cardNode.position, delay: 0.1) { [weak self] in
                guard let self = self else { return }
                
                // Notify about card deal
                self.gameDelegate?.showNotification("Player received a card", duration: 1.5)
                
                // Check for combos after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.checkForCombos()
                }
            }
        } else {
            // 电脑回合处理
            computerDealsCount += 1
            
            // Add to computer's hand
            computerHand.append(card)
            
            // Create and position card node
            let cardNode = createCardNode(for: card, in: computerHandArea)
            computerCardNodes.append(cardNode)
            
            // Position cards
            positionComputerCards()
            
            // Animate dealing
            cardNode.animateDeal(to: cardNode.position, delay: 0.1) { [weak self] in
                guard let self = self else { return }
                
                // Notify about card deal
                self.gameDelegate?.showNotification("Computer received a card", duration: 1.5)
                
                // Check for combos after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.checkForCombos()
                }
            }
        }
    }
    
    private func createCardNode(for card: Card, in container: SKNode) -> CardNode {
        let cardNode = CardNode(card: card)
        
        // 如果是电脑区域的牌，禁用用户交互
        if container === computerHandArea {
            cardNode.isUserInteractionEnabled = false
        }
        
        // 不添加到容器，而是返回节点
        return cardNode
    }
    
    // MARK: - Card Positioning
    
    private func positionPlayerCards() {
        let count = playerCardNodes.count
        guard count > 0 else { return }
        
        // 移除所有卡牌节点
        playerCardNodes.forEach { $0.removeFromParent() }
        
        // 清空滚动容器并重新添加
        playerScrollView.contentNode.removeAllChildren()
        
        // 计算卡牌宽度和间距
        let cardWidth = CardNode.cardSize.width
        
        // 动态调整卡牌间距，确保更多牌能完全显示
        // 根据卡牌数量动态调整间距
        if count > 30 {
            cardSpacing = 0.5  // 超过30张时使用最小间距
        } else if count > 20 {
            cardSpacing = 0.8  // 20-30张时使用较小间距
        } else if count > 16 {
            cardSpacing = 1.0  // 16-20张时使用小间距
        } else {
            cardSpacing = 3.0  // 少于16张时使用标准间距
        }
        
        // 计算所需总宽度
        let cardWidthWithSpacing = cardWidth + cardSpacing
        let totalWidth = CGFloat(count) * cardWidthWithSpacing - cardSpacing
        
        // 按花色和点数排序卡牌
        let sortedNodes = playerCardNodes.sorted(by: { first, second in
            if first.card.suit != second.card.suit {
                return first.card.suit.rawValue < second.card.suit.rawValue
            }
            return first.card.value < second.card.value
        })
        
        // 设置滚动视图内容大小
        // 确保内容区域足够大
        let extraPadding = cardWidth * 4.0
        // 确保内容宽度至少是总卡牌宽度加上额外边距
        let contentWidth = max(totalWidth + extraPadding, size.width - 2*handPadding)
        playerScrollView.contentSize = CGSize(width: contentWidth, height: 140)
        
        // 确保有足够空间在边缘
        playerScrollView.ensureEnoughSpaceForCardEdges()
        
        // 从左侧开始排列卡牌 - 确保第一张牌完全显示
        var xPos: CGFloat = cardWidth/2
        
        // 定位每张牌
        for (index, cardNode) in sortedNodes.enumerated() {
            // 应用动态缩放 - 根据卡牌数量调整大小
            cardNode.adjustSize(forCardCount: count)
            
            cardNode.position = CGPoint(x: xPos, y: 0)
            xPos += cardWidthWithSpacing
            
            // 添加到滚动内容节点
            playerScrollView.contentNode.addChild(cardNode)
        }
        
        // 使内容居中显示 - 关键修改
        playerScrollView.centerContent()
        
        // 最后更新所有卡牌的交互状态
        updateAllCardsInteractionState(enabled: isSelectionEnabled)
    }
    
    private func positionComputerCards() {
        let count = computerCardNodes.count
        guard count > 0 else { return }
        
        // 移除所有卡牌节点
        computerCardNodes.forEach { $0.removeFromParent() }
        
        // 清空滚动容器并重新添加
        computerScrollView.contentNode.removeAllChildren()
        
        // 计算卡牌宽度和间距
        let cardWidth = CardNode.cardSize.width
        
        // 动态调整卡牌间距，确保更多牌能完全显示
        // 根据卡牌数量动态调整间距
        if count > 30 {
            cardSpacing = 0.5  // 超过30张时使用最小间距
        } else if count > 20 {
            cardSpacing = 0.8  // 20-30张时使用较小间距
        } else if count > 16 {
            cardSpacing = 1.0  // 16-20张时使用小间距
        } else {
            cardSpacing = 3.0  // 少于16张时使用标准间距
        }
        
        // 计算所需总宽度
        let cardWidthWithSpacing = cardWidth + cardSpacing
        let totalWidth = CGFloat(count) * cardWidthWithSpacing - cardSpacing
        
        // 按花色和点数排序卡牌
        let sortedNodes = computerCardNodes.sorted(by: { first, second in
            if first.card.suit != second.card.suit {
                return first.card.suit.rawValue < second.card.suit.rawValue
            }
            return first.card.value < second.card.value
        })
        
        // 设置滚动视图内容大小
        // 确保内容区域足够大
        let extraPadding = cardWidth * 4.0
        // 确保内容宽度至少是总卡牌宽度加上额外边距
        let contentWidth = max(totalWidth + extraPadding, size.width - 2*handPadding)
        computerScrollView.contentSize = CGSize(width: contentWidth, height: 140)
        
        // 确保有足够空间在边缘
        computerScrollView.ensureEnoughSpaceForCardEdges()
        
        // 从左侧开始排列卡牌 - 确保第一张牌完全显示
        var xPos: CGFloat = cardWidth/2
        
        // 定位每张牌
        for (index, cardNode) in sortedNodes.enumerated() {
            // 应用动态缩放 - 根据卡牌数量调整大小
            cardNode.adjustSize(forCardCount: count)
            
            cardNode.position = CGPoint(x: xPos, y: 0)
            xPos += cardWidthWithSpacing
            
            // 确保电脑的牌不可交互
            cardNode.isUserInteractionEnabled = false
            
            // 添加到滚动内容节点
            computerScrollView.contentNode.addChild(cardNode)
        }
        
        // 使内容居中显示 - 关键修改
        computerScrollView.centerContent()
    }
    
    // MARK: - Combo Detection and Handling
    
    private func checkForCombos() {
        // 在组合检查开始之前，确保禁用选牌
        isSelectionEnabled = false
        
        // 关键修复：如果玩家和电脑的牌数量差距太大，强制平衡
        if playerDealsCount > computerDealsCount + 1 {
            // 玩家比电脑多太多牌，强制切换到电脑
            isPlayerTurn = false
            comboCheckInProgress = false
            needsBalancing = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.dealCard()
            }
            return
        }
        
        if computerDealsCount > playerDealsCount + 1 {
            // 电脑比玩家多太多牌，强制切换到玩家
            isPlayerTurn = true
            comboCheckInProgress = false
            needsBalancing = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.dealCard()
            }
            return
        }
        
        // 关键修复：如果是第三轮而电脑还没收到牌，直接切换到电脑回合并发牌
        if roundNumber >= 3 && computerDealsCount == 0 && isPlayerTurn {
            isPlayerTurn = false
            
            // 直接跳过组合检查，立即给电脑发牌
            comboCheckInProgress = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.dealCard()
            }
            return
        }
        
        // Different logic based on whose turn it is
        if !isPlayerTurn {
            // Computer's turn - check for computer combos
            let computerCombos = ComboHelper.findCombinations(in: computerHand)
            
            if !computerCombos.isEmpty {
                comboCheckInProgress = true
                
                // Show notification
                gameDelegate?.showNotification("Computer found a combination!", duration: 2.0)
                
                // Highlight combo cards
                highlightComputerCombo(computerCombos[0])
                
                // Remove combo after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.removeComputerCombo(computerCombos[0])
                }
                return
            } else {
                // No computer combos - switch to player's turn
                isPlayerTurn = true
                
                // Deal to player after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    
                    // 修复：确保回合状态正确设置为玩家回合
                    if !self.isPlayerTurn {
                        self.isPlayerTurn = true
                    }
                    self.dealCard()
                }
                return
            }
        } else {
            // Player's turn - check if they can form combinations
            if playerHand.count >= 3 {
                startPlayerSelectionPhase()
            } else {
                // Not enough cards for player to make a combo
                isPlayerTurn = false
                
                // Deal to computer after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    
                    // 确保正确设置为电脑回合
                    if self.isPlayerTurn {
                        self.isPlayerTurn = false
                    }
                    self.dealCard()
                }
                return
            }
        }
    }
    
    private func startPlayerSelectionPhase() {
        // 清除之前的所有选择
        clearAllSelections()
        
        // 设置组合检查状态
        comboCheckInProgress = true
        
        // 启用选择功能
        isSelectionEnabled = true
        
        // 确保所有玩家卡牌可交互
        updateAllCardsInteractionState(enabled: true)
        
        // 显示选择提示
        gameDelegate?.showNotification("Select cards to form a combination", duration: 2.0)
        
        // Find potential combos
        let playerCombos = ComboHelper.findCombinations(in: playerHand)
        
        if !playerCombos.isEmpty {
            // Highlight a recommended combo
            highlightPlayerCombo(playerCombos[0])
            
            // Get combo type and score
            let combo = playerCombos[0]
            let comboType = checkComboType(cards: combo)
            let score = comboType == .sequence ? sequenceScore : tripletScore
            
            gameDelegate?.startPlayerSelectionPhase(hasRecommendedCombo: true, 
                                                   comboType: comboType.rawValue,
                                                   comboScore: score)
        } else {
            gameDelegate?.startPlayerSelectionPhase(hasRecommendedCombo: false, 
                                                   comboType: nil,
                                                   comboScore: nil)
        }
    }
    
    private func checkComboType(cards: [Card]) -> ComboType {
        let result = ComboHelper.checkCombo(cards: cards)
        return result.type ?? .sequence
    }
    
    private func highlightPlayerCombo(_ combo: [Card]) {
        // Clear any previous selection
        playerCardNodes.forEach { $0.isSelected = false }
        
        // Highlight recommended combo
        for cardNode in playerCardNodes {
            if combo.contains(where: { $0.id == cardNode.card.id }) {
                cardNode.isSelected = true
                cardNode.pulse()
            }
        }
    }
    
    private func highlightComputerCombo(_ combo: [Card]) {
        for cardNode in computerCardNodes {
            if combo.contains(where: { $0.id == cardNode.card.id }) {
                cardNode.pulse()
            }
        }
    }
    
    // MARK: - Selection Management
    
    func setSelectionEnabled(_ enabled: Bool) {
        isSelectionEnabled = enabled
        
        // 更新所有玩家卡牌的交互状态 - 根据游戏阶段设置
        for cardNode in playerCardNodes {
            cardNode.isUserInteractionEnabled = enabled && isPlayerTurn && comboCheckInProgress
        }
    }
    
    func clearAllSelections() {
        // Clear all selected cards
        playerCardNodes.forEach { $0.isSelected = false }
    }

    // MARK: - Card Selection
    
    func cardWasTapped(_ cardNode: CardNode) {
        // 验证卡牌是否属于玩家 - 防止选择电脑的牌
        if !playerCardNodes.contains(where: { $0 === cardNode }) {
            return
        }
        
        // 确保在组合检查阶段（玩家选牌阶段）才能选牌
        if !comboCheckInProgress || !isPlayerTurn {
            // 在发牌阶段或不是玩家回合，告知玩家等待
            gameDelegate?.showNotification("Please wait for your turn", duration: 1.0)
            return
        }
        
        // 确保允许选择卡牌
        if !isSelectionEnabled {
            gameDelegate?.showNotification("Selection not allowed yet", duration: 1.0)
            return
        }
        
        // Play card tap sound
        soundManager.playSound(.cardTap)
        
        // 获取当前已选择的卡牌数量
        let currentSelectionCount = playerCardNodes.filter { $0.isSelected }.count
        
        // 切换卡牌选择状态
        cardNode.isSelected = !cardNode.isSelected
        
        // 重新计算选择卡牌的数量
        let newSelectionCount = playerCardNodes.filter { $0.isSelected }.count
        
        // 显示选择提示
        if newSelectionCount < 3 {
            gameDelegate?.showNotification("Select \(3 - newSelectionCount) more cards", duration: 1.0)
            // 未达到3张牌，不进行验证
            gameDelegate?.playerDidSelectInvalidCombo()
            return
        }
        
        // 只有当选择了刚好3张牌时才进行验证
        if newSelectionCount == 3 {
            // 获取所有选中的牌
            let selectedNodes = playerCardNodes.filter { $0.isSelected }
            
            // 验证组合
            let selectedCards = selectedNodes.map { $0.card }
            let result = ComboHelper.checkCombo(cards: selectedCards)
            
            if result.isValid, let type = result.type {
                // 有效组合
                gameDelegate?.playerDidSelectValidCombo(comboType: type.rawValue, score: type.scoreValue)
            } else {
                // 无效组合 - 显示错误信息
                gameDelegate?.showNotification(result.message, duration: 1.5)
                gameDelegate?.playerDidSelectInvalidCombo()
            }
        } else if newSelectionCount > 3 {
            // 选择超过3张牌，显示错误提示
            gameDelegate?.showNotification("Please select exactly 3 cards", duration: 1.5)
            // 可以保持选择状态，让玩家自己取消多余的选择
        }
    }
    
    // MARK: - Combo Validation
    
    func validateSelectedCombination() -> Bool {
        // Get selected cards
        let selectedNodes = playerCardNodes.filter { $0.isSelected }
        
        // Check if exactly 3 cards are selected
        guard selectedNodes.count == 3 else {
            gameDelegate?.showNotification("Please select exactly 3 cards", duration: 2.0)
            return false
        }
        
        // Validate the combination
        let selectedCards = selectedNodes.map { $0.card }
        let result = ComboHelper.checkCombo(cards: selectedCards)
        
        // Return validation result
        return result.isValid
    }
    
    // MARK: - Combo Removal
    
    func removeSelectedCombination() {
        // Get selected cards
        let selectedNodes = playerCardNodes.filter { $0.isSelected }
        
        if selectedNodes.count != 3 {
            soundManager.playSound(.error)
            return
        }
        
        // Validate the combination
        let selectedCards = selectedNodes.map { $0.card }
        let result = ComboHelper.checkCombo(cards: selectedCards)
        
        if !result.isValid {
            soundManager.playSound(.error)
            return
        }
        
        guard let comboType = result.type else { 
            return 
        }
        
        // Play success sound
        soundManager.playSound(comboType == .sequence ? .sequence : .triplet)
        
        // Determine score
        let score = comboType == .sequence ? sequenceScore : tripletScore
        
        // Animate removing cards
        var removedCount = 0
        for cardNode in selectedNodes {
            // Find and remove card from player hand
            if let index = playerHand.firstIndex(where: { $0.id == cardNode.card.id }) {
                playerHand.remove(at: index)
            }
            
            // Remove from nodes array
            if let index = playerCardNodes.firstIndex(where: { $0 === cardNode }) {
                playerCardNodes.remove(at: index)
            }
            
            // Animate removal
            cardNode.animateRemove {
                removedCount += 1
                
                // When all cards are removed
                if removedCount == selectedNodes.count {
                    // Update player score
                    self.playerScore += score
                    self.gameDelegate?.playerScoreDidChange(newScore: self.playerScore)
                    
                    // Show notification
                    self.gameDelegate?.showNotification("Removed \(comboType.rawValue), gained \(score) points!", duration: 1.5)
                    
                    // Reposition remaining cards
                    self.positionPlayerCards()
                    
                    // Hide controls
                    self.gameDelegate?.hidePlayerControls()
                    
                    // Check if game should end
                    if self.playerHand.isEmpty {
                        self.endGame(playerWon: true)
                        return
                    }
                    
                    // Continue game
                    self.comboCheckInProgress = false
                    
                    // 设置为电脑回合
                    self.isPlayerTurn = false
                    
                    // 更新回合计数
                    self.roundNumber += 1
                    
                    // Deal next card after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        // 确保是电脑回合
                        if self.isPlayerTurn {
                            self.isPlayerTurn = false
                        }
                        self.dealCard()
                    }
                }
            }
        }
    }
    
    private func removeComputerCombo(_ combo: [Card]) {
        // Determine combo type and score
        let comboType = checkComboType(cards: combo)
        let score = comboType == .sequence ? sequenceScore : tripletScore
        
        // Play computer success sound
        soundManager.playSound(.computerCombo)
        
        // Find nodes to remove
        let nodesToRemove = computerCardNodes.filter { node in
            combo.contains { $0.id == node.card.id }
        }
        
        // Animate removing cards
        var removedCount = 0
        for cardNode in nodesToRemove {
            // Find and remove card from computer hand
            if let index = computerHand.firstIndex(where: { $0.id == cardNode.card.id }) {
                computerHand.remove(at: index)
            }
            
            // Remove from nodes array
            if let index = computerCardNodes.firstIndex(where: { $0 === cardNode }) {
                computerCardNodes.remove(at: index)
            }
            
            // Animate removal
            cardNode.animateRemove {
                removedCount += 1
                
                // When all cards are removed
                if removedCount == nodesToRemove.count {
                    // Update computer score
                    self.computerScore += score
                    self.gameDelegate?.computerScoreDidChange(newScore: self.computerScore)
                    
                    // Show notification
                    self.gameDelegate?.showNotification("Computer removed \(comboType.rawValue), gained \(score) points!", duration: 1.5)
                    
                    // Reposition remaining cards
                    self.positionComputerCards()
                    
                    // Check if game should end
                    if self.computerHand.isEmpty {
                        self.endGame(playerWon: false)
                        return
                    }
                    
                    // Continue game
                    self.comboCheckInProgress = false
                    
                    // 设置为玩家回合
                    self.isPlayerTurn = true
                    
                    // 更新回合计数
                    self.roundNumber += 1
                    
                    // Deal next card after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        // 确保是玩家回合
                        if !self.isPlayerTurn {
                            self.isPlayerTurn = true
                        }
                        self.dealCard()
                    }
                }
            }
        }
    }
    
    func skipCombination() {
        // Play skip sound
        soundManager.playSound(.skip)
        
        // Clear selection
        playerCardNodes.forEach { $0.isSelected = false }
        
        // Hide controls
        gameDelegate?.hidePlayerControls()
        
        // Show notification
        gameDelegate?.showNotification("Skipped combination", duration: 1.0)
        
        // Continue game
        comboCheckInProgress = false
        
        // 设置为电脑回合
        self.isPlayerTurn = false
        
        // 更新回合计数
        self.roundNumber += 1
        
        // Deal next card after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // 关键修复：如果是第三轮而电脑还没收到牌，强制确保这次给电脑发牌
            if self.roundNumber >= 3 && self.computerDealsCount == 0 {
                self.isPlayerTurn = false
            }
            
            self.dealCard()
        }
    }
    
    // MARK: - Game End
    
    private func endGame(playerWon: Bool? = nil) {
        gameActive = false
        
        // Play game end sound
        if let playerWon = playerWon {
            soundManager.playSound(playerWon ? .win : .lose)
        } else if playerScore > computerScore {
            soundManager.playSound(.win)
        } else if playerScore < computerScore {
            soundManager.playSound(.lose)
        } else {
            soundManager.playSound(.draw)
        }
        
        // Determine winner and rewards
        var earnedCoins = 0
        
        if let playerWon = playerWon {
            // Specific win condition
            earnedCoins = playerWon ? 300 : 0
        } else {
            // Compare scores
            if playerScore > computerScore {
                earnedCoins = 200
            } else if playerScore == computerScore {
                earnedCoins = 100
            }
        }
        
        // Notify delegate
        gameDelegate?.gameDidEnd(playerWon: playerWon, playerCoins: earnedCoins)
    }
    
    // Handle when the timer expires
    func timeExpired() {
        if comboCheckInProgress {
            // Skip the current selection
            skipCombination()
        }
    }
    
    // Returns the number of cards currently selected by the player
    func getSelectedCardCount() -> Int {
        return playerCardNodes.filter { $0.isSelected }.count
    }
    
    // 修复和增强的更新卡牌交互状态方法
    private func updateAllCardsInteractionState(enabled: Bool) {
        for cardNode in playerCardNodes {
            // 只有在以下条件全部满足时允许交互:
            // 1. 传入的启用参数为true
            // 2. 当前是玩家回合
            // 3. 处于组合检查阶段（玩家选牌阶段）
            // 4. 允许选择状态为true
            cardNode.isUserInteractionEnabled = enabled && isPlayerTurn && comboCheckInProgress && isSelectionEnabled
            
            // 重要：确保视觉状态正确更新
            cardNode.updateSelectionState()
        }
        
        // 确保电脑卡牌始终不可交互
        for cardNode in computerCardNodes {
            cardNode.isUserInteractionEnabled = false
        }
    }
} 
