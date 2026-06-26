import AVFoundation
import AppKit
import SwiftUI

private let maxPreviewImageBytes: Int = 10 * 1024 * 1024
private let maxPreviewVideoBytes: Int = 30 * 1024 * 1024
private let previewRequestTimeout: TimeInterval = 20

struct SearchResultListView: View {
    let response: TraceMoeSearchResponse
    let settings: AppSettings
    let language: AppLanguage
    let favoriteIDs: Set<String>
    let animateEntrance: Bool
    let markResultsShown: () -> Void
    let toggleFavorite: (TraceMoeResult) -> Void

    @State private var visibleCount: Int = 5
    @State private var shouldScrollToNewResults: Bool = false

    private let pageSize: Int = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(Array(visibleResults.enumerated()), id: \.element.id) { index, result in
                            SearchResultRowView(
                                result: result,
                                settings: settings,
                                language: language,
                                isFavorite: favoriteIDs.contains(result.id),
                                toggleFavorite: toggleFavorite
                            )
                            .id(result.id)
                            .transition(rowTransition)
                            .animation(rowAnimation(index: index), value: visibleCount)
                        }
                    }
                    .padding(8)
                }
                .scrollIndicators(.hidden)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(nsColor: .separatorColor).opacity(0.55), lineWidth: 0.5)
                }
                .onChange(of: visibleCount) { _, _ in
                    guard shouldScrollToNewResults, let lastResult: TraceMoeResult = visibleResults.last else {
                        return
                    }

                    shouldScrollToNewResults = false
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 0.24)) {
                            proxy.scrollTo(lastResult.id, anchor: .bottom)
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.18), value: visibleCount)

            if visibleCount < response.result.count {
                HStack {
                    Spacer()
                    Button(t(.more, language: language)) {
                        shouldScrollToNewResults = true
                        withAnimation(.easeInOut(duration: 0.18)) {
                            visibleCount = min(visibleCount + pageSize, response.result.count)
                        }
                    }
                    .buttonStyle(TracePressButtonStyle())
                    Spacer()
                }
            }
        }
        .frame(maxHeight: response.result.isEmpty ? nil : 360)
        .transition(animateEntrance ? .opacity.combined(with: .move(edge: .bottom)) : .identity)
        .animation(.easeInOut(duration: 0.24), value: response.result.map(\.id))
        .onAppear {
            markResultsShown()
        }
        .onChange(of: response.result.count) { _, _ in
            visibleCount = min(pageSize, response.result.count)
        }
    }

    private var visibleResults: [TraceMoeResult] {
        Array(response.result.prefix(visibleCount))
    }

    private var rowTransition: AnyTransition {
        animateEntrance ? .opacity.combined(with: .scale(scale: 0.98, anchor: .top)) : .identity
    }

    private func rowAnimation(index: Int) -> Animation? {
        guard animateEntrance else {
            return nil
        }

        return .easeInOut(duration: 0.22).delay(Double(index) * 0.035)
    }
}

struct SearchResultRowView: View {
    let result: TraceMoeResult
    let settings: AppSettings
    let language: AppLanguage
    let isFavorite: Bool
    let toggleFavorite: (TraceMoeResult) -> Void

    @State private var isPreviewPlaying: Bool = false
    @State private var isMuted: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    if isPreviewPlaying {
                        InlineVideoPreviewView(
                            url: previewURL(result.video, size: settings.previewSize, muteVideo: isMuted),
                            isMuted: isMuted
                        )
                        .transition(.opacity)
                    } else {
                        CachedPreviewImageView(
                            url: previewURL(result.image, size: settings.previewSize, muteVideo: false)
                        )
                        .transition(.opacity)
                    }
                }
                .frame(width: 112, height: 63)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .id(previewURL(result.image, size: settings.previewSize, muteVideo: false))

                VStack(alignment: .leading, spacing: 4) {
                    Text(displayTitle(anilist: result.anilist))
                        .font(.headline)
                        .lineLimit(2)
                    Text("\(displayEpisode(result.episode, language: language)) · \(displayTimestamp(result.at))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    SimilarityBadge(value: result.similarity)
                }

                Spacer(minLength: 0)
            }
            .contentShape(RoundedRectangle(cornerRadius: 7))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.16)) {
                    isPreviewPlaying.toggle()
                }
            }
            .help(t(.openPreview, language: language))

            HStack(spacing: 8) {
                TooltipIconButton(
                    text: t(.mutePreview, language: language),
                    systemImage: isMuted ? "speaker.slash" : "speaker.wave.2",
                    fontSize: 15
                ) {
                    isMuted.toggle()
                }
                .frame(width: 30, height: 26)
                .liquidGlass(cornerRadius: 13, isActive: false)

                TooltipIconButton(
                    text: isFavorite ? t(.removeFavorite, language: language) : t(.favorite, language: language),
                    systemImage: isFavorite ? "star.fill" : "star",
                    fontSize: 15
                ) {
                    toggleFavorite(result)
                }
                .frame(width: 30, height: 26)
                .liquidGlass(cornerRadius: 13, isActive: false)

                TooltipIconButton(
                    text: t(.copyResult, language: language),
                    systemImage: "link.badge.plus",
                    fontSize: 15
                ) {
                    copyURLAndOpen(URL(string: "https://anilist.co/anime/\(anilistID(anilist: result.anilist))")!)
                }
                .frame(width: 30, height: 26)
                .liquidGlass(cornerRadius: 13, isActive: false)

                if let malID: Int = malID(anilist: result.anilist) {
                    TooltipIconButton(
                        text: t(.openMAL, language: language),
                        systemImage: "link",
                        fontSize: 15
                    ) {
                        copyURLAndOpen(URL(string: "https://myanimelist.net/anime/\(malID)")!)
                    }
                    .frame(width: 30, height: 26)
                    .liquidGlass(cornerRadius: 13, isActive: false)
                }

                TooltipIconButton(
                    text: t(.copyDetails, language: language),
                    systemImage: "doc.on.doc",
                    fontSize: 15
                ) {
                    copyText(resultClipboardText(result: result, language: language))
                }
                .frame(width: 30, height: 26)
                .liquidGlass(cornerRadius: 13, isActive: false)
            }
        }
        .padding(10)
        .liquidGlass(cornerRadius: 12, isActive: false)
        .sensoryFeedback(.impact, trigger: isFavorite)
    }
}

struct CachedPreviewImageView: View {
    let url: URL

    @State private var image: NSImage?
    @State private var isLoading: Bool = false
    @State private var didFail: Bool = false

    var body: some View {
        ZStack {
            if let image: NSImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
            } else if didFail {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        if let cachedImage: NSImage = await PreviewImageCache.shared.image(url: url) {
            image = cachedImage
            isLoading = false
            didFail = false
            return
        }

        isLoading = true
        didFail = false

        do {
            let data: Data = try await downloadPreviewImageData(url: url)
            guard let loadedImage: NSImage = NSImage(data: data) else {
                throw URLError(.cannotDecodeContentData)
            }

            await PreviewImageCache.shared.store(data: data, url: url)
            image = loadedImage
            isLoading = false
            didFail = false
        } catch {
            image = nil
            isLoading = false
            didFail = true
        }
    }
}

struct InlineVideoPreviewView: View {
    let url: URL
    let isMuted: Bool

    @State private var player: AVPlayer?
    @State private var observation: NSKeyValueObservation?
    @State private var downloadTask: Task<Void, Never>?
    @State private var temporaryFileURL: URL?
    @State private var isReady: Bool = false
    @State private var didFail: Bool = false

    init(url: URL, isMuted: Bool) {
        self.url = url
        self.isMuted = isMuted
    }

    var body: some View {
        ZStack {
            InlinePlayerLayerView(player: player)

            if !isReady && !didFail {
                ProgressView()
                    .controlSize(.small)
            }

            if didFail {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
            }
        }
        .background(Color.black.opacity(0.18))
        .onAppear {
            downloadTask = Task {
                do {
                    let localURL: URL = try await downloadPreviewVideo(remoteURL: url)
                    try Task.checkCancellation()
                    await MainActor.run {
                        temporaryFileURL = localURL
                        playPreview(localURL: localURL)
                    }
                } catch {
                    await MainActor.run {
                        isReady = false
                        didFail = true
                    }
                }
            }
        }
        .onDisappear {
            downloadTask?.cancel()
            downloadTask = nil
            observation?.invalidate()
            observation = nil
            player?.pause()
            player = nil
            removeTemporaryPreview()
            isReady = false
            didFail = false
        }
    }

    private func playPreview(localURL: URL) {
        let item: AVPlayerItem = AVPlayerItem(url: localURL)
        let nextPlayer: AVPlayer = AVPlayer(playerItem: item)
        nextPlayer.isMuted = isMuted
        player = nextPlayer
        observation = item.observe(\.status, options: [.initial, .new]) { observedItem, _ in
            Task { @MainActor in
                switch observedItem.status {
                case .readyToPlay:
                    isReady = true
                    didFail = false
                    nextPlayer.play()
                case .failed:
                    isReady = false
                    didFail = true
                case .unknown:
                    isReady = false
                    didFail = false
                @unknown default:
                    isReady = false
                    didFail = true
                }
            }
        }
    }

    private func removeTemporaryPreview() {
        guard let temporaryFileURL: URL else {
            return
        }

        try? FileManager.default.removeItem(at: temporaryFileURL)
        self.temporaryFileURL = nil
    }
}

func downloadPreviewImageData(url: URL) async throws -> Data {
    let request: URLRequest = try makePreviewRequest(url: url)
    let payload: (Data, URLResponse) = try await URLSession.shared.data(for: request)

    guard let response: HTTPURLResponse = payload.1 as? HTTPURLResponse,
        (200...299).contains(response.statusCode),
        payload.0.count <= maxPreviewImageBytes
    else {
        throw URLError(.cannotDecodeContentData)
    }

    return payload.0
}

func downloadPreviewVideo(remoteURL: URL) async throws -> URL {
    let request: URLRequest = try makePreviewRequest(url: remoteURL)
    let payload: (Data, URLResponse) = try await URLSession.shared.data(for: request)

    guard let response: HTTPURLResponse = payload.1 as? HTTPURLResponse,
        (200...299).contains(response.statusCode),
        payload.0.count <= maxPreviewVideoBytes,
        responseContentType(response: response, contains: "video/mp4")
    else {
        throw URLError(.cannotDecodeContentData)
    }

    let fileURL: URL = FileManager.default.temporaryDirectory
        .appendingPathComponent("TraceAnime-\(UUID().uuidString)")
        .appendingPathExtension("mp4")
    try payload.0.write(to: fileURL, options: .atomic)
    return fileURL
}

private func makePreviewRequest(url: URL) throws -> URLRequest {
    guard url.scheme?.lowercased() == "https" else {
        throw URLError(.unsupportedURL)
    }

    var request: URLRequest = URLRequest(
        url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: previewRequestTimeout)
    request.setValue("no-store", forHTTPHeaderField: "Cache-Control")
    return request
}

private func responseContentType(response: HTTPURLResponse, contains expectedValue: String) -> Bool {
    guard let contentType: String = response.value(forHTTPHeaderField: "Content-Type")?.lowercased() else {
        return false
    }

    return contentType.contains(expectedValue)
}

struct InlinePlayerLayerView: NSViewRepresentable {
    let player: AVPlayer?

    func makeNSView(context: Context) -> PlayerContainerView {
        PlayerContainerView()
    }

    func updateNSView(_ nsView: PlayerContainerView, context: Context) {
        nsView.playerLayer.player = player
    }
}

final class PlayerContainerView: NSView {
    let playerLayer: AVPlayerLayer = AVPlayerLayer()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer = CALayer()
        playerLayer.videoGravity = .resizeAspectFill
        layer?.addSublayer(playerLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layout() {
        super.layout()
        playerLayer.frame = bounds
    }
}

struct SimilarityBadge: View {
    let value: Double

    var body: some View {
        Text(displaySimilarity(value))
            .font(.caption.weight(.semibold))
            .foregroundStyle(value >= 0.9 ? .green : .orange)
    }
}

func openURL(_ url: URL) {
    guard url.scheme?.lowercased() == "https" else {
        return
    }

    NSWorkspace.shared.open(url)
    NSApplication.shared.windows.forEach { window in
        window.orderBack(nil)
    }
}

func copyURLAndOpen(_ url: URL) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(url.absoluteString, forType: .string)
    openURL(url)
}

func copyText(_ text: String) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(text, forType: .string)
}
