import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FishListView()
                .tabItem {
                    Label("Fish", systemImage: "fish")
                }
            
            BaitsListView()
                .tabItem {
                    Label("Baits", systemImage: "leaf.arrow.circlepath")
                }
            
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "chart.bar.fill")
                }
            
            TipsView()
                .tabItem {
                    Label("Tips", systemImage: "lightbulb.fill")
                }
            
            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "questionmark.circle.fill")
                }
        }
        .accentColor(.lightCyan)
        .background(Color.midnightIce.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
