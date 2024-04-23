//
//  ASAuthorizationAppleIDButton.swift
//
//
//  Created by Nick Sarno on 4/22/24.
//

import Foundation
import SwiftUI
import AuthenticationServices

extension ASAuthorizationAppleIDButton.Style {
    var backgroundColor: Color {
        switch self {
        case .white:
            return .white
        case .whiteOutline:
            return .white
        default:
            return .black
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .white:
            return .black
        case .whiteOutline:
            return .black
        default:
            return .white
        }
    }
    
    var borderColor: Color {
        switch self {
        case .white:
            return .white
        case .whiteOutline:
            return .black
        default:
            return .black
        }
    }
}

extension ASAuthorizationAppleIDButton.ButtonType {
    var buttonText: String {
        switch self {
        case .signIn:
            return "Sign in with"
        case .continue:
            return "Continue with"
        case .signUp:
            return "Sign up with"
        default:
            return "Sign in with"
        }
    }
}
