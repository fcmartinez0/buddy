import Foundation

struct FoodItem: Identifiable, Codable {
    let id: String
    let name: String
    let emoji: String
    let hungerValue: Double
    let happinessValue: Double
    let cost: Int
    let description: String

    static let all: [FoodItem] = [
        FoodItem(id: "apple",     name: "Apple",       emoji: "🍎", hungerValue: 25, happinessValue: 5,  cost: 5,  description: "Simple and filling."),
        FoodItem(id: "cookie",    name: "Cookie",      emoji: "🍪", hungerValue: 10, happinessValue: 30, cost: 8,  description: "A treat. Don't go overboard."),
        FoodItem(id: "pizza",     name: "Pizza",       emoji: "🍕", hungerValue: 40, happinessValue: 20, cost: 15, description: "The crowd-pleaser."),
        FoodItem(id: "salad",     name: "Salad",       emoji: "🥗", hungerValue: 20, happinessValue: 8,  cost: 6,  description: "Healthy, if a bit boring."),
        FoodItem(id: "icecream",  name: "Ice Cream",   emoji: "🍦", hungerValue: 5,  happinessValue: 45, cost: 12, description: "Pure joy."),
        FoodItem(id: "steak",     name: "Steak",       emoji: "🥩", hungerValue: 60, happinessValue: 25, cost: 30, description: "Max hunger, premium vibes."),
        FoodItem(id: "watermelon",name: "Watermelon",  emoji: "🍉", hungerValue: 15, happinessValue: 20, cost: 7,  description: "Refreshing and sweet."),
        FoodItem(id: "ramen",     name: "Ramen",       emoji: "🍜", hungerValue: 45, happinessValue: 30, cost: 20, description: "Comfort in a bowl."),
    ]

    static func find(_ id: String) -> FoodItem? {
        all.first { $0.id == id }
    }
}
