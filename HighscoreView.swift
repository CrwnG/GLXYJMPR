import SwiftUI

struct HighscoreView: View {
    @ObservedObject var highscoreManager = HighscoreManager.shared
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
                
                List(highscoreManager.highscores.indices, id: \.self) { index in
                        Text("\(index + 1). Score: \(highscoreManager.highscores[index])")
                            .foregroundColor(.white)
                    }
                }
                .listStyle(PlainListStyle())
                
                Button("Volver al menú") {
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
