import SwiftUI

/// Service details. A working, well-structured screen; richer sections
/// (reviews, similar services, availability) are expanded in Phase 8.
struct ServiceDetailView: View {
    let service: Service

    @Environment(Router.self) private var router
    @Environment(FavoritesStore.self) private var favorites
    @Environment(MessagesStore.self) private var messages
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSlot: Int = 0

    private var isFavorite: Bool { favorites.contains(service.id) }
    private static let sheetRadius: CGFloat = 24

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                VStack(alignment: .leading, spacing: MYSpacing.lg) {
                    titleBlock
                    providerCard
                    scheduleSection
                    aboutSection
                    includesSection
                    locationSection
                    reviewsSection
                    similarSection
                }
                .padding(.top, MYSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    UnevenRoundedRectangle(topLeadingRadius: Self.sheetRadius,
                                           topTrailingRadius: Self.sheetRadius,
                                           style: .continuous)
                        .fill(MYColor.background)
                )
                .padding(.top, -Self.sheetRadius)
            }
            .padding(.bottom, MYSpacing.xxxl)
        }
        .myScreenBackground()
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) { bookBar }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) { topControls }
    }

    // MARK: Header image
    private var header: some View {
        MYRemoteImage(assetName: service.category.imageName,
                      urlString: service.imageURL,
                      fallbackIcon: service.category.icon,
                      accent: service.category.accent)
            .frame(height: 320)
            .clipped()
    }

    // MARK: Floating back / favorite / share
    private var topControls: some View {
        HStack {
            circleButton("chevron.backward") { dismiss() }
            Spacer()
            HStack(spacing: MYSpacing.sm) {
                circleButton("square.and.arrow.up") {}
                circleButton(isFavorite ? "heart.fill" : "heart",
                             tint: isFavorite ? MYColor.error : MYColor.textPrimary) {
                    Haptics.medium()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        favorites.toggle(service.id)
                    }
                }
            }
        }
        .padding(.horizontal, MYSpacing.lg)
        .padding(.top, 54)
    }

    private func circleButton(_ icon: String,
                              tint: Color = MYColor.textPrimary,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(MYColor.surface, in: Circle())
                .myShadow(MYShadow.raised)
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: Category / title / rating
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: MYSpacing.xs) {
            Text(service.category.title)
                .font(.appFont(12, weight: .semibold))
                .foregroundStyle(MYColor.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(MYColor.primaryTint, in: Capsule())

            Text(service.title)
                .font(MYTypography.pageTitle)
                .foregroundStyle(MYColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: MYSpacing.md) {
                MYRating(rating: service.rating, reviewsCount: service.reviewsCount)
                HStack(spacing: MYSpacing.xxs) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(MYColor.textTertiary)
                    Text(locationText)
                        .font(MYTypography.caption)
                        .foregroundStyle(MYColor.textSecondary)
                }
            }
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    // MARK: Academy card
    private var providerCard: some View {
        Button {
            if let provider = SampleData.providers.first(where: { $0.id == service.providerId }) {
                router.push(.providerProfile(provider))
            }
        } label: {
            HStack(spacing: MYSpacing.md) {
                Text(String(service.providerName.replacingOccurrences(of: "أكاديمية ", with: "").prefix(1)))
                    .font(.appFont(17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(MYColor.brandSolid,
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(service.providerName)
                            .font(MYTypography.cardTitle)
                            .foregroundStyle(MYColor.textPrimary)
                            .lineLimit(1)
                        if service.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(MYColor.primary)
                        }
                    }
                    Text(service.isVerified ? "جهة موثّقة · عرض الملف" : "عرض الملف")
                        .font(MYTypography.caption)
                        .foregroundStyle(MYColor.textSecondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.forward")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(MYColor.textTertiary)
            }
            .myCard(padding: MYSpacing.md)
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.horizontal, MYSpacing.screen)
    }

    // MARK: Upcoming sessions
    private var upcomingDays: [Date] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: .now)
        return [2, 4, 6, 8].compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text("أقرب المواعيد")
                .font(MYTypography.section)
                .foregroundStyle(MYColor.textPrimary)
            HStack(spacing: MYSpacing.xs) {
                ForEach(Array(upcomingDays.enumerated()), id: \.offset) { i, day in
                    let on = i == selectedSlot
                    Button {
                        Haptics.selection()
                        withAnimation(.snappy) { selectedSlot = i }
                    } label: {
                        VStack(spacing: 2) {
                            Text(day.formatted(.dateTime.weekday(.wide).locale(Locale(identifier: "ar"))))
                                .font(.appFont(12))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Text(day.formatted(.dateTime.day().locale(Locale(identifier: "ar"))))
                                .font(.appFont(17, weight: .bold))
                        }
                        .foregroundStyle(on ? .white : MYColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(on ? MYColor.primary : MYColor.surface,
                                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(on ? .clear : MYColor.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    private var locationText: String {
        if let d = service.distanceMeters {
            return "\(service.location.city) · \(MYFormat.distance(d))"
        }
        return service.location.city
    }

    // MARK: Sections
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text("عن الخدمة")
                .font(MYTypography.section)
                .foregroundStyle(MYColor.textPrimary)
            Text(service.summary)
                .font(MYTypography.body)
                .foregroundStyle(MYColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    private var includesSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text("ماذا ستحصل عليه")
                .font(MYTypography.section)
                .foregroundStyle(MYColor.textPrimary)
            ForEach(includes, id: \.self) { item in
                HStack(spacing: MYSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(MYColor.primary)
                    Text(item)
                        .font(MYTypography.body)
                        .foregroundStyle(MYColor.textPrimary)
                }
            }
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    private var includes: [String] {
        ["خطة مخصّصة حسب مستواك", "متابعة دورية مع المدرب", "شهادة إتمام معتمدة", "دعم مباشر عبر التطبيق"]
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            Text("الموقع")
                .font(MYTypography.section)
                .foregroundStyle(MYColor.textPrimary)
            HStack(spacing: MYSpacing.sm) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(MYColor.primary)
                Text([service.location.district, service.location.city].compactMap { $0 }.joined(separator: "، "))
                    .font(MYTypography.body)
                    .foregroundStyle(MYColor.textSecondary)
            }
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    // MARK: Reviews
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            Text("آراء العملاء")
                .font(MYTypography.section)
                .foregroundStyle(MYColor.textPrimary)
            ratingSummary
            ForEach(SampleData.reviews) { review in
                VStack(alignment: .leading, spacing: MYSpacing.xs) {
                    HStack {
                        Text(review.authorName)
                            .font(MYTypography.cardTitle)
                            .foregroundStyle(MYColor.textPrimary)
                        Spacer()
                        MYRating(rating: review.rating, showCount: false)
                    }
                    Text(review.comment)
                        .font(MYTypography.secondary)
                        .foregroundStyle(MYColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .myCard(padding: MYSpacing.md)
            }
        }
        .padding(.horizontal, MYSpacing.screen)
    }

    /// Overall score + star distribution of the reviews shown below.
    private var ratingSummary: some View {
        let reviews = SampleData.reviews
        let total = max(reviews.count, 1)
        return HStack(spacing: MYSpacing.lg) {
            VStack(spacing: 2) {
                Text(String(format: "%.1f", service.rating))
                    .font(.appFont(30, weight: .bold))
                    .foregroundStyle(MYColor.textPrimary)
                Text("\(service.reviewsCount) تقييم")
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textSecondary)
            }
            .frame(minWidth: 70)
            VStack(spacing: 5) {
                ForEach([5, 4, 3, 2, 1], id: \.self) { star in
                    let n = reviews.filter { Int($0.rating.rounded()) == star }.count
                    HStack(spacing: MYSpacing.xs) {
                        Text("\(star)")
                            .font(.appFont(11))
                            .foregroundStyle(MYColor.textSecondary)
                            .frame(width: 10)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(MYColor.surfaceSecondary)
                                Capsule().fill(MYColor.star)
                                    .frame(width: geo.size.width * CGFloat(n) / CGFloat(total))
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
            .accessibilityHidden(true)
        }
        .myCard(padding: MYSpacing.md)
        .accessibilityElement(children: .combine)
    }

    // MARK: Similar services
    private var similar: [Service] {
        SampleData.services.filter { $0.category == service.category && $0.id != service.id }
    }

    @ViewBuilder
    private var similarSection: some View {
        if !similar.isEmpty {
            VStack(alignment: .leading, spacing: MYSpacing.md) {
                Text("خدمات مشابهة")
                    .font(MYTypography.section)
                    .foregroundStyle(MYColor.textPrimary)
                    .padding(.horizontal, MYSpacing.screen)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: MYSpacing.md) {
                        ForEach(similar) { s in
                            MYServiceCard(service: s, onTap: { router.push(.serviceDetail(s)) })
                                .frame(width: 244)
                        }
                    }
                    .padding(.horizontal, MYSpacing.screen)
                }
            }
        }
    }

    // MARK: Sticky book bar
    private var bookBar: some View {
        HStack(spacing: MYSpacing.md) {
            VStack(alignment: .leading, spacing: 0) {
                Text("يبدأ من")
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textSecondary)
                Text(MYFormat.price(service.startingPrice))
                    .font(.appFont(19, weight: .bold))
                    .foregroundStyle(MYColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer(minLength: 0)
            contactButton
            MYButton(title: "احجز الآن", fullWidth: false) {
                router.push(.booking(service))
            }
        }
        .padding(.horizontal, MYSpacing.screen)
        .padding(.vertical, MYSpacing.md)
        .background(MYColor.surface)
        .overlay(alignment: .top) { Divider() }
        .myTabBarClearance()
    }

    /// "تواصل" — opens a chat thread with this service's academy.
    private var contactButton: some View {
        Button {
            Haptics.light()
            let conversation = messages.openConversation(with: service,
                                                         traineeName: appState.currentUser?.name)
            router.push(.chat(conversation))
        } label: {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(MYColor.textPrimary)
                .frame(width: 52, height: 52)
                .background(MYColor.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(MYColor.border, lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("تواصل مع الأكاديمية")
    }
}

#Preview {
    NavigationStack {
        ServiceDetailView(service: SampleData.services[0])
            .environment(Router())
            .environment(FavoritesStore())
            .environment(MessagesStore())
            .environment(AppState())
    }
    .environment(\.layoutDirection, .rightToLeft)
    .environment(\.locale, Locale(identifier: "ar"))
}
