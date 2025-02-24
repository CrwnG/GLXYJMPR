import AVFoundation

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?
    
    func playSound(_ soundName: String) {
        // Agrega "menu.mp3" y "jump.wav" en Resources
        guard let url = Bundle.main.url(forResource: soundName, withExtension: nil) else {
            print("No se encontró el sonido: \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error al reproducir sonido: \(error)")
        }
    }
}
