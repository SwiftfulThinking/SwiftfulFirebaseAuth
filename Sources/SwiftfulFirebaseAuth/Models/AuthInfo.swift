//
//  AuthInfo.swift
//  
//
//  Created by Nick Sarno on 4/10/24.
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
