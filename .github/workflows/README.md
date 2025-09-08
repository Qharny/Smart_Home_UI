# GitHub Workflows for Smart Home App

This directory contains GitHub Actions workflows for building and releasing the Smart Home Flutter app.

## 📁 Workflow Files

### 1. `android-release.yml` - Basic Android Release
- **Trigger**: When a new release is published
- **Purpose**: Builds and uploads APK and AAB files to GitHub releases
- **Outputs**: 
  - Universal APK
  - App Bundle (AAB)

### 2. `android-release-advanced.yml` - Advanced Android Release
- **Trigger**: When a new release is published or manually triggered
- **Purpose**: Builds multiple APK variants and provides detailed build information
- **Outputs**:
  - Universal APK
  - ARM64 APK
  - ARM32 APK
  - x86_64 APK
  - App Bundle (AAB)
- **Features**:
  - Code coverage reports
  - File size analysis
  - Detailed build summaries

### 3. `google-play-deploy.yml` - Google Play Store Deployment
- **Trigger**: When a new release is published or manually triggered
- **Purpose**: Automatically deploys to Google Play Store
- **Features**:
  - Multiple release tracks (internal, alpha, beta, production)
  - Automatic release notes integration
  - Play Store status updates

## 🚀 How to Use

### Creating a Release

1. **Create a new release on GitHub:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Go to GitHub Releases page:**
   - Navigate to your repository
   - Click on "Releases"
   - Click "Create a new release"
   - Choose the tag you created
   - Add release notes
   - Click "Publish release"

3. **Workflows will automatically trigger:**
   - `android-release.yml` will build and upload APK/AAB files
   - `android-release-advanced.yml` will create multiple APK variants
   - `google-play-deploy.yml` will deploy to Google Play Store (if configured)

### Manual Workflow Trigger

You can also trigger workflows manually:

1. Go to the "Actions" tab in your repository
2. Select the workflow you want to run
3. Click "Run workflow"
4. Choose the branch and any required inputs
5. Click "Run workflow"

## 🔧 Configuration

### Required Secrets

For Google Play Store deployment, you need to set up these secrets:

1. **`GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`**:
   - Create a service account in Google Cloud Console
   - Download the JSON key file
   - Add the entire JSON content as a repository secret

### Package Name

Update the package name in `google-play-deploy.yml`:
```yaml
packageName: com.example.smart_home  # Change this to your actual package name
```

### Release Notes

Update release notes in `release-notes/en-US.txt` for each release.

## 📱 Build Outputs

### APK Files
- **Universal APK**: Works on all Android devices
- **ARM64 APK**: Optimized for 64-bit ARM devices
- **ARM32 APK**: Optimized for 32-bit ARM devices
- **x86_64 APK**: Optimized for x86_64 devices (emulators, some tablets)

### App Bundle (AAB)
- **Google Play Store**: Use this for Play Store submissions
- **Smaller size**: Google Play generates optimized APKs for each device

## 🔍 Monitoring

### Build Status
- Check the "Actions" tab to monitor workflow progress
- View build logs for debugging
- Check release assets in the "Releases" section

### Build Summaries
- Each workflow generates a detailed summary
- Includes file sizes, build information, and next steps
- Available in the workflow run details

## 🛠️ Troubleshooting

### Common Issues

1. **Flutter version mismatch**:
   - Update the Flutter version in workflow files
   - Ensure local Flutter version matches

2. **Build failures**:
   - Check Flutter doctor output in workflow logs
   - Verify all dependencies are properly configured

3. **Google Play deployment issues**:
   - Verify service account JSON is correct
   - Check package name matches Play Console
   - Ensure app is properly configured in Play Console

### Debug Steps

1. Check workflow logs in the Actions tab
2. Verify all required secrets are set
3. Test builds locally before pushing
4. Check Flutter doctor output

## 📚 Additional Resources

- [Flutter CI/CD Documentation](https://docs.flutter.dev/deployment/ci)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Google Play Console API](https://developers.google.com/android-publisher)

## 🤝 Contributing

When adding new workflows or modifying existing ones:

1. Test workflows thoroughly
2. Update this README with changes
3. Ensure proper error handling
4. Add appropriate documentation