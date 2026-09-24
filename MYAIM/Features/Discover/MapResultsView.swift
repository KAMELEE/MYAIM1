import SwiftUI
import MapKit

/// Map mode for Discover. Shows live user location, price pins for services,
/// and grid-based clustering that merges nearby markers as you zoom out (Phase 7).
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

    // Clustering state (recomputed whenever the camera settles).
    @State private var clusters: [ServiceCluster] = []
    @State private var currentSpan = 6.0

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

    /// Rebuild clusters for the visible region. Cell size scales with zoom
    /// (~9 grid rows), so markers merge when zoomed out and split as you zoom in.
    private func rebuildClusters(for region: MKCoordinateRegion) {
        currentSpan = max(region.span.latitudeDelta, 0.005)
        var buckets: [String: [Service]] = [:]
        for service in services {
            let key = "\(Int(service.location.latitude / (region.span.latitudeDelta / 9))):\(Int(service.location.longitude / (region.span.longitudeDelta / 9)))"
            buckets[key, default: []].append(service)
        }
        let next = buckets.values
            .map { ServiceCluster(services: $0.sorted { $0.title < $1.title }) }
            .sorted { $0.anchor.title < $1.anchor.title }
        // Keep selection valid: if the selected service's cluster still exists
        // as a merged cluster, drop the selection (a cluster isn't a card).
        if let selectedID,
           let cluster = next.first(where: { $0.contains(selectedID) }),
           cluster.services.count > 1 {
            self.selectedID = nil
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            clusters = next
        }
    }

    var body: some View {
        Map(position: $position, selection: $selectedID) {
            UserAnnotation()
            ForEach(clusters) { cluster in
                if cluster.services.count == 1 {
                    Annotation(cluster.anchor.title,
                               coordinate: cluster.coordinate) {
                        pin(for: cluster.anchor)
                    }
                    .tag(cluster.anchor.id)
                } else {
                    Annotation(cluster.displayTitle,
                               coordinate: cluster.coordinate) {
                        Button {
                            zoomInto(cluster)
                        } label: {
                            clusterPin(cluster)
                        }
                    }
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onMapCameraChange(frequency: .onEnd) { update in
            rebuildClusters(for: update.region)
        }
        .onChange(of: userLocationKey) { _, _ in centerOnUserIfNeeded() }
        .onAppear {
            // Seed clusters for the initial (Riyadh) region before the first pan.
            rebuildClusters(for: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753),
                span: MKCoordinateSpan(latitudeDelta: 6, longitudeDelta: 6)
            ))
            centerOnUserIfNeeded()
        }
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

    /// Zoom into a merged cluster so its members split apart.
    private func zoomInto(_ cluster: ServiceCluster) {
        Haptics.light()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            let span = max(currentSpan * 0.4, 0.02)
            position = .region(MKCoordinateRegion(
                center: cluster.coordinate,
                span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
            ))
        }
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

    private func clusterPin(_ cluster: ServiceCluster) -> some View {
        VStack(spacing: 2) {
            Text("\(cluster.services.count)")
                .font(.appFont(14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Circle().fill(MYColor.primary))
                .overlay(Circle().strokeBorder(.white.opacity(0.9), lineWidth: 2))
                .myShadow()
            Text(MYFormat.price(cluster.minPrice))
                .font(.appFont(10, weight: .bold))
                .foregroundStyle(MYColor.primary)
                .padding(.horizontal, MYSpacing.sm)
                .padding(.vertical, 2)
                .background(MYColor.surface)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(MYColor.primary, lineWidth: 1))
                .myShadow()
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

// MARK: - Clustering

/// A group of services whose markers share one grid cell at the current zoom.
struct ServiceCluster: Identifiable, Equatable {
    /// Stable per rebuild: anchored on the first member's id.
    var id: UUID { services.first?.id ?? UUID() }
    let services: [Service]

    var anchor: Service { services[0] }
    var coordinate: CLLocationCoordinate2D {
        let lat = services.reduce(0.0) { $0 + $1.location.latitude } / Double(services.count)
        let lon = services.reduce(0.0) { $0 + $1.location.longitude } / Double(services.count)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    var minPrice: Double {
        services.map(\.startingPrice).min() ?? 0
    }
    var displayTitle: String {
        "\(services.count) خدمات"
    }
    func contains(_ serviceID: UUID) -> Bool {
        services.contains { $0.id == serviceID }
    }

    static func == (lhs: ServiceCluster, rhs: ServiceCluster) -> Bool { lhs.id == rhs.id }
}
