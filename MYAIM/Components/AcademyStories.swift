import SwiftUI

// MARK: - Model

/// One academy "story": a short sequence of full-screen pages shown in a
/// Stories viewer, Instagram-style.
struct AcademyStory: Identifiable {
    let id = UUID()
    let providerName: String
    let avatarAsset: String?
    let accent: Color
    /// Pages are mutable so the academy can append later from the dashboard.
    var pages: [StoryPage]

    struct StoryPage: Identifiable {
        let id = UUID()
        let imageAsset: String?
        let caption: String
    }
}

// MARK: - Stories row (Home)

/// Horizontal row of tappable academy story bubbles with a gradient ring —
/// sits at the very top of the Home feed.
struct AcademyStoriesRow: View {
    let stories: [AcademyStory]
    @Binding var seenStoryIds: Set<UUID>
    var onTap: (AcademyStory) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MYSpacing.md) {
                ForEach(stories) { story in
                    bubble(story)
                }
            }
            .padding(.horizontal, MYSpacing.screen)
        }
        .padding(.horizontal, -MYSpacing.screen)
    }

    private func bubble(_ story: AcademyStory) -> some View {
        Button {
            Haptics.selection()
            onTap(story)
        } label: {
            VStack(spacing: MYSpacing.xs) {
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(colors: [story.accent, story.accent.opacity(0.5), MYColor.primary],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2.5
                        )
                        .frame(width: 68, height: 68)

                    MYRemoteImage(assetName: story.avatarAsset, accent: story.accent)
                        .frame(width: 58, height: 58)
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(MYColor.background, lineWidth: 2))
                }
                .overlay(alignment: .top) {
                    if !seenStoryIds.contains(story.id) {
                        Circle()
                            .fill(MYColor.error)
                            .frame(width: 9, height: 9)
                            .offset(x: 2, y: -2)
                    }
                }

                Text(story.providerName)
                    .font(MYTypography.caption)
                    .foregroundStyle(MYColor.textPrimary)
                    .lineLimit(1)
            }
            .frame(width: 78)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Story viewer (full screen)

/// Full-screen stories viewer: progress bars, auto-advancing pages,
/// tap-to-move (RTL-aware) and swipe-down to dismiss.
struct StoryViewer: View {
    let stories: [AcademyStory]
    let startIndex: Int
    @Binding var seenStoryIds: Set<UUID>
    let onClose: () -> Void

    @State private var index: Int = 0
    @State private var page: Int = 0
    @State private var progress: Double = 0
    @State private var dragOffset: CGFloat = 0

    private let tick = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let duration: Double = 5.0

    private var story: AcademyStory { stories[index] }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            pageImage
                .overlay(alignment: .bottom) { captionBar }
                .overlay(alignment: .top) { topControls }
                .overlay { tapZones }
                .offset(y: dragOffset)
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { v in
                    if v.translation.height > 0 { dragOffset = v.translation.height }
                }
                .onEnded { v in
                    if v.translation.height > 130 {
                        close()
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { dragOffset = 0 }
                    }
                }
        )
        .onAppear {
            index = startIndex
            markSeen()
            resetProgress()
        }
        .onChange(of: index) { _, _ in markSeen() }
        .onReceive(tick) { _ in advanceProgress() }
    }

    // MARK: Pieces
    private var pageImage: some View {
        Group {
            if let asset = story.pages[page].imageAsset {
                Image(asset)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(colors: [story.accent.opacity(0.7), .black],
                              startPoint: .top, endPoint: .bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .animation(.easeInOut(duration: 0.25), value: page)
    }

    private var topControls: some View {
        VStack(alignment: .leading, spacing: MYSpacing.md) {
            // Progress bars
            HStack(spacing: MYSpacing.xxs) {
                ForEach(story.pages.indices, id: \.self) { i in
                    Capsule()
                        .fill(Color.white.opacity(i < page ? 1 : (i == page ? 1 : 0.35)))
                        .frame(height: 3)
                        .overlay(alignment: .leading) {
                            if i == page {
                                GeometryReader { geo in
                                    Capsule().fill(.white)
                                        .frame(width: geo.size.width * progress, height: 3)
                                }
                            }
                        }
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: MYSpacing.sm) {
                Button(action: close) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(.white.opacity(0.2), in: Circle())
                }
                Spacer()
                Text(story.providerName)
                    .font(MYTypography.cardTitle)
                    .foregroundStyle(.white)
            }
        }
        .padding(MYSpacing.lg)
        .background(
            LinearGradient(colors: [.black.opacity(0.55), .clear],
                           startPoint: .top, endPoint: .bottom)
        )
    }

    /// RTL-aware tap zones: right side goes back, left side advances.
    private var tapZones: some View {
        HStack(spacing: 0) {
            Button { previous() } label: { Color.clear }
            Button { next() } label: { Color.clear }
        }
        .buttonStyle(.plain)
    }

    private var captionBar: some View {
        Text(story.pages[page].caption)
            .font(MYTypography.cardTitle)
            .foregroundStyle(.white)
            .padding(.horizontal, MYSpacing.lg)
            .padding(.vertical, MYSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(colors: [.clear, .black.opacity(0.6)],
                               startPoint: .top, endPoint: .bottom)
            )
    }

    // MARK: Flow
    private func advanceProgress() {
        progress += 0.05 / duration
        if progress >= 1 { next() }
    }

    private func next() {
        if page < story.pages.count - 1 {
            page += 1
        } else if index < stories.count - 1 {
            index += 1
            markSeen()
            page = 0
        } else {
            close()
            return
        }
        resetProgress()
    }

    private func previous() {
        if page > 0 {
            page -= 1
        } else if index > 0 {
            index -= 1
            markSeen()
            page = 0
        }
        resetProgress()
    }

    private func resetProgress() { progress = 0 }

    private func markSeen() {
        seenStoryIds.insert(story.id)
    }

    private func close() {
        Haptics.light()
        onClose()
    }
}
