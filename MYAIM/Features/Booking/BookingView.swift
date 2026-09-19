import SwiftUI

struct BookingView: View {
    @Environment(Router.self) private var router
    @State private var vm: BookingViewModel

    init(service: Service) {
        _vm = State(initialValue: BookingViewModel(service: service))
    }

    private let dayFmt: DateFormatter = {
        let f = DateFormatter(); f.locale = MYFormat.arLocale; f.dateFormat = "EEE"; return f
    }()
    private let dayNumFmt: DateFormatter = {
        let f = DateFormatter(); f.locale = MYFormat.arLocale; f.dateFormat = "d"; return f
    }()

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

                    switch vm.step {
                    case 0: dateStep
                    case 1: timeStep
                    default: confirmStep
                    }
                }
                .padding(MYSpacing.screen)
            }

            bottomBar
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: MYSpacing.sm) {
            ForEach(0..<3) { i in
                Capsule()
                    .fill(i <= vm.step ? MYColor.primary : MYColor.border)
                    .frame(height: 5)
            }
        }
    }

    // MARK: Step 1 — date
    private var dateStep: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MYSpacing.sm) {
                ForEach(vm.days, id: \.self) { day in
                    let isOn = vm.selectedDate.map { Calendar.current.isDate($0, inSameDayAs: day) } ?? false
                    Button {
                        Haptics.selection()
                        vm.selectedDate = day
                    } label: {
                        VStack(spacing: MYSpacing.xs) {
                            Text(dayFmt.string(from: day))
                                .font(MYTypography.caption)
                            Text(dayNumFmt.string(from: day))
                                .font(MYTypography.cardTitle)
                        }
                        .foregroundStyle(isOn ? .white : MYColor.textPrimary)
                        .frame(width: 60, height: 72)
                        .background(isOn ? MYColor.primary : MYColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                            .strokeBorder(isOn ? .clear : MYColor.border, lineWidth: 1))
                    }
                }
            }
        }
    }

    // MARK: Step 2 — time
    private var timeStep: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                  spacing: MYSpacing.sm) {
            ForEach(vm.times, id: \.self) { time in
                let isOn = vm.selectedTime == time
                Button {
                    Haptics.selection()
                    vm.selectedTime = time
                } label: {
                    Text(time)
                        .font(MYTypography.secondary)
                        .foregroundStyle(isOn ? .white : MYColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, MYSpacing.md)
                        .background(isOn ? MYColor.primary : MYColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: MYRadius.md, style: .continuous)
                            .strokeBorder(isOn ? .clear : MYColor.border, lineWidth: 1))
                }
            }
        }
    }

    // MARK: Step 3 — confirm
    private var confirmStep: some View {
        VStack(spacing: MYSpacing.md) {
            summaryRow("الخدمة", vm.service.title)
            summaryRow("المقدّم", vm.service.providerName)
            summaryRow("التاريخ", vm.selectedDate.map { MYFormat.longDate($0) } ?? "-")
            summaryRow("الوقت", vm.selectedTime ?? "-")
            Divider().background(MYColor.border)
            summaryRow("السعر", MYFormat.price(vm.service.startingPrice), emphasized: true)

            if let msg = vm.errorMessage {
                AuthErrorBanner(message: msg)
            }
        }
        .myCard()
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
            if vm.step < 2 {
                MYButton(title: "التالي", isEnabled: vm.canProceed) { vm.next() }
            } else {
                MYButton(title: "تأكيد الحجز", icon: "checkmark", isLoading: vm.isSubmitting) {
                    Task { await vm.confirm() }
                }
            }
        }
        .padding(MYSpacing.lg)
        .background(.regularMaterial)
        .overlay(alignment: .top) { Divider() }
    }

    // MARK: Success
    private var successView: some View {
        VStack(spacing: MYSpacing.lg) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 84))
                .foregroundStyle(MYColor.success)
            Text("تم تأكيد حجزك!")
                .font(MYTypography.pageTitle)
                .foregroundStyle(MYColor.textPrimary)
            Text("\(vm.service.title)\n\(vm.selectedDate.map { MYFormat.longDate($0) } ?? "") · \(vm.selectedTime ?? "")")
                .font(MYTypography.body)
                .foregroundStyle(MYColor.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            MYButton(title: "العودة للرئيسية") { router.popToRoot() }
                .padding(.horizontal, MYSpacing.screen)
        }
        .padding(.bottom, MYSpacing.xxxl)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack { BookingView(service: SampleData.services[0]) }
        .environment(Router())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
