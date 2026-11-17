
import SwiftUI

struct HomeView: View {

    @AppStorage("isDarkMode") private var isDarkMode = true

    @State private var animate = false
    @State private var showContent = false

    private var accent: Color {
        Color(red: 0.30, green: 0.65, blue: 1.0)
    }

    private var background: Color {
        isDarkMode
        ? Color(red: 0.035, green: 0.045, blue: 0.09)
        : Color(red: 0.95, green: 0.96, blue: 1.0)
    }

    private var foreground: Color {
        isDarkMode ? .white : Color(red: 0.10, green: 0.12, blue: 0.20)
    }

    var body: some View {

        NavigationStack {

            ZStack {

                // MARK: Background

                background
                    .ignoresSafeArea()

                // Ambient lighting

                Circle()
                    .fill(Color.blue.opacity(isDarkMode ? 0.20 : 0.10))
                    .frame(width: 280, height: 280)
                    .blur(radius: 100)
                    .offset(x: -150, y: -300)
                    .scaleEffect(animate ? 1.2 : 0.8)

                Circle()
                    .fill(Color.purple.opacity(isDarkMode ? 0.16 : 0.08))
                    .frame(width: 250, height: 250)
                    .blur(radius: 100)
                    .offset(x: 160, y: 200)
                    .scaleEffect(animate ? 0.8 : 1.2)

                // MARK: Main Layout

                VStack(spacing: 0) {

                    header

                    ScrollView(showsIndicators: false) {

                        VStack(alignment: .leading, spacing: 28) {

                            heroSection

                            sectionHeader

                            gameCards

                            bottomSection
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 35)
                        .padding(.bottom, 30)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear {

                withAnimation(
                    .easeInOut(duration: 5)
                    .repeatForever(autoreverses: true)
                ) {
                    animate = true
                }

                withAnimation(.spring(duration: 0.8).delay(0.15)) {
                    showContent = true
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    // MARK: Header

    private var header: some View {

        HStack {

            HStack(spacing: 11) {

                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)

                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {

                    Text("NEXUS")
                        .font(.system(size: 16, weight: .black))
                        .tracking(2)
                        .foregroundColor(foreground)

                    Text("GAMING STUDIO")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(2)
                        .foregroundColor(foreground.opacity(0.45))
                }
            }

            Spacer()

            Button {

                withAnimation(.spring(duration: 0.4)) {
                    isDarkMode.toggle()
                }

            } label: {

                Image(systemName: isDarkMode
                      ? "sun.max.fill"
                      : "moon.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(isDarkMode ? .yellow : .indigo)
                    .frame(width: 45, height: 45)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(
                                foreground.opacity(0.12),
                                lineWidth: 1
                            )
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }

    // MARK: Hero

    private var heroSection: some View {

        VStack(alignment: .leading, spacing: 14) {

            HStack(spacing: 7) {

                Circle()
                    .fill(Color.green)
                    .frame(width: 7, height: 7)

                Text("YOUR GAMING DESTINATION")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundColor(foreground.opacity(0.5))
            }

            Text("Play beyond\nlimits.")
                .font(.system(size: 43, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: isDarkMode
                        ? [.white, Color.cyan.opacity(0.85)]
                        : [Color.black, Color.blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .fixedSize(horizontal: false, vertical: true)

            Text("Choose your challenge and discover\nwhat you are capable of.")
                .font(.system(size: 14, weight: .regular))
                .lineSpacing(5)
                .foregroundColor(foreground.opacity(0.55))
        }
        .offset(y: showContent ? 0 : 20)
        .opacity(showContent ? 1 : 0)
    }

    // MARK: Section Header

    private var sectionHeader: some View {

        HStack {

            VStack(alignment: .leading, spacing: 5) {

                Text("EXPLORE GAMES")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundColor(accent)

                Text("Choose your adventure")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(foreground)
            }

            Spacer()

            Text("02 GAMES")
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundColor(foreground.opacity(0.45))
        }
    }

    // MARK: Game Cards

    private var gameCards: some View {

        VStack(spacing: 18) {

            NavigationLink(destination: ContentView()) {

                ProfessionalGameCard(
                    title: "Tap Frenzy",
                    subtitle: "Speed. Focus. Reaction.",
                    category: "REFLEX CHALLENGE",
                    icon: "hand.tap.fill",
                    colors: [
                        Color(red: 0.05, green: 0.55, blue: 0.95),
                        Color(red: 0.20, green: 0.30, blue: 0.85)
                    ],
                    isDarkMode: isDarkMode
                )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: LightItUpView()) {

                ProfessionalGameCard(
                    title: "Light It Up",
                    subtitle: "Think fast. Remember more.",
                    category: "MEMORY CHALLENGE",
                    icon: "lightbulb.max.fill",
                    colors: [
                        Color(red: 0.95, green: 0.48, blue: 0.12),
                        Color(red: 0.85, green: 0.20, blue: 0.35)
                    ],
                    isDarkMode: isDarkMode
                )
            }
            .buttonStyle(.plain)
        }
        .offset(y: showContent ? 0 : 30)
        .opacity(showContent ? 1 : 0)
    }

    // MARK: Footer

    private var bottomSection: some View {

        VStack(spacing: 13) {

            Rectangle()
                .fill(foreground.opacity(0.10))
                .frame(height: 1)

            HStack {

                Text("NEXUS GAMING")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2)

                Spacer()

                Image(systemName: "sparkles")
                    .foregroundColor(accent)

                Text("MADE TO PLAY")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
            }
            .foregroundColor(foreground.opacity(0.4))
        }
        .padding(.top, 12)
    }
}

// MARK: - Professional Game Card

struct ProfessionalGameCard: View {

    let title: String
    let subtitle: String
    let category: String
    let icon: String
    let colors: [Color]
    let isDarkMode: Bool

    @State private var isPressed = false
    @State private var animateGlow = false

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            HStack {

                Text(category)
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.75))

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(.white.opacity(0.15))
                    .clipShape(Circle())
            }

            Spacer(minLength: 25)

            HStack(alignment: .bottom) {

                VStack(alignment: .leading, spacing: 8) {

                    Text(title)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                }

                Spacer()

                ZStack {

                    Circle()
                        .fill(.white.opacity(0.13))
                        .frame(width: 75, height: 75)

                    Circle()
                        .stroke(.white.opacity(0.35), lineWidth: 1)
                        .frame(width: 75, height: 75)

                    Image(systemName: icon)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.6), radius: 12)
                }
                .shadow(
                    color: .white.opacity(animateGlow ? 0.25 : 0.08),
                    radius: 18
                )
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background {

            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay {

            RoundedRectangle(cornerRadius: 26)
                .stroke(
                    .white.opacity(animateGlow ? 0.5 : 0.15),
                    lineWidth: 1
                )
        }
        .overlay(alignment: .topTrailing) {

            Circle()
                .fill(.white.opacity(0.10))
                .frame(width: 140, height: 140)
                .blur(radius: 35)
                .offset(x: 35, y: -55)
                .allowsHitTesting(false)
        }
        .shadow(
            color: colors[0].opacity(animateGlow ? 0.35 : 0.15),
            radius: animateGlow ? 22 : 10,
            y: 10
        )
        .scaleEffect(isPressed ? 0.97 : 1)
        .onAppear {

            withAnimation(
                .easeInOut(duration: 2.5)
                .repeatForever(autoreverses: true)
            ) {
                animateGlow = true
            }
        }
    }
}

// MARK: Preview

#Preview {
    HomeView()
}
