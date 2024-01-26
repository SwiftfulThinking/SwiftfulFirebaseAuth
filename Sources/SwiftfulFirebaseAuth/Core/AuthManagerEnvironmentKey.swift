//
//  AuthManagerEnvironmentKey.swift
//
//
//  Created by Nick Sarno on 12/10/23.
//

import Foundation
import SwiftUI

public struct AuthManagerEnvironmentKey: EnvironmentKey {
    @MainActor
    public static let defaultValue: AuthManager = AuthManager(configuration: .mock)
}

public extension EnvironmentValues {
    var auth: AuthManager {
        get { self[AuthManagerEnvironmentKey.self] }
        set { self[AuthManagerEnvironmentKey.self] = newValue }
    }
}
