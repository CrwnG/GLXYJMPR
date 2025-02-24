import SwiftUI

struct HighscoreView: View {
    @ObservedObject var highscoreManager = HighscoreManager()
    @Binding var currentScreen: ScreenState
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.purple, .black]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Highscores")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                List {
                    ForEach(highscoreManager.highscores, id: \.self) { score in
                        Text("Score: \(score)")
                            .foregroundColor(.black)
                    }
                }
                .listStyle(PlainListStyle())
                
                Button("Volver al Menú") {
                    withAnimation {
                        currentScreen = .menu
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
    }
}
