import SwiftUI
import AVFoundation
import Photos

struct AvatarCreationView: View {
    @Binding var selectedImage: UIImage?
    @Binding var currentScreen: ScreenState
    
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType?
    
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
                        requestCameraPermission {
                            DispatchQueue.main.async {
                                sourceType = .camera
                                showingImagePicker = true
                            }
                        }
                    }
                    .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                    
                    Button("Elegir de galería") {
                        requestGalleryPermission {
                            DispatchQueue.main.async {
                                sourceType = .photoLibrary
                                showingImagePicker = true
                            }
                        }
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
        .sheet(isPresented: Binding(
            get: { showingImagePicker && sourceType != nil },
            set: { newValue in
                if !newValue {
                    showingImagePicker = false
                    sourceType = nil
                }
            }
        )) {
            if let source = sourceType {
                ImagePicker(sourceType: source) { image in
                    selectedImage = image
                }
            }
        }
    }
    
    ///solicta permiso para la cámara
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
        case .denied, .restricted:
            showPermissionAlert(for: "cámara")
        @unknown default:
            showPermissionAlert(for: "cámara")
        }
    }
    
    /// permiso para la galería
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
        case .denied, .restricted:
            showPermissionAlert(for: "galería")
        @unknown default:
            showPermissionAlert(for: "galería")
        }
    }
    
    ///muestra una alerta si los permisos son denegados
    private func showPermissionAlert(for feature: String) {
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
