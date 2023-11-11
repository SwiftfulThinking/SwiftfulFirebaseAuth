# SwiftfulFirebaseAuth 🤙

Convenience methods to manage Firebase Authentication in Swift projects.

- ✅ Sign In With Apple
- ✅ Sign In With Google

```swift
Task {
     do {
          let (userAuthInfo, isNewUser) = try await authManager.signInApple()
          // User is signed in

          if isNewUser {
               // New user -> Create user profile in Firestore
          } else {
               // Existing user -> sign in
          }
     } catch {
          // User auth failed
     }
}
```

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
Add the Firebase SDK to your application and configure() the SDK on launch.

##### Sign In With Apple
1. Enable Apple as a Sign-In Method in Firebase Authentication console.
2. Add Sign in with Apple Signing Capability to your Xcode project.

https://firebase.google.com/docs/auth/ios/apple


```swift
try await authManager.signInApple()
```
```swift
SignInWithAppleButtonView(
     type: .signUp,
     style: .black,
     cornerRadius: 10
)
.frame(height: 50)
```

##### Sign In With Google
1. Enable Apple as a Sign-In Method in Firebase Authentication console & update the info.plist file.
2. Add custom URL scheme (URL Types -> REVERSED_CLIENT_ID)

https://firebase.google.com/docs/auth/ios/google-signin


```swift
let clientId = FirebaseApp.app()?.options.clientId
try await authManager.signInGoogle(GIDClientID: clientId)
```
```swift
SignInWithGoogleButtonView(
     type: .signUp,
     style: .black,
     cornerRadius: 10
)
.frame(height: 50)
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

## Want to contribute?
Open a PR! New Sign-In Methods must use Swift Concurrency (async/await).
