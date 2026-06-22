import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var petVM: PetViewModel
    @AppStorage("hasOnboarded") var hasOnboarded = false

    @State private var step = 0
    @State private var petName = ""
    @State private var eggScale: CGFloat = 1.0
    @State private var eggShake: CGFloat = 0
    @State private var cracking = false
    @State private var hatched = false

    @FocusState private var nameFocused: Bool

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            switch step {
            case 0: welcomePage
            case 1: namePage
            case 2: hatchPage
            default: EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: step)
    }

    // MARK: - Pages

    var welcomePage: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("🥚")
                .font(.system(size: 120))
                .scaleEffect(eggScale)
                .onAppear { startEggBob() }

            VStack(spacing: 12) {
                Text("Something\nis about to hatch.")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text("Your new buddy is waiting.\nTake good care of it.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)

            Spacer()

            OnboardingButton(label: "Let's go") {
                step = 1
            }
            .padding(.bottom, 48)
        }
        .padding(.horizontal, 32)
    }

    var namePage: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("🥚")
                .font(.system(size: 100))
                .scaleEffect(eggScale)

            VStack(spacing: 20) {
                Text("What will you\ncall it?")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.top, 28)

                TextField("Give it a name", text: $petName)
                    .font(.title2.weight(.medium))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .focused($nameFocused)
                    .submitLabel(.done)
                    .onSubmit { advanceFromName() }
                    .onAppear { nameFocused = true }
            }

            Spacer()

            OnboardingButton(label: "Next", disabled: petName.trimmingCharacters(in: .whitespaces).isEmpty) {
                advanceFromName()
            }
            .padding(.bottom, 48)
        }
        .padding(.horizontal, 32)
    }

    var hatchPage: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                if hatched {
                    Text(Pet.EvolutionStage.egg.emoji)
                        .font(.system(size: 120))
                        .opacity(0)

                    VStack(spacing: 8) {
                        Text(Pet.EvolutionStage.baby.emoji)
                            .font(.system(size: 120))
                            .scaleEffect(eggScale)
                            .transition(.scale.combined(with: .opacity))

                        Text("✨")
                            .font(.system(size: 40))
                            .opacity(eggScale > 1 ? 1 : 0)
                    }
                } else {
                    Text("🥚")
                        .font(.system(size: 120))
                        .rotationEffect(.degrees(eggShake))
                        .scaleEffect(eggScale)
                }
            }
            .frame(height: 180)

            VStack(spacing: 12) {
                Text(hatched
                     ? "Meet \(petName)! 🎉"
                     : "Tap the egg.")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.top, 28)

                Text(hatched
                     ? "Keep \(petName) fed and happy\nand it'll grow into something amazing."
                     : "It's almost ready.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            if hatched {
                OnboardingButton(label: "Start playing") {
                    finishOnboarding()
                }
                .padding(.bottom, 48)
            } else {
                Button {
                    hatchEgg()
                } label: {
                    Text("🥚")
                        .font(.system(size: 80))
                        .scaleEffect(cracking ? 1.15 : 1.0)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 48)
                .disabled(cracking)
            }
        }
        .padding(.horizontal, 32)
        .onAppear { startEggShake() }
    }

    // MARK: - Logic

    func advanceFromName() {
        let trimmed = petName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        nameFocused = false
        petName = trimmed
        step = 2
    }

    func hatchEgg() {
        cracking = true
        // shake intensifies
        withAnimation(.easeInOut(duration: 0.07).repeatCount(8, autoreverses: true)) {
            eggShake = 14
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                hatched = true
                eggScale = 1.4
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.spring()) { eggScale = 1.0 }
            }
        }
    }

    func finishOnboarding() {
        petVM.rename(petName)
        hasOnboarded = true
    }

    // MARK: - Animations

    func startEggBob() {
        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
            eggScale = 1.08
        }
    }

    func startEggShake() {
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
            eggShake = 6
        }
        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
            eggScale = 1.06
        }
    }

    var background: some View {
        LinearGradient(
            colors: [Color(.systemIndigo).opacity(0.12), Color(.systemPurple).opacity(0.06)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct OnboardingButton: View {
    let label: String
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(disabled ? Color.secondary.opacity(0.3) : Color.purple)
                .foregroundColor(.white)
                .cornerRadius(18)
        }
        .disabled(disabled)
        .animation(.easeInOut(duration: 0.2), value: disabled)
    }
}
