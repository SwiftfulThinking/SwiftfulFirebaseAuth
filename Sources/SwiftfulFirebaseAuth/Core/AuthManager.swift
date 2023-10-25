//
//  AuthManager.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation

public struct AuthInfo {
    let profile: UserAuthInfo?
    
    var userId: String? {
        profile?.uid
    }
    
    var isSignedIn: Bool {
        profile != nil
    }
}

public final class AuthManager {
    
    private let provider: AuthProvider
    
    @Published public private(set) var currentUser: AuthInfo?
    
    public init(provider: AuthProvider) {
        self.provider = provider
        self.currentUser = AuthInfo(profile: provider.getAuthenticatedUser())
        self.streamSignInChanges()
    }
    
    private func streamSignInChanges() {
        Task {
            for await user in await provider.authenticationDidChangeStream() {
                currentUser = AuthInfo(profile: user)
            }
        }
    }
    
    public func signInGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await provider.authenticateUser_Google()
    }
    
    public func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await provider.authenticateUser_Apple()
    }
    
    public func signOut() throws {
        try provider.signOut()
    }
    
    public func deleteAuthentication() async throws {
        try await provider.deleteAccount()
    }
}
