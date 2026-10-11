import SwiftUI

/// The two legal documents, shown in-app and mirrored as hosted web pages
/// (see /hosting) for the App Store Connect privacy/terms URLs.
enum LegalDoc: String, Hashable, Identifiable {
    case terms, privacy
    var id: String { rawValue }

    var title: String {
        self == .terms ? "الشروط والأحكام" : "سياسة الخصوصية"
    }
}

/// A heading + paragraph block.
struct LegalSection: Identifiable {
    let id = UUID()
    let heading: String
    let body: String
}

struct LegalView: View {
    let document: LegalDoc

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MYSpacing.lg) {
                Text("آخر تحديث: ٣٠ سبتمبر ٢٠٢٥")
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textTertiary)

                ForEach(LegalContent.sections(for: document)) { section in
                    VStack(alignment: .leading, spacing: MYSpacing.xs) {
                        Text(section.heading)
                            .font(MYTypography.cardTitle)
                            .foregroundStyle(MYColor.textPrimary)
                        Text(section.body)
                            .font(MYTypography.body)
                            .foregroundStyle(MYColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Text("للتواصل بخصوص هذه الوثيقة: support@myaim.app")
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textTertiary)
                    .padding(.top, MYSpacing.md)
            }
            .padding(MYSpacing.screen)
        }
        .myScreenBackground()
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { LegalView(document: .privacy) }
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
