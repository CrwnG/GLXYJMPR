import SwiftUI
import AVFoundation
import Photos
import PhotosUI
import ImagePlayground

//definir ImagePickerType
enum ImagePickerType: Identifiable {
    case camera
    case library
    
    var id: Int {
        switch self {
        case .camera: return 1
        case .library: return 2
        }
    }
}

struct AvatarCreationView: View {
    @Binding var selectedImage: UIImage?
    
    @Environment(\.supportsImagePlayground) var supportsImagePlayground
    @State private var isShowingImagePlayground = false
    @State private var imageGenerationConcept = ""
    
    @State private var pickerType: ImagePickerType? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.black, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Crear tu Personaje")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
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
                    
                    if supportsImagePlayground {
                        Button("Generar Avatar con AI") {
                            isShowingImagePlayground = true
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).stroke(Color.white, lineWidth: 2))
                        .foregroundColor(.white)
                    }
                    
                    Button("Tomar foto") {
                        requestCameraPermission {
                            pickerType = ImagePickerType.camera
                        }
                    }
                    .buttonStyle(DefaultButtonStyle())
                    
                    Button("Elegir de galería") {
                        requestGalleryPermission {
                            pickerType = ImagePickerType.library
                        }
                    }
                    .buttonStyle(DefaultButtonStyle())
                    
                    NavigationLink(destination: MenuView(selectedImage: $selectedImage)) {
                        Text("Guardar y Volver al Menú")
                            .padding()
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .sheet(item: $pickerType) { (type: ImagePickerType) in
                let source: UIImagePickerController.SourceType = (type == .camera) ? .camera : .photoLibrary
                ImagePicker(sourceType: source) { image in
                    selectedImage = image
                }
            }
            .imagePlaygroundSheet(isPresented: $isShowingImagePlayground, concept: imageGenerationConcept, sourceImage: selectedImage.map { Image(uiImage: $0) }) { url in
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    selectedImage = image
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // funciones de permisos
    private func requestCameraPermission(completion: @escaping () -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        completion()
                    } else {
                        showPermissionAlert(for: "cámara")
                    }
                }
            }
        default:
            showPermissionAlert(for: "cámara")
        }
    }
    
    private func requestGalleryPermission(completion: @escaping () -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            completion()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        completion()
                    } else {
                        showPermissionAlert(for: "galería")
                    }
                }
            }
        default:
            showPermissionAlert(for: "galería")
        }
    }
    private func showPermissionAlert(for feature: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Permiso de \(feature) requerido",
                message: "Para usar la \(feature), habilita el acceso en Ajustes.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            }
        }
    }
    
    private func showUnavailableAlert(for feature: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "\(feature.capitalized) no disponible",
                message: "Este dispositivo no soporta \(feature).",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            }
        }
    }
}
