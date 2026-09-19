# Services

خدمات النظام منخفضة المستوى التي تستخدمها الـRepositories والـViewModels:

- `LocationService` — CoreLocation (موقع المستخدم، المسافات) — المرحلة 7
- `NotificationService` — UserNotifications (الإشعارات المحلية) — المرحلة 11
- `PersistenceService` — SwiftData (المفضلة، الأهداف محليًا) — عند الحاجة
- `ImageCache` / تحميل الصور — مع AsyncImage — المرحلة 5+

كل خدمة تُغلَّف خلف بروتوكول ليسهل اختبارها واستبدالها.
