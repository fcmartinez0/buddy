import SwiftUI

// MARK: - Character view

struct BuddyCharacterView: View {
    let stage: Pet.EvolutionStage
    let species: Pet.PetSpecies
    let hunger: Double
    let health: Double
    var hatchProgress: Double = 0   // 0–1, only used during egg stage

    @State private var bounceOffset: CGFloat = 0
    @State private var blinkOpacity: Double = 1
    @State private var wobbleAngle: Double = 0

    private var isSad: Bool    { (hunger + health) / 2 < 35 }
    private var isHappy: Bool  { (hunger + health) / 2 > 65 }
    private var smileAmount: Double { isHappy ? 0.78 : isSad ? -0.52 : 0.12 }

    private var bodyColor: Color {
        switch (species, stage) {
        case (_, .egg):             return Color(red: 0.94, green: 0.91, blue: 0.84)
        case (.bub, .baby):         return Color(red: 0.72, green: 0.87, blue: 0.97)
        case (.bub, .child):        return Color(red: 0.70, green: 0.92, blue: 0.76)
        case (.bub, .teen):         return Color(red: 0.80, green: 0.73, blue: 0.96)
        case (.bub, .adult):        return Color(red: 0.97, green: 0.73, blue: 0.73)
        case (.fin, .baby):         return Color(red: 0.97, green: 0.88, blue: 0.70)
        case (.fin, .child):        return Color(red: 0.97, green: 0.76, blue: 0.60)
        case (.fin, .teen):         return Color(red: 0.95, green: 0.65, blue: 0.50)
        case (.fin, .adult):        return Color(red: 0.90, green: 0.50, blue: 0.40)
        }
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width * 0.8, geo.size.height * 0.8)
            let eyeSize   = size * 0.135
            let mouthW    = size * 0.26
            let mouthH    = mouthW * 0.55

            ZStack {
                // Drop shadow
                Ellipse()
                    .fill(Color.black.opacity(0.07))
                    .frame(width: size * 0.65, height: size * 0.09)
                    .blur(radius: 12)
                    .offset(y: size * 0.5 + bounceOffset * 0.25 + 8)

                if stage == .egg {
                    eggBody(size: size)
                } else {
                    // Ears — baby and child only
                    if stage == .baby || stage == .child {
                        let earSize = stage == .baby ? size * 0.17 : size * 0.22
                        HStack(spacing: size * 0.54) {
                            earView(size: earSize)
                            earView(size: earSize)
                        }
                        .offset(y: -size * 0.37)
                    }

                    // Body
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [bodyColor.opacity(0.52), bodyColor],
                                center: UnitPoint(x: 0.38, y: 0.30),
                                startRadius: 0,
                                endRadius: size * 0.65
                            )
                        )
                        .frame(width: size, height: size)

                    // Face
                    VStack(spacing: size * 0.09) {
                        HStack(spacing: size * 0.21) {
                            BuddyEye(size: eyeSize, sad: isSad,
                                     bodyColor: bodyColor, blinkOpacity: blinkOpacity)
                            BuddyEye(size: eyeSize, sad: isSad,
                                     bodyColor: bodyColor, blinkOpacity: blinkOpacity)
                        }

                        BuddyMouthShape(smile: smileAmount)
                            .stroke(
                                Color(white: 0.18).opacity(0.72),
                                style: StrokeStyle(lineWidth: mouthW * 0.11, lineCap: .round)
                            )
                            .frame(width: mouthW, height: mouthH)
                            .animation(.spring(response: 0.5), value: smileAmount)
                    }
                    .offset(y: size * 0.05)
                }
            }
            .rotationEffect(stage == .egg ? .degrees(wobbleAngle) : .zero)
            .offset(y: stage == .egg ? 0 : bounceOffset)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            if stage == .egg { startWobble() } else { startBounce(); startBlink() }
        }
        .onChange(of: stage) { newStage in
            if newStage != .egg { startBounce(); startBlink() }
        }
    }

    // MARK: - Egg appearance

    private func eggBody(size: CGFloat) -> some View {
        let eggW = size * 0.68
        let eggH = size * 0.84

        return ZStack {
            // Shadow
            Ellipse()
                .fill(Color.black.opacity(0.06))
                .frame(width: eggW * 0.75, height: eggH * 0.09)
                .blur(radius: 10)
                .offset(y: eggH * 0.52)

            // Egg body
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [bodyColor.opacity(0.45), bodyColor],
                        center: UnitPoint(x: 0.38, y: 0.28),
                        startRadius: 0,
                        endRadius: eggH * 0.6
                    )
                )
                .frame(width: eggW, height: eggH)

            // Hatch progress arc along bottom of egg
            if hatchProgress > 0 {
                Circle()
                    .trim(from: 0, to: hatchProgress)
                    .stroke(
                        Color(white: 0.30).opacity(0.25),
                        style: StrokeStyle(lineWidth: eggW * 0.03, lineCap: .round, dash: [4, 5])
                    )
                    .frame(width: eggW * 0.55, height: eggW * 0.55)
                    .rotationEffect(.degrees(-90))
                    .offset(y: eggH * 0.14)
            }
        }
    }

    private func startWobble() {
        // Idle gentle rock; speeds up as egg gets close to hatching
        let intensity = 3.0 + hatchProgress * 5.0
        let duration  = 1.4 - hatchProgress * 0.5
        withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            wobbleAngle = intensity
        }
    }

    private func earView(size: CGFloat) -> some View {
        Circle()
            .fill(bodyColor.opacity(0.72))
            .frame(width: size, height: size)
    }

    private func startBounce() {
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            bounceOffset = -10
        }
    }

    private func startBlink() {
        func schedule() {
            let delay = Double.random(in: 2.8...5.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.07)) { blinkOpacity = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                    withAnimation(.easeInOut(duration: 0.07)) { blinkOpacity = 1 }
                    schedule()
                }
            }
        }
        schedule()
    }
}

// MARK: - Eye

struct BuddyEye: View {
    let size: CGFloat
    let sad: Bool
    let bodyColor: Color
    let blinkOpacity: Double

    var body: some View {
        ZStack {
            // White sclera
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

            // Pupil
            Circle()
                .fill(Color(white: 0.10))
                .frame(width: size * 0.50, height: size * 0.50)
                .offset(y: sad ? size * 0.07 : 0)
                .animation(.easeInOut(duration: 0.3), value: sad)

            // Shine
            Circle()
                .fill(Color.white.opacity(0.80))
                .frame(width: size * 0.17, height: size * 0.17)
                .offset(x: -size * 0.13, y: -size * 0.13)

            // Blink lid (slides down from top)
            Rectangle()
                .fill(bodyColor)
                .frame(width: size * 1.05, height: size)
                .offset(y: -size * (blinkOpacity > 0.5 ? 1.0 : 0.0))
                .animation(.easeInOut(duration: 0.07), value: blinkOpacity)

            // Droopy lid when sad
            if sad {
                Ellipse()
                    .fill(bodyColor)
                    .frame(width: size * 1.12, height: size * 0.60)
                    .offset(y: -size * 0.26)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// MARK: - Mouth shape

struct BuddyMouthShape: Shape {
    var smile: Double   // –1 frown … 0 flat … 1 big smile

    var animatableData: Double {
        get { smile }
        set { smile = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let controlY = rect.midY - CGFloat(smile) * rect.height * 0.95
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: controlY)
        )
        return p
    }
}
