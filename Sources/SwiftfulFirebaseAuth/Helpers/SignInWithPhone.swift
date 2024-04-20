//
//  SignInWithPhone.swift
//
//
//  Created by Vamsi Madduluri on 10/04/24.
//

import FirebaseAuth
import UIKit

public struct SignInWithPhoneResult {
    public let verificationID: String
}

/// A helper class that provides methods for phone authentication.
@MainActor
final class SignInWithPhoneHelper: NSObject {
    
    private var presentedViewController: UIViewController? = nil
    private var topViewController: UIViewController? = nil

    func startPhoneFlow(phoneNumber: String, viewController: UIViewController? = nil) async throws -> SignInWithPhoneResult {
        guard let topVC = viewController ?? UIApplication.topViewController() else {
            throw PhoneSignInError.noViewController
        }
        topViewController = topVC
        
        let verificationID = try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: self)

        return SignInWithPhoneResult(verificationID: verificationID)
    }

}

extension SignInWithPhoneHelper: AuthUIDelegate {

    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        // Should never fail, since already set in startPhoneFlow
        guard let topViewController else { return }

        viewControllerToPresent.modalPresentationStyle = .overFullScreen
        topViewController.present(viewControllerToPresent, animated: flag, completion: completion)
        presentedViewController = viewControllerToPresent
    }

    func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        presentedViewController?.dismiss(animated: flag, completion: completion)
    }
    
    private enum PhoneSignInError: LocalizedError {
        case noViewController
        case badResponse
        
        var errorDescription: String? {
            switch self {
            case .noViewController:
                return "Could not find top view controller."
            case .badResponse:
                return "Phone Sign In had a bad response."
            }
        }
    }
}
