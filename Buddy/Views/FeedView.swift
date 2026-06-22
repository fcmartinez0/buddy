import SwiftUI

struct FeedView: View {
    @EnvironmentObject var petVM: PetViewModel
    @State private var fedFood: String? = nil

    var inventoryItems: [(FoodItem, Int)] {
        FoodItem.all.compactMap { food in
            let count = petVM.pet.foodInventory[food.id] ?? 0
            return count > 0 ? (food, count) : nil
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                hungerSummary
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if inventoryItems.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                            ForEach(inventoryItems, id: \.0.id) { (food, count) in
                                FoodCard(food: food, count: count, highlighted: fedFood == food.id) {
                                    feed(food)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Feed \(petVM.pet.name)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    var hungerSummary: some View {
        HStack(spacing: 16) {
            HungerChip(label: "Hunger", value: petVM.pet.hunger, color: .orange)
            HungerChip(label: "Happiness", value: petVM.pet.happiness, color: .pink)
        }
        .padding(.vertical, 8)
    }

    var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("🛒")
                .font(.system(size: 60))
            Text("Nothing to eat")
                .font(.title3.bold())
            Text("Head to the Shop to stock up on food.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }

    func feed(_ food: FoodItem) {
        petVM.feed(food: food)
        fedFood = food.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            fedFood = nil
        }
    }
}

struct HungerChip: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(value))")
                    .font(.caption.monospacedDigit().bold())
                    .foregroundColor(color)
            }
            ProgressView(value: value, total: 100)
                .tint(color)
        }
        .padding(10)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }
}

struct FoodCard: View {
    let food: FoodItem
    let count: Int
    let highlighted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Text(food.emoji)
                        .font(.system(size: 52))

                    Text("×\(count)")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.purple)
                        .cornerRadius(8)
                        .offset(x: 4, y: -4)
                }

                Text(food.name)
                    .font(.subheadline.bold())

                Text(food.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Label("+\(Int(food.hungerValue))", systemImage: "fork.knife")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Label("+\(Int(food.happinessValue))", systemImage: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(.pink)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(highlighted ? Color.purple.opacity(0.2) : Color(.secondarySystemBackground))
            .cornerRadius(16)
            .scaleEffect(highlighted ? 1.04 : 1.0)
            .animation(.spring(response: 0.25), value: highlighted)
        }
        .buttonStyle(.plain)
    }
}
