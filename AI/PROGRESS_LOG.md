# SkootureStudent Project Update Log - August 20, 2026

## Overview
This log documents the successful merge of core updates and features from `e-school-saas` v1.10.0 into the `SkootureStudent` project while preserving all Skooture customizations, branding, base URLs, Firebase configurations, biometric authentication, and transport/diary modules.

## Key Accomplishments

### 1. International Phone Formatting & Model Upgrades
*   **Country Code Standardization**: Added `countryCode` / `country_code` parsing to `Student`, `Guardian`, `Teacher`, `ChildUserDetails`, `StudentDetails`, and `StudentUser` models.
*   **Formatting Utility**: Integrated `Utils.formatMobileNumber({countryCode, mobile})` to properly format international phone numbers with `+` prefixes.
*   **Defensive Type Parsing**: Integrated `_toInt()`, `_toIntOrNull()`, `_parseMobile()`, and `_parseString()` across models to prevent runtime casting crashes on dynamic backend payloads.

### 2. Student ID Card & Certificate Integration
*   **ID Card Download**: Integrated `DownloadStudentIdCardCubit`, `DownloadStudentIdCardDialog`, and `Api.downloadStudentIdCard` to retrieve, decode (Base64 PDF), save, and open the generated ID card.
*   **Certificate Models**: Added `CertificateAssignment` and supporting models (`CertificateUser`, `CertificateTemplate`, `CertificateExam`).
*   **System Module**: Configured `certificateManagementModuleId = 18` in `systemModules.dart`.

### 3. UI/UX Modernization
*   **Teacher Subject Grouping**: Completely modernized `ChildTeachersScreen` with `_groupByTeacher()` consolidation, subject badges, and expandable `_SubjectsBottomSheet`.
*   **Profile Enhancements**: Added phone number tile with `user_pro_phone_icon.svg`, dynamic form field rendering (checkbox parsing, file viewing), profile photo pinch-to-zoom preview with Hero animations, and logout action.
*   **Guardian Details**: Added Hero image preview and country-code phone formatting.

### 4. Localization & Dependencies
*   **Multi-language Support**: Synchronized new translation keys across English (`en.json`), Arabic (`ar.json`), and French (`fr.json`).
*   **Build Health & Plugin Deduplication**:
    *   Resolved iOS crash (`Duplicate plugin key: OpenFilePlugin`) by removing redundant `open_file` package and standardizing on `open_filex: ^4.7.0` (which avoids broad media permission injections).
    *   Updated `StudentProfileScreen` to invoke `OpenFilex.open()`.
    *   Rebuilt CocoaPods with `pod install` in `ios/`.
    *   Maintained `path_provider_foundation: 2.4.1` dependency override.

### 5. Runtime Fixes & Stability
*   **Student Profile Route Argument Parsing**: Fixed `type 'int' is not a subtype of type 'Map<String, dynamic>?'` exception when navigating from parent child view to student profile by updating `StudentProfileScreen.routeInstance()` to handle both `int` and `Map<String, dynamic>` arguments.
*   **Transport Plan Deserialization**: Fixed `type 'List<dynamic>' is not a subtype of type 'Map<dynamic, dynamic>'` in `TransportRepository.getCurrentTransportPlan` by implementing defensive `_extractDataMap` parser when backend returns empty lists.
*   **Teachers Endpoint Alignment**: Updated `ParentRepository.fetchChildTeachers` to pass `student_id` and `child_id` query parameters matching the backend API requirement.

## Current Status
*   **Branch**: `feature/mergeNewUpdates`
*   **Version**: `1.2.0+1`
*   **Health**: `flutter analyze lib` passes with 0 issues; iOS CocoaPods and Xcode build cleanly without plugin collisions.

---

# SkootureStudent Project Update Log - May 10, 2026

## Overview
This log documents the resolution of the Google Play Store rejection regarding invalid use of broad media permissions (`READ_MEDIA_IMAGES` and `READ_MEDIA_VIDEO`).

## Key Accomplishments

### 1. Media Permission Compliance
*   **Manifest Cleanup**: Removed `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, and `READ_MEDIA_IMAGES` from `android/app/src/main/AndroidManifest.xml`. 
*   **Permission Stripping**: Implemented `tools:node="remove"` for `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`, `READ_EXTERNAL_STORAGE`, and `WRITE_EXTERNAL_STORAGE`. This explicitly strips these permissions from the final merged manifest, even if they are injected by third-party dependencies (e.g., `open_filex`), ensuring 100% compliance with Google Play Store policies.
*   **Scoped Media Access**: Transitioned the app to rely on the Android Photo Picker and System File Picker for occasional media selection (assignments, chat attachments), which is compliant with Google's latest privacy policies.
*   **Code Update**: Modified `lib/utils/utils.dart` to bypass manual permission requests for storage and gallery on Android 13+ (SDK 33+). The app now correctly handles these requests by allowing the system pickers to manage access, improving user privacy and satisfying store requirements.

### 2. Production Build Generation (In Progress)
*   **AAB Regeneration**: Initiated the process to generate a new production Android App Bundle (`app-release.aab`) incorporating the permission fixes.

## Current Status
*   **Compliance**: The app now follows Google's "Best practices for media permissions" by using scoped access.
*   **Codebase**: Updated `AndroidManifest.xml` and `utils.dart` have been verified.

---

# SkootureStudent Project Update Log - May 9, 2026

## Overview
This log documents the successful transition of the project's Android package identity and the generation of production-ready deployment artifacts.

## Key Accomplishments

### 1. Android Package Rebranding
*   **Package Name Migration**: Successfully changed the Android package name from `com.skooture.app` to `com.skooture.student`.
*   **Directory Restructuring**: Reorganized the Kotlin source directory structure from `com.wrteam.saas.school` to `com.skooture.student` to align with the new package name and Android development standards.
*   **Configuration Updates**:
    *   Updated `applicationId` and `namespace` in `android/app/build.gradle`.
    *   Updated the `package` attribute in both main and debug `AndroidManifest.xml` files.
    *   Updated the package declaration in `MainActivity.kt`.

### 2. Firebase Infrastructure Update
*   **Configuration Refresh**: Replaced the project's Firebase configuration with a new set of credentials for the `skooture-student` project.
*   **File Updates**:
    *   Updated `android/app/google-services.json` with the new project settings.
    *   Synchronized `lib/firebase_options.dart` to reflect the updated API keys and project IDs.

### 3. Production Artifact Generation
*   **App Bundle (AAB) Creation**: Successfully generated the production Android App Bundle (`app-release.aab`) for Google Play Store upload.
*   **Build Optimization**: Conducted multiple build iterations to stabilize the environment across complex dependency requirements (Stripe, device_info_plus) and Kotlin versioning.

## Current Status
*   **Package Identity**: Android is now fully identified as `com.skooture.student`.
*   **Artifacts**: The production AAB is available at `build/app/outputs/bundle/release/app-release.aab`.
*   **Source Control**: All configurations and package changes have been pushed to the `feature/addMoreUpdates` branch on GitHub.

---

# SkootureStudent Project Update Log - May 6, 2026

## Overview
This log documents the successful resolution of Android build issues and the generation of the release APK for the `SkootureStudent` project.

## Key Accomplishments

### 1. Android Build & Compatibility Fixes
*   **Kotlin Gradle Plugin Upgrade**: Successfully updated the `org.jetbrains.kotlin.android` plugin from `1.9.24` to `2.3.10` in `settings.gradle`. This was required to satisfy the version requirements of modern dependencies, particularly the Stripe Android SDK.
*   **Android NDK Upgrade**: Updated the `ndkVersion` in `android/app/build.gradle` to `28.2.13676358` as recommended by the Android build tools to ensure backward compatibility across all plugins.
*   **Release APK Generation**: Successfully generated the release APK (`app-release.apk`) after resolving all Kotlin compilation and dependency metadata version mismatches.

## Current Status
*   **Android Build**: The project builds successfully in release mode (`flutter build apk --release`).
*   **Artifacts**: The release APK is available at `build/app/outputs/flutter-apk/app-release.apk`.

# SkootureStudent Project Update Log - April 12, 2026

## Overview
This log documents the recent migration and update of the `SkootureStudent` project, incorporating features from the `e-school-saas` v1.9.2 release and updating the Flutter development environment.

## Key Accomplishments

### 1. Integration of `e-school-saas` v1.9.2
Successfully merged core logical and feature updates from the SaaS codebase:
*   **Reverb WebSocket Migration**: Replaced legacy WebSocket implementation with Reverb, including improved connection management and silent message synchronization.
*   **Notification Enhancements**:
    *   Integrated API-based notification fetching alongside local caching for offline reliability.
    *   Implemented "Pending Notification" processing to capture messages missed while the app was backgrounded.
*   **Security & Stability**:
    *   Integrated `ScreenProtectorWrapper` on sensitive screens (Online Exam, Payment WebView) to mitigate screen recording/capture.
    *   Added robust offline submission retry logic for online exams.
*   **New Modules**: Successfully added the "Student Diary" and "File Viewer" screens, fully integrated into the routing system.
*   **UI/UX Improvements**: Enabled session-year filtering for Results and School Gallery modules.

### 2. Localization & Branding
*   **Language Support**: Successfully merged new translation keys from SaaS into `en.json`, `hi.json`, and `ur.json` while preserving all custom `SkootureStudent` strings.
*   **Customization Preservation**: Ensured that all branded UI components, custom login flows, and `baseUrl` configuration remained intact throughout the merge.

### 3. Flutter & Environment Upgrade
*   **SDK Upgrade**: Successfully upgraded the project to match the latest Flutter SDK environment.
*   **Dependency Resolution**:
    *   Resolved conflict between `device_info_plus` and `file_picker`.
    *   Patched `RazorpayDelegate.swift` and `FPPDeviceInfoPlusPlugin.m` to resolve native compilation errors encountered during the SDK upgrade.
    *   Fresh installation of iOS Pods using `pod install --repo-update`.

### 4. Bug Fixes & Code Cleanup
*   **Biometric Login Removal**: Resolved a critical compilation error in `studentLoginScreen.dart` by completely and cleanly removing all unused biometric login dependencies, UI elements (`_buildBiometricButton`), and `local_auth` integrations.

## Current Status
*   **Compilation**: The project passes `flutter analyze` with 0 issues and builds successfully for iOS.
*   **Health**: All native dependencies and Swift interop issues caused by the SDK migration have been resolved.

## Future Recommendations
*   **Unused Code**: Consider removing the unused private method `_formatIsoDateForDisplay` (`examOnlineListContainer.dart`) if it is no longer required for future features.
*   **Plugin Migration**: Several plugins (e.g., `awesome_notifications`, `screen_protector`) do not yet support Swift Package Manager. Monitor their respective GitHub repositories for updates to avoid future build warnings.
