import Foundation

struct Pet: Codable {
    var name: String = "Buddy"
    var hunger: Double = 80       // 0 = starving, 100 = full
    var happiness: Double = 70
    var health: Double = 100
    var ageInMinutes: Int = 0
    var level: Int = 1
    var xp: Int = 0
    var coins: Int = 50
    var lastUpdated: Date = Date()
    var stage: EvolutionStage = .egg
    var isSleeping: Bool = false
    var totalFeedings: Int = 0
    var totalGamesPlayed: Int = 0
    var foodInventory: [String: Int] = ["apple": 3, "cookie": 1]

    enum EvolutionStage: String, Codable, CaseIterable {
        case egg, baby, child, teen, adult

        var emoji: String {
            switch self {
            case .egg:   return "🥚"
            case .baby:  return "🐣"
            case .child: return "🐥"
            case .teen:  return "🦎"
            case .adult: return "🐉"
            }
        }

        var displayName: String { rawValue.capitalized }

        var order: Int { Pet.EvolutionStage.allCases.firstIndex(of: self) ?? 0 }

        var xpToNext: Int {
            switch self {
            case .egg:   return 30
            case .baby:  return 150
            case .child: return 400
            case .teen:  return 800
            case .adult: return Int.max
            }
        }
    }

    var mood: Mood {
        let avg = (hunger + happiness + health) / 3
        switch avg {
        case 80...100: return .ecstatic
        case 60..<80:  return .happy
        case 40..<60:  return .okay
        case 20..<40:  return .sad
        default:       return .critical
        }
    }

    enum Mood {
        case ecstatic, happy, okay, sad, critical

        var emoji: String {
            switch self {
            case .ecstatic: return "😄"
            case .happy:    return "😊"
            case .okay:     return "😐"
            case .sad:      return "😢"
            case .critical: return "😰"
            }
        }

        var label: String {
            switch self {
            case .ecstatic: return "Ecstatic!"
            case .happy:    return "Happy"
            case .okay:     return "Okay"
            case .sad:      return "Sad"
            case .critical: return "Needs help!"
            }
        }
    }

    var xpToNextLevel: Int { level * 50 }

    var ageDisplay: String {
        let hours = ageInMinutes / 60
        let days  = hours / 24
        if days > 0  { return "\(days)d \(hours % 24)h" }
        if hours > 0 { return "\(hours)h \(ageInMinutes % 60)m" }
        return "\(ageInMinutes)m"
    }

    mutating func applyDecay(minutes: Double) {
        let rate = isSleeping ? 0.3 : 1.0
        hunger    = max(0, hunger    - minutes * 0.8 * rate)
        happiness = max(0, happiness - minutes * 0.5 * rate)

        if hunger < 20 {
            health = max(0, health - minutes * 0.4)
        } else if hunger > 60 && happiness > 60 {
            health = min(100, health + minutes * 0.2)
        }

        ageInMinutes += Int(minutes)
        lastUpdated = Date()
    }
}

struct GameNotification: Identifiable {
    let id = UUID()
    let message: String
    let type: NotificationType

    enum NotificationType { case warning, reward }
}
