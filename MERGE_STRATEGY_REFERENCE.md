# Comprehensive Project Merge & Update Strategy
## Reference Guide for Customized Flutter Applications

This document serves as a blueprint for merging updates from a base "SaaS" or "Master" project into a highly customized derivative project (like `SkootureStudent`). Use this process to ensure new features are integrated without losing custom UI, logic, or localizations.

---

## 1. Research & Pre-Merge Phase
*   **Identify Versions**: Compare `changelog.txt` files to understand the scope of the update (e.g., v1.6.0 to v1.9.2).
*   **Audit Customizations**: List critical custom features in the destination project (e.g., Biometric Login, Custom Branding, specific API `baseUrl`).
*   **Draft a Plan**: Document which directories are "Safe to Sync" (Data/Models) and which require "Surgical Merging" (UI/Screens).

---

## 2. Dependency Management (`pubspec.yaml`)
*   **Conflict Resolution**: Identify new packages in the Master project. Add them to the Custom project.
*   **Version Bumps**: Upgrade existing packages to match the Master project to ensure native compatibility.
*   **Flutter Version**: If the Master project requires a newer Flutter SDK, perform `flutter upgrade --force`.
*   **Post-Update**: Always run `flutter pub get` and `flutter analyze` immediately.

---

## 3. Core Logic Migration (Data & State)
*   **Models**: Update models (`lib/data/models`) to match new API response structures. Be careful with custom `getFullName()` or `toString()` methods.
*   **Repositories**: Merge repository logic. Ensure any custom local caching (like `getTemporarilyStoredNotifications`) is preserved even if the Master project moves to API-only logic.
*   **Cubits**: Update Cubits to handle new states. Ensure any new Cubits are registered in the `MultiBlocProvider` within `lib/app/app.dart`.

---

## 4. Surgical UI Merging
*   **NEVER Overwrite**: Do not copy-paste UI screens directly.
*   **Diff & Extract**: Use a diff tool to find logical changes (new API calls, `BlocListeners`, navigation logic) and apply them to the Custom project's widgets.
*   **Bypass Onboarding**: If the Master project adds generic onboarding/branding, navigate directly to `Routes.home` or `Routes.parentHome` in the `SignInSuccess` listener to maintain the custom user experience.

---

## 5. Assets & Localization
*   **Language Files**: Use `jq` or a similar tool to merge JSON language keys. Ensure the Custom project's values take precedence for existing keys while appending new ones.
    *   *Command*: `cat master_en.json | jq -s '.[0] * .[1]' - custom_en.json > merged_en.json`
*   **Images/SVGs**: Add new icons required for features but do not replace existing custom branding files (e.g., `appLogo.svg`).

---

## 6. iOS-Specific Build Fixes (Critical)
*   **CocoaPods Management**:
    *   Disable experimental features if they cause issues: `flutter config --no-enable-swift-package-manager`.
    *   Force a fresh install: `rm -rf Pods Podfile.lock && pod install --repo-update`.
*   **Swift Compatibility**:
    *   If plugins (like `ScreenProtectorKit`) fail on newer Xcode versions, add a `post_install` patch in the `Podfile` to overwrite the source or force `SWIFT_VERSION = '5.0'`.
*   **Firebase Modules**:
    *   If `No such module 'Firebase'` appears, update `AppDelegate.swift` to `import FirebaseCore` and ensure the `Podfile` correctly installs native dependencies.

---

## 7. Common Fixes & Troubleshooting
*   **`ProviderNotFoundException`**: Usually occurs when adding a new Cubit dependency to a screen but forgetting to update the `routeInstance()` in `routes.dart` or the screen's own Provider wrapper.
*   **`isiOSAppOnVision` Errors**: Occurs when `device_info_plus` is too old for the current Xcode SDK. Upgrade the package or patch the `.pub-cache` source code using `sed`.
*   **WebSocket Reconnect**: When migrating to Reverb, ensure `SocketSettingCubit` includes a `reconnect()` method and update home screens to trigger it on `AppLifecycleState.resumed`.

---

## 8. Final Verification Flow
1.  `flutter clean`
2.  `flutter pub get`
3.  `cd ios && pod install --repo-update`
4.  `flutter analyze` (Must have 0 critical errors)
5.  `git commit -m "feat: detailed merge description"`
