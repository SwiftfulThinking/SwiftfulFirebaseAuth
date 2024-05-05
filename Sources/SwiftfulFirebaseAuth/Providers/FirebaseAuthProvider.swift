//
//  FirebaseAuthProvider.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation
import Firebase
import FirebaseAuth

struct FirebaseAuthProvider: AuthProvider {
    
    private var auth: Auth
    
    init() {
        self.auth = Auth.auth()
    }
    
    init(firebaseAuth: Auth) {
        self.auth = firebaseAuth
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        if let currentUser = auth.currentUser {
            return UserAuthInfo(user: currentUser)
        } else {
            return nil
        }
    }
    
    @MainActor
    func authenticationDidChangeStream() -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            auth.addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }
        }
    }
    
    @MainActor
    func authenticateUser_Anonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        
        // Sign in to Firebase
        let authDataResult = try await auth.signInAnonymously()
        
        // Determines if this is the first time this user is being authenticated
        let isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? true
        
        // Convert to generic type
        let user = UserAuthInfo(user: authDataResult.user)
            
        return (user, isNewUser)
    }
    
    @MainActor
    func authenticateUser_Apple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = SignInWithAppleHelper()
        
        // Sign in to Apple account
        for try await appleResponse in helper.startSignInWithAppleFlow() {
            
            // Convert Apple Auth to Firebase credential
            let credential = OAuthProvider.credential(
                withProviderID: AuthProviderOption.apple.rawValue,
                idToken: appleResponse.token,
                rawNonce: appleResponse.nonce
            )
            
            // Sign in to Firebase
            let authDataResult = try await signInOrLink(credential: credential)
            
            var firebaserUser = authDataResult.user
            
            // Determines if this is the first time this user is being authenticated
            let isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? true
            
            if isNewUser {
                // Update Firebase user profile with info from Apple account
                if let updatedUser = try await updateUserProfile(
                    displayName: appleResponse.displayName,
                    firstName: appleResponse.firstName,
                    lastName: appleResponse.lastName,
                    photoUrl: nil
                ) {
                    firebaserUser = updatedUser
                }
            }
            
            // Convert to generic type
            let user = UserAuthInfo(user: firebaserUser)
            
            return (user, isNewUser)
        }
        
        // Should never occur - only would occur if startSignInWithAppleFlow() completed without yielding a result (success or error)
        throw AuthError.noResponse
    }
    
    @MainActor
    func authenticateUser_Google(GIDClientID: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = SignInWithGoogleHelper(GIDClientID: GIDClientID)
        
        // Sign in to Google account
        let googleResponse = try await helper.signIn()
        
        // Convert Google Auth to Firebase credential
        let credential = GoogleAuthProvider.credential(withIDToken: googleResponse.idToken, accessToken: googleResponse.accessToken)
        
        // Sign in to Firebase
        let authDataResult = try await signInOrLink(credential: credential)
        
        var firebaserUser = authDataResult.user
        
        // Determines if this is the first time this user is being authenticated
        let isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? true
        
        if isNewUser {
            // Update Firebase user profile with info from Google account
            if let updatedUser = try await updateUserProfile(
                displayName: googleResponse.displayName,
                firstName: googleResponse.firstName,
                lastName: googleResponse.lastName,
                photoUrl: googleResponse.profileImageUrl
            ) {
                firebaserUser = updatedUser
            }
        }
        
        // Convert to generic type
        let user = UserAuthInfo(user: firebaserUser)
        
        return (user, isNewUser)
    }
    
    @MainActor
    func authenticateUser_PhoneNumber_Start(phoneNumber: String) async throws {
        let helper = SignInWithPhoneHelper()
        
        // Send code to phone number
        let result = try await helper.startPhoneFlow(phoneNumber: phoneNumber)
        
        UserDefaults.auth.phoneVerificationID = result.verificationID
    }
    
    @MainActor
    func authenticateUser_PhoneNumber_Verify(code: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        guard let verificationId = UserDefaults.auth.phoneVerificationID else {
            throw AuthError.verificationIDNotFound
        }
        
        // Convert phone auth to Firebase credential
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: code)
        
        // Sign in to Firebase
        let authDataResult = try await signInOrLink(credential: credential)

        let firebaserUser = authDataResult.user
        
        // Determines if this is the first time this user is being authenticated
        let isNewUser = authDataResult.additionalUserInfo?.isNewUser ?? true

        // Convert to generic type
        let user = UserAuthInfo(user: firebaserUser)
        
        return (user, isNewUser)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = auth.currentUser else {
            throw AuthError.userNotFound
        }
        
        try await user.delete()
    }
    
    // MARK: PRIVATE
    
    
    private func signInOrLink(credential: AuthCredential) async throws -> AuthDataResult {
        // If user is anonymous, attempt to link credential to existing account. On failure, fall-back to signIn to create a new account.
        if let user = auth.currentUser, user.isAnonymous, let result = try? await user.link(with: credential) {
            return result
        }
        
        return try await auth.signIn(with: credential)
    }
    
    private func updateUserProfile(displayName: String?, firstName: String?, lastName: String?, photoUrl: URL?) async throws -> User? {
        let request = auth.currentUser?.createProfileChangeRequest()
        
        var didMakeChanges: Bool = false
        if let displayName {
            request?.displayName = displayName
            didMakeChanges = true
        }
        
        if let firstName {
            UserDefaults.auth.firstName = firstName
        }
        
        if let lastName {
            UserDefaults.auth.lastName = lastName
        }
        
        if let photoUrl {
            request?.photoURL = photoUrl
            didMakeChanges = true
        }
        
        if didMakeChanges {
            try await request?.commitChanges()
        }
        
        return auth.currentUser
    }
    
    
    private enum AuthError: LocalizedError {
        case noResponse
        case userNotFound
        case verificationCodeNotFound
        case verificationIDNotFound
        
        var errorDescription: String? {
            switch self {
            case .noResponse:
                return "Bad response."
            case .userNotFound:
                return "Current user not found."
            case .verificationCodeNotFound:
                return "Verification code not found."
            case .verificationIDNotFound:
                return "Verification ID not found."
            }
        }
    }
    
}

extension UserDefaults {
    
    static let auth = UserDefaults(suiteName: "auth_defaults")!
    
    func reset() {
        firstName = nil
        lastName = nil
        phoneVerificationID = nil
    }
    
    var firstName: String? {
        get {
            self.value(forKey: "first_name") as? String
        }
        set {
            self.setValue(newValue, forKey: "first_name")
        }
    }
    
    var lastName: String? {
        get {
            self.value(forKey: "last_name") as? String
        }
        set {
            self.setValue(newValue, forKey: "last_name")
        }
    }
    
    var phoneVerificationID: String? {
        get {
            self.value(forKey: "phone_verification_id") as? String
        }
        set {
            self.setValue(newValue, forKey: "phone_verification_id")
        }
    }
    
}
