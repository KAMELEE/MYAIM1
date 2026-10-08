import AVFoundation
import Observation

/// Plays chat voice notes — local recordings or synced Firebase Storage URLs
/// (remote audio is downloaded once and cached in memory).
@MainActor
@Observable
final class VoiceNotePlayer {
    /// The message currently playing (drives the play/pause icon).
    private(set) var playingId: UUID?
    /// The message whose remote audio is being fetched.
    private(set) var loadingId: UUID?

    private var player: AVAudioPlayer?
    private var cache: [URL: Data] = [:]

    func toggle(_ msg: Message) {
        guard let url = msg.audioURL else { return }
        if playingId == msg.id {
            stop()
            return
        }
        stop()
        Task { await play(url, id: msg.id, duration: msg.audioDuration) }
    }

    func stop() {
        player?.stop()
        player = nil
        playingId = nil
    }

    private func play(_ url: URL, id: UUID, duration: Double?) async {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)

        if url.isFileURL {
            player = try? AVAudioPlayer(contentsOf: url)
        } else {
            loadingId = id
            let data: Data?
            if let cached = cache[url] {
                data = cached
            } else {
                data = try? await URLSession.shared.data(from: url).0
                if let data { cache[url] = data }
            }
            loadingId = nil
            guard let data else { return }
            player = try? AVAudioPlayer(data: data)
        }
        guard let player, player.play() else { return }
        playingId = id

        let length = duration ?? player.duration
        try? await Task.sleep(for: .seconds(max(length, 0.5)))
        // Only clear if a different note didn't start meanwhile.
        if playingId == id { playingId = nil }
    }
}
