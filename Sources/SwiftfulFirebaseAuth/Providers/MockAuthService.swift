//
//  MockAuthProvider.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation
import Combine

@MainActor class MockAuthDatabase {
    static let instance = MockAuthDatabase()

    //@FileManagerCodable("mock_user_profile") // TODO - FIX ME AND SAVE?
    private(set) var currentUser: UserAuthInfo?
    
    @discardableResult
    func signIn() -> (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo.mock
        currentUser = user
        return (user, false)
    }
    
    func signOut() {
        currentUser = nil
    }
}

struct MockAuthService: AuthService {
    
    let config: AuthServiceOption.MockUserServiceOption
    
    @MainActor func getAuthenticatedUser() -> UserAuthInfo? {
        switch config {
        case .startFromSavedState:
            return MockAuthDatabase.instance.currentUser
        case .startSignedIn:
            MockAuthDatabase.instance.signIn()
            return MockAuthDatabase.instance.currentUser
        case .startSignedOut:
            MockAuthDatabase.instance.signOut()
            return nil
        }
    }
    
    func authenticationDidChangeStream() -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
        }
    }
    
    @MainActor func authenticateUser_Google(GIDClientID: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return MockAuthDatabase.instance.signIn()
    }
      
    @MainActor func authenticateUser_Apple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return MockAuthDatabase.instance.signIn()
    }
    
    @MainActor func signOut() throws {
        MockAuthDatabase.instance.signOut()
    }
    
    func deleteAccount() async throws {
        await MockAuthDatabase.instance.signOut()
    }
    
}
