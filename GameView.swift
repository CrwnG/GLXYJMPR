import SwiftUI
import SpriteKit

struct GameView: View {
    var selectedImage: UIImage?
    @Binding var currentScreen: ScreenState
    
    @State private var scene: GameScene? = nil
    @State private var isGameOver = false
    @State private var currentScore = 0
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene ?? makeGameScene())
                .ignoresSafeArea()
            
            VStack {
                Text("Score: \(currentScore)")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack(spacing: 30) {
                    // Botón IZQUIERDA (presionable)
                    PressableButton(
                        onPressDown: {
                            scene?.horizontalInput = -1
                        },
                        onPressUp: {
                            scene?.horizontalInput = 0
                        }
                    ) {
                        Text("←")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.white.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    // Botón DETENER (tap normal)
                    Button(action: {
                        scene?.horizontalInput = 0
                    }) {
                        Text("⏹")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.white.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    // Botón DERECHA (presionable)
                    PressableButton(
                        onPressDown: {
                            scene?.horizontalInput = 1
                        },
                        onPressUp: {
                            scene?.horizontalInput = 0
                        }
                    ) {
                        Text("→")
                            .font(.largeTitle)
                            .padding()
                            .background(Color.white.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 40)
            }
            
            if isGameOver {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    Text("Game Over")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Text("Your Score: \(currentScore)")
                        .foregroundColor(.white)
                    
                    Button("Menú") {
                        currentScreen = .menu
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .onAppear {
            let newScene = makeGameScene()
            newScene.onScoreUpdate = { newScore in
                currentScore = newScore
            }
            newScene.onGameOver = {
                HighscoreManager.shared.addScore(currentScore)
                DispatchQueue.main.async {
                    isGameOver = true
                }
            }
            scene = newScene
        }
    }
    
    func makeGameScene() -> GameScene {
        // Usar tamaño real de la pantalla
        let screenSize = UIScreen.main.bounds.size
        let newScene = GameScene(size: screenSize, chosenImage: selectedImage)
        newScene.scaleMode = .resizeFill
        return newScene
    }
}
