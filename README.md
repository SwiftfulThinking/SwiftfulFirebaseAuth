# SwiftfulFirebaseAuth 🤙

Convenience methods to manage Firebase Authentication in Swift projects.

-
-
-
WORK IN PROGRESS
-
-
-

## Usage

Import the package to your project.
* File -> Swift Packages -> Add Package Dependency
* Add URL for this repository: https://github.com/SwiftfulThinking/SwiftfulFirebaseAuth.git

#### Import the package to your file.
```swift
import SwiftfulFirebaseAuth
```

#### Create one instance of AuthManager for your application.
```swift
let authManager = AuthManager(configuration: .firebase)
```


#### Use Mock configuration to avoid running Firebase while developing (ex. for SwiftUI Previews).
```swift
let authManager = AuthManager(configuration: .mock)
```

#### Configure your Firebase project.
* Add the Firebase SDK to your application and configure() the SDK prior to access the AuthManager.
* WORK IN PROGRESS

#### Authentication users.
```swift
Task {
     do {
          let (userAuthInfo, isNewUser) = try await authManager.signInApple()
          // User is signed in

          if isNewUser {
               // Create user profile in Firestore
          }
     } catch {
          // User auth failed
     }
}
```

#### The framework currently supports Apple and Google SSO.
```swift
// Note: You first need to add the Signing Capability for Sign https://developer.apple.com/documentation/xcode/configuring-sign-in-with-apple
try await authManager.signInApple()
```
```swift
// Note: Google SDK is already imported into the Framework.
try await authManager.signInGoogle()
```


#### Synchronously get user's authentication info.
```swift
let userAuthProfile: UserAuthInfo? = authManager.currentUser.profile
let userIsSignedIn: Bool = authManager.currentUser.isSignedIn
let userId: String? = authManager.currentUser.userId
```


#### Asynchronously listen for changes to user's authentication info.
```swift
Task {
     for await authInfo in authManager.$currentUser.values {
                    
          let userAuthProfile: UserAuthInfo? = authInfo.profile
          let userIsSignedIn: Bool = authInfo.isSignedIn
          let userId: String? = authInfo.userId
     }                
}
```


#### Sign out or delete user's authentication.
```swift
try authManager.signOut()
```
```swift
try await authManager.deleteAuthentication()
```


#### Convenience View for SignInWithApple button in SwiftUI.
```swift
SignInWithAppleButtonView(
     type: .signUp,
     style: .black,
     cornerRadius: 10
)
.frame(height: 50)
```
