# MY AIM — App Store Release Checklist

Status of readiness for submitting to the App Store. Items marked **[done]**
are handled in the codebase; **[you]** require your Apple/Firebase accounts.

## 1. Apple Developer & signing — [you]
- [ ] Enroll in the Apple Developer Program ($99/yr).
- [ ] Put your Team ID in `project.yml` → `DEVELOPMENT_TEAM`.
- [ ] Create the App ID for bundle `com.myaim.app` in the developer portal.
- [ ] Produce a **signed Release archive** (Mac + Xcode, or CI with an
      App Store Connect API key). CI currently builds unsigned for the
      simulator only (`CODE_SIGNING_ALLOWED=NO`).

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
