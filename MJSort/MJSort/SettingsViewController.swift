import UIKit

class SettingsViewController: UIViewController {
    
    // UI Elements
    private var titleLabel: UILabel!
    private var tableView: UITableView!
    private var closeButton: UIButton!
    
    // Settings options
    private let settingsOptions = ["Game Rules", "Privacy Policy", "Feedback"]
    
    // Sound manager
    private let soundManager = SoundManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Set background
        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        
        // 添加背景图片
        addBackgroundImage()
        
        // Title
        titleLabel = UILabel()
        titleLabel.text = "Settings"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        titleLabel.layer.shadowOpacity = 0.5
        titleLabel.layer.shadowRadius = 2
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Table view
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.clear
        tableView.separatorColor = UIColor.white.withAlphaComponent(0.3)
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
        
        // 添加表格半透明背景
        let tableBackground = UIView(frame: .zero)
        tableBackground.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        tableBackground.layer.cornerRadius = 10
        view.addSubview(tableBackground)
        tableBackground.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableBackground.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
        ])
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
        ])
        
        // Close button
        closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
        closeButton.layer.cornerRadius = 15
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 120),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Load sound preferences
        soundManager.loadSoundPreferences()
    }
    
    // 添加背景图片
    private func addBackgroundImage() {
        // 创建背景图片视图
        let backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.image = UIImage(named: "mahjong_settings_bg")
        backgroundImageView.contentMode = .scaleAspectFill
        
        // 添加到视图最底层
        view.insertSubview(backgroundImageView, at: 0)
        
        // 设置自动布局约束
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 添加半透明深色蒙版，使文字更容易读取
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.insertSubview(overlayView, at: 1)
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true) {
            self.soundManager.playSound(.buttonTap)
        }
    }
    
    @objc private func soundSwitchChanged(_ sender: UISwitch) {
        soundManager.setSoundEnabled(sender.isOn)
        
        // Play a test sound if turned on
        if sender.isOn {
            soundManager.playSound(.buttonTap)
        }
    }
    
    // MARK: - Helper Methods
    
    private func showGameRules() {
        soundManager.playSound(.buttonTap)
        let rulesVC = ContentViewController()
        rulesVC.titleText = "Game Rules"
        rulesVC.contentText = """
        [Mahjong Elimination] Game Rules:

        1. The game uses Mahjong tiles 1-9 in three suits (Wan, Tiao, Tong), with 4 of each, totaling 108 tiles.
        
        2. At the start of the game, players pay a fee of 100 coins.
        
        3. Players and the computer take turns drawing one card from the deck.
        
        4. After drawing, the system checks for the following combinations:
           - Sequence: Three consecutive tiles of the same suit (e.g., 123 Wan)
           - Triplet: Three identical tiles (e.g., 333 Tong)
        
        5. When combinations are found:
           - The computer automatically removes them
           - Players can choose to remove or skip
           - Removing a sequence earns 200 points
           - Removing a triplet earns 300 points
        
        6. Game ending conditions:
           - Either side uses all their tiles
           - The deck is empty and no more combinations can be made
        
        7. Rewards:
           - Player wins: Receive 100 coins
           - Draw: Higher score wins
        """
        
        present(rulesVC, animated: true)
    }
    
    private func showPrivacyPolicy() {
        soundManager.playSound(.buttonTap)
        let privacyVC = ContentViewController()
        privacyVC.titleText = "Privacy Policy"
        privacyVC.contentText = """
        [Mahjong Elimination] Privacy Policy

        This game respects and protects all users' personal privacy.

        Information Collection:
        - This game does not collect any personal information
        - Game data like coins and scores are stored locally on your device
        - No data is uploaded to any server

        Data Usage:
        - Locally stored game data is only used to save game progress
        - It is not used for any other purpose

        Third-Party Sharing:
        - No user data is shared with any third parties

        Data Security:
        - This game makes every effort to protect user data security
        
        If you have any questions about the privacy policy, please contact us through the feedback feature.
        """
        
        present(privacyVC, animated: true)
    }
    
    private func showFeedback() {
        soundManager.playSound(.buttonTap)
        let alert = UIAlertController(title: "Feedback", message: "Please describe any issues or suggestions", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Enter your feedback..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            guard let feedback = alert.textFields?.first?.text, !feedback.isEmpty else {
                self?.showErrorAlert(message: "Please enter feedback content")
                return
            }
            
            // Here you would normally send the feedback to a server
            self?.showThankYouAlert()
        })
        
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showThankYouAlert() {
        let alert = UIAlertController(title: "Thank You", message: "Thank you for your feedback! We will read every comment carefully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TableView Delegate & DataSource

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.text = settingsOptions[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        cell.textLabel?.textColor = UIColor.white
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.clear
        cell.tintColor = UIColor.white // 箭头颜色
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        switch indexPath.row {
        case 0: // Game Rules
            showGameRules()
        case 1: // Privacy Policy
            showPrivacyPolicy()
        case 2: // Feedback
            showFeedback()
        default:
            break
        }
    }
}

// MARK: - Switch Cell

class SwitchTableViewCell: UITableViewCell {
    
    let switchControl = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add switch to content view
        contentView.addSubview(switchControl)
        
        // Configure switch position
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Content View Controller

class ContentViewController: UIViewController {
    
    var titleText: String = ""
    var contentText: String = ""
    
    private var scrollView: UIScrollView!
    private var contentLabel: UILabel!
    private var closeButton: UIButton!
    private let soundManager = SoundManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0)
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Scroll view for content
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70)
        ])
        
        // Content
        contentLabel = UILabel()
        contentLabel.text = contentText
        contentLabel.font = UIFont.systemFont(ofSize: 17)
        contentLabel.textColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        
        scrollView.addSubview(contentLabel)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Close button
        closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
        closeButton.layer.cornerRadius = 15
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 120),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true) {
            self.soundManager.playSound(.buttonTap)
        }
    }
} 
