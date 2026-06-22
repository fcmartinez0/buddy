import SwiftUI

struct StatsView: View {
    @EnvironmentObject var petVM: PetViewModel
    @State private var showResetConfirm = false

    var pet: Pet { petVM.pet }

    var body: some View {
        NavigationStack {
            List {
                profileSection
                vitalSection
                progressSection
                activitySection
                dangerSection
            }
            .navigationTitle("Stats")
        }
    }

    var profileSection: some View {
        Section {
            HStack(spacing: 16) {
                Text(pet.stage.emoji)
                    .font(.system(size: 60))

                VStack(alignment: .leading, spacing: 4) {
                    Text(pet.name)
                        .font(.title2.bold())
                    Text("\(pet.stage.displayName) · Level \(pet.level)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Age: \(pet.ageDisplay)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    var vitalSection: some View {
        Section("Vitals") {
            statRow("Hunger",    value: pet.hunger,    color: .orange, icon: "fork.knife")
            statRow("Happiness", value: pet.happiness, color: .pink,   icon: "heart.fill")
            statRow("Health",    value: pet.health,    color: .green,  icon: "cross.fill")
            HStack {
                Label("Mood", systemImage: "face.smiling")
                Spacer()
                Text("\(pet.mood.emoji) \(pet.mood.label)")
                    .foregroundColor(.secondary)
            }
            HStack {
                Label("Sleeping", systemImage: "moon.fill")
                Spacer()
                Text(pet.isSleeping ? "Yes 😴" : "No")
                    .foregroundColor(.secondary)
            }
        }
    }

    var progressSection: some View {
        Section("Progress") {
            HStack {
                Label("Level", systemImage: "star.fill")
                Spacer()
                Text("\(pet.level)")
                    .foregroundColor(.purple)
                    .bold()
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("XP")
                        .font(.subheadline)
                    Spacer()
                    Text("\(pet.xp) / \(pet.xpToNextLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                ProgressView(value: Double(pet.xp), total: Double(pet.xpToNextLevel))
                    .tint(.purple)
            }
            HStack {
                Label("Coins", systemImage: "dollarsign.circle.fill")
                Spacer()
                Text("🪙 \(pet.coins)")
                    .foregroundColor(.secondary)
            }
            evolutionProgress
        }
    }

    var evolutionProgress: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Evolution")
                .font(.subheadline)
            HStack(spacing: 0) {
                ForEach(Pet.EvolutionStage.allCases, id: \.self) { stage in
                    VStack(spacing: 4) {
                        Text(stage.emoji)
                            .font(.title3)
                            .opacity(pet.stage.rawValue >= stage.rawValue ? 1.0 : 0.3)
                        Text(stage.displayName)
                            .font(.system(size: 8))
                            .foregroundColor(pet.stage == stage ? .purple : .secondary)
                    }
                    .frame(maxWidth: .infinity)

                    if stage != .adult {
                        Rectangle()
                            .fill(pet.stage.rawValue > stage.rawValue ? Color.purple : Color.secondary.opacity(0.3))
                            .frame(height: 2)
                            .offset(y: -10)
                    }
                }
            }
        }
    }

    var activitySection: some View {
        Section("Activity") {
            HStack {
                Label("Total Feedings", systemImage: "fork.knife.circle.fill")
                Spacer()
                Text("\(pet.totalFeedings)")
                    .foregroundColor(.secondary)
            }
            HStack {
                Label("Games Played", systemImage: "gamecontroller.fill")
                Spacer()
                Text("\(pet.totalGamesPlayed)")
                    .foregroundColor(.secondary)
            }
        }
    }

    var dangerSection: some View {
        Section {
            Button(role: .destructive) {
                showResetConfirm = true
            } label: {
                Label("Start Over", systemImage: "arrow.counterclockwise")
            }
            .confirmationDialog("This will reset everything.", isPresented: $showResetConfirm, titleVisibility: .visible) {
                Button("Reset", role: .destructive) { petVM.resetPet() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    func statRow(_ label: String, value: Double, color: Color, icon: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            ProgressView(value: value, total: 100)
                .tint(color)
                .frame(width: 80)
            Text("\(Int(value))")
                .font(.caption.monospacedDigit())
                .foregroundColor(.secondary)
                .frame(width: 28, alignment: .trailing)
        }
    }
}
