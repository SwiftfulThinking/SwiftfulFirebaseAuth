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
    public let uid: String
    public let email: String?
    public let isAnonymous: Bool
    public let authProviders: [AuthProviderOption]
    public let displayName: String?
    public let phoneNumber: String?
    public let photoURL: URL?
    
    init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        authProviders: [AuthProviderOption] = [],
        displayName: String? = nil,
        phoneNumber: String? = nil,
        photoURL: URL? = nil
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.authProviders = authProviders
        self.displayName = displayName
        self.phoneNumber = phoneNumber
        self.photoURL = photoURL
    }
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.authProviders = user.providerData.compactMap({ AuthProviderOption(rawValue: $0.providerID) })
        self.displayName = user.displayName
        self.phoneNumber = user.phoneNumber
        self.photoURL = user.photoURL
    }
}

public enum AuthProviderOption: String {
    case google = "google.com"
    case apple = "apple.com"
    case email = "password"
    case mock = "mock"
}
