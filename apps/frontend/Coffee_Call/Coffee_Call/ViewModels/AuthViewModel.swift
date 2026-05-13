import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {

    // MARK: - Published State
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // Internal: store verification ID between steps
    private var verificationID: String? = nil
    private let db = Firestore.firestore()
    private var otpTimeoutTask: DispatchWorkItem?

    // MARK: - Init (check existing session)
    init() {
        let isFirebaseAuthed = Auth.auth().currentUser != nil
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        isAuthenticated = isFirebaseAuthed && hasCompletedOnboarding

        #if targetEnvironment(simulator)
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        #endif
    }

    // MARK: - Step 1: Send OTP
    func sendOTP(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        otpTimeoutTask?.cancel()



        let timeoutTask = DispatchWorkItem { [weak self] in
            guard let self = self, self.isLoading else { return }
            self.isLoading = false
            self.errorMessage = AppStrings.Error.otpTimeout
            completion(false)
        }
        otpTimeoutTask = timeoutTask
        DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: timeoutTask)

        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            DispatchQueue.main.async {
                self?.otpTimeoutTask?.cancel()
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("[AuthViewModel] sendOTP error: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let verificationID = verificationID, !verificationID.isEmpty else {
                    self?.errorMessage = AppStrings.Error.missingVerificationID
                    completion(false)
                    return
                }

                self?.verificationID = verificationID
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

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )

        Auth.auth().signIn(with: credential) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = AppStrings.Error.incorrectCode
                    print("[AuthViewModel] OTP Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }

    // MARK: - Step 3: Save Profile to Firestore
    func saveProfile(name: String, completion: @escaping (Bool) -> Void) {
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
            "phone": user.phoneNumber ?? "",
            "createdAt": Timestamp(date: Date()),
            "interests": []
        ]

        db.collection("users").document(user.uid).setData(data) { [weak self] error in
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
        try? Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        isAuthenticated = false
    }
}
