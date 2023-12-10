//
//  AuthManager.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation

public struct AuthInfo {
    public let profile: UserAuthInfo?
    
    public var userId: String? {
        profile?.uid
    }
    
    public var isSignedIn: Bool {
        profile != nil
    }
}

public enum Configuration {
    case mock, firebase
    
    var provider: AuthProvider {
        switch self {
        case .firebase:
            return FirebaseAuthProvider()
        case .mock:
            return MockAuthProvider()
        }
    }
}

public final class AuthManager {
    
    private let provider: AuthProvider
    
    @Published public private(set) var currentUser: AuthInfo
    private var task: Task<Void, Never>? = nil
    
    public init(configuration: Configuration) {
        self.provider = configuration.provider
        self.currentUser = AuthInfo(profile: provider.getAuthenticatedUser())
        self.streamSignInChangesIfNeeded()
    }
    
    func getUserId() throws -> String {
        guard let id = currentUser.userId else {
            // If there is no userId, user should not be signed in.
            // Sign out anyway, in case there's an edge case?
            defer {
                try? signOut()
            }
            
            throw AuthManagerError.noUserId
        }
        
        return id
    }
    
    enum AuthManagerError: Error {
        case noUserId
    }
    
    private func streamSignInChangesIfNeeded() {
        // Only stream changes if a user is signed in
        // This is mainly for if their auth gets removed via Firebase Console or another application, we can automatically sign user out
        // However, we don't want to stream user signing in, since the signIn() methods should confirm sign in success
        guard currentUser.isSignedIn else { return }
        
        self.task = Task {
            for await user in await provider.authenticationDidChangeStream() {
                currentUser = AuthInfo(profile: user)
            }
        }
    }
    
    public func signInGoogle(GIDClientID: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let value = try await provider.authenticateUser_Google(GIDClientID: GIDClientID)
        currentUser = AuthInfo(profile: value.user)
        
        defer {
            streamSignInChangesIfNeeded()
        }
        
        return value
    }
    
    public func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let value = try await provider.authenticateUser_Apple()
        currentUser = AuthInfo(profile: value.user)

        defer {
            streamSignInChangesIfNeeded()
        }
        
        return value
    }
    
    public func signOut() throws {
        try provider.signOut()
        clearLocalData()
    }
    
    public func deleteAuthentication() async throws {
        try await provider.deleteAccount()
        clearLocalData()
    }
    
    private func clearLocalData() {
        task?.cancel()
        task = nil
        UserDefaults.auth.reset()
        currentUser = AuthInfo(profile: nil)
    }
}
