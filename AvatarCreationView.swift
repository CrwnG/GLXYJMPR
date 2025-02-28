import SwiftUI

struct AvatarCreationView: View {
    @Binding var selectedImage: UIImage?
    @Binding var currentScreen: ScreenState
    
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.black, .purple]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Crear tu Personaje")
                    .font(.title)
                    .foregroundColor(.white)
                
                if let image = selectedImage {
                    Image(uiImage: circularImage(from: image, size: CGSize(width: 150, height: 150)))
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 150, height: 150)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                } else {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 150, height: 150)
                }
                
                HStack(spacing: 20) {
                    Button("Tomar foto") {
                        sourceType = .camera
                        showingImagePicker = true
                    }
                    .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                    
                    Button("Elegir de librería") {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    }
                }
                .foregroundColor(.white)
                
                Button("Guardar y Volver al Menú") {
                    withAnimation {
                        currentScreen = .menu
                    }
                }
                .padding()
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(sourceType: sourceType) { image in
                selectedImage = image
            }
        }
    }
}
