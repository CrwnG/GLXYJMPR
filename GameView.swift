import SwiftUI
import SpriteKit
import Foundation

struct GameView: View {
    @State private var scene: GameScene? = nil
    @State private var isGameOver = false
    @State private var currentScore = 0
    @Binding var selectedImage: UIImage?
    
    var body: some View {
        ZStack {
            //vista de SpriteKit con escena del juego
            if let gameScene = scene {
                SpriteView(scene: gameScene)
                    .ignoresSafeArea()
            }
            
            //mostrar el puntaje actual 
            VStack {
                Text("Score: \(currentScore)")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                Spacer()
            }
            
            //controles de movimiento izquierda/derecha 
            VStack {
                Spacer()
                HStack(spacing: 30) {
                    // Botón IZQUIERDA
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
                    
                    // Botón DERECHA
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
            
            //Game Over
            if isGameOver {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    Text("Game Over")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Text("Your Score: \(currentScore)")
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            if scene == nil {
                scene = makeGameScene()
                scene?.onScoreUpdate = { newScore in
                    currentScore = newScore
                }
                scene?.onGameOver = {
                    HighscoreManager.shared.addScore(self.currentScore)
                    self.isGameOver = true
                }
            }
        }
    }
    
    func makeGameScene() -> GameScene {
        let screenSize = UIScreen.main.bounds.size
        let newScene = GameScene(size: screenSize, chosenImage: selectedImage)
        newScene.scaleMode = .resizeFill
        return newScene
    }
}
