import SwiftUI
import PhotosUI

// MARK: - Source

enum PhotoPickerSource {
    case library
    case camera
}

// MARK: - Modifier

struct PhotoPickerModifier: ViewModifier {
    @Binding var source: PhotoPickerSource?
    var onImagePicked: (UIImage) -> Void

    @State private var showCameraPermissionAlert = false
    @State private var showLibraryPicker = false
    @State private var showCameraPicker = false

    private let permissionService: PhotoPickerPermissionService = DefaultPhotoPickerPermissionService()

    func body(content: Content) -> some View {
        content
            .onChange(of: source) { newSource in
                guard let newSource else { return }
                switch newSource {
                case .library:
                    showLibraryPicker = true
                case .camera:
                    permissionService.requestCameraPermission { granted in
                        if granted {
                            showCameraPicker = true
                        } else {
                            showCameraPermissionAlert = true
                        }
                        source = nil
                    }
                }
            }
            .onChange(of: showLibraryPicker) { showing in
                if !showing { source = nil }
            }
            // Library picker (out-of-process, no permission required)
            .sheet(isPresented: $showLibraryPicker) {
                LibraryPicker { image in
                    onImagePicked(image)
                }
                .ignoresSafeArea()
            }
            // Camera picker (requires AVCaptureDevice permission)
            .fullScreenCover(isPresented: $showCameraPicker) {
                CameraPicker { image in
                    onImagePicked(image)
                }
                .ignoresSafeArea()
            }
            // Permission denied alert
            .alert("Camera Access Required", isPresented: $showCameraPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("CoffeeCall needs camera access to take a profile photo. You can enable this in Settings.")
            }
    }
}

// MARK: - View Extension

extension View {
    func photoPicker(
        source: Binding<PhotoPickerSource?>,
        onImagePicked: @escaping (UIImage) -> Void
    ) -> some View {
        self.modifier(PhotoPickerModifier(source: source, onImagePicked: onImagePicked))
    }
}
