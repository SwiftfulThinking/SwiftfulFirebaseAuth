//
//  MockAuthProvider.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation

final class MockAuthProvider: AuthProvider {
    
    private var mockUser: UserAuthInfo {
        UserAuthInfo(
            uid: "mock123",
            email: "mock123@mock.com",
            isAnonymous: false,
            authProviders: [.mock],
            displayName: "Mock User",
            phoneNumber: "1-234-5678"
        )
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        if UserDefaults.userIsSignedIn {
            return mockUser
        }
        
        return nil
    }
    
    func authenticationDidChangeStream() -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            continuation.yield(getAuthenticatedUser())
        }
    }
    
    func authenticateUser_Google() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return signInMockUser()
    }
        
    func authenticateUser_Apple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        return signInMockUser()
    }
    
    private func signInMockUser() -> (user: UserAuthInfo, isNewUser: Bool) {
        let count = UserDefaults.userSignedInAuthCount
        let newCount = count + 1
        
        // Increment auth count
        UserDefaults.userSignedInAuthCount = newCount
        
        // Persist mock sign in
        UserDefaults.userIsSignedIn = true
        
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
        UserDefaults.userIsSignedIn = false
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
