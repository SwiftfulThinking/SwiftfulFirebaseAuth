//
//  AuthProvider.swift
//  
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation
import FirebaseAuth

public protocol AuthProvider {
    func getAuthenticatedUser() -> UserAuthInfo?
    @MainActor func authenticationDidChangeStream() -> AsyncStream<UserAuthInfo?>
    @MainActor func authenticateUser_Google() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    @MainActor func authenticateUser_Apple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
}

public struct UserAuthInfo {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let authProviders: [AuthProviderOption]
    let displayName: String?
    let phoneNumber: String?
    
    init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        authProviders: [AuthProviderOption] = [],
        displayName: String? = nil,
        phoneNumber: String? = nil
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.authProviders = authProviders
        self.displayName = displayName
        self.phoneNumber = phoneNumber
    }
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.authProviders = user.providerData.compactMap({ AuthProviderOption(rawValue: $0.providerID) })
        self.displayName = user.displayName
        self.phoneNumber = user.phoneNumber
    }
}

enum AuthProviderOption: String {
    case google = "google.com"
    case apple = "apple.com"
    case email = "password"
    case mock = "mock"
}
