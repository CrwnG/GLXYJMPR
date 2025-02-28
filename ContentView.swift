import SwiftUI

struct ContentView: View {
    @State private var currentScreen: ScreenState = .menu
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        switch currentScreen {
        case .menu:
            MenuView(currentScreen: $currentScreen, selectedImage: $selectedImage)
        case .avatarCreation:
            AvatarCreationView(selectedImage: $selectedImage, currentScreen: $currentScreen)
        case .game:
            if selectedImage == nil {
                AvatarCreationView(selectedImage: $selectedImage, currentScreen: $currentScreen)
            } else {
                GameView(selectedImage: selectedImage, currentScreen: $currentScreen)
            }
        case .highscore:
            HighscoreView(currentScreen: $currentScreen)
        }
    }
}
