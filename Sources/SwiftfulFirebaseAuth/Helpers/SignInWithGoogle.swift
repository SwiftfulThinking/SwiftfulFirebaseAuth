//
//  File.swift
//  
//
//  Created by Nick Sarno on 10/25/23.
//

import Foundation
import SwiftUI
import UIKit
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResult {
    let idToken: String
    let accessToken: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let fullName: String?
    let profileImageUrl: URL?
    
    var displayName: String? {
        fullName ?? firstName ?? lastName
    }
    
    init?(result: GIDSignInResult) {
        guard let idToken = result.user.idToken?.tokenString else {
            return nil
        }

        self.idToken = idToken
        self.accessToken = result.user.accessToken.tokenString
        self.email = result.user.profile?.email
        self.firstName = result.user.profile?.givenName
        self.lastName = result.user.profile?.familyName
        self.fullName = result.user.profile?.name
        
        let dimension = round(400 * UIScreen.main.scale)
        
        if result.user.profile?.hasImage == true {
            self.profileImageUrl = result.user.profile?.imageURL(withDimension: UInt(dimension))
        } else {
            self.profileImageUrl = nil
        }
    }
}

final class SignInWithGoogleHelper {
    
    init(GIDClientID: String) {
        let config = GIDConfiguration(clientID: GIDClientID)
        GIDSignIn.sharedInstance.configuration = config
    }
        
    @MainActor
    func signIn(viewController: UIViewController? = nil) async throws -> GoogleSignInResult {
        guard let topViewController = viewController ?? UIApplication.topViewController() else {
            throw GoogleSignInError.noViewController
        }
                
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)
        
        guard let result = GoogleSignInResult(result: gidSignInResult) else {
            throw GoogleSignInError.badResponse
        }
        
        return result
    }
    
    private enum GoogleSignInError: LocalizedError {
        case noViewController
        case badResponse
        
        var errorDescription: String? {
            switch self {
            case .noViewController:
                return "Could not find top view controller."
            case .badResponse:
                return "Google Sign In had a bad response."
            }
        }
    }
}
