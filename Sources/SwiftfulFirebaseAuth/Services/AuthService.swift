//
//  AuthProvider.swift
//  
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation
import FirebaseAuth

public protocol AuthService: Sendable {
    func getAuthenticatedUser() -> UserAuthInfo?
    func authenticationDidChangeStream() -> AsyncStream<UserAuthInfo?>
    func authenticateUser_Google(GIDClientID: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func authenticateUser_Apple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
}

public enum AuthServiceOption: Equatable, Sendable {
    case mock(_ option: MockUserServiceOption), firebase
    
    var service: AuthService {
        switch self {
        case .mock(let config):
            return MockAuthService(config: config)
        case .firebase:
            return FirebaseAuthService()
        }
    }
    
    
    public enum MockUserServiceOption: Equatable, Sendable {
        case startFromSavedState, startSignedIn, startSignedOut
    }
}
