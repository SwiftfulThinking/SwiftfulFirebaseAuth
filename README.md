# SwiftfulFirebaseAuth 🤙

Convenience methods to manage Firebase Authentication in Swift projects.

- ✅ Sign In With Apple
- ✅ Sign In With Google
- ✅ Sign In With Phone

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

Sample project: https://github.com/SwiftfulThinking/SwiftfulFirebasePackagesExample

## Setup

<details>
<summary> Details (Click to expand) </summary>
<br>
     
### 1. Import the package to your project.
* File -> Swift Packages -> Add Package Dependency
* Add URL for this repository: https://github.com/SwiftfulThinking/SwiftfulFirebaseAuth.git

### 2. Import the package to your file.
```swift
import SwiftfulFirebaseAuth
```

### 3. Create one instance of AuthManager for your application.
```swift
let authManager = AuthManager(configuration: .firebase)

// Use Mock configuration to avoid running Firebase while developing (ex. for SwiftUI Previews).
let authManager = AuthManager(configuration: .mock)
```

### 4. Configure your Firebase project.
Add the Firebase SDK to your application and configure() the SDK on launch.

```swift
@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
```
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     FirebaseApp.configure()
     return true
}
```

</details>

## Sign In With Apple

<details>
<summary> Details (Click to expand) </summary>
<br>

Firebase docs: https://firebase.google.com/docs/auth/ios/apple

### 1. Enable Apple as a Sign-In Method in Firebase Authentication console.
* Firebase Console -> Authentication -> Sign-in method -> Add new provider

### 2. Add Sign in with Apple Signing Capability to your Xcode project.
* Xcode Project Navigator -> Target -> Signing & Capabilities -> + Capability -> Sign in with Apple (requires Apple Developer Account)

### 3. Add Apple Button (optional)
```swift
SignInWithAppleButtonView()
    .frame(height: 50)
```

### 4. Sign in

```swift
try await authManager.signInApple()
```
</details>


## Sign In With Google

<details>
<summary> Details (Click to expand) </summary>
<br>

Firebase docs: https://firebase.google.com/docs/auth/ios/google-signin

### 1. Enable Google as a Sign-In Method in Firebase Authentication console.
* Firebase Console -> Authentication -> Sign-in method -> Add new provider

### 2. Update you app's the info.plist file.
* Firebase Console -> Project Settings -> Your apps -> GoogleService-Info.plist

### 3. Add custom URL scheme (URL Types -> REVERSED_CLIENT_ID)
* GoogleService-Info.plist -> REVERSED_CLIENT_ID
* Xcode Project Navigator -> Target -> Info -> URL Types -> add REVERSED_CLIENT_ID as URL Schemes value

### 4. Add Google Button (optional)
```swift
SignInWithGoogleButtonView()
    .frame(height: 50)
```

### 5. Sign in
```swift
let clientId = FirebaseApp.app()?.options.clientId
try await authManager.signInGoogle(GIDClientID: clientId)
```

</details>

## Sign In With Phone

<details>
<summary> Details (Click to expand) </summary>
<br>

Firebase docs: https://firebase.google.com/docs/auth/ios/phone-auth

### 1. Enable Phone Number as a Sign-In Method in Firebase Authentication console.
* Firebase Console -> Authentication -> Sign-in method -> Add new provider

### 2. Enable APNs notifications (silent push notifications).
* Create an APNs Authentication Key in [Apple Developer Member Center](https://developer.apple.com/membercenter/index.action) (requires Apple Developer Account)
* Certificates, Identifiers & Profiles -> New Key for Apple Push Notifications service (APNs) -> download .p8 file

### 3. Upload APNs key to Firebase.
* Firebase Console -> Project Settings -> Cloud Messaging -> APNs Authentication Key

### 4. Enable reCAPTCHA verification (optional?).
* Firebase Console -> Project Settings -> Encoded App ID
* Xcode Project Navigator -> Target -> Info -> URL Types -> add Encoded App ID as URL Schemes value

### 5. Add UIDelegate methods to handle push notifications

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
     Auth.auth().setAPNSToken(deviceToken, type: .prod)
}

func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
     if Auth.auth().canHandleNotification(notification) {
          completionHandler(.noData)
          return
     }
}
    
func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
     if Auth.auth().canHandle(url) {
          return true
     }
     return false
}
```

### 6. Get the user's phone number
* This SDK does NOT format phone numbers or provide UI for this. You must provide a string in the correct format.
* Phone numbers have to be correctly formatted, such as "+1 650-555-3434" for US numbers.
* See [Firebase Docs](https://firebase.google.com/docs/auth/ios/phone-auth) for details about phone number implementation
* Possible resources for phone number formatting:
     - https://stackoverflow.com/questions/32364055/formatting-phone-number-in-swift
     - https://github.com/iziz/libPhoneNumber-iOS
     - https://github.com/MojtabaHs/iPhoneNumberField

### 7. Add Phone Number Button (optional)

```swift
SignInWithPhoneButtonView()
     .frame(height: 50)
```

### 8. Send verification code to user's phone.

```swift
try await authManager.signInPhone_Start(phoneNumber: phoneNumber)
```

### 9. Verify code and sign in
```swift
try await authManager.signInPhone_Verify(code: code)
```

</details>

## Already Signed In

<details>
<summary> Details (Click to expand) </summary>
<br>

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

</details>

## Want to contribute?
Open a PR! New Sign-In Methods must use Swift Concurrency (async/await).
