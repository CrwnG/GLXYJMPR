import SwiftUI

struct HighscoreView: View {
    @ObservedObject var highscoreManager = HighscoreManager.shared
    
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
                        .foregroundColor(.primary) 
                        .listRowBackground(Color.clear) 
                }
                .listStyle(PlainListStyle())
                .background(Color.clear) 
                .scrollContentBackground(.hidden) 
                
                NavigationLink(destination: MenuView(selectedImage: .constant(nil))) {
                    Text("Volver al menú")
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

