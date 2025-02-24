import SwiftUI

struct MenuView: View {
    @Binding var currentScreen: ScreenState
    @Binding var selectedImage: UIImage?
    
    @State private var showAlert = false
    @State private var animateTitle = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.blue]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("Galaxy Jumper")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .scaleEffect(animateTitle ? 1.1 : 0.9)
                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true),
                               value: animateTitle)
                    .onAppear { animateTitle = true }
                
                if let img = selectedImage {
                    Image(uiImage: circularImage(from: img, size: CGSize(width: 100, height: 100)))
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 100, height: 100)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(radius: 10)
                } else {
                    Image(systemName: "star.circle.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                }
                
                Button(action: {
                    SoundManager.shared.playSound("menu.mp3")
                    withAnimation {
                        currentScreen = .avatarCreation
                    }
                }) {
                    Text("Crear Personaje")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 50)
                
                Button(action: {
                    if selectedImage == nil {
                        showAlert = true
                    } else {
                        withAnimation {
                            currentScreen = .game
                        }
                    }
                }) {
                    Text("Jugar")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 50)
                
                Button(action: {
                    withAnimation {
                        currentScreen = .highscore
                    }
                }) {
                    Text("Highscores")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 50)
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Atención"),
                  message: Text("No puedes jugar sin crear un personaje primero."),
                  dismissButton: .default(Text("OK")))
        }
    }
}
