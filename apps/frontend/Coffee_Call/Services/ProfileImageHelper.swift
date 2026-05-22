import UIKit

struct ProfileImageHelper {
    private static let fileName = "profile_photo.jpg"
    
    private static var fileURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(fileName)
    }
    
    static func saveProfileImage(_ image: UIImage) {
        guard let fileURL = fileURL else { return }
        if let data = image.jpegData(compressionQuality: 0.8) {
            do {
                try data.write(to: fileURL, options: .atomic)
            } catch {
                print("Failed to save profile image: \(error.localizedDescription)")
            }
        }
    }
    
    static func loadProfileImage() -> UIImage? {
        guard let fileURL = fileURL else { return nil }
        if let data = try? Data(contentsOf: fileURL) {
            return UIImage(data: data)
        }
        return nil
    }
    
    static func clearProfileImage() {
        guard let fileURL = fileURL else { return }
        try? FileManager.default.removeItem(at: fileURL)
    }
}
