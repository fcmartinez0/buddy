import SwiftUI

struct ShopView: View {
    @EnvironmentObject var petVM: PetViewModel
    @State private var boughtId: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    coinBanner

                    Text("Food")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 12) {
                        ForEach(FoodItem.all) { food in
                            ShopCard(
                                food: food,
                                owned: petVM.pet.foodInventory[food.id] ?? 0,
                                canAfford: petVM.pet.coins >= food.cost,
                                justBought: boughtId == food.id
                            ) {
                                buy(food)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
            }
            .navigationTitle("Shop")
        }
    }

    var coinBanner: some View {
        HStack {
            Text("🪙")
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text("Your coins")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(petVM.pet.coins)")
                    .font(.title2.bold().monospacedDigit())
            }
            Spacer()
            Text("Play games to earn more →")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.yellow.opacity(0.15))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }

    func buy(_ food: FoodItem) {
        petVM.buyFood(food)
        boughtId = food.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            boughtId = nil
        }
    }
}

struct ShopCard: View {
    let food: FoodItem
    let owned: Int
    let canAfford: Bool
    let justBought: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(food.emoji)
                    .font(.system(size: 46))

                Text(food.name)
                    .font(.subheadline.bold())

                Text(food.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(minHeight: 28)

                HStack(spacing: 10) {
                    Label("+\(Int(food.hungerValue))", systemImage: "fork.knife")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Label("+\(Int(food.happinessValue))", systemImage: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(.pink)
                }

                Divider()

                HStack {
                    HStack(spacing: 3) {
                        Text("🪙")
                        Text("\(food.cost)")
                            .font(.subheadline.bold())
                    }
                    .foregroundColor(canAfford ? .primary : .secondary)

                    Spacer()

                    if owned > 0 {
                        Text("×\(owned)")
                            .font(.caption.bold())
                            .foregroundColor(.purple)
                    }
                }
            }
            .padding(12)
            .background(justBought ? Color.green.opacity(0.15) : canAfford ? Color(.secondarySystemBackground) : Color(.systemFill))
            .cornerRadius(16)
            .scaleEffect(justBought ? 1.03 : 1.0)
            .animation(.spring(response: 0.25), value: justBought)
            .opacity(canAfford ? 1 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(!canAfford)
    }
}
