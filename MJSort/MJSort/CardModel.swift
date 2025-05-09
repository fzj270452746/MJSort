import Foundation
import SpriteKit

// MARK: - Card Suit & Colors

enum CardSuit: String, CaseIterable {
    case wan = "Wan"   // Characters
    case tiao = "Tiao" // Bamboo
    case tong = "Tong" // Circles
    
    var color: UIColor {
        switch self {
            case .wan: return UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
            case .tiao: return UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1.0)
            case .tong: return UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
        }
    }
    
    var displayName: String {
        return self.rawValue
    }
    
    var shortName: String {
        return String(self.rawValue.prefix(1))
    }
}

// MARK: - Card Model

struct Card: Equatable, Hashable {
    let suit: CardSuit
    let value: Int
    let id: UUID
    
    init(suit: CardSuit, value: Int) {
        self.suit = suit
        self.value = value
        self.id = UUID()
    }
    
    // Description for displaying on cards
    var description: String {
        return "\(value)"
    }
    
    // Full description for debugging
    var fullDescription: String {
        return "\(value)\(suit.shortName)"
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.suit == rhs.suit && lhs.value == rhs.value
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(suit)
        hasher.combine(value)
        hasher.combine(id)
    }
}

// MARK: - Combo Types

enum ComboType: String {
    case sequence = "Sequence" // Run
    case triplet = "Triplet"   // Set
    
    var scoreValue: Int {
        switch self {
            case .sequence: return 200
            case .triplet: return 300
        }
    }
}

// MARK: - Combo Validation

struct ComboResult {
    let isValid: Bool
    let type: ComboType?
    let message: String
    
    static func validSequence() -> ComboResult {
        return ComboResult(isValid: true, type: .sequence, message: "Valid sequence")
    }
    
    static func validTriplet() -> ComboResult {
        return ComboResult(isValid: true, type: .triplet, message: "Valid triplet")
    }
    
    static func invalid(message: String) -> ComboResult {
        return ComboResult(isValid: false, type: nil, message: message)
    }
}

// MARK: - Combo Helper

class ComboHelper {
    // Checks if 3 cards form a valid combo (sequence or triplet)
    static func checkCombo(cards: [Card]) -> ComboResult {
        guard cards.count == 3 else {
            return .invalid(message: "Need exactly 3 cards")
        }
        
        // Check if it's a triplet (3 cards with same value and suit)
        if isTriplet(cards: cards) {
            return .validTriplet()
        }
        
        // Check if it's a sequence (3 consecutive values of the same suit)
        if isSequence(cards: cards) {
            return .validSequence()
        }
        
        // Provide more specific error messages
        // Check if all cards have the same suit
        let firstSuit = cards[0].suit
        if !cards.allSatisfy({ $0.suit == firstSuit }) {
            return .invalid(message: "All cards must be of the same suit")
        }
        
        // Sort cards by value
        let sortedCards = cards.sorted { $0.value < $1.value }
        
        // Check if values might be a sequence but with gaps
        if sortedCards[2].value - sortedCards[0].value <= 4 {
            return .invalid(message: "Cards must be consecutive values")
        }
        
        // Check if all values are same (but different suits)
        if sortedCards[0].value == sortedCards[1].value && sortedCards[1].value == sortedCards[2].value {
            // This is actually a valid triplet in our modified rules
            return .validTriplet()
        }
        
        // General error
        return .invalid(message: "Not a valid sequence or triplet")
    }
    
    // Check if cards form a triplet (same value and suit)
    private static func isTriplet(cards: [Card]) -> Bool {
        guard cards.count == 3 else { return false }
        
        // All cards must have the same value (but can be different suits)
        let firstValue = cards[0].value
        return cards.allSatisfy { card in
            card.value == firstValue
        }
    }
    
    // Check if cards form a sequence (consecutive values of same suit)
    private static func isSequence(cards: [Card]) -> Bool {
        guard cards.count == 3 else { return false }
        
        // All cards must have the same suit
        let firstSuit = cards[0].suit
        guard cards.allSatisfy({ $0.suit == firstSuit }) else {
            return false
        }
        
        // Sort by value
        let sortedCards = cards.sorted { $0.value < $1.value }
        
        // Check if values are consecutive
        return sortedCards[1].value == sortedCards[0].value + 1 &&
               sortedCards[2].value == sortedCards[1].value + 1
    }
    
    // Find valid combinations in a hand
    static func findCombinations(in hand: [Card]) -> [[Card]] {
        var combinations: [[Card]] = []
        
        // Find triplets
        let triplets = findTriplets(in: hand)
        combinations.append(contentsOf: triplets)
        
        // Find sequences
        let sequences = findSequences(in: hand)
        combinations.append(contentsOf: sequences)
        
        return combinations
    }
    
    // Find all triplets in a hand
    private static func findTriplets(in hand: [Card]) -> [[Card]] {
        var triplets: [[Card]] = []
        let suits = CardSuit.allCases
        
        for suit in suits {
            let cardsOfSuit = hand.filter { $0.suit == suit }
            
            // Group by value
            let valueGroups = Dictionary(grouping: cardsOfSuit) { $0.value }
            
            // Find groups with at least 3 cards
            for (_, cards) in valueGroups where cards.count >= 3 {
                // Only take the first 3 cards
                triplets.append(Array(cards.prefix(3)))
            }
        }
        
        return triplets
    }
    
    // Find all sequences in a hand
    private static func findSequences(in hand: [Card]) -> [[Card]] {
        var sequences: [[Card]] = []
        let suits = CardSuit.allCases
        
        for suit in suits {
            let cardsOfSuit = hand.filter { $0.suit == suit }
            
            // Too few cards for a sequence
            if cardsOfSuit.count < 3 { continue }
            
            // Create a dictionary to find cards by value
            let cardsByValue = Dictionary(grouping: cardsOfSuit) { $0.value }
            
            // Iterate through potential starting values (1-7, since we need 3 consecutive values)
            for startValue in 1...7 {
                if let first = cardsByValue[startValue]?.first,
                   let second = cardsByValue[startValue + 1]?.first,
                   let third = cardsByValue[startValue + 2]?.first {
                    sequences.append([first, second, third])
                }
            }
        }
        
        return sequences
    }
} 