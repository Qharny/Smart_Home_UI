# iOS Build & Deploy Workflow

This GitHub workflow automates the building, testing, and deployment of your Flutter iOS app.

## Workflow Overview

The workflow consists of several jobs that run based on different triggers:

### Triggers
- **Push to main/develop branches**: Runs tests and builds
- **Pull Requests**: Runs tests and builds for simulator
- **Release published**: Full build, code signing, and TestFlight deployment

### Jobs

1. **Test**: Runs Flutter tests and code analysis
2. **Build iOS**: Creates release build for iOS devices
3. **Build iOS Simulator**: Creates debug build for iOS simulator (PRs only)
4. **Code Sign iOS**: Signs the app for App Store distribution
5. **Deploy TestFlight**: Uploads to TestFlight for testing
6. **Notify**: Provides build status notifications

## Setup Instructions

### 1. Required GitHub Secrets

Add these secrets to your GitHub repository (Settings > Secrets and variables > Actions):

#### For Code Signing:
- `IOS_P12_BASE64`: Base64 encoded P12 certificate file
- `IOS_P12_PASSWORD`: Password for the P12 certificate

#### For App Store Connect:
- `APPSTORE_ISSUER_ID`: Your App Store Connect Issuer ID
- `APPSTORE_KEY_ID`: Your App Store Connect API Key ID
- `APPSTORE_PRIVATE_KEY`: Your App Store Connect API Private Key
- `APPSTORE_CONNECT_USERNAME`: Your App Store Connect username
- `APPSTORE_CONNECT_APP_SPECIFIC_PASSWORD`: App-specific password for App Store Connect

### 2. Bundle Identifier

Update the bundle identifier in the workflow file:
```yaml
bundle-id: 'com.example.smartHome'  # Change to your actual bundle ID
```

### 3. Flutter Version

The workflow uses Flutter version 3.24.5. Update the `FLUTTER_VERSION` environment variable if needed.

## How to Get Required Credentials

### App Store Connect API Key
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to Users and Access > Keys
3. Create a new API key with App Manager role
4. Download the key and note the Key ID and Issuer ID

### P12 Certificate
1. Open Keychain Access on macOS
2. Export your iOS Distribution certificate as P12
3. Convert to base64: `base64 -i certificate.p12 | pbcopy`

### App-Specific Password
1. Go to [Apple ID](https://appleid.apple.com)
2. Security > App-Specific Passwords
3. Generate a new password for App Store Connect

## Usage

### For Development
- Push to `develop` branch to trigger tests and builds
- Create pull requests to test simulator builds

### For Production
- Push to `main` branch to trigger full build pipeline
- Create a GitHub release to deploy to TestFlight

## Customization

### Branch Names
Update the branch names in the workflow triggers:
```yaml
branches: [ main, develop ]  # Add your branch names
```

### Build Configuration
Modify build flags in the workflow:
```yaml
flutter build ios --release --no-codesign  # For unsigned builds
flutter build ios --release  # For signed builds
```

### Notification
Customize the notification step to integrate with your preferred notification system (Slack, Discord, etc.).

## Troubleshooting

### Common Issues

1. **Pod install fails**: Ensure your iOS dependencies are properly configured
2. **Code signing errors**: Verify your certificates and provisioning profiles
3. **TestFlight upload fails**: Check your App Store Connect credentials

### Debug Mode
To run the workflow in debug mode, you can temporarily modify the conditions:
```yaml
if: true  # Remove conditions for testing
```

## Security Notes

- Never commit sensitive credentials to your repository
- Use GitHub Secrets for all sensitive information
- Regularly rotate your App Store Connect API keys
- Use app-specific passwords instead of your main Apple ID password 