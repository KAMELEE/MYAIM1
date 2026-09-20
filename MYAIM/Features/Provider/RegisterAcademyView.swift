import SwiftUI

struct RegisterAcademyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var name = ""
    @State private var category: ServiceCategory = .sports
    @State private var city = "الرياض"
    @State private var phone = ""
    @State private var about = ""
    @State private var isSubmitting = false
    @State private var didSubmit = false
    @State private var errors: [String: String] = [:]

    private let cities = ["الرياض", "جدة", "الدمام", "الخبر"]

    var body: some View {
        Group {
            if didSubmit { success } else { form }
        }
        .myScreenBackground()
        .navigationTitle("سجّل أكاديميتك")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                Text("انضم كمقدّم خدمة")
                    .font(MYTypography.section).foregroundStyle(MYColor.textPrimary)
                Text("عبّئ البيانات وسيتواصل معك فريقنا لإكمال التسجيل.")
                    .font(MYTypography.secondary).foregroundStyle(MYColor.textSecondary)

                MYTextField(title: "اسم الأكاديمية / النشاط", icon: "building.2",
                            placeholder: "مثال: أكاديمية النخبة", text: $name,
                            error: errors["name"])

                categoryPicker
                cityPicker

                MYTextField(title: "رقم الجوال", icon: "phone",
                            placeholder: "05XXXXXXXX", text: $phone,
                            keyboard: .phonePad, error: errors["phone"])

                VStack(alignment: .leading, spacing: MYSpacing.xs) {
                    Text("نبذة (اختياري)").font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
                    TextField("اكتب نبذة عن خدماتك", text: $about, axis: .vertical)
                        .font(MYTypography.body)
                        .lineLimit(3...6)
                        .padding(MYSpacing.md)
                        .background(MYColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                            .strokeBorder(MYColor.border, lineWidth: 1))
                }

                MYButton(title: "إرسال الطلب", icon: "paperplane", isLoading: isSubmitting) {
                    submit()
                }
                .padding(.top, MYSpacing.xs)
            }
            .padding(MYSpacing.screen)
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: MYSpacing.xs) {
            Text("المجال").font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MYSpacing.sm) {
                    ForEach(ServiceCategory.allCases) { c in
                        let on = category == c
                        Button { Haptics.selection(); category = c } label: {
                            Text(c.title).font(MYTypography.secondary)
                                .foregroundStyle(on ? .white : MYColor.textPrimary)
                                .padding(.horizontal, MYSpacing.md).padding(.vertical, MYSpacing.sm)
                                .background(on ? MYColor.primary : MYColor.surface)
                                .clipShape(Capsule())
                                .overlay(Capsule().strokeBorder(on ? .clear : MYColor.border, lineWidth: 1))
                        }
                    }
                }
            }
        }
    }

    private var cityPicker: some View {
        VStack(alignment: .leading, spacing: MYSpacing.xs) {
            Text("المدينة").font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
            HStack(spacing: MYSpacing.sm) {
                ForEach(cities, id: \.self) { c in
                    let on = city == c
                    Button { Haptics.selection(); city = c } label: {
                        Text(c).font(MYTypography.secondary)
                            .foregroundStyle(on ? .white : MYColor.textPrimary)
                            .padding(.horizontal, MYSpacing.md).padding(.vertical, MYSpacing.sm)
                            .background(on ? MYColor.primary : MYColor.surface)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(on ? .clear : MYColor.border, lineWidth: 1))
                    }
                }
            }
        }
    }

    private var success: some View {
        VStack(spacing: MYSpacing.lg) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80)).foregroundStyle(MYColor.success)
            Text("تم استلام طلبك!")
                .font(MYTypography.pageTitle).foregroundStyle(MYColor.textPrimary)
            Text("شكرًا لانضمامك إلى MY AIM. سيتواصل معك فريقنا قريبًا لإكمال التسجيل.")
                .font(MYTypography.body).foregroundStyle(MYColor.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, MYSpacing.xl)
            Spacer()
            VStack(spacing: MYSpacing.sm) {
                MYButton(title: "الدخول إلى لوحة الأكاديمية", icon: "building.2.fill") {
                    Haptics.success()
                    withAnimation { appState.switchMode(.provider) }
                }
                MYButton(title: "لاحقًا", style: .ghost) { dismiss() }
            }
            .padding(.horizontal, MYSpacing.screen)
        }
        .padding(.bottom, MYSpacing.xxxl)
    }

    private func submit() {
        errors = [:]
        errors["name"] = Validation.name(name)
        errors["phone"] = Validation.saudiPhone(phone)
        if !errors.isEmpty { Haptics.error(); return }

        isSubmitting = true
        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            isSubmitting = false
            Haptics.success()
            withAnimation { didSubmit = true }
        }
    }
}

#Preview {
    NavigationStack { RegisterAcademyView() }
        .environment(AppState())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
