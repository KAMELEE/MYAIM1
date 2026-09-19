# Repository Architecture

كل Repository يُعرَّف كـ **بروتوكول** أولاً، ثم تُبنى تطبيقاته:

1. `MockXxxRepository` — بيانات وهمية واقعية (المرحلة الحالية من التطوير).
2. لاحقًا: `RemoteXxxRepository` — REST / Firebase / Supabase — دون تغيير الواجهة (Views/ViewModels).

البروتوكولات المخطّطة:
- `AuthRepository`
- `ServiceRepository`
- `ProviderRepository`
- `BookingRepository`
- `GoalRepository`

تُبنى بالكامل عند الوصول للميزات التي تستهلكها (المرحلة 4 وما بعدها)، بحيث يعتمد كل ViewModel على البروتوكول لا على التطبيق الفعلي (Dependency Inversion → قابلية ربط أي Backend لاحقًا).
