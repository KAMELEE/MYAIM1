# MY AIM — App Store Release Checklist

Status of readiness for submitting to the App Store. Items marked **[done]**
are handled in the codebase; **[you]** require your Apple/Firebase accounts.

## 1. Apple Developer & signing — [you]
- [ ] Enroll in the Apple Developer Program ($99/yr).
- [ ] A signed-release **CI workflow is ready**: `.github/workflows/release.yml`
      (manual trigger → archives, signs with cloud-managed signing, and uploads
      to TestFlight). You only add four secrets:
      - `APPLE_TEAM_ID` — your 10-char Team ID.
      - `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8` — an App Store Connect API
        key (Users and Access ▸ Integrations), role **App Manager**. Paste the
        whole `AuthKey_XXXX.p8` file contents into `ASC_KEY_P8`.
      Then run the "Release to App Store Connect (TestFlight)" workflow from the
      Actions tab. Automatic signing creates the distribution certificate and
      App Store profile for `com.myaim.app` on first run.
- [ ] (Optional) also set `DEVELOPMENT_TEAM` in `project.yml` for local Xcode builds.

## 2. App technical requirements — [done]
- [x] Privacy Manifest `PrivacyInfo.xcprivacy` (data types + required-reason APIs).
- [x] Export compliance `ITSAppUsesNonExemptEncryption = false` in Info.plist.
- [x] Permission usage strings (location, microphone, photo library).
- [x] App icon 1024×1024 RGB, no alpha channel.
- [x] Supports Dark Mode; Dynamic Type via relative font sizing.
- [x] Deployment target iOS 17, iPhone-only.

## 3. Backend (Firebase) — [you]
- [ ] Enable Auth providers: Email/Password and Phone.
- [ ] Phone auth needs the **Blaze** plan + an **APNs key** uploaded to Firebase.
- [ ] Deploy rules:  `firebase deploy --only firestore:rules,storage`
      (rules are already written and locked to each user — see `firestore.rules`,
      `storage.rules`).
- [ ] Restrict the iOS API key in Google Cloud Console to the app's bundle ID.
- [ ] Seed real academies/services, or onboard providers to populate the catalog.

## 4. Legal pages — [done in code, deploy = you]
- [x] In-app Terms & Privacy screens (Settings / Profile).
- [x] Hosted pages under `/hosting` + Firebase Hosting config.
- [ ] Publish them:  `firebase use <project-id>` then
      `firebase deploy --only hosting` → gives
      `https://<project>.web.app/privacy` and `/terms` for App Store Connect.

## 5. App Store Connect listing — [you, assets ready]
- [x] Screenshots: raw (`ci-logs/store/`) and branded Arabic frames
      (`ci-logs/store-framed/`), 6.9" = 1320×2868, produced by CI.
- [ ] App name, subtitle, description, keywords (AR + EN), category, age rating.
- [ ] Privacy "nutrition label" — mirror `PrivacyInfo.xcprivacy`
      (Name, Phone, Email, User ID, Audio, User Content; not used for tracking).
- [ ] Privacy Policy URL + Support URL.

## 6. Payments note — [informational]
Bookings are paid by bank transfer / QR for a **real-world service**
(in-person training), which is allowed outside Apple IAP. Keep it presented as
a real-world service, not a digital purchase. Do not add IAP unless you sell
purely digital content.

## 7. Pre-submit — [you]
- [ ] TestFlight beta on real devices.
- [ ] Final pass on production data and auth.

---
### Recommended next enhancements (not blockers)
- Push notifications (FCM/APNs) for booking approval — currently local only.
- Sign in with Apple — required only if you later add Google/third-party login.
