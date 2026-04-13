# Campcon

## Google Sign-In setup checklist

If Google Sign-In fails with errors like `ApiException: 10` or `sign_in_failed`, complete all steps below and rebuild the app.

### 1) Enable Google provider in Firebase

- Firebase Console → **Authentication** → **Sign-in method**
- Enable **Google**
- Set support email and save

### 2) Register Android SHA fingerprints

Add both debug and release SHA-1/SHA-256 for package `com.campcon.app` in Firebase Android app settings.

Generate debug SHA values on Windows:

```powershell
cd android
./gradlew signingReport
```

For release SHA values:

```powershell
keytool -list -v -keystore <path-to-your-release-keystore>
```

After adding SHA keys, download a fresh `google-services.json` and replace:

- `android/app/google-services.json`

### 3) iOS Google Sign-In config

- Ensure `ios/Runner/GoogleService-Info.plist` is from Firebase project `campcon-806c3`
- Ensure `REVERSED_CLIENT_ID` is present in `ios/Runner/Info.plist` URL schemes

### 4) Clean and rebuild

```powershell
flutter clean
flutter pub get
flutter run
```
