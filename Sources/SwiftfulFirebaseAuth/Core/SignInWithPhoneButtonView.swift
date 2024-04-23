//
//  SignInWithPhoneButtonView.swift
//
//
//  Created by Nick Sarno on 4/22/24.
//

import SwiftUI
import SwiftUI
import AuthenticationServices

public struct SignInWithPhoneButtonView: View {
    
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
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(borderColor)
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .padding(0.8)
            
            HStack(spacing: 8) {
                Image(systemName: "phone.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                
                Text("\(buttonText) Phone")
                    .font(.system(size: 21))
                    .fontWeight(.medium)
            }
            .foregroundColor(foregroundColor)
        }
        .padding(.vertical, 1)
        .disabled(true)
    }
}

#Preview("SignInWithGoogleButtonView") {
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
    }
}
