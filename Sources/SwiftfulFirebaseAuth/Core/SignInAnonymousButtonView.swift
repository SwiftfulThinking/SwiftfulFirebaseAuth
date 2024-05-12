//
//  SignInAnonymousButtonView.swift
//
//
//  Created by Nick Sarno on 5/11/24.
//

import SwiftUI
import SwiftUI
import AuthenticationServices

// TODO: Streamline all Sign In Buttons
// Note: Most Anonymous sign-in should happen in the background and not be a button the user clicks.

public struct SignInAnonymousButtonView: View {
    
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
        self.buttonText = type.buttonText.removingWord(" with")
    }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(borderColor)
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .padding(0.8)
            
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                
                Text("\(buttonText) Anonymously")
                    .font(.system(size: 21))
                    .fontWeight(.medium)
            }
            .foregroundColor(foregroundColor)
        }
        .padding(.vertical, 1)
        .disabled(true)
    }
}

fileprivate extension String {
    func removingWord(_ word: String) -> String {
        let pattern = "\\b\(word)\\b"
        return self.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
    }
}

#Preview("SignInAnonymousButtonView") {
    VStack {
        SignInWithAppleButtonView()
            .frame(height: 60)
            .padding()
        SignInWithGoogleButtonView()
            .frame(height: 60)
            .padding()
        SignInWithPhoneButtonView()
            .frame(height: 60)
            .padding()
        
        if #available(iOS 14.0, *) {
            SignInAnonymousButtonView(type: .signUp)
                .frame(height: 60)
                .padding()
        }
        
        SignInAnonymousButtonView(type: .continue)
            .frame(height: 60)
            .padding()

        SignInAnonymousButtonView(type: .signIn)
            .frame(height: 60)
            .padding()
        SignInAnonymousButtonView(type: .default)
            .frame(height: 60)
            .padding()
    }
}
