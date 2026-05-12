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

    // MARK: - Init (check existing session)
    init() {
        isAuthenticated = Auth.auth().currentUser != nil
    }

    // MARK: - Step 1: Send OTP
    func sendOTP(phoneNumber: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil

        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
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
            errorMessage = "Something went wrong. Please try again."
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
                    self?.errorMessage = "Incorrect code. Please try again."
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
            errorMessage = "Not signed in."
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
                self?.isAuthenticated = true
                completion(true)
            }
        }
    }

    // MARK: - Sign Out
    func signOut() {
        try? Auth.auth().signOut()
        isAuthenticated = false
    }
}
