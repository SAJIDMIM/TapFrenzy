
import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {

                Text("MY GAMES")
                    .font(.largeTitle)
                    .bold()

                Text("Choose Your Game Mode")
                    .font(.headline)

                NavigationLink(destination: ContentView()) {
                    Text("Tap Frenzy")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                }

                NavigationLink(destination: LightItUpView()) {
                    Text("Light It Up")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(15)
                }
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}
