//
//  MockAuthProvider.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation
import Combine

final class MockAuthProvider: AuthProvider {
    
    static private var mockUser: UserAuthInfo {
        UserAuthInfo(
            uid: "mock123",
            email: "mock123@mock.com",
            isAnonymous: false,
            authProviders: [.mock],
            displayName: "Mock User",
            phoneNumber: "1-234-5678"
        )
    }
    
    @Published private(set) var authenticatedUser: UserAuthInfo? {
        didSet {
            UserDefaults.userIsSignedIn = authenticatedUser != nil
            continuation?.yield(authenticatedUser)
        }
    }
    
    init() {
        self.authenticatedUser = UserDefaults.userIsSignedIn ? MockAuthProvider.mockUser : nil
    }
    
    private var continuation: AsyncStream<UserAuthInfo?>.Continuation? = nil
    
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        authenticatedUser
    }
    
    func authenticationDidChangeStream() -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }
    
    func authenticateUser_Google(GIDClientID: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return signInMockUser()
    }
    
    func authenticateUser_Apple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return signInMockUser()
    }
    
    func authenticateUser_PhoneNumber(phoneNumber: String, verificationCode: String?) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        // Check if verification code is provided
        if let code = verificationCode {
            // If verification code is provided, proceed with authentication
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            return signInMockUser()
        } else {
            // If verification code is not provided, return a default user info and mark as not new user
            let defaultUser = UserAuthInfo(uid: "", isAnonymous: true)
            return (defaultUser, false)
        }
    }
    
    private func signInMockUser() -> (user: UserAuthInfo, isNewUser: Bool) {
        let count = UserDefaults.userSignedInAuthCount
        let newCount = count + 1
        
        // Increment auth count
        UserDefaults.userSignedInAuthCount = newCount
        
        
        // Persist mock sign in
        let mockUser = MockAuthProvider.mockUser
        authenticatedUser = mockUser
        
        let isNewUser = newCount == 1
        return (mockUser, isNewUser)
    }
    
    func signOut() throws {
        signOutMockUser()
    }
    
    func deleteAccount() async throws {
        signOutMockUser()
    }
    
    private func signOutMockUser() {
        // Reset auth count
        UserDefaults.userSignedInAuthCount = 0
        
        // Persist mock sign out
        authenticatedUser = nil
    }
    
}

private extension UserDefaults {
    
    private static let MockAuthDefaults = UserDefaults(suiteName: "SwiftfulFirebaseAuth_MockDefaults") ?? .standard
    
    private static let userIsSignedIn_key = "mock_user_signed_in"
    static var userIsSignedIn: Bool {
        get {
            return MockAuthDefaults.bool(forKey: userIsSignedIn_key)
        }
        set {
            return MockAuthDefaults.set(newValue, forKey: userIsSignedIn_key)
        }
    }
    
    private static let userSignedInAuthCount_key = "mock_user_signed_in_auth_count"
    static var userSignedInAuthCount: Int {
        get {
            return MockAuthDefaults.integer(forKey: userSignedInAuthCount_key)
        }
        set {
            return MockAuthDefaults.set(newValue, forKey: userSignedInAuthCount_key)
        }
    }
}
