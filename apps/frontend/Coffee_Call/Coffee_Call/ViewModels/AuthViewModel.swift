import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {

    // MARK: - Published State
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var verificationID: String? = nil
    private lazy var db: Firestore? = {
        guard FirebaseApp.app() != nil else { return nil }
        return Firestore.firestore()
    }()
    private let verificationIDKey = "authVerificationID"

    // MARK: - Init (check existing session)
    init() {
        // Safe offline/JIT configuration for Previews
        if FirebaseApp.app() == nil {
            let bundle = Bundle(for: AppDelegate.self)
            let plistPath =
                Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") ??
                Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist", inDirectory: "App") ??
                bundle.path(forResource: "GoogleService-Info", ofType: "plist") ??
                bundle.path(forResource: "GoogleService-Info", ofType: "plist", inDirectory: "App")

            if let plistPath, let options = FirebaseOptions(contentsOfFile: plistPath) {
                FirebaseApp.configure(options: options)
            }
        }

        if FirebaseApp.app() != nil {
            Auth.auth().languageCode = "en"
            verificationID = UserDefaults.standard.string(forKey: verificationIDKey)

            let isFirebaseAuthed = Auth.auth().currentUser != nil
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
            isAuthenticated = isFirebaseAuthed && hasCompletedOnboarding
        } else {
            // Preview/Offline default
            isAuthenticated = false
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

        guard FirebaseApp.app() != nil else {
            // Safe offline preview fallback mock flow
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
                self.verificationID = "mock-verification-id"
                UserDefaults.standard.set("mock-verification-id", forKey: self.verificationIDKey)
                completion(true)
            }
            return
        }

        PhoneAuthProvider.provider().verifyPhoneNumber(normalizedPhone, uiDelegate: nil) { [weak self] verificationID, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }

                guard let verificationID = verificationID, !verificationID.isEmpty else {
                    self.errorMessage = AppStrings.Error.missingVerificationID
                    completion(false)
                    return
                }

                self.verificationID = verificationID
                UserDefaults.standard.set(verificationID, forKey: self.verificationIDKey)
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

        guard FirebaseApp.app() != nil else {
            // Safe offline preview fallback mock flow
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
                self.verificationID = nil
                UserDefaults.standard.removeObject(forKey: self.verificationIDKey)
                completion(true)
            }
            return
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )

        Auth.auth().signIn(with: credential) { [weak self] _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false
                if let error = error {
                    self.errorMessage = AppStrings.Error.incorrectCode
                    completion(false)
                    return
                }
                
                self.verificationID = nil
                UserDefaults.standard.removeObject(forKey: self.verificationIDKey)
                completion(true)
            }
        }
    }

    // MARK: - Step 3: Save Profile to Firestore
    func saveProfile(name: String, completion: @escaping (Bool) -> Void) {
        guard FirebaseApp.app() != nil else {
            // Safe offline preview fallback mock flow
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
                completion(true)
            }
            return
        }

        guard let user = Auth.auth().currentUser else {
            errorMessage = AppStrings.Error.notSignedIn
            completion(false)
            return
        }

        isLoading = true
        errorMessage = nil

        let data: [String: Any] = [
            "uid": user.uid,
            "name": name,
            "phoneNumber": user.phoneNumber ?? "",
            "createdAt": Timestamp(date: Date()),
            "interests": []
        ]

        guard let db = db else {
            isLoading = false
            completion(true)
            return
        }

        db.collection("users").document(user.uid).setData(data, merge: true) { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                // Profile saved successfully, but don't set isAuthenticated = true yet.
                // Wait for the user to complete the remaining onboarding screens.
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
        if FirebaseApp.app() != nil {
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
