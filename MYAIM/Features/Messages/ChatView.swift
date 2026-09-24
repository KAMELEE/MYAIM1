import SwiftUI
import AVFoundation

struct ChatView: View {
    @Environment(MessagesStore.self) private var store
    let conversation: Conversation

    @State private var draft = ""
    @FocusState private var focused: Bool

    // Voice recording
    @State private var recorder: AVAudioRecorder?
    @State private var isRecording = false
    @State private var recordStart: Date?
    @State private var player: AVAudioPlayer?
    @State private var playingId: UUID?

    private var live: Conversation { store.conversation(conversation.id) ?? conversation }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: MYSpacing.sm) {
                        ForEach(live.messages) { msg in
                            if msg.isVoice {
                                HStack {
                                    if msg.fromMe { Spacer(minLength: 40) }
                                    voiceBubble(msg)
                                    if !msg.fromMe { Spacer(minLength: 40) }
                                }
                                .id(msg.id)
                            } else {
                                bubble(msg).id(msg.id)
                            }
                        }
                        if !starterChips.isEmpty {
                            starterReplies
                                .id("starter")
                        }
                        if store.typingIn.contains(live.id) {
                            typingBubble
                        }
                    }
                    .padding(MYSpacing.screen)
                }
                .onChange(of: live.messages.count) { _, _ in
                    if let last = live.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                .onAppear {
                    store.markRead(live.id)
                    if let last = live.messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            inputBar
        }
        .myScreenBackground()
        .navigationTitle(live.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func bubble(_ msg: Message) -> some View {
        HStack {
            if msg.fromMe { Spacer(minLength: 40) }
            VStack(alignment: msg.fromMe ? .trailing : .leading, spacing: 3) {
                Text(msg.text)
                    .font(MYTypography.body)
                    .foregroundStyle(msg.fromMe ? .white : MYColor.textPrimary)
                    .padding(.horizontal, MYSpacing.md)
                    .padding(.vertical, MYSpacing.sm)
                    .background(msg.fromMe ? MYColor.primary : MYColor.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous)
                            .strokeBorder(msg.fromMe ? .clear : MYColor.border, lineWidth: 0.5)
                    )
                Text(MYFormat.time(msg.date))
                    .font(MYTypography.caption).foregroundStyle(MYColor.textTertiary)
            }
            if !msg.fromMe { Spacer(minLength: 40) }
        }
    }

    /// "The academy is typing…" animated dots bubble.
    private var typingBubble: some View {
        HStack {
            TypingDots()
            Spacer(minLength: 40)
        }
        .padding(.top, MYSpacing.xs)
    }

    /// Voice-note bubble with play/pause + duration.
    private func voiceBubble(_ msg: Message) -> some View {
        let isPlaying = playingId == msg.id
        return Button {
            togglePlay(msg)
        } label: {
            HStack(spacing: MYSpacing.sm) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(msg.fromMe ? .white : MYColor.primary)
                Text(MYFormat.duration(msg.audioDuration ?? 0))
                    .font(MYTypography.caption)
                    .foregroundStyle(msg.fromMe ? .white : MYColor.textSecondary)
                Image(systemName: "waveform")
                    .font(.system(size: 15))
                    .foregroundStyle(msg.fromMe ? .white.opacity(0.8) : MYColor.textTertiary)
            }
            .padding(.horizontal, MYSpacing.md)
            .padding(.vertical, MYSpacing.sm)
            .background(msg.fromMe ? MYColor.primary : MYColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous)
                    .strokeBorder(msg.fromMe ? .clear : MYColor.border, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("رسالة صوتية")
    }

    private func togglePlay(_ msg: Message) {
        guard let url = msg.audioURL else { return }
        if playingId == msg.id {
            player?.stop()
            playingId = nil
            return
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
        playingId = msg.id
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(msg.audioDuration ?? 1 + 2))
            playingId = nil
        }
    }

    // MARK: Recording
    private var micButton: some View {
        Button {
            isRecording ? stopRecording() : startRecording()
        } label: {
            Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(isRecording ? MYColor.error : MYColor.primary)
                .frame(width: 44, height: 44)
                .background(isRecording ? MYColor.error.opacity(0.12) : MYColor.primaryTint,
                            in: Circle())
                .scaleEffect(isRecording ? 1.08 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRecording)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(isRecording ? "إيقاف التسجيل" : "تسجيل رسالة صوتية")
    }

    private func startRecording() {
        let session = AVAudioSession.sharedInstance()
        guard (try? session.setCategory(.playAndRecord, mode: .default)) != nil,
              (try? session.setActive(true)) != nil else { return }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("voice-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        recorder = try? AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
        recordStart = Date()
        Haptics.medium()
        withAnimation { isRecording = true }
    }

    private func stopRecording() {
        guard let recorder, let start = recordStart else { return }
        recorder.stop()
        let duration = Date().timeIntervalSince(start)
        self.recorder = nil
        recordStart = nil
        withAnimation { isRecording = false }
        guard duration > 0.6 else { return } // ignore accidental taps
        Haptics.light()
        store.sendVoice(url: recorder.url, duration: duration, to: live.id)
    }

    /// Quick starter questions, shown once at the start of a fresh thread to
    /// make contacting an academy frictionless.
    private var starterChips: [String] {
        live.messages.count == 1 && live.messages.first?.fromMe == false
            ? ["ما هي مواعيد الدورات؟", "هل توجد خصومات؟", "كيف أقدر أحجز؟"]
            : []
    }

    @ViewBuilder
    private var starterReplies: some View {
        if !starterChips.isEmpty {
            VStack(alignment: .leading, spacing: MYSpacing.sm) {
                ForEach(starterChips, id: \.self) { chip in
                    Button {
                        draft = chip
                        focused = true
                        Haptics.selection()
                    } label: {
                        Text(chip)
                            .font(MYTypography.secondary)
                            .foregroundStyle(MYColor.primary)
                            .padding(.horizontal, MYSpacing.md)
                            .padding(.vertical, MYSpacing.sm)
                            .background(MYColor.primaryTint)
                            .clipShape(Capsule())
                            .overlay(Capsule().strokeBorder(MYColor.border, lineWidth: 0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, MYSpacing.xs)
        }
    }

    private var inputBar: some View {
        HStack(spacing: MYSpacing.sm) {
            TextField("اكتب رسالة…", text: $draft, axis: .vertical)
                .font(MYTypography.body)
                .lineLimit(1...4)
                .focused($focused)
                .padding(.horizontal, MYSpacing.md)
                .frame(minHeight: 44)
                .background(MYColor.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))

            micButton

            Button {
                store.send(draft, to: live.id)
                draft = ""
                Haptics.light()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(draft.trimmingCharacters(in: .whitespaces).isEmpty ? MYColor.textTertiary : MYColor.primary)
                    .clipShape(Circle())
            }
            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(MYSpacing.md)
        .background(.regularMaterial)
        .overlay(alignment: .top) { Divider() }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if isRecording {
                HStack(spacing: MYSpacing.xs) {
                    Circle().fill(MYColor.error).frame(width: 8, height: 8)
                        .opacity(0.5)
                        .animation(.easeInOut(duration: 0.6).repeatForever(), value: isRecording)
                    Text("جارٍ التسجيل… تضغط مرة أخرى للإرسال")
                        .font(MYTypography.caption)
                        .foregroundStyle(MYColor.error)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, MYSpacing.xs)
                .background(MYColor.surface)
                .overlay(alignment: .top) { Divider() }
            }
        }
    }
}

/// Three bouncing dots — the "typing…" indicator.
private struct TypingDots: View {
    @State private var phase = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(MYColor.textTertiary)
                    .frame(width: 8, height: 8)
                    .offset(y: phase ? -4 : 2)
                    .animation(.easeInOut(duration: 0.45).repeatForever().delay(Double(i) * 0.15),
                               value: phase)
            }
        }
        .padding(.horizontal, MYSpacing.md)
        .padding(.vertical, MYSpacing.md + 2)
        .background(MYColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: MYRadius.lg, style: .continuous))
        .onAppear { phase = true }
    }
}

#Preview {
    NavigationStack { ChatView(conversation: MessagesStore().conversations[0]) }
        .environment(MessagesStore())
        .environment(\.layoutDirection, .rightToLeft)
        .environment(\.locale, Locale(identifier: "ar"))
}
