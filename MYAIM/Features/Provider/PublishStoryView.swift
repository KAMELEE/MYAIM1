import SwiftUI

/// Academy-side: publish a story that appears in the trainees' stories row.
struct PublishStoryView: View {
    @Environment(ProviderStore.self) private var store
    @Environment(FeaturedStore.self) private var featured
    @Environment(\.dismiss) private var dismiss

    @State private var caption = ""
    @State private var attachImage = true

    private var canPublish: Bool { !caption.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                academyRow

                Text("تظهر الستوري أعلى الرئيسية للمتدربين لمدة ٢٤ ساعة.")
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textSecondary)

                TextField("عن ماذا تتحدث الستوري؟ مثال: خصم ٢٥٪ لفترة محدودة",
                          text: $caption, axis: .vertical)
                    .font(MYTypography.body)
                    .lineLimit(2...4)
                    .padding(MYSpacing.md)
                    .background(MYColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                        .strokeBorder(MYColor.border, lineWidth: 1))

                Toggle(isOn: $attachImage) {
                    Label("استخدام صورة الأكاديمية", systemImage: "photo")
                        .font(MYTypography.body).foregroundStyle(MYColor.textPrimary)
                }
                .tint(MYColor.primary)

                if attachImage {
                    MYRemoteImage(assetName: store.category.imageName, accent: store.category.accent)
                        .frame(height: 150).frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                }
            }
            .padding(MYSpacing.screen)
        }
        .safeAreaInset(edge: .bottom) {
            MYButton(title: "نشر الستوري", icon: "flame.fill", isEnabled: canPublish) {
                featured.publishStory(
                    providerName: store.academyName,
                    imageAsset: attachImage ? store.category.imageName : nil,
                    accent: store.category.accent,
                    caption: caption.trimmingCharacters(in: .whitespaces)
                )
                Haptics.success()
                dismiss()
            }
            .padding(MYSpacing.lg)
            .background(.regularMaterial)
            .myTabBarClearance()
        }
        .myScreenBackground()
        .navigationTitle("ستوري جديد")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
    }

    private var academyRow: some View {
        HStack(spacing: MYSpacing.sm) {
            MYRemoteImage(assetName: store.category.imageName, accent: store.category.accent)
                .frame(width: 44, height: 44).clipShape(Circle())
            Text(store.academyName)
                .font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary)
            Spacer()
        }
    }
}

/// Academy-side: buy a paid ad shown first on the trainees' Home.
/// Steps (one screen): content → package → payment (bank transfer / QR).
struct PublishAdView: View {
    @Environment(ProviderStore.self) private var store
    @Environment(FeaturedStore.self) private var featured
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var subtitle = ""
    @State private var attachImage = true
    @State private var package: AdPackage = .twoWeeks
    @State private var method: PaymentMethod = .bankTransfer
    @State private var reference = "AD-\(Int.random(in: 1000...9999))"
    @State private var submitted = false

    private var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && !subtitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Group {
            if submitted { successView } else { form }
        }
        .myScreenBackground()
        .navigationTitle(submitted ? "" : "إعلان مدفوع")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Form
    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                section("١. محتوى الإعلان") {
                    field("عنوان الإعلان", "مثال: خصم ٣٠٪ على الاشتراك الشهري", $title)
                    field("الوصف", "مثال: برامج صباحية ومسائية بإشراف مدربين معتمدين",
                          $subtitle, multiline: true)
                    Toggle(isOn: $attachImage) {
                        Label("استخدام صورة الأكاديمية", systemImage: "photo")
                            .font(MYTypography.body).foregroundStyle(MYColor.textPrimary)
                    }
                    .tint(MYColor.primary)
                    preview
                }

                section("٢. مدة الظهور") {
                    ForEach(AdPackage.allCases) { p in packageRow(p) }
                }

                section("٣. الدفع") {
                    methodSwitch
                    if method == .bankTransfer { bankDetails } else { qrDetails }
                    Text("حوّل المبلغ واكتب الرقم المرجعي في ملاحظة التحويل. يظهر إعلانك للمتدربين فور تأكيد الإدارة للدفع.")
                        .font(MYTypography.caption).foregroundStyle(MYColor.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(MYSpacing.screen)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: MYSpacing.md) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("الإجمالي").font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
                    Text(MYFormat.price(package.price))
                        .font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary)
                }
                MYButton(title: "حوّلت المبلغ — انشر", icon: "megaphone.fill", isEnabled: canPublish) {
                    featured.publishAd(
                        title: title.trimmingCharacters(in: .whitespaces),
                        subtitle: subtitle.trimmingCharacters(in: .whitespaces),
                        providerName: store.academyName,
                        imageAsset: attachImage ? store.category.imageName : nil,
                        accent: store.category.accent,
                        package: package, paymentMethod: method, reference: reference
                    )
                    Haptics.success()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { submitted = true }
                }
            }
            .padding(MYSpacing.lg)
            .background(.regularMaterial)
            .overlay(alignment: .top) { Divider() }
            .myTabBarClearance()
        }
    }

    /// Live preview of how trainees will see the ad.
    private var preview: some View {
        SponsoredAdCard(ad: AcademyAd(
            title: title.isEmpty ? "عنوان إعلانك" : title,
            subtitle: subtitle.isEmpty ? "وصف قصير يظهر للمتدربين" : subtitle,
            providerName: store.academyName,
            imageAsset: attachImage ? store.category.imageName : nil,
            accentHex: "#5B3FBF"), onTap: {})
            .allowsHitTesting(false)
    }

    private func packageRow(_ p: AdPackage) -> some View {
        let on = package == p
        return Button {
            Haptics.selection()
            withAnimation(.snappy) { package = p }
        } label: {
            HStack(spacing: MYSpacing.md) {
                Image(systemName: on ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(on ? MYColor.primary : MYColor.textTertiary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(p.title) · \(p.days) يوم")
                        .font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary)
                    Text(p.note).font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
                }
                Spacer()
                Text(MYFormat.price(p.price))
                    .font(MYTypography.cardTitle)
                    .foregroundStyle(on ? MYColor.primary : MYColor.textPrimary)
            }
            .padding(MYSpacing.md)
            .background(on ? MYColor.primaryTint : MYColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                .strokeBorder(on ? MYColor.primary : MYColor.border, lineWidth: on ? 1.5 : 0.5))
        }
        .buttonStyle(.plain)
    }

    private var methodSwitch: some View {
        HStack(spacing: 0) {
            ForEach(PaymentMethod.allCases) { m in
                let on = method == m
                Button {
                    Haptics.selection(); withAnimation { method = m }
                } label: {
                    HStack(spacing: MYSpacing.xs) {
                        Image(systemName: m.icon).font(.system(size: 14, weight: .semibold))
                        Text(m.title).font(MYTypography.secondary)
                    }
                    .foregroundStyle(on ? .white : MYColor.textSecondary)
                    .frame(maxWidth: .infinity).padding(.vertical, MYSpacing.sm)
                    .background(on ? MYColor.primary : .clear)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(3).background(MYColor.surfaceSecondary).clipShape(Capsule())
    }

    private var bankDetails: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            copyRow("المصرف", PaymentInfo.bankName, copyable: false)
            copyRow("اسم الحساب", PaymentInfo.accountName, copyable: false)
            copyRow("الآيبان", PaymentInfo.iban)
            copyRow("الرقم المرجعي", reference)
        }
        .myCard()
    }

    private var qrDetails: some View {
        VStack(spacing: MYSpacing.sm) {
            MYQRCode(value: PaymentInfo.qrPayload(amount: package.price, ref: reference))
            Text("امسح الرمز عبر تطبيق مصرفك لإتمام التحويل")
                .font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
            copyRow("الرقم المرجعي", reference)
        }
        .frame(maxWidth: .infinity)
        .myCard()
    }

    private func copyRow(_ label: String, _ value: String, copyable: Bool = true) -> some View {
        HStack {
            Text(label).font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
            Spacer()
            Text(value).font(MYTypography.secondary).foregroundStyle(MYColor.textPrimary)
                .lineLimit(1).truncationMode(.middle)
            if copyable {
                Button {
                    UIPasteboard.general.string = value
                    Haptics.success()
                } label: {
                    Image(systemName: "doc.on.doc").font(.system(size: 13)).foregroundStyle(MYColor.primary)
                }
            }
        }
        .padding(.vertical, MYSpacing.xxs)
    }

    private func section<Content: View>(_ title: String,
                                        @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text(title).font(MYTypography.section).foregroundStyle(MYColor.textPrimary)
            content()
        }
    }

    private func field(_ label: String, _ placeholder: String, _ text: Binding<String>,
                       multiline: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: MYSpacing.xs) {
            Text(label).font(MYTypography.secondary).foregroundStyle(MYColor.textPrimary)
            TextField(placeholder, text: text, axis: multiline ? .vertical : .horizontal)
                .font(MYTypography.body)
                .lineLimit(multiline ? 1...3 : 1...1)
                .padding(MYSpacing.md)
                .background(MYColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                    .strokeBorder(MYColor.border, lineWidth: 1))
        }
    }

    // MARK: Success
    private var successView: some View {
        VStack(spacing: MYSpacing.lg) {
            Spacer()
            Image(systemName: featured.activatesInstantly ? "checkmark.seal.fill" : "clock.badge.checkmark.fill")
                .font(.system(size: 64))
                .foregroundStyle(featured.activatesInstantly ? MYColor.success : MYColor.primary)
                .symbolEffect(.bounce, value: submitted)
            Text(featured.activatesInstantly ? "إعلانك ظاهر الآن" : "استلمنا طلب إعلانك")
                .font(MYTypography.section).foregroundStyle(MYColor.textPrimary)
            Text(featured.activatesInstantly
                 ? "يظهر أول شيء في رئيسية المتدربين لمدة \(package.days) يوم."
                 : "بعد تأكيد التحويل (المرجع \(reference)) يظهر إعلانك أول شيء في رئيسية المتدربين لمدة \(package.days) يوم.")
                .font(MYTypography.body).foregroundStyle(MYColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MYSpacing.xl)
            Spacer()
            MYButton(title: "تم", icon: nil) { dismiss() }
                .padding(MYSpacing.lg)
                .myTabBarClearance()
        }
    }
}

#Preview {
    NavigationStack { PublishStoryView() }
        .environment(ProviderStore())
        .environment(FeaturedStore())
        .environment(\.layoutDirection, .rightToLeft)
}
