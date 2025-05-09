import Foundation

protocol GameSceneDelegate: AnyObject {
    // Game lifecycle events
    func gameDidStart()
    func gameDidEnd(playerWon: Bool?, playerCoins: Int)
    
    // UI updates
    func updateRemainingCards(count: Int)
    func updateScoreDisplay()
    func playerScoreDidChange(newScore: Int)
    func computerScoreDidChange(newScore: Int)
    
    // Player interaction
    func startPlayerSelectionPhase(hasRecommendedCombo: Bool, comboType: String?, comboScore: Int?)
    func playerDidSelectValidCombo(comboType: String, score: Int)
    func playerDidSelectInvalidCombo()
    func hidePlayerControls()
    
    // Notifications
    func showNotification(_ message: String, duration: TimeInterval)
} 