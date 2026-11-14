import SwiftUI
import Combine

// MARK: - Game Phase 1 and first setup

enum GamePhase {
    case idle
    case playing
    case over
}

// MARK: - Main Game View

struct ContentView: View {

    // MARK: Game Settings

    private let gameDuration: Double = 10
    private let comboWindow: Double = 0.75

    private let timer = Timer.publish(
        every: 0.05,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: Game State

    @State private var phase: GamePhase = .idle

    @State private var score: Int = 0
    @State private var timeRemaining: Double = 10

    @State private var comboCount: Int = 0
    @State private var lastTapDate: Date?

    @State private var isTrap: Bool = false
    @State private var nextColorChange = Date()

    @State private var feedbackMessage = "Tap to start!"
    @State private var feedbackExpiresAt = Date.distantPast

    @State private var deadline = Date.distantFuture

    // MARK: Persistent Data

    @AppStorage("tapFrenzyBestScore")
    private var bestScore: Int = 0

    @AppStorage("tapFrenzyGamesPlayed")
    private var gamesPlayed: Int = 0

    // MARK: Colors

    private let backgroundColor = Color(
        red: 0.035,
        green: 0.045,
        blue: 0.10
    )

    private let blueColor = Color(
        red: 0.10,
        green: 0.55,
        blue: 1.0
    )

    private let purpleColor = Color(
        red: 0.55,
        green: 0.30,
        blue: 1.0
    )

    private let trapColor = Color(
        red: 1.0,
        green: 0.20,
        blue: 0.30
    )

    // MARK: Main Interface

    var body: some View {

        ZStack {

            backgroundColor
                .ignoresSafeArea()

            Circle()
                .fill(purpleColor.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: 140, y: -300)

            Circle()
                .fill(blueColor.opacity(0.12))
                .frame(width: 250, height: 250)
                .blur(radius: 100)
                .offset(x: -150, y: 300)

            VStack(spacing: 22) {

                header

                scoreSection

                timerSection

                Spacer(minLength: 8)

                gameSection

                Spacer(minLength: 8)

                statisticsSection

            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 15)

        }
        .preferredColorScheme(.dark)
        .onReceive(timer) { _ in
            updateGame()
        }
    }

    // MARK: Header

    private var header: some View {

        VStack(spacing: 6) {

            HStack(spacing: 8) {

                Image(systemName: "bolt.fill")
                    .foregroundStyle(.yellow)
                    .font(.title2)

                Text("TAP FRENZY")
                    .font(.system(
                        size: 27,
                        weight: .black,
                        design: .rounded
                    ))
                    .tracking(2)

            }

            Text("TEST YOUR SPEED. BEAT YOUR BEST.")
                .font(.system(size: 10, weight: .semibold))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.5))

        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Score Section

    private var scoreSection: some View {

        HStack(spacing: 12) {

            VStack(spacing: 7) {

                Text("SCORE")
                    .font(.caption)
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.55))

                Text("\(score)")
                    .font(.system(
                        size: 43,
                        weight: .black,
                        design: .rounded
                    ))
                    .contentTransition(.numericText())
                    .foregroundStyle(.white)

            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(.white.opacity(0.12))
                .frame(width: 1, height: 55)

            VStack(spacing: 7) {

                Text("BEST")
                    .font(.caption)
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.55))

                Text("\(bestScore)")
                    .font(.system(
                        size: 43,
                        weight: .black,
                        design: .rounded
                    ))
                    .foregroundStyle(.yellow)

            }
            .frame(maxWidth: .infinity)

        }
        .padding(.vertical, 17)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }

    // MARK: Timer Section

    private var timerSection: some View {

        VStack(spacing: 10) {

            HStack {

                Label("TIME LEFT", systemImage: "timer")
                    .font(.caption.bold())
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.6))

                Spacer()

                Text("\(Int(ceil(timeRemaining)))s")
                    .font(.system(
                        size: 20,
                        weight: .bold,
                        design: .rounded
                    ))
                    .foregroundStyle(timerColor)

            }

            GeometryReader { geometry in

                ZStack(alignment: .leading) {

                    Capsule()
                        .fill(.white.opacity(0.10))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    timerColor,
                                    timerColor.opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width *
                            progress
                        )
                        .animation(
                            .linear(duration: 0.1),
                            value: progress
                        )

                }

            }
            .frame(height: 9)

        }
    }

    private var timerColor: Color {

        if timeRemaining > 6 {
            return .green
        } else if timeRemaining > 3 {
            return .orange
        } else {
            return trapColor
        }
    }

    private var progress: Double {

        max(0, min(1, timeRemaining / gameDuration))
    }

    // MARK: Game Section

    private var gameSection: some View {

        VStack(spacing: 22) {

            if phase == .over {

                gameOverView

            } else {

                Text(feedbackMessage)
                    .font(.system(
                        size: 16,
                        weight: .bold,
                        design: .rounded
                    ))
                    .foregroundStyle(
                        feedbackMessage.contains("TRAP")
                        ? trapColor
                        : .white.opacity(0.85)
                    )
                    .frame(height: 25)

                tapButton

                if phase == .playing {

                    HStack(spacing: 8) {

                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)

                        Text("COMBO x\(comboCount)")
                            .font(.system(
                                size: 15,
                                weight: .bold
                            ))
                            .foregroundStyle(.white)

                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.08))
                    .clipShape(Capsule())

                } else {

                    Text("FIRST TAP STARTS THE GAME")
                        .font(.caption.bold())
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.5))

                }

            }

        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Circular Tap Button

    private var tapButton: some View {

        let buttonColor: Color =
            phase == .playing && isTrap
            ? trapColor
            : blueColor

        return Button {

            handleTap()

        } label: {

            ZStack {

                Circle()
                    .fill(buttonColor.opacity(0.12))
                    .frame(width: 240, height: 240)

                Circle()
                    .stroke(
                        buttonColor.opacity(0.3),
                        lineWidth: 2
                    )
                    .frame(width: 225, height: 225)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                buttonColor,
                                buttonColor.opacity(0.65)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 195, height: 195)
                    .shadow(
                        color: buttonColor.opacity(0.5),
                        radius: 25,
                        y: 10
                    )

                VStack(spacing: 9) {

                    Image(
                        systemName:
                            phase == .playing && isTrap
                            ? "exclamationmark.triangle.fill"
                            : "hand.tap.fill"
                    )
                    .font(.system(size: 39, weight: .bold))

                    Text(
                        phase == .playing && isTrap
                        ? "TRAP!"
                        : "TAP"
                    )
                    .font(.system(
                        size: 30,
                        weight: .black,
                        design: .rounded
                    ))
                    .tracking(2)

                }
                .foregroundStyle(.white)

            }
            .frame(width: 250, height: 250)
            .scaleEffect(phase == .playing ? 1.0 : 0.97)

        }
        .buttonStyle(.plain)
        .disabled(phase == .over)

        .accessibilityLabel("Tap Frenzy game button")
    }

    // MARK: Game Over Screen

    private var gameOverView: some View {

        VStack(spacing: 18) {

            Image(systemName: "trophy.fill")
                .font(.system(size: 55))
                .foregroundStyle(.yellow)

            Text("TIME'S UP!")
                .font(.system(
                    size: 29,
                    weight: .black,
                    design: .rounded
                ))
                .foregroundStyle(.white)

            Text("YOUR FINAL SCORE")
                .font(.caption.bold())
                .tracking(2)
                .foregroundStyle(.white.opacity(0.55))

            Text("\(score)")
                .font(.system(
                    size: 65,
                    weight: .black,
                    design: .rounded
                ))
                .foregroundStyle(.white)

            Text("Best Score: \(bestScore)")
                .font(.headline)
                .foregroundStyle(.yellow)

            Button {

                resetGame()

            } label: {

                Label(
                    "PLAY AGAIN",
                    systemImage: "arrow.clockwise"
                )
                .font(.system(
                    size: 16,
                    weight: .black
                ))
                .tracking(1)
                .foregroundStyle(.white)
                .padding(.horizontal, 35)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [blueColor, purpleColor],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())

            }
            .buttonStyle(.plain)

        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)

    }

    // MARK: Statistics

    private var statisticsSection: some View {

        HStack(spacing: 12) {

            statisticCard(
                title: "GAMES PLAYED",
                value: "\(gamesPlayed)",
                icon: "gamecontroller.fill"
            )

            statisticCard(
                title: "BEST SCORE",
                value: "\(bestScore)",
                icon: "crown.fill"
            )

        }
    }

    private func statisticCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {

        VStack(spacing: 9) {

            Image(systemName: icon)
                .foregroundStyle(.cyan)
                .font(.title3)

            Text(value)
                .font(.system(
                    size: 25,
                    weight: .black,
                    design: .rounded
                ))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.5))

        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18))

    }

    // MARK: Handle Button Tap

    private func handleTap() {

        let now = Date()

        if phase == .over {
            return
        }

        // Start game on first tap

        if phase == .idle {

            startGame()

        }

        // Prevent scoring after the deadline

        if now >= deadline {

            finishGame()
            return

        }

        // C2: Trap Colour Challenge

        if isTrap {

            score = max(0, score - 2)

            comboCount = 0
            lastTapDate = nil

            feedbackMessage = "TRAP! -2 POINTS"

            feedbackExpiresAt = now.addingTimeInterval(0.8)

        } else {

            // C1: Combo Challenge

            if let previousTap = lastTapDate,
               now.timeIntervalSince(previousTap) <= comboWindow {

                comboCount += 1

            } else {

                comboCount = 1

            }

            lastTapDate = now

            score += 1

            // Bonus every 5 consecutive quick taps

            if comboCount % 5 == 0 {

                score += 3

                feedbackMessage = "COMBO BONUS +3!"

            } else {

                feedbackMessage = "+1 POINT"

            }

            feedbackExpiresAt = now.addingTimeInterval(0.5)

        }

    }

    // MARK: Start Game

    private func startGame() {

        score = 0
        comboCount = 0
        lastTapDate = nil

        timeRemaining = gameDuration

        isTrap = false

        deadline = Date().addingTimeInterval(gameDuration)

        nextColorChange = Date().addingTimeInterval(1.2)

        gamesPlayed += 1

        feedbackMessage = "GO! GO! GO!"

        withAnimation(.spring()) {

            phase = .playing

        }

    }

    // MARK: Update Timer

    private func updateGame() {

        guard phase == .playing else {
            return
        }

        let now = Date()

        // Update countdown

        timeRemaining = max(
            0,
            deadline.timeIntervalSince(now)
        )

        // End game when time reaches zero

        if timeRemaining <= 0 {

            finishGame()
            return

        }

        // Change trap colour periodically

        if now >= nextColorChange {

            isTrap = Int.random(in: 0...3) == 0

            nextColorChange = now.addingTimeInterval(1.2)

        }

        // Clear temporary feedback

        if now >= feedbackExpiresAt {

            feedbackMessage = "KEEP TAPPING!"

        }

    }

    // MARK: Finish Game

    private func finishGame() {

        timeRemaining = 0

        if score > bestScore {

            bestScore = score

        }

        withAnimation(.spring()) {

            phase = .over

        }

    }

    // MARK: Reset Game

    private func resetGame() {

        score = 0

        timeRemaining = gameDuration

        comboCount = 0

        lastTapDate = nil

        isTrap = false

        feedbackMessage = "Tap to start!"

        deadline = .distantFuture

        withAnimation(.spring()) {

            phase = .idle

        }

    }

}

// MARK: - Preview

#Preview {
    ContentView()
}
