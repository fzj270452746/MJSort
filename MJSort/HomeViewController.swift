import UIKit

class HomeViewController: UIViewController {
    
    // UI Elements
    private var titleLabel: UILabel!
    private var startButton: UIButton!
    private var coinsLabel: UILabel!
    private var settingsButton: UIButton!
    
    // Sound manager
    private let soundManager = SoundManager.shared
    
    // Game state
    private var coins: Int = 2000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load saved coins
        if let savedCoins = UserDefaults.standard.object(forKey: "mjSortCoins") as? Int {
            coins = savedCoins
        }
        
        // Load sound preferences
        soundManager.loadSoundPreferences()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update coins when returning to this screen
        if let savedCoins = UserDefaults.standard.object(forKey: "mjSortCoins") as? Int {
            coins = savedCoins
            coinsLabel.text = "Coins: \(coins)"
        }
    }
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .landscape
//    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Set background
        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        
        // 添加主背景图片
        addBackgroundImage()
        
        // Add decorative background elements
        setupBackgroundElements()
        
        // Title label
        titleLabel = UILabel()
        titleLabel.text = "Mahjong Elimination"
        titleLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        titleLabel.layer.shadowOpacity = 0.7
        titleLabel.layer.shadowRadius = 4
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ])
        
        // Start button
        startButton = createButton(title: "Start Game", color: UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0))
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Coins label
        coinsLabel = UILabel()
        coinsLabel.text = "Coins: \(coins)"
        coinsLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        coinsLabel.textColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1.0)
        coinsLabel.textAlignment = .center
        coinsLabel.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 0.7)
        coinsLabel.layer.cornerRadius = 20
        coinsLabel.layer.masksToBounds = true
        
        view.addSubview(coinsLabel)
        coinsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coinsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            coinsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            coinsLabel.widthAnchor.constraint(equalToConstant: 150),
            coinsLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Settings button
        settingsButton = createButton(title: "Settings", color: UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0))
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        
        view.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 50),
            settingsButton.widthAnchor.constraint(equalToConstant: 200),
            settingsButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // 添加漂亮的背景图片
    private func addBackgroundImage() {
        // 创建背景图片视图
        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: "mahjong_home_bg")
        backgroundImageView.contentMode = .scaleAspectFill
        
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
        
        // 添加渐变叠加层，使UI元素更加突出
        let gradientView = UIView(frame: view.bounds)
        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = view.bounds
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
    
    private func setupBackgroundElements() {
        // Create some decorative mahjong tiles in the background
        let suits = ["wan", "tiao", "tong"]
        let values = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        for _ in 0..<15 {
            // Create tile container view
            let tileView = UIView()
            tileView.backgroundColor = .clear
//            tileView.layer.cornerRadius = 8
//            tileView.layer.borderWidth = 1
//            tileView.layer.borderColor = UIColor.lightGray.cgColor
            
            // Add shadow
//            tileView.layer.shadowColor = UIColor.black.cgColor
//            tileView.layer.shadowOffset = CGSize(width: 3, height: 3)
//            tileView.layer.shadowOpacity = 0.2
//            tileView.layer.shadowRadius = 4
            
            // Random position
            let x = CGFloat.random(in: 50...(view.bounds.height - 100))
            let y = CGFloat.random(in: 50...(view.bounds.width - 100))
            let rotation = CGFloat.random(in: -0.3...0.3)
            
            tileView.frame = CGRect(x: x, y: y, width: 60, height: 80)
            tileView.transform = CGAffineTransform(rotationAngle: rotation)
            
            // Add actual mahjong tile image
            let randomSuit = suits.randomElement()!
            let randomValue = values.randomElement()!
            
            let tileImageView = UIImageView()
            tileImageView.contentMode = .scaleToFill
            tileImageView.image = UIImage(named: "\(randomSuit)_\(randomValue)")
            
            tileView.addSubview(tileImageView)
            tileImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tileImageView.topAnchor.constraint(equalTo: tileView.topAnchor),
                tileImageView.leadingAnchor.constraint(equalTo: tileView.leadingAnchor),
                tileImageView.trailingAnchor.constraint(equalTo: tileView.trailingAnchor),
                tileImageView.bottomAnchor.constraint(equalTo: tileView.bottomAnchor)
            ])
            
            // Add to background (behind other elements)
            view.addSubview(tileView)
//            view.sendSubviewToBack(tileView)
        }
    }
    
    private func createButton(title: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 15
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        // Add shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        
        return button
    }
    
    // MARK: - Actions
    
    @objc private func startButtonTapped() {
        soundManager.playSound(.buttonTap)
        
        // Check if player has enough coins
        let gameFee = 100
        
        if coins < gameFee {
            showAlert(title: "Not Enough Coins", message: "The game requires \(gameFee) coins, but you only have \(coins) coins.")
            soundManager.playSound(.error)
            return
        }
        
        // Deduct fee
        coins -= gameFee
        UserDefaults.standard.set(coins, forKey: "mjSortCoins")
        
        // Navigate to game screen
        let gameVC = GameViewController()
        gameVC.modalPresentationStyle = .fullScreen
        present(gameVC, animated: true)
    }
    
    @objc private func settingsButtonTapped() {
        soundManager.playSound(.buttonTap)
        
        let settingsVC = SettingsViewController()
        settingsVC.modalPresentationStyle = .pageSheet
        present(settingsVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 
