import Foundation
import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {

    // MARK: - Published State
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var verificationID: String? = nil
    private let verificationIDKey = "authVerificationID"

    private var isFirebaseEnabled: Bool {
        return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }

    // MARK: - Init
    init() {
        if isFirebaseEnabled {
            // Restore verification ID if present
            self.verificationID = UserDefaults.standard.string(forKey: verificationIDKey)
            
            // Check if user is already authenticated
            if Auth.auth().currentUser != nil {
                // If they completed onboarding earlier
                if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                    self.isAuthenticated = true
                }
            }
        } else {
            // Mock auth state restore
            if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                self.isAuthenticated = true
            }
        }
    }

    // MARK: - Step 1: Send OTP
    func sendOTP(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil

        let normalizedPhone = phoneNumber.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        let normalizedDigits = normalizedPhone.dropFirst()
        guard normalizedPhone.hasPrefix("+"),
              normalizedDigits.allSatisfy(\.isNumber),
              (8...15).contains(normalizedDigits.count)
        else {
            isLoading = false
            errorMessage = AppStrings.Error.invalidPhoneNumber
            completion(false)
            return
        }

        if isFirebaseEnabled {
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        completion(false)
                        return
                    }
                    self.verificationID = verificationID
                    UserDefaults.standard.set(verificationID, forKey: self.verificationIDKey)
                    completion(true)
                }
            }
        } else {
            // Safe offline preview fallback mock flow
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
                self.verificationID = "mock-verification-id"
                UserDefaults.standard.set("mock-verification-id", forKey: self.verificationIDKey)
                completion(true)
            }
        }
    }

    // MARK: - Step 2: Verify OTP
    func verifyOTP(code: String, completion: @escaping (Bool) -> Void) {
        guard let verificationID = verificationID else {
            errorMessage = AppStrings.Error.generic
            completion(false)
            return
        }

        isLoading = true
        errorMessage = nil

        if isFirebaseEnabled {
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        completion(false)
                        return
                    }
                    self.verificationID = nil
                    UserDefaults.standard.removeObject(forKey: self.verificationIDKey)
                    completion(true)
                }
            }
        } else {
            // Safe offline preview fallback mock flow
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
                self.verificationID = nil
                UserDefaults.standard.removeObject(forKey: self.verificationIDKey)
                completion(true)
            }
        }
    }

    // MARK: - Step 3: Save Profile
    func saveProfile(name: String, image: UIImage? = nil, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil

        // Persist photo to disk immediately if provided
        if let image = image {
            ProfileImageHelper.saveProfileImage(image)
        }

        if isFirebaseEnabled {
            guard let currentUid = Auth.auth().currentUser?.uid else {
                isLoading = false
                errorMessage = AppStrings.Error.generic
                completion(false)
                return
            }

            let db = Firestore.firestore()
            db.collection("users").document(currentUid).setData([
                "uid": currentUid,
                "name": name,
                "createdAt": FieldValue.serverTimestamp()
            ], merge: true) { [weak self] error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        } else {
            // Safe offline preview fallback mock flow
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
                completion(true)
            }
        }
    }

    // MARK: - Finalize Onboarding
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isAuthenticated = true
    }

    // MARK: - Sign Out
    func signOut() {
        if isFirebaseEnabled {
            try? Auth.auth().signOut()
        }
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: verificationIDKey)
        verificationID = nil
        isAuthenticated = false
    }

    func clearError() {
        errorMessage = nil
    }
}
