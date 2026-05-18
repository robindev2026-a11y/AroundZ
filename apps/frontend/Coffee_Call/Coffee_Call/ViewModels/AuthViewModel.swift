import Foundation
// import FirebaseCore
// import FirebaseAuth
// import FirebaseFirestore

class AuthViewModel: ObservableObject {

    // MARK: - Published State
    @Published var isAuthenticated: Bool = true
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var verificationID: String? = nil
    private let verificationIDKey = "authVerificationID"

    // MARK: - Init (stubbed)
    init() {
        // Firebase has been commented out to load faster and support offline demoing.
    }

    // MARK: - Step 1: Send OTP (Mock)
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

        // Safe offline preview fallback mock flow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            self.verificationID = "mock-verification-id"
            UserDefaults.standard.set("mock-verification-id", forKey: self.verificationIDKey)
            completion(true)
        }
    }

    // MARK: - Step 2: Verify OTP (Mock)
    func verifyOTP(code: String, completion: @escaping (Bool) -> Void) {
        guard let verificationID = verificationID else {
            errorMessage = AppStrings.Error.generic
            completion(false)
            return
        }

        isLoading = true
        errorMessage = nil

        // Safe offline preview fallback mock flow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            self.verificationID = nil
            UserDefaults.standard.removeObject(forKey: self.verificationIDKey)
            completion(true)
        }
    }

    // MARK: - Step 3: Save Profile (Mock)
    func saveProfile(name: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil

        // Safe offline preview fallback mock flow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            completion(true)
        }
    }

    // MARK: - Finalize Onboarding
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isAuthenticated = true
    }

    // MARK: - Sign Out
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: verificationIDKey)
        verificationID = nil
        isAuthenticated = false
    }

    func clearError() {
        errorMessage = nil
    }
}

