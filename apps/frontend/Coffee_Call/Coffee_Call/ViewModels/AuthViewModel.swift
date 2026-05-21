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
    /// true  → brand new user, caller should navigate to ProfileSetupScreen
    /// false → returning user, completeOnboarding() was already called
    @Published var isNewUser: Bool = false
    /// true only on the very first ever app launch on this device.
    /// After that it stays false even across sign-outs.
    @Published var isFirstLaunch: Bool = false

    private var verificationID: String? = nil
    private let verificationIDKey = "authVerificationID"

    private var isFirebaseEnabled: Bool {
        return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }

    // MARK: - Init
    init() {
        if isFirebaseEnabled {
            // Restore any in-progress verification ID
            self.verificationID = UserDefaults.standard.string(forKey: verificationIDKey)

            // Firebase is the single source of truth for session state.
            if Auth.auth().currentUser != nil {
                self.isAuthenticated = true
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            }
        } else {
            // Offline / preview mock mode — fall back to local flag only.
            if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                self.isAuthenticated = true
            }
        }

        // First launch = app has never been opened on this device.
        // We track this separately so sign-out users skip the marketing slides.
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            self.isFirstLaunch = true
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

                    // Check Firestore to decide if this is a new or returning user.
                    // Returning users already have a 'name' field — skip profile setup.
                    guard let uid = Auth.auth().currentUser?.uid else {
                        self.isNewUser = true
                        completion(true)
                        return
                    }
                    let db = Firestore.firestore()
                    db.collection("users").document(uid).getDocument { snapshot, _ in
                        DispatchQueue.main.async {
                            let hasProfile = (snapshot?.data()?["name"] as? String)?.isEmpty == false
                            if hasProfile {
                                // Existing user — go straight to the main app.
                                self.isNewUser = false
                                self.completeOnboarding()
                            } else {
                                // New user — caller navigates to ProfileSetupScreen.
                                self.isNewUser = true
                            }
                            completion(true)
                        }
                    }
                }
            }
        } else {
            // Offline / preview mock mode — treat as new user so profile setup is reachable.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
                self.verificationID = nil
                UserDefaults.standard.removeObject(forKey: self.verificationIDKey)
                self.isNewUser = true
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
