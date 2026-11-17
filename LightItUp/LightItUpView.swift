
import SwiftUI
import Combine

struct LightItUpView: View {

    // MARK: - Saved High Score

    @AppStorage("lightItUpHighScore")
    private var highScore = 0

    // MARK: - Game State

    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var lives = 3
    @State private var elapsedTime: Double = 0

    @State private var currentLevel: Level = .L1

    @State private var isPlaying = false
    @State private var gameOver = false

    @State private var litCardID: Int? = nil
    @State private var litDeadline: Date? = nil
    @State private var nextSpawnTime: Double = 0

    @State private var startTime: Date? = nil

    // MARK: - Timer

    private let timer = Timer.publish(
        every: 0.1,
        on: .main,
        in: .common
    ).autoconnect()

    // MARK: - Grid Layout

    private var columns: [GridItem] {
        let count = currentLevel.gridCount <= 4 ? 2 : 3

        return Array(
            repeating: GridItem(.flexible(), spacing: 12),
            count: count
        )
    }

    var body: some View {

        VStack(spacing: 20) {

            Text("Light It Up")
                .font(.largeTitle)
                .bold()

            // Score, Level and Lives

            HStack {

                statView(title: "SCORE", value: "\(score)")

                Spacer()

                statView(
                    title: "LEVEL",
                    value: "\(currentLevel.rawValue)"
                )

                Spacer()

                statView(title: "LIVES", value: "\(lives)")
            }
            .padding()

            Text(
                "TIME: \(max(0, 60 - Int(elapsedTime))) seconds"
            )
            .font(.headline)

            // Card Grid

            LazyVGrid(columns: columns, spacing: 12) {

                ForEach(cards) { card in

                    Button {
                        handleTap(card.id)
                    } label: {

                        RoundedRectangle(cornerRadius: 15)
                            .fill(
                                card.isLit
                                ? Color.yellow
                                : Color.blue
                            )
                            .frame(height: 90)
                            .overlay {
                                Image(systemName: "bolt.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(
                                        card.isLit
                                        ? .orange
                                        : .white.opacity(0.5)
                                    )
                            }
                            .scaleEffect(
                                card.isLit ? 1.08 : 1.0
                            )
                            .animation(
                                .easeInOut(duration: 0.2),
                                value: card.isLit
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!isPlaying)
                }
            }
            .padding()

            // Start / Restart Button

            if !isPlaying {

                if gameOver {

                    Text("ROUND OVER")
                        .font(.title2)
                        .bold()

                    Text("Final Score: \(score)")
                        .font(.headline)

                } else {

                    Text("Tap below to start!")
                        .foregroundColor(.secondary)
                }

                Button(gameOver ? "Play Again" : "Start Game") {
                    startGame()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(12)
                .padding(.horizontal)
            }

            Text("HIGH SCORE: \(highScore)")
                .font(.headline)

            Spacer()
        }
        .padding()
        .onReceive(timer) { _ in
            updateGame()
        }
        .onAppear {
            resetCards()
        }
    }

    // MARK: - Statistics View

    private func statView(
        title: String,
        value: String
    ) -> some View {

        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title2)
                .bold()
        }
    }

    // MARK: - Create Cards

    private func resetCards() {

        cards = (0..<currentLevel.gridCount).map {
            Card(id: $0)
        }
    }

    // MARK: - Start Game

    private func startGame() {

        score = 0
        lives = 3
        elapsedTime = 0

        currentLevel = .L1

        litCardID = nil
        litDeadline = nil

        nextSpawnTime = 0
        startTime = Date()

        gameOver = false
        isPlaying = true

        resetCards()
    }

    // MARK: - Game Timer

    private func updateGame() {

        guard isPlaying,
              let startTime = startTime else {
            return
        }

        elapsedTime = Date().timeIntervalSince(startTime)

        // End after 60 seconds

        if elapsedTime >= 60 {
            endGame()
            return
        }

        // Change levels

        let newLevel: Level

        switch elapsedTime {
        case 0..<15:
            newLevel = .L1
        case 15..<30:
            newLevel = .L2
        case 30..<45:
            newLevel = .L3
        default:
            newLevel = .L4
        }

        if newLevel != currentLevel {

            currentLevel = newLevel

            litCardID = nil
            litDeadline = nil

            nextSpawnTime = elapsedTime

            resetCards()
        }

        // Check if player missed the lit card

        if let deadline = litDeadline,
           Date() >= deadline {

            loseLife()

            if isPlaying {
                nextSpawnTime =
                    elapsedTime + currentLevel.tickInterval
            }

            return
        }

        // Light up a random card

        if litCardID == nil &&
            elapsedTime >= nextSpawnTime {

            lightRandomCard()
        }
    }

    // MARK: - Light Random Card

    private func lightRandomCard() {

        guard !cards.isEmpty else { return }

        let randomID = cards.randomElement()!.id

        litCardID = randomID

        litDeadline = Date().addingTimeInterval(
            currentLevel.litWindow
        )

        for index in cards.indices {
            cards[index].isLit = cards[index].id == randomID
        }
    }

    // MARK: - Handle Card Tap

    private func handleTap(_ id: Int) {

        guard isPlaying else { return }

        if id == litCardID {

            // Correct tap

            score += 1

            litCardID = nil
            litDeadline = nil

            for index in cards.indices {
                cards[index].isLit = false
            }

            nextSpawnTime =
                elapsedTime + currentLevel.tickInterval

        } else {

            // Wrong tap

            loseLife()
        }
    }

    // MARK: - Lose Life

    private func loseLife() {

        lives -= 1

        litCardID = nil
        litDeadline = nil

        for index in cards.indices {
            cards[index].isLit = false
        }

        if lives <= 0 {
            endGame()
        }
    }

    // MARK: - End Game

    private func endGame() {

        isPlaying = false
        gameOver = true

        if score > highScore {
            highScore = score
        }

        litCardID = nil
        litDeadline = nil
    }
}

