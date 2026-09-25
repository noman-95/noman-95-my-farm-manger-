# Ali Goat Farm — APK build

1. Upload the contents of this folder to the GitHub repository root.
2. Do not upload `android/local.properties` (it is intentionally absent because it contains a machine-specific Flutter SDK path).
3. Open Actions → Build APK → Run workflow.
4. After a successful run, download the artifact named `ali-goat-farm-release-apk`.

Android configuration in this package:
- Flutter 3.35.2
- Android Gradle Plugin 8.9.1
- compileSdk 36
- targetSdk 35
- Flutter engine Maven repository configured
- `image_picker` 1.2.2
