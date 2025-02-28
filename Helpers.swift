import SwiftUI
import SpriteKit

//Navegación
enum ScreenState {
    case menu
    case avatarCreation
    case game
    case highscore
}

//HighscoreManager
class HighscoreManager: ObservableObject {
    static let shared = HighscoreManager()
    @Published var highscores: [Int] = []
    
    private let key = "highscores"
    
    init(){
        loadScores()
        resetScores()
    }
    
    func addScore(_ newScore: Int) {
        highscores.append(newScore)
        highscores.sort(by: >)
        if highscores.count > 10 {
            highscores.removeLast()
        }
        saveScores()
    }
    
    private func saveScores(){
        UserDefaults.standard.set(highscores, forKey: key)
    }
    
    private func loadScores(){
        if let savedScores = UserDefaults.standard.array(forKey: key) as? [Int]{
            highscores = savedScores
        } else {
            highscores = []
        } 
    }
    
    func resetScores(){
        highscores = []
        UserDefaults.standard.removeObject(forKey: key)
    }
}

//Función para recortar imagen en círculo
func circularImage(from image: UIImage, size: CGSize) -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { _ in
        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(ovalIn: rect).addClip()
        image.draw(in: rect)
    }
}

//ImagePicker
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
