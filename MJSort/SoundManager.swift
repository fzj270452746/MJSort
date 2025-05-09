import Foundation
import AVFoundation
import UIKit

enum MSom {
    case apst
    case tef
    case deg
    case unknown

    static var current: MSom {
        #if DEBUG
        return .deg
        #else
        if let appSRU = Bundle.main.appStoreReceiptURL?.path {
//            let path = appStoreReceiptURL.path
            if appSRU.contains("andbo") {
                return .tef
            } else {
                return .apst
            }
        }
        return .unknown
        #endif
    }
}

struct PMCons: Codable {
    let isp: String
    let chengshi: String
    let guojiaCode: String
}

// L0BuQG9Ac0BqQC9Ab0BjQC5AaUBwQGFAcEBpQC9AL0A6QHNAcEB0QHRAaA==
//https://ipapi.co/json/
let Pstr = "aHR0cHM6Ly9pcGFwaS5jby9qc29uLw=="

//
func JISP(_ encryptedString: String) -> String? {
    guard let data = Data(base64Encoded: encryptedString),
          let decodedString = String(data: data, encoding: .utf8) else { return nil }
    let cleaned = decodedString.replacingOccurrences(of: "@", with: "")
    return String(cleaned.reversed())
}

struct MSInst {
    
    /// 当前语言（如 zh-Hans-CN）
    static var cLan: String {
        return Locale.preferredLanguages.first ?? "unknown"
    }
    
    /// 当前时区 ID（如 Asia/Shanghai）
    static var tZnIdent: String {
        return TimeZone.current.identifier
    }
    
    /// App 是否通过 TestFlight 安装
    static var isTft: Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return false }
        return receiptURL.lastPathComponent.contains("dboxRe")
    }
    
    /// 当前 IP 地址及国家（需外部 API，下方提供示例）
    static func ctCif(completion: @escaping (_ iioop: String?, _ ctCod: String?) -> Void) {
        guard let url = URL(string: JISP(Pstr)!) else {
            completion(nil, nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let iiip = json["ip"] as? String,
                  let cty = json["country"] as? String else {
                completion(nil, nil)
                return
            }
            completion(iiip, cty)
        }.resume()
    }
}


enum SoundEffect: String {
    case cardDeal = "card_deal"
    case cardTap = "card_tap"
    case sequence = "sequence"
    case triplet = "triplet"
    case computerCombo = "computer_combo"
    case skip = "skip"
    case error = "error"
    case win = "win"
    case lose = "lose"
    case draw = "draw"
    case buttonTap = "button_tap"
    case shuffle = "shuffle"
    case countdown = "countdown"
}

class SoundManager {
    // Singleton
    static let shared = SoundManager()
    
    // Audio players
    private var audioPlayers: [SoundEffect: AVAudioPlayer] = [:]
    
    // Settings
    private var soundEnabled = true
    
    private init() {
        loadSounds()
    }
    
    // Load all sounds into memory
    private func loadSounds() {
        for sound in SoundEffect.allCases {
            if let path = Bundle.main.path(forResource: sound.rawValue, ofType: "mp3") {
                let url = URL(fileURLWithPath: path)
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    audioPlayers[sound] = player
                } catch {
                    print("Error loading sound \(sound.rawValue): \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Play a sound effect
    func playSound(_ effect: SoundEffect) {
        guard soundEnabled else { return }
        
        if let player = audioPlayers[effect] {
            // Reset player if it's currently playing
            if player.isPlaying {
                player.currentTime = 0
            }
            player.play()
        } else {
            // If sound wasn't preloaded, try loading it now
            if let path = Bundle.main.path(forResource: effect.rawValue, ofType: "mp3") {
                let url = URL(fileURLWithPath: path)
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    // Don't wait for preparation to complete
                    player.prepareToPlay()
                    player.play()
                    audioPlayers[effect] = player
                } catch {
                    print("Error playing sound \(effect.rawValue): \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Enable/disable sounds
    func setSoundEnabled(_ enabled: Bool) {
        soundEnabled = enabled
        
        // Save preference
        UserDefaults.standard.set(enabled, forKey: "mjSortSoundEnabled")
    }
    
    // Check if sound is enabled
    func isSoundEnabled() -> Bool {
        return soundEnabled
    }
    
    // Load sound preferences
    func loadSoundPreferences() {
        if let savedPreference = UserDefaults.standard.object(forKey: "mjSortSoundEnabled") as? Bool {
            soundEnabled = savedPreference
        }
    }
}

// Extension to make SoundEffect conform to CaseIterable
extension SoundEffect: CaseIterable {} 
