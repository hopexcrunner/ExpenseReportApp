# Build & Deployment Guide

## Building the APK

### Debug Build (for testing)

```bash
# Using Android Studio
Build → Build Bundle(s) / APK(s) → Build APK(s)

# OR using command line
cd ExpenseReportApp
./gradlew assembleDebug

# Output location:
# app/build/outputs/apk/debug/app-debug.apk
```

### Release Build (for distribution)

1. **Generate Signing Key** (first time only):
```bash
keytool -genkey -v -keystore avant-expense.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias avant-expense-key
```

2. **Create keystore.properties**:
```properties
# In project root
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=avant-expense-key
storeFile=../avant-expense.jks
```

3. **Update app/build.gradle.kts**:
```kotlin
android {
    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("keystore.properties")
            val keystoreProperties = Properties()
            keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // ... rest of config
        }
    }
}
```

4. **Build Release APK**:
```bash
./gradlew assembleRelease

# Output: app/build/outputs/apk/release/app-release.apk
```

## Installation Options

### Option 1: Direct Install via USB
```bash
# Connect device via USB
adb install app/build/outputs/apk/debug/app-debug.apk

# OR click Run in Android Studio
```

### Option 2: Email APK
1. Email the APK file to users
2. Users open email on Android device
3. Download and install APK
4. May need to enable "Install from Unknown Sources"

### Option 3: Google Play Store (Internal Testing)
1. Create Google Play Developer account ($25 one-time fee)
2. Create app listing
3. Upload APK to Internal Testing track
4. Add test users by email
5. Users install via Play Store link

### Option 4: Firebase App Distribution (Recommended for Testing)
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy
firebase appdistribution:distribute app-debug.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "testers" \
  --release-notes "Version 1.0 - Initial release"
```

## System Requirements

### Development
- **Android Studio**: Arctic Fox (2020.3.1) or newer
- **JDK**: 8 or higher
- **Gradle**: 7.5 or higher
- **RAM**: Minimum 8GB, 16GB recommended
- **Disk Space**: 4GB for Android Studio + 2GB for project

### Runtime (End Users)
- **Android Version**: 7.0 (Nougat) or higher (API 24+)
- **Storage**: ~50MB for app + space for receipts
- **Camera**: Any camera (back camera recommended)
- **RAM**: 2GB minimum

## Pre-Deployment Checklist

- [ ] Test on multiple Android versions (7.0, 10, 13+)
- [ ] Test camera on different devices
- [ ] Verify OCR accuracy with various receipts
- [ ] Test Excel generation with template
- [ ] Verify email draft creation works
- [ ] Test file permissions on Android 11+
- [ ] Check app icons and splash screen
- [ ] Verify all strings in strings.xml
- [ ] Test without internet connection
- [ ] Review app permissions

## Testing Devices

Recommended test devices:
- **Budget**: Samsung Galaxy A series
- **Mid-range**: Google Pixel 6a/7a
- **High-end**: Samsung S23/S24
- **Emulator**: Pixel 5 API 30+

Test scenarios:
1. Fresh install
2. Camera capture in various lighting
3. Different receipt types
4. Excel file opening
5. Email with attachments
6. Permission denial/grant
7. Low storage space
8. Airplane mode

## Distribution Checklist

### Internal Testing Phase
- [ ] 5-10 internal testers
- [ ] Test for 1-2 weeks
- [ ] Collect feedback
- [ ] Fix critical bugs
- [ ] Document known issues

### Beta Release
- [ ] 20-50 beta users
- [ ] Real-world receipt testing
- [ ] Performance monitoring
- [ ] Crash reporting (Firebase Crashlytics)
- [ ] Analytics (Firebase Analytics)

### Production Release
- [ ] All critical bugs fixed
- [ ] User documentation complete
- [ ] Support channel established
- [ ] Backup plan for issues
- [ ] Version rollback plan

## Update Strategy

### Version Numbering
- **versionCode**: Integer that increases with each release
- **versionName**: User-visible version (e.g., "1.0.0")

Example:
```kotlin
defaultConfig {
    versionCode = 2
    versionName = "1.0.1"
}
```

### Update Distribution
1. Build new APK with incremented version
2. Test thoroughly
3. Distribute via same channel
4. Notify users of update
5. Monitor adoption rate

## CI/CD Setup (Optional)

### GitHub Actions Example
```yaml
name: Android Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up JDK 11
      uses: actions/setup-java@v2
      with:
        java-version: '11'
        distribution: 'adopt'
    - name: Build with Gradle
      run: ./gradlew assembleDebug
    - name: Upload APK
      uses: actions/upload-artifact@v2
      with:
        name: app-debug
        path: app/build/outputs/apk/debug/app-debug.apk
```

## Monitoring & Analytics

### Firebase Setup
1. Create Firebase project
2. Add Android app to project
3. Download `google-services.json`
4. Place in `app/` directory
5. Add Firebase dependencies:

```kotlin
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-crashlytics-ktx")
}
```

### Key Metrics to Track
- Daily active users
- Receipt capture success rate
- OCR accuracy rate
- Excel generation success rate
- Email sent rate
- Crash-free users percentage
- Average processing time

## Troubleshooting Build Issues

### Common Issues

**Gradle sync fails**
```bash
# Clear cache
./gradlew clean
# In Android Studio: File → Invalidate Caches → Restart
```

**Dependencies not resolving**
```bash
# Update repositories in settings.gradle.kts
repositories {
    google()
    mavenCentral()
}
```

**APK too large**
```kotlin
// Enable code shrinking
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(...)
    }
}
```

**Build timeout**
```properties
# In gradle.properties
org.gradle.jvmargs=-Xmx4096m
```

## Support Resources

- **Android Developers**: https://developer.android.com
- **Stack Overflow**: Tag `android`, `kotlin`, `camerax`
- **ML Kit Docs**: https://developers.google.com/ml-kit
- **Apache POI Docs**: https://poi.apache.org/

## Security Considerations

- [ ] No sensitive data in logs
- [ ] Secure file storage
- [ ] Proper permission checks
- [ ] No hardcoded credentials
- [ ] HTTPS for any network calls
- [ ] Input validation
- [ ] ProGuard rules for release

## Rollout Plan

### Week 1-2: Internal Alpha
- 5 developers/testers
- Fix critical bugs
- Validate core functionality

### Week 3-4: Closed Beta
- 20-30 finance team members
- Real-world usage
- Gather feedback
- Performance tuning

### Week 5: Open Beta
- All interested employees
- Monitor for edge cases
- Final polishing

### Week 6: Production Release
- Company-wide announcement
- Training materials ready
- Support team briefed
- Monitor closely

---

**Contact**: For build issues or deployment questions, contact the development team at dev@avant.org
