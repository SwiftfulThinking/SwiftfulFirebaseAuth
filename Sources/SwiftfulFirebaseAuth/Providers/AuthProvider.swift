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
    @MainActor func authenticateUser_Google(GIDClientID: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)
    @MainActor func authenticateUser_Apple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
}

public struct UserAuthInfo: Codable {
    public let uid: String
    public let email: String?
    public let isAnonymous: Bool
    public let authProviders: [AuthProviderOption]
    public let displayName: String?
    public var firstName: String? = nil
    public var lastName: String? = nil
    public let phoneNumber: String?
    public let photoURL: URL?
    public let creationDate: Date?
    public let lastSignInDate: Date?
    
    init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        authProviders: [AuthProviderOption] = [],
        displayName: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        photoURL: URL? = nil,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.authProviders = authProviders
        self.displayName = displayName
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.photoURL = photoURL
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
    }
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.authProviders = user.providerData.compactMap({ AuthProviderOption(rawValue: $0.providerID) })
        self.displayName = user.displayName
        self.firstName = nil
        self.lastName = nil
        self.phoneNumber = user.phoneNumber
        self.photoURL = user.photoURL
        self.creationDate = user.metadata.creationDate
        self.lastSignInDate = user.metadata.lastSignInDate
    }
    
    enum CodingKeys: String, CodingKey {
        case uid = "user_id"
        case email = "email"
        case isAnonymous = "is_anonymous"
        case authProviders = "auth_providers"
        case displayName = "display_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone_number"
        case photoURL = "photo_url"
        case creationDate = "creation_date"
        case lastSignInDate = "last_sign_in_date"
    }
}

public enum AuthProviderOption: String, Codable {
    case google = "google.com"
    case apple = "apple.com"
    case email = "password"
    case mock = "mock"
}
