//
//  SignInWithPhone.swift
//
//
//  Created by Vamsi Madduluri on 10/04/24.
//

import FirebaseAuth

public struct SignInWithPhoneResult {
    public let verificationID: String
}

/// A helper class that provides methods for phone authentication.
final class SignInWithPhoneHelper {
    
    /// Starts the phone authentication flow.
    /// - Parameter phoneNumber: The phone number to verify.
    /// - Returns: An `AsyncThrowingStream` that yields `SignInWithPhoneResult` instances and throws `Error` instances.
//    @MainActor
//    func startPhoneAuthFlow(phoneNumber: String) -> AsyncThrowingStream<SignInWithPhoneResult, Error> {
//        AsyncThrowingStream { continuation in
//            // Indicate that the code is being sent
//            continuation.yield(SignInWithPhoneResult(status: .sendingCode))
//            
//            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
//                if let error {
//                    // Indicate that there was an error
//                    continuation.yield(SignInWithPhoneResult(status: .error(error)))
//                    continuation.finish()
//                    return
//                }
//                
//                if let verificationID {
//                    // Indicate that the code has been sent
//                    let result = SignInWithPhoneResult(verificationID: verificationID, status: .codeSent)
//                    continuation.yield(result)
//                    continuation.finish()
//                    return
//                }
//            }
//        }
//    }
    
    func startPhoneFlow(phoneNumber: String) async throws -> SignInWithPhoneResult {
        let verificationID = try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil)
        return SignInWithPhoneResult(verificationID: verificationID)
    }

}
