import SwiftUI

struct BookingView: View {
    @Environment(Router.self) private var router
    @Environment(NotificationService.self) private var notifications
    @State private var vm: BookingViewModel

    init(service: Service) {
        _vm = State(initialValue: BookingViewModel(service: service))
    }

    var body: some View {
        Group {
            if vm.didConfirm {
                successView
            } else {
                bookingFlow
            }
        }
        .myScreenBackground()
        .navigationTitle(vm.didConfirm ? "" : "الحجز")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-demoMode") { return }
            #endif
            notifications.request()
        }
    }

    // MARK: Flow
    private var bookingFlow: some View {
        VStack(spacing: 0) {
            stepIndicator.padding(MYSpacing.screen)
            Divider().background(MYColor.border)

            ScrollView {
                VStack(alignment: .leading, spacing: MYSpacing.lg) {
                    Text(vm.stepTitle)
                        .font(MYTypography.section)
                        .foregroundStyle(MYColor.textPrimary)

                    if vm.step == 0 { reviewStep } else { paymentStep }
                }
                .padding(MYSpacing.screen)
            }

            bottomBar
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: MYSpacing.sm) {
            ForEach(0...BookingViewModel.lastStep, id: \.self) { i in
                Capsule()
                    .fill(i <= vm.step ? MYColor.primary : MYColor.border)
                    .frame(height: 5)
            }
        }
    }

    // MARK: Step 1 — review + instructions
    private var reviewStep: some View {
        VStack(alignment: .leading, spacing: MYSpacing.lg) {
            // Service summary
            VStack(spacing: MYSpacing.md) {
                summaryRow("الخدمة", vm.service.title)
                summaryRow("المقدّم", vm.service.providerName)
                Divider().background(MYColor.border)
                summaryRow("السعر", MYFormat.price(vm.service.startingPrice), emphasized: true)
            }
            .myCard()

            // Instructions for the trainee
            VStack(alignment: .leading, spacing: MYSpacing.md) {
                HStack(spacing: MYSpacing.xs) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 15)).foregroundStyle(MYColor.primary)
                    Text("خطوات إتمام الحجز")
                        .font(MYTypography.cardTitle).foregroundStyle(MYColor.textPrimary)
                }
                ForEach(Array(BookingInstructions.steps.enumerated()), id: \.offset) { idx, s in
                    instructionRow(number: idx + 1, icon: s.icon, title: s.title, detail: s.detail)
                }
            }
            .myCard()

            if let msg = vm.errorMessage { AuthErrorBanner(message: msg) }
        }
    }

    private func instructionRow(number: Int, icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: MYSpacing.md) {
            Text("\(number)")
                .font(.appFont(13, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(MYColor.primary)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(MYTypography.secondary).foregroundStyle(MYColor.textPrimary)
                Text(detail)
                    .font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private func summaryRow(_ label: String, _ value: String, emphasized: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(MYTypography.secondary)
                .foregroundStyle(MYColor.textSecondary)
            Spacer()
            Text(value)
                .font(emphasized ? MYTypography.cardTitle : MYTypography.secondary)
                .foregroundStyle(emphasized ? MYColor.primary : MYColor.textPrimary)
        }
    }

    // MARK: Bottom bar
    private var bottomBar: some View {
        HStack(spacing: MYSpacing.md) {
            if vm.step > 0 {
                MYButton(title: "السابق", style: .outline, fullWidth: false) { vm.back() }
            }
            if vm.step < BookingViewModel.lastStep {
                MYButton(title: "المتابعة للدفع") { vm.next() }
            } else {
                MYButton(title: "أرسل الطلب", icon: "paperplane.fill", isLoading: vm.isSubmitting) {
                    Task { await vm.submitRequest() }
                }
            }
        }
        .padding(MYSpacing.lg)
        .background(.regularMaterial)
        .overlay(alignment: .top) { Divider() }
        .myTabBarClearance()
    }

    // MARK: Success
    private var successView: some View {
        VStack(spacing: MYSpacing.lg) {
            Spacer()
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 80))
                .foregroundStyle(MYColor.warning)
            Text("تم إرسال طلبك")
                .font(MYTypography.pageTitle)
                .foregroundStyle(MYColor.textPrimary)
            Text("طلبك قيد المراجعة — سيتم تأكيد الحجز بعد التحقق من التحويل من قِبل الإدارة، وستصلك رسالة عند التأكيد لتحديد الموعد.")
                .font(MYTypography.body)
                .foregroundStyle(MYColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MYSpacing.xl)
            MYTag(text: "الرقم المرجعي: \(vm.reference)", style: .brand)
            Text(vm.service.title)
                .font(MYTypography.caption)
                .foregroundStyle(MYColor.textTertiary)
                .multilineTextAlignment(.center)
            Spacer()
            MYButton(title: "متابعة حجوزاتي", icon: "calendar") { router.popToRoot() }
                .padding(.horizontal, MYSpacing.screen)
        }
        .padding(.bottom, MYSpacing.xxxl)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Step 2 — payment (bank transfer / QR)
    private var paymentStep: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            // Amount
            HStack {
                Text("المبلغ المطلوب").font(MYTypography.secondary).foregroundStyle(MYColor.textSecondary)
                Spacer()
                Text(MYFormat.price(vm.service.startingPrice))
                    .font(MYTypography.section).foregroundStyle(MYColor.primary)
            }
            .myCard(padding: MYSpacing.md)

            // Method switch
            HStack(spacing: 0) {
                ForEach(PaymentMethod.allCases) { m in
                    let on = vm.paymentMethod == m
                    Button {
                        Haptics.selection(); withAnimation { vm.paymentMethod = m }
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

            if vm.paymentMethod == .bankTransfer { bankDetails } else { qrDetails }

            Text("بعد إتمام التحويل اضغط «أرسل الطلب». تتحقق الإدارة من التحويل ثم تؤكّد الحجز.")
                .font(MYTypography.caption).foregroundStyle(MYColor.textTertiary)
                .fixedSize(horizontal: false, vertical: true)

            if let msg = vm.errorMessage { AuthErrorBanner(message: msg) }
        }
    }

    private var bankDetails: some View {
        VStack(alignment: .leading, spacing: MYSpacing.sm) {
            copyRow("المصرف", PaymentInfo.bankName, copyable: false)
            copyRow("اسم الحساب", PaymentInfo.accountName, copyable: false)
            copyRow("رقم الحساب", PaymentInfo.accountNumber)
            copyRow("الآيبان", PaymentInfo.iban)
            copyRow("الرقم المرجعي", vm.reference)
        }
        .myCard()
    }

    private var qrDetails: some View {
        VStack(spacing: MYSpacing.sm) {
            MYQRCode(value: PaymentInfo.qrPayload(amount: vm.service.startingPrice, ref: vm.reference))
            Text("امسح الرمز عبر تطبيق مصرفك لإتمام التحويل")
                .font(MYTypography.caption).foregroundStyle(MYColor.textSecondary)
            copyRow("الرقم المرجعي", vm.reference)
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
}

#Preview {
    NavigationStack { BookingView(service: SampleData.services[0]) }
        .environment(Router())
        .environment(NotificationService())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
