import SwiftUI
import MapKit

/// Map mode for Discover. Shows service markers; tapping one reveals a mini card.
/// Live user location + clustering arrive in Phase 7.
struct MapResultsView: View {
    let services: [Service]
    var userLocation: CLLocationCoordinate2D? = nil
    var onOpen: (Service) -> Void

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753), // الرياض
            span: MKCoordinateSpan(latitudeDelta: 6, longitudeDelta: 6)
        )
    )
    @State private var selectedID: UUID?
    @State private var centeredOnUser = false

    private var selectedService: Service? {
        services.first { $0.id == selectedID }
    }

    private var userLocationKey: String {
        guard let u = userLocation else { return "" }
        return "\(u.latitude),\(u.longitude)"
    }

    private func centerOnUserIfNeeded() {
        guard !centeredOnUser, let u = userLocation else { return }
        centeredOnUser = true
        withAnimation {
            position = .region(MKCoordinateRegion(
                center: u,
                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
            ))
        }
    }

    var body: some View {
        Map(position: $position, selection: $selectedID) {
            UserAnnotation()
            ForEach(services) { service in
                Annotation(service.title, coordinate: service.location.coordinate) {
                    pin(for: service)
                }
                .tag(service.id)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onChange(of: userLocationKey) { _, _ in centerOnUserIfNeeded() }
        .onAppear { centerOnUserIfNeeded() }
        .overlay(alignment: .bottom) {
            if let service = selectedService {
                miniCard(service)
                    .padding(MYSpacing.lg)
                    .padding(.bottom, 70) // clear the floating tab bar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selectedID)
    }

    private func pin(for service: Service) -> some View {
        let isSelected = service.id == selectedID
        return VStack(spacing: 2) {
            Text(MYFormat.price(service.startingPrice))
                .font(.appFont(11, weight: .bold))
                .foregroundStyle(isSelected ? .white : MYColor.primary)
                .padding(.horizontal, MYSpacing.sm)
                .padding(.vertical, MYSpacing.xs)
                .background(isSelected ? MYColor.primary : MYColor.surface)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(MYColor.primary, lineWidth: 1))
                .myShadow()
                .scaleEffect(isSelected ? 1.1 : 1.0)
        }
    }

    private func miniCard(_ service: Service) -> some View {
        Button {
            onOpen(service)
        } label: {
            HStack(spacing: MYSpacing.md) {
                MYRemoteImage(assetName: service.category.imageName,
                              urlString: service.imageURL,
                              fallbackIcon: service.category.icon,
                              accent: service.category.accent)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.sm, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(service.title)
                        .font(MYTypography.cardTitle)
                        .foregroundStyle(MYColor.textPrimary)
                        .lineLimit(1)
                    MYRating(rating: service.rating, reviewsCount: service.reviewsCount)
                    MYPrice(amount: service.startingPrice)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.forward")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MYColor.textTertiary)
            }
            .myCard(padding: MYSpacing.md)
        }
        .buttonStyle(PressableButtonStyle())
    }
}
