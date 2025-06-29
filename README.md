# Fireblocks iOS NCW Demo

This demo application showcases both **Embedded Wallet (EW)** and **Non-Custodial Wallet (NCW)** SDKs from Fireblocks, demonstrating wallet creation, key management, transaction handling, NFT support, and Web3 capabilities for iOS applications.

## SDK Overview

### Embedded Wallet (EW) SDK
The **Embedded Wallet SDK** is Fireblocks' latest offering that simplifies wallet integration by handling all wallet management logic internally. It uses the NCW SDK as its core library for cryptographic operations while eliminating the need for a custom backend infrastructure.

### Non-Custodial Wallet (NCW) SDK  
The **NCW SDK** provides the core cryptographic functionality for key generation and transaction signing. It serves as the foundation that powers the Embedded Wallet SDK.

### How They Work Together
- **EW SDK** is the primary SDK that uses **NCW SDK** as its core library
- **NCW SDK** handles key generation and transaction signing operations
- **EW SDK** manages all wallet operations, user flows, and backend communication
- This architecture eliminates the need for developers to build custom backend services

## Getting Started

### Recommended Setup (Default Configuration)
For the best developer experience and to understand the demo code examples, use the **`EW-sandbox`** target:

1. Open the `Fireblocks.xcodeproj` project with Xcode
2. Select the **`EW-sandbox`** scheme from the scheme selector
3. Build and run on your device or simulator

### Firebase Setup (Required)
1. **Create a Firebase Project**:
   - Go to the [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use an existing one

2. **Add iOS App**:
   - Add an iOS app to your Firebase project
   - Use bundle identifier: `com.fireblocks.embeddedwallet` (recommended for Embedded Wallet)

3. **Configure Authentication**:
   - Enable Google and Apple sign-in providers in Firebase Authentication
   - Configure OAuth settings for both providers

4. **Download Configuration**:
   - Download the `GoogleService-Info.plist` file
   - Replace the existing `GoogleService-Info.plist` files in the respective target folders:
     - `Targets/EW-sandbox/GoogleService-Info.plist` (recommended)
     - `Targets/EW-production/GoogleService-Info.plist`
     - `Targets/EW-dev/GoogleService-Info.plist`
     - `Targets/NCW-sandbox/GoogleService-Info.plist`
     - `Targets/NCW-production/GoogleService-Info.plist`
     - `Targets/NCW-dev/GoogleService-Info.plist`

5. **Configure URL Scheme**:
   - Add the reversed Google Client ID to the target's `Info.plist` file:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>***REVERSED GOOGLE CLIENT ID KEY***</string>
           </array>
       </dict>
   </array>
   ```

### Transaction Updates Configuration (Embedded Wallet)

The Embedded Wallet implementation supports two methods for receiving transaction status updates:

#### Push Notifications (Default - Recommended)
- **Configuration**: `useTransactionPolling = false` in the FireblocksManager (default)
- **Requirements**: 
  - Set up the Fireblocks minimal backend server (use our [EW Backend Demo](https://github.com/fireblocks/ew-backend-demo))
  - Create a webhook in the Fireblocks Console
  - Configure Firebase Cloud Messaging (FCM) for push notifications
  - Configure APNs certificates (see detailed instructions in AppDelegate.swift)
- **Benefits**: Real-time updates, reduced battery usage, better user experience

**Important**: The EW targets use a dedicated `AppDelegate.swift` file with complete push notification implementation. This file contains:
- Detailed APNs certificate setup instructions in the header comments
- Firebase configuration and FCM token handling
- Silent notification processing for transaction updates
- Required Info.plist configuration (`FirebaseAppDelegateProxyEnabled = false`)

#### Polling Mechanism (Fallback Option)
- **Configuration**: Set `useTransactionPolling = true` in the FireblocksManager
- **Requirements**: No additional backend setup needed
- **Benefits**: Simpler setup, no external dependencies, works out of the box

**Note**: The demo uses push notifications (`useTransactionPolling = false`) by default for optimal performance. You can switch to polling (`useTransactionPolling = true`) if you prefer a simpler setup without backend requirements.

### Build Targets

The project uses different targets for various SDK and environment configurations:

#### Embedded Wallet Targets (Recommended):
- **`EW-sandbox`** - EW SDK with Sandbox environment (recommended for development)
- **`EW-production`** - EW SDK with Production environment
- **`EW-dev`** - EW SDK with Development environment (Fireblocks internal)

#### NCW Targets:
- **`NCW-sandbox`** - NCW SDK with Sandbox environment
- **`NCW-production`** - NCW SDK with Production environment  
- **`NCW-dev`** - NCW SDK with Development environment (Fireblocks internal)

### Build and Run

1. **Clone the repository**:
   ```bash
   git clone git@github.com:fireblocks/ncw-ios-demo.git
   ```
2. **Set up Firebase** (see Firebase Setup section above)
3. **Open the project**:
   - Open `Fireblocks.xcodeproj` with Xcode
4. **Select your target** (EW-sandbox recommended)
5. **Build and run** on your device or simulator

### Project Structure

```
Fireblocks/
├── Managers/
│   ├── EW/                     # Embedded Wallet managers
│   │   ├── EWManager.swift
│   │   └── FireblocksManager.swift
│   └── NCW/                    # NCW managers
│       ├── FireblocksManager.swift
│       └── Models/
├── UI/
│   ├── SwiftUIViews/          # Modern SwiftUI screens
│   └── Auth/                  # Authentication flows
├── Targets/                   # Target-specific configurations
│   ├── EW-sandbox/           # EW Sandbox config
│   ├── EW-production/        # EW Production config
│   ├── NCW-sandbox/          # NCW Sandbox config
│   └── NCW-production/       # NCW Production config
└── Assets/                   # Shared resources
```

## Documentation

For comprehensive documentation, setup guides, and API references:

📖 **[Fireblocks NCW Developer Guide](https://ncw-developers.fireblocks.com/v6.0/docs/getting-started)**

The developer guide includes:
- Detailed setup instructions
- API documentation (Swift documentation available)
- Integration examples
- Best practices
- Troubleshooting guides

## Key Features Demonstrated

- 🔐 **Wallet Creation & Recovery** - Generate new wallets or recover existing ones
- 🔑 **Key Management** - Secure key generation, backup, and recovery
- 💸 **Transactions** - Send, receive, and track cryptocurrency transactions with real-time updates
- 🖼️ **NFT Support** - View, manage, and transfer NFTs across supported networks
- 🌐 **Web3 Integration** - Connect to dApps and sign Web3 transactions
- 📱 **Multi-Device** - Add and manage multiple devices per wallet
- 🔒 **Biometric Security** - Face ID and Touch ID integration
- 🔔 **Push Notifications** - Real-time transaction status updates (EW implementation)
- ☁️ **Cloud Backup** - Google Drive and iCloud backup integration
- 🎨 **Modern iOS UI** - Built with SwiftUI and UIKit

## Architecture Highlights

### Managers Layer
- **EWManager**: Handles Embedded Wallet operations and backend communication
- **FireblocksManager**: Core wallet operations for both EW and NCW implementations
- **RecoverManager**: Manages wallet recovery flows
- **BackupRepository**: Handles cloud backup operations

### UI Layer
- **SwiftUI Views**: Modern declarative UI for new features
- **UIKit Controllers**: Legacy screens with Xib files
- **Responsive Design**: Adapts to different iOS device sizes

### Target-Specific Code
- Environment constants per target
- Firebase configurations per environment
- App icons and branding per SDK type

## Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5.5+
- Firebase project with authentication configured
- Valid Fireblocks workspace configuration

## Dependencies

The demo includes:
- **FireblocksSDK.xcframework** - Core NCW/EW functionality
- **Firebase** - Authentication and messaging
- **Google Sign-In** - OAuth authentication
- **Apple Sign-In** - Native iOS authentication

## Development Notes

### Environment Configuration
Each target has its own environment constants file:
- `EnvironmentConstantsEWSandbox.swift` (EW Sandbox)
- `EnvironmentConstantsEWProduction.swift` (EW Production)
- `EnvironmentConstants.swift` (NCW Sandbox)
- `EnvironmentConstantsProd.swift` (NCW Production)

### Push Notifications Implementation (EW Targets)
The EW targets include a complete push notification implementation in `AppDelegate.swift`. **This file contains critical setup instructions and code that will save you significant development time.**

**Key Implementation Details:**
- **APNs Certificate Setup**: Complete step-by-step instructions in the file header comments, including how to generate, convert, and upload certificates to Firebase
- **Firebase Configuration**: Automatic FCM token registration and handling
- **Silent Notifications**: Handles background transaction updates via `didReceiveRemoteNotification`
- **Notification Delegates**: Implements both `UNUserNotificationCenterDelegate` and `MessagingDelegate`
- **Token Management**: Automatic registration of both APNs and FCM tokens with Fireblocks backend

**Required Info.plist Configuration:**
```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```
This disables Firebase's automatic method swizzling, allowing manual notification handling.

**Note**: The AppDelegate implementation is ready-to-use and handles all the complexity of iOS push notifications for you. Simply follow the certificate setup instructions in the comments.

### Backup Integration
The demo supports multiple backup providers:
- Google Drive (configured via Firebase)
- iCloud (iOS native)
- Manual passphrase backup

## Support

For technical support and questions:
- Review the [Developer Documentation](https://ncw-developers.fireblocks.com/v6.0/docs/getting-started)
- Check the code examples in this demo app
- Contact Fireblocks support for additional assistance

## License

MIT License

Copyright (c) Fireblocks Ltd.

This demo application is provided for educational and development purposes to showcase Fireblocks SDK integration patterns.