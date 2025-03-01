import SwiftUI

struct ContentView: View {
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        NavigationStack {
                MenuView(selectedImage: $selectedImage)
        }
    }
}
