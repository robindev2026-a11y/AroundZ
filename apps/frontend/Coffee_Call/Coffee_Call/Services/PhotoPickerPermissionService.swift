import Foundation
import AVFoundation

protocol PhotoPickerPermissionService {
    func requestCameraPermission(completion: @escaping (Bool) -> Void)
}

class DefaultPhotoPickerPermissionService: PhotoPickerPermissionService {
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        default:
            completion(false)
        }
    }
}
