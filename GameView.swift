import SwiftUI
import SpriteKit

struct GameView: View {
    var selectedImage: UIImage?
    
    @State private var jumpSliderValue: Double = 0.0
    @State private var gameScene: GameScene? = nil
    
    var body: some View {
        ZStack {
            SpriteView(scene: gameScene ?? makeGameScene())
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Slider(value: $jumpSliderValue, in: 0...1, step: 0.01)
                    .padding()
                    .onChange(of: jumpSliderValue) { newValue in
                        if newValue >= 0.99 {
                            gameScene?.jump()
                            jumpSliderValue = 0.0
                        }
                    }
            }
        }
        .onAppear {
            // Crear la escena al aparecer la vista
            gameScene = GameScene(size: CGSize(width: 375, height: 667), chosenImage: selectedImage)
        }
    }
    
    func makeGameScene() -> SKScene {
        let scene = GameScene(size: CGSize(width: 375, height: 667), chosenImage: selectedImage)
        scene.scaleMode = .resizeFill
        return scene
    }
}
