import SpriteKit

protocol CardScrollViewDelegate: AnyObject {
    func cardScrollViewDidSelectCard(_ scrollView: CardScrollView, cardNode: CardNode)
}

class CardScrollView: SKNode {
    // 可见区域
    private var maskNode: SKCropNode
    private var shapeNode: SKShapeNode
    
    // 内容容器
    var contentNode: SKNode
    
    // 内容尺寸
    var contentSize: CGSize = .zero {
        didSet {
            updateContentSize()
        }
    }
    
    // 可见尺寸
    var viewSize: CGSize
    
    // 滚动指示器
    private var scrollIndicator: SKShapeNode?
    
    // 滚动状态
    private var isDragging = false
    private var lastTouchPosition: CGPoint = .zero
    private var scrollVelocity: CGFloat = 0
    private var lastUpdateTime: TimeInterval = 0
    private var isDecelerating = false
    
    // 相关配置
    var isComputerView = false
    
    // 委托
    weak var delegate: CardScrollViewDelegate?
    
    init(size: CGSize) {
        viewSize = size
        
        // 创建遮罩节点
        maskNode = SKCropNode()
        
        // 创建遮罩形状
        shapeNode = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height), cornerRadius: 8)
        shapeNode.fillColor = .white
        shapeNode.strokeColor = UIColor.clear
        shapeNode.lineWidth = 2
        
        // 内容节点
        contentNode = SKNode()
        
        super.init()
        
        // 设置遮罩
        maskNode.maskNode = shapeNode
        addChild(maskNode)
        
        // 添加内容节点到遮罩节点
        maskNode.addChild(contentNode)
        
        // 设置用户交互
        isUserInteractionEnabled = true
        
        // 为了确保正确显示，添加背景
        let background = SKShapeNode(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height), cornerRadius: 8)
        background.fillColor = UIColor.black.withAlphaComponent(0.3)
        background.strokeColor = UIColor.gray.withAlphaComponent(0.3)
        background.lineWidth = 2
        background.zPosition = -10 // 确保在内容之后
        maskNode.addChild(background)
        
        // 不再添加滚动指示器
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Add more padding to content size to ensure last card is fully visible
    func ensureEnoughSpaceForCardEdges() {
        // 增加额外的边距，确保更多张牌都能显示
        let extraPadding: CGFloat = CardNode.cardSize.width * 4.0
        
        // Apply padding if needed
        if contentSize.width > viewSize.width {
            let newWidth = contentSize.width + extraPadding
            contentSize = CGSize(width: newWidth, height: contentSize.height)
        } else {
            // 即使内容不够宽，也确保有足够的滚动空间
            contentSize = CGSize(width: viewSize.width * 1.5, height: contentSize.height)
        }
    }
    
    // 更新内容尺寸
    private func updateContentSize() {
        // 确保内容不小于视图尺寸，额外增加宽度用于超大数量的卡牌
        let minWidth = max(contentSize.width, viewSize.width * 1.5)
        
        // 如果内容尺寸变化，更新滚动指示器
        updateScrollIndicator()
    }
    
    // 设置滚动指示器 - 空方法，不再使用滚动指示器
    private func setupScrollIndicator() {
        // 移除现有的指示器
        scrollIndicator?.removeFromParent()
        scrollIndicator = nil
    }
    
    // 更新滚动指示器 - 空方法实现，不再显示指示器
    func updateScrollIndicator() {
        // 不执行任何操作，保持方法接口兼容
    }
    
    // MARK: - 滚动处理
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // 停止任何正在进行的动画
        contentNode.removeAllActions()
        scrollIndicator?.removeAllActions()
        isDecelerating = false
        
        // 记录触摸起始位置
        lastTouchPosition = touch.location(in: self)
        isDragging = true
        scrollVelocity = 0
        lastUpdateTime = touch.timestamp
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, let touch = touches.first else { return }
        
        // 计算移动距离
        let currentPosition = touch.location(in: self)
        let deltaX = currentPosition.x - lastTouchPosition.x
        
        // 仅当有足够的水平移动时才触发滚动，避免干扰点击
        if abs(deltaX) >= 3.0 {
            // 应用滚动
            scrollContent(deltaX: deltaX)
            
            // 通知子节点这是滚动行为，防止触发卡牌选择
            for child in contentNode.children {
                if let cardNode = child as? CardNode {
                    cardNode.touchMoved = true
                }
            }
            
            // 计算速度
            let deltaTime = touch.timestamp - lastUpdateTime
            if deltaTime > 0 {
                scrollVelocity = deltaX / CGFloat(deltaTime)
            }
            
            // 更新上次位置和时间
            lastTouchPosition = currentPosition
            lastUpdateTime = touch.timestamp
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // 确认是否是滚动操作结束，还是简单的点击
        let currentPosition = touch.location(in: self)
        let deltaX = abs(currentPosition.x - lastTouchPosition.x)
        
        // 如果有明显的水平移动，则处理为滚动结束
        if deltaX >= 5.0 {
            finishScrolling()
            
            // 拦截触摸事件，防止传递给卡牌节点
            return
        } else if isDragging {
            // 移动很小，但已经开始拖动，仍然作为滚动结束处理
            finishScrolling()
        }
        
        // 否则，这可能是简单的点击，让事件继续传递给子视图处理
        for child in contentNode.children where child.contains(touch.location(in: contentNode)) {
            if let cardNode = child as? CardNode, !cardNode.touchMoved {
                child.touchesEnded(touches, with: event)
                break
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishScrolling()
        
        // 重置所有卡片的触摸状态
        for child in contentNode.children {
            if let cardNode = child as? CardNode {
                cardNode.touchMoved = false
            }
        }
    }
    
    private func finishScrolling() {
        isDragging = false
        
        // 如果有足够的速度，启动减速效果
        if abs(scrollVelocity) > 100 {
            startDeceleration()
        } else {
            // 否则，检查是否需要弹回边界
            bounceBackIfNeeded()
            
            // 滚动结束后居中显示内容
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.centerContent()
            }
        }
    }
    
    private func scrollContent(deltaX: CGFloat) {
        var newX = contentNode.position.x + deltaX
        
        // 检查是否能滚动（内容宽度需大于视图宽度）
        if contentSize.width <= viewSize.width {
            contentNode.position.x = 0
            return
        }
        
        // 计算滚动范围
        // 为了确保所有卡牌都可见，增加最大滚动范围
        let minX = -(contentSize.width - viewSize.width)
        let maxX = 0.0
        
        // 应用边界弹性 - 当超出边界时提供更大的弹性效果
        if newX < minX {
            // 左边界弹性 - 增加弹性系数
            newX = minX + (newX - minX) * 0.5
        } else if newX > maxX {
            // 右边界弹性 - 增加弹性系数
            newX = maxX + (newX - maxX) * 0.5
        }
        
        // 应用新位置
        contentNode.position.x = newX
        
        // 更新滚动指示器
        updateScrollIndicator()
    }
    
    private func startDeceleration() {
        isDecelerating = true
        
        // 启动减速动画
        let action = SKAction.customAction(withDuration: 1.0) { [weak self] (node, elapsedTime) in
            guard let self = self, self.isDecelerating else { return }
            
            // 计算减速后的速度
            let deceleratedVelocity = self.scrollVelocity * (1.0 - elapsedTime)
            
            // 应用移动
            self.scrollContent(deltaX: deceleratedVelocity / 60) // 假设60fps
            
            // 检查是否应该停止减速
            if abs(deceleratedVelocity) < 10 || elapsedTime > 0.8 {
                self.isDecelerating = false
                self.bounceBackIfNeeded()
                
                // 减速结束后居中显示内容
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.centerContent()
                }
            }
        }
        
        contentNode.run(action)
    }
    
    private func bounceBackIfNeeded() {
        // 确保计算正确的边界
        let minX = -(contentSize.width - viewSize.width)
        let maxX = 0.0
        
        var targetX = contentNode.position.x
        var needsBounce = false
        
        // 检查是否超出边界
        if targetX < minX {
            // 超出左边界
            targetX = minX
            needsBounce = true
        } else if targetX > maxX {
            // 超出右边界
            targetX = maxX
            needsBounce = true
        }
        
        if needsBounce {
            // 创建平滑的弹回动画
            let bounceAction = SKAction.sequence([
                SKAction.moveTo(x: targetX, duration: 0.3),
                SKAction.moveTo(x: targetX + (contentNode.position.x - targetX) * 0.2, duration: 0.1),
                SKAction.moveTo(x: targetX, duration: 0.1)
            ])
            
            contentNode.run(bounceAction)
        }
    }

    // 居中显示内容
    func centerContent() {
        // 计算内容总宽度
        var minX: CGFloat = .greatestFiniteMagnitude
        var maxX: CGFloat = -.greatestFiniteMagnitude
        
        // 遍历所有卡牌节点找出左右边界
        for child in contentNode.children {
            let leftEdge = child.position.x - child.calculateAccumulatedFrame().width/2
            let rightEdge = child.position.x + child.calculateAccumulatedFrame().width/2
            
            minX = min(minX, leftEdge)
            maxX = max(maxX, rightEdge)
        }
        
        // 如果没有子节点，直接返回
        if minX == .greatestFiniteMagnitude || contentNode.children.isEmpty {
            contentNode.position.x = 0
            return
        }
        
        // 计算内容总宽度
        let contentWidth = maxX - minX
        
        // 如果内容宽度小于视图宽度，完全居中显示
        if contentWidth <= viewSize.width {
            // 计算内容的中心点
            let contentCenter = minX + contentWidth/2
            // 设置位置使内容居中
            contentNode.position.x = -contentCenter
        } else {
            // 如果内容宽度大于视图宽度，确保内容从左侧开始，且在视图中心位置的卡牌是对称的
            
            // 计算视图中心对应内容坐标系中的位置
            let viewCenterInContent = contentWidth/2
            
            // 根据卡牌数量调整居中策略
            let cardCount = contentNode.children.count
            
            // 设置内容位置，使视图中心与内容中心对齐
            contentNode.position.x = -viewCenterInContent + viewSize.width/2
            
            // 确保位置不超出边界
            let minX = -(contentWidth - viewSize.width)
            let maxX = 0.0
            
            contentNode.position.x = max(minX, min(maxX, contentNode.position.x))
        }
    }
}

// MARK: - GameScene作为CardScrollViewDelegate的扩展
extension GameScene: CardScrollViewDelegate {
    func cardScrollViewDidSelectCard(_ scrollView: CardScrollView, cardNode: CardNode) {
        // 处理卡牌选择
        if !scrollView.isComputerView {
            cardWasTapped(cardNode)
        }
    }
} 
