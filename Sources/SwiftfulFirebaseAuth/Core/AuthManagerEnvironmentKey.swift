//
//  AuthManagerEnvironmentKey.swift
//
//
//  Created by Nick Sarno on 12/10/23.
//

import Foundation
import SwiftUI

public struct AuthManagerEnvironmentKey: EnvironmentKey {
    // FIX ME
    @MainActor
    public static let defaultValue: AuthManager = AuthManager(config: .mock(.startFromSavedState))
}

public extension EnvironmentValues {
    var auth: AuthManager {
        get { self[AuthManagerEnvironmentKey.self] }
        set { self[AuthManagerEnvironmentKey.self] = newValue }
    }
}