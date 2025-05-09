import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    // Game scene
    private var gameScene: GameScene?
    
    // Sound manager
    private let soundManager = SoundManager.shared
    
    // Game settings
    private let gameFee = 100
    private let sequenceScore = 200
    private let tripletScore = 300
    private let countdownTime = 10
    
    // Game state
    private var coins: Int = 1000
    private var playerScore: Int = 0
    private var computerScore: Int = 0
    private var isSelectionAllowed: Bool = false
    private var countdownSeconds: Int = 10
    private var countdownTimer: Timer?
    
    // UI Elements
    private var coinLabel: UILabel!
    private var playerScoreLabel: UILabel!
    private var computerScoreLabel: UILabel!
    private var remainingCardsLabel: UILabel!
    private var countdownLabel: UILabel!
    private var notificationLabel: UILabel!
    private var comboActionsView: UIView!
    private var combosFoundLabel: UILabel!
    private var removeComboButton: UIButton!
    private var skipComboButton: UIButton!
    private var exitButton: UIButton!
    private var backupRemoveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load saved coins
        if let savedCoins = UserDefaults.standard.object(forKey: "mjSortCoins") as? Int {
            coins = savedCoins
        }
        
        // Load sound preferences
        soundManager.loadSoundPreferences()
        
        setupUI()
        setupGame()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Set up view controller for landscape
        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        
        // 添加背景图片
        addBackgroundImage()
        
        // Create header view
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 0.7)
        headerView.layer.cornerRadius = 10
        view.addSubview(headerView)
        
        // Position header view
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            headerView.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        // Score labels
        playerScoreLabel = createLabel(text: "Player: 0", fontSize: 16)
        computerScoreLabel = createLabel(text: "Computer: 0", fontSize: 16)
        coinLabel = createLabel(text: "Coins: \(coins)", fontSize: 16)
        coinLabel.textColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1.0)
        remainingCardsLabel = createLabel(text: "Cards: 108", fontSize: 16)
        
        // Add labels to header
        let labelsStackView = UIStackView(arrangedSubviews: [playerScoreLabel, computerScoreLabel, coinLabel, remainingCardsLabel])
        labelsStackView.axis = .horizontal
        labelsStackView.distribution = .equalSpacing
        labelsStackView.spacing = 15
        
        headerView.addSubview(labelsStackView)
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelsStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            labelsStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -100), // Leave space for countdown
            labelsStackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        // Countdown label - moved to the right side of header
        countdownLabel = createLabel(text: "\(countdownTime)s", fontSize: 18)
        countdownLabel.textAlignment = .center
        countdownLabel.backgroundColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
        countdownLabel.textColor = .white
        countdownLabel.layer.cornerRadius = 15
        countdownLabel.layer.masksToBounds = true
        
        headerView.addSubview(countdownLabel)
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countdownLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            countdownLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            countdownLabel.widthAnchor.constraint(equalToConstant: 60),
            countdownLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        countdownLabel.isHidden = true
        
        // Exit button
        exitButton = createButton(title: "Exit", color: UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1.0))
        exitButton.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
        view.addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            exitButton.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            exitButton.widthAnchor.constraint(equalToConstant: 80),
            exitButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Notification label
        notificationLabel = createLabel(text: "", fontSize: 16)
        notificationLabel.textAlignment = .center
        notificationLabel.backgroundColor = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 0.9)
        notificationLabel.textColor = .white
        notificationLabel.layer.cornerRadius = 15
        notificationLabel.layer.masksToBounds = true
        notificationLabel.alpha = 0
        
        view.addSubview(notificationLabel)
        notificationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            notificationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notificationLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            notificationLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
            notificationLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Combo actions view
        comboActionsView = UIView()
        comboActionsView.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        comboActionsView.layer.cornerRadius = 10
        comboActionsView.isUserInteractionEnabled = true
        
        view.addSubview(comboActionsView)
        comboActionsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            comboActionsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            comboActionsView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            comboActionsView.widthAnchor.constraint(equalToConstant: 300),
            comboActionsView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        // Combo label
        combosFoundLabel = createLabel(text: "Select 3 cards to form a combination", fontSize: 16)
        combosFoundLabel.textAlignment = .center
        combosFoundLabel.numberOfLines = 0
        
        // Combo buttons
        removeComboButton = createButton(title: "Remove Combo", color: UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0))
        removeComboButton.addTarget(self, action: #selector(removeComboBtnTapped), for: .touchUpInside)
        removeComboButton.isUserInteractionEnabled = true
        
        skipComboButton = createButton(title: "Skip", color: UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1.0))
        skipComboButton.addTarget(self, action: #selector(skipComboBtnTapped), for: .touchUpInside)
        skipComboButton.isUserInteractionEnabled = true
        
        let buttonsStackView = UIStackView(arrangedSubviews: [removeComboButton, skipComboButton])
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 10
        buttonsStackView.isUserInteractionEnabled = true
        
        let comboStackView = UIStackView(arrangedSubviews: [combosFoundLabel, buttonsStackView])
        comboStackView.axis = .vertical
        comboStackView.spacing = 10
        comboStackView.distribution = .fillEqually
        comboStackView.isUserInteractionEnabled = true
        
        comboActionsView.addSubview(comboStackView)
        comboStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            comboStackView.topAnchor.constraint(equalTo: comboActionsView.topAnchor, constant: 10),
            comboStackView.leadingAnchor.constraint(equalTo: comboActionsView.leadingAnchor, constant: 10),
            comboStackView.trailingAnchor.constraint(equalTo: comboActionsView.trailingAnchor, constant: -10),
            comboStackView.bottomAnchor.constraint(equalTo: comboActionsView.bottomAnchor, constant: -10)
        ])
        
        comboActionsView.isHidden = true
    }
    
    // 添加背景图片的方法
    private func addBackgroundImage() {
        // 创建背景图片视图
        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: "mahjong_table_bg")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.7 // 设置透明度，避免背景过于突出
        
        // 添加到视图最底层
//        view.insertSubview(backgroundImageView, at: 0)
        view.addSubview(backgroundImageView)
        
        // 设置自动布局约束
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 可选：添加模糊效果
//        let blurEffect = UIBlurEffect(style: .light)
//        let blurView = UIVisualEffectView(effect: blurEffect)
//        blurView.alpha = 0.3
//        blurView.frame = view.bounds
//        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.addSubview(blurView)
        
        // 添加渐变叠加层，使UI元素更加突出
        let gradientView = UIView(frame: view.bounds)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        // 添加渐变层
//        view.insertSubview(gradientView, at: 1)
        view.addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func createLabel(text: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        label.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        // 添加文本阴影提高可读性
        label.shadowColor = UIColor.white.withAlphaComponent(0.5)
        label.shadowOffset = CGSize(width: 1, height: 1)
        return label
    }
    
    private func createButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 4
        
        return button
    }
    
    // MARK: - Game Setup
    
    private func setupGame() {
        // Create an SKView and add it to the view hierarchy
        let skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(skView, at: 2) // Insert at index 0 so UI elements appear on top
//        view.addSubview(skView)
        
        // Configure the view
        skView.ignoresSiblingOrder = true
        skView.allowsTransparency = true // 允许透明区域触摸穿透
        
//        #if DEBUG
//        skView.showsFPS = true
//        skView.showsNodeCount = true
//        #endif
        
        // Create and configure the scene
        let scene = GameScene(size: skView.bounds.size)
        gameScene = scene
        scene.gameDelegate = self
        scene.scaleMode = .aspectFill
        
        // Present the scene
        skView.presentScene(scene)
        
        // Initial UI updates
        updateScoreDisplay()
    }
    
    // MARK: - UI Actions
    
    @objc private func removeComboBtnTapped() {
        print("=== REMOVE COMBO BUTTON TAPPED ===")
        print("触发来源: \(Thread.callStackSymbols)")
        soundManager.playSound(.buttonTap)
        
        // 调试信息
        print("comboActionsView.isHidden = \(comboActionsView.isHidden)")
        print("removeComboButton.isEnabled = \(removeComboButton.isEnabled)")
        
        // Check if the selected combination is valid
        guard let gameScene = gameScene else { 
            print("Error: gameScene is nil!")
            return 
        }
        
        // Get current selection state
        let selectedCount = gameScene.getSelectedCardCount()
        print("Selected cards count: \(selectedCount)")
        
        if selectedCount != 3 {
            showNotification("Please select exactly 3 cards", duration: 2.0)
            print("Need to select 3 cards (current: \(selectedCount))")
            return
        }
        
        print("Validating selected combination...")
        if gameScene.validateSelectedCombination() {
            print("Combination validated - removing...")
            gameScene.removeSelectedCombination()
        } else {
            print("Combination validation failed!")
            showNotification("Not a valid combination", duration: 2.0)
        }
    }
    
    @objc private func skipComboBtnTapped() {
        print("=== SKIP BUTTON TAPPED ===")
        soundManager.playSound(.buttonTap)
        gameScene?.skipCombination()
    }
    
    @objc private func exitButtonTapped() {
        // Show confirmation dialog
        let alert = UIAlertController(title: "Exit Game", 
                                      message: "Are you sure you want to exit? Your progress will be lost.", 
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.soundManager.playSound(.buttonTap)
        })
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.soundManager.playSound(.buttonTap)
            }
        })
        
        soundManager.playSound(.buttonTap)
        present(alert, animated: true)
    }
    
    // MARK: - Helper Functions
    
    func showNotification(_ message: String, duration: TimeInterval = 2.0) {
        notificationLabel.text = message
        
        // Animate appearance
        UIView.animate(withDuration: 0.3, animations: {
            self.notificationLabel.alpha = 1.0
        }) { _ in
            // Animate disappearance after duration
            UIView.animate(withDuration: 0.3, delay: duration, options: [], animations: {
                self.notificationLabel.alpha = 0
            })
        }
    }
    
    func updateCoinDisplay() {
        coinLabel.text = "Coins: \(coins)"
        UserDefaults.standard.set(coins, forKey: "mjSortCoins")
    }
    
    // MARK: - Countdown
    
    private func startCountdown() {
        // Reset countdown
        countdownSeconds = countdownTime
        countdownLabel.text = "\(countdownSeconds)s"
        countdownLabel.isHidden = false
        
        // Enable card selection during countdown
        gameScene?.setSelectionEnabled(true)
        
        // Play countdown sound
        soundManager.playSound(.countdown)
        
        // Start timer
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    @objc private func updateCountdown() {
        countdownSeconds -= 1
        countdownLabel.text = "\(countdownSeconds)s"
        
        if countdownSeconds <= 3 {
            countdownLabel.textColor = .red
        }
        
        if countdownSeconds <= 0 {
            countdownTimer?.invalidate()
            countdownLabel.isHidden = true
            countdownLabel.textColor = .white
            gameScene?.timeExpired()
            gameScene?.setSelectionEnabled(false)
        }
    }
    
    func showComboActions(show: Bool, message: String = "") {
        print("=== SHOW COMBO ACTIONS ===")
        print("Show: \(show), Message: \(message)")
        
        comboActionsView.isHidden = !show
        if show && !message.isEmpty {
            combosFoundLabel.text = message
        }
        
        print("comboActionsView.isHidden = \(!show)")
    }
    
    // MARK: - Game End
    
    private func showGameEndDialog(playerWon: Bool?, playerCoins: Int) {
        var title = ""
        var message = ""
        
        if let playerWon = playerWon {
            if playerWon {
                title = "Victory!"
                message = "Congratulations! You won the game!\n\nPlayer Score: \(playerScore)\nComputer Score: \(computerScore)\n\nCoins Earned: \(playerCoins)"
                soundManager.playSound(.win)
            } else {
                title = "Defeat"
                message = "You lost the game.\n\nPlayer Score: \(playerScore)\nComputer Score: \(computerScore)\n\nBetter luck next time!"
                soundManager.playSound(.lose)
            }
        } else {
            if playerScore > computerScore {
                title = "Victory!"
                message = "You win by having a higher score!\n\nPlayer Score: \(playerScore)\nComputer Score: \(computerScore)\n\nCoins Earned: \(playerCoins)"
                soundManager.playSound(.win)
            } else if playerScore < computerScore {
                title = "Defeat"
                message = "You lost by having a lower score.\n\nPlayer Score: \(playerScore)\nComputer Score: \(computerScore)\n\nBetter luck next time!"
                soundManager.playSound(.lose)
            } else {
                title = "Draw"
                message = "The game ended in a draw.\n\nPlayer Score: \(playerScore)\nComputer Score: \(computerScore)\n\nCoins Earned: \(playerCoins)"
                soundManager.playSound(.draw)
            }
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play Again", style: .default) { [weak self] _ in
            self?.restartGame()
        })
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true) {
                self?.soundManager.playSound(.buttonTap)
            }
        })
        present(alert, animated: true)
    }
    
    private func restartGame() {
        // Reset the game scene
        if let skView = view.subviews.first(where: { $0 is SKView }) as? SKView {
            // Create and configure a new scene
            let scene = GameScene(size: skView.bounds.size)
            gameScene = scene
            scene.gameDelegate = self
            scene.scaleMode = .aspectFill
            
            // Present the new scene
            skView.presentScene(scene)
            
            // Reset UI
            playerScore = 0
            computerScore = 0
            updateScoreDisplay()
            
            // Hide any leftover UI elements
            comboActionsView.isHidden = true
            countdownLabel.isHidden = true
            
            // Show notification
            showNotification("New game started", duration: 1.5)
            
            // Play a sound
            soundManager.playSound(.shuffle)
        }
    }
}

// MARK: - GameSceneDelegate

extension GameViewController: GameSceneDelegate {
    func gameDidStart() {
        // Reset scores
        playerScore = 0
        computerScore = 0
        updateScoreDisplay()
        
        // Show notification
        showNotification("Game started! Your turn.")
    }
    
    func gameDidEnd(playerWon: Bool?, playerCoins: Int) {
        showGameEndDialog(playerWon: playerWon, playerCoins: playerCoins)
        
        // Update player's coins
        coins += playerCoins
        
        // Save coins
        UserDefaults.standard.set(coins, forKey: "mjSortCoins")
        
        // Update UI
        updateCoinDisplay()
    }
    
    func updateRemainingCards(count: Int) {
        remainingCardsLabel.text = "Cards: \(count)"
    }
    
    func updateScoreDisplay() {
        playerScoreLabel.text = "Player: \(playerScore)"
        computerScoreLabel.text = "Computer: \(computerScore)"
    }
    
    func playerScoreDidChange(newScore: Int) {
        playerScore = newScore
        updateScoreDisplay()
    }
    
    func computerScoreDidChange(newScore: Int) {
        computerScore = newScore
        updateScoreDisplay()
    }
    
    func startPlayerSelectionPhase(hasRecommendedCombo: Bool, comboType: String?, comboScore: Int?) {
        print("=== START PLAYER SELECTION PHASE ===")
        print("Has recommended combo: \(hasRecommendedCombo)")
        if let comboType = comboType, let comboScore = comboScore {
            print("Combo type: \(comboType), score: \(comboScore)")
        }
        
        // Show combo controls
        comboActionsView.isHidden = false
        print("Showing combo actions view")
        
        // Update labels based on whether we have a system-recommended combo
        if hasRecommendedCombo, let comboType = comboType, let comboScore = comboScore {
            combosFoundLabel.text = "Found \(comboType): \(comboScore) pts\nSelect to remove or skip"
            // Enable the button only for recommended combos initially
//            removeComboButton.isEnabled = false // Start with disabled, enable when player verifies the combination
            print("Setting combo label for recommended combo")
        } else {
            combosFoundLabel.text = "Select 3 cards to form a combination"
//            removeComboButton.isEnabled = false
            print("Setting combo label for manual selection")
        }
        
        // Show countdown
        countdownLabel.isHidden = false
        countdownLabel.text = "\(countdownTime)s"
        print("Starting countdown from \(countdownTime)s")
        
        // Start countdown animation
        startCountdown()
    }
    
    func playerDidSelectValidCombo(comboType: String, score: Int) {
        print("=== PLAYER SELECTED VALID COMBO ===")
        print("Combo type: \(comboType), score: \(score)")
        
        // Update UI
        comboActionsView.isHidden = false
        combosFoundLabel.text = "Valid \(comboType): \(score) pts\nReady to remove!"
        removeComboButton.isEnabled = true
        print("Enabled remove button")
        
        // Show notification
        showNotification("Valid \(comboType)! +\(score) points", duration: 1.5)
    }
    
    func playerDidSelectInvalidCombo() {
        print("=== PLAYER SELECTED INVALID COMBO ===")
        
        // Update UI with invalid selection message
        comboActionsView.isHidden = false
        combosFoundLabel.text = "Not a valid combination\nTry a different selection"
//        removeComboButton.isEnabled = false
        print("Disabled remove button")
    }
    
    func hidePlayerControls() {
        print("=== HIDING PLAYER CONTROLS ===")
        comboActionsView.isHidden = true
        countdownLabel.isHidden = true
        removeComboButton.isEnabled = true
    }
} 
