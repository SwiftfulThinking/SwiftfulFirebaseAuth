//
//  SignInWithGoogleButtonView.swift
//
//
//  Created by Nicholas Sarno on 11/6/23.
//

import Foundation
import SwiftUI
import AuthenticationServices

fileprivate extension ASAuthorizationAppleIDButton.Style {
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

fileprivate extension ASAuthorizationAppleIDButton.ButtonType {
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

public struct SignInWithGoogleButtonView: View {
    
    private var backgroundColor: Color
    private var foregroundColor: Color
    private var borderColor: Color
    private var buttonText: String
    private var cornerRadius: CGFloat

    public init(
        type: ASAuthorizationAppleIDButton.ButtonType = .signIn,
        style: ASAuthorizationAppleIDButton.Style = .black,
        cornerRadius: CGFloat = 10
    ) {
        self.cornerRadius = cornerRadius
        self.backgroundColor = style.backgroundColor
        self.foregroundColor = style.foregroundColor
        self.borderColor = style.borderColor
        self.buttonText = type.buttonText
    }
    
    public init(
        type: ASAuthorizationAppleIDButton.ButtonType = .signIn,
        backgroundColor: Color = .black,
        borderColor: Color = .black,
        foregroundColor: Color = .white,
        cornerRadius: CGFloat = 10
    ) {
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.foregroundColor = foregroundColor
        self.buttonText = type.buttonText
    }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(borderColor)
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .padding(0.8)
            
            HStack(spacing: 6) {
                Image("GoogleIcon", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                
                Text("\(buttonText) Google")
                    .font(.system(size: 23))
                    .fontWeight(.medium)
            }
            .foregroundColor(foregroundColor)
        }
        .padding(.vertical, 1)
        .disabled(true)
    }
}

#Preview("SignInWithGoogleButtonView") {
    SignInWithGoogleButtonView()
        .frame(height: 60)
        .padding()
}
