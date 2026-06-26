import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct MenuBarRootView: View {
    let onSizeChange: (CGSize) -> Void

    @State private var settings: AppSettings = defaultAppSettings()
    @State private var urlText: String = ""
    @State private var searchResponse: TraceMoeSearchResponse?
    @State private var user: TraceMoeUser?
    @State private var errorText: String?
    @State private var quotaErrorText: String?
    @State private var isSearching: Bool = false
    @State private var isCheckingQuota: Bool = false
    @State private var didLoadSettings: Bool = false
    @State private var currentSearchImage: SearchImageSnapshot?
    @State private var quotaNeedsRefresh: Bool = true
    @State private var animatedResultSetIDs: Set<String> = []
    @State private var selectedTab: RootTab = .search
    @State private var previousMainTab: RootTab = .search
    @State private var history: [SearchHistoryEntry] = []
    @State private var favorites: [FavoriteResult] = []

    private let client: TraceMoeClient
    private let queue: SearchQueue
    private let clipboardProvider: ClipboardImageProvider
    private let fileProvider: FileImageProvider
    private let settingsStorage: AppSettingsStorage
    private let libraryStorage: LibraryStorage

    init(onSizeChange: @escaping (CGSize) -> Void) {
        self.onSizeChange = onSizeChange
        let decoder: JSONDecoder = JSONDecoder()
        let client: TraceMoeClient = TraceMoeClient(
            baseURL: URL(string: "https://api.trace.moe/")!,
            session: .shared,
            decoder: decoder
        )
        self.client = client
        self.queue = SearchQueue(client: client)
        self.clipboardProvider = ClipboardImageProvider()
        self.fileProvider = FileImageProvider()
        self.settingsStorage = AppSettingsStorage(userDefaults: .standard)
        self.libraryStorage = LibraryStorage(userDefaults: .standard, encoder: JSONEncoder(), decoder: JSONDecoder())
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                TooltipIconButton(
                    text: t(.history, language: settings.language),
                    systemImage: selectedTab == .history ? "arrow.left.circle" : "clock.arrow.circlepath",
                    fontSize: 17
                ) {
                    toggleLibraryTab(.history)
                }
                .frame(width: 26, height: 26)
                .liquidGlass(cornerRadius: 20, isActive: selectedTab == .history)
                .clipShape(Circle())

                TooltipIconButton(
                    text: t(.favorites, language: settings.language),
                    systemImage: selectedTab == .favorites ? "arrow.left.circle" : "star.circle",
                    fontSize: 17
                ) {
                    toggleLibraryTab(.favorites)
                }
                .frame(width: 26, height: 26)
                .liquidGlass(cornerRadius: 20, isActive: selectedTab == .favorites)
                .clipShape(Circle())

                StaticGlassTabControl(
                    selection: mainTabSelection,
                    segments: mainTabs.map { tab in
                        GlassSegment(value: tab, title: tab.title(language: settings.language), systemImage: nil)
                    },
                    segmentWidth: 74
                )

                TooltipIconButton(
                    text: t(.extraTab, language: settings.language),
                    systemImage: selectedTab == .extra ? "arrow.left.circle" : "ellipsis",
                    fontSize: 17
                ) {
                    toggleLibraryTab(.extra)
                }
                .frame(width: 26, height: 26)
                .liquidGlass(cornerRadius: 20, isActive: selectedTab == .extra)
                .clipShape(Circle())

                TooltipIconButton(
                    text: t(.quit, language: settings.language),
                    systemImage: "power.circle.fill",
                    fontSize: 17
                ) {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
                .frame(width: 26, height: 26)
                .liquidGlass(cornerRadius: 20, isActive: false)
                .clipShape(Circle())
            }
            .frame(height: 42)
            .transaction { transaction in
                transaction.animation = nil
            }

            ZStack {
                switch selectedTab {
                case .search:
                    searchContent
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                case .settings:
                    SettingsView(
                        settings: $settings,
                        language: settings.language
                    )
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                case .extra:
                    ExtraView(
                        settings: $settings,
                        user: user,
                        isCheckingQuota: isCheckingQuota,
                        quotaErrorText: quotaErrorText,
                        language: settings.language,
                        checkQuota: checkQuota,
                        clearCache: clearPreviewImageCache
                    )
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                case .history:
                    HistoryView(
                        history: history,
                        language: settings.language,
                        openHistory: openHistory(_:),
                        deleteHistory: deleteHistory(_:),
                        clearHistory: clearHistory
                    )
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                case .favorites:
                    FavoritesView(
                        favorites: favorites,
                        settings: settings,
                        language: settings.language,
                        toggleFavorite: toggleFavorite(_:)
                    )
                    .transition(.opacity.combined(with: .move(edge: .leading)))
                }
            }
            .animation(.easeInOut(duration: 0.18), value: selectedTab)

        }
        .padding(14)
        .frame(width: 430)
        .fixedSize(horizontal: false, vertical: true)
        .environment(\.layoutDirection, .leftToRight)
        .environment(\.locale, locale(language: settings.language))
        .background(SizeReaderView())
        .onPreferenceChange(ViewSizePreferenceKey.self) { size in
            onSizeChange(size)
        }
        .onAppear {
            if !didLoadSettings {
                loadSettings()
                loadLibrary()
                didLoadSettings = true
            }
        }
        .onChange(of: settings) { previousSettings, nextSettings in
            saveSettings(nextSettings)

            if previousSettings.apiKey != nextSettings.apiKey {
                quotaNeedsRefresh = true
                user = nil
            }
        }
        .onChange(of: history) { _, nextHistory in
            saveHistory(nextHistory)
        }
        .onChange(of: favorites) { _, nextFavorites in
            saveFavorites(nextFavorites)
        }
        .onChange(of: selectedTab) { _, nextTab in
            if nextTab == .extra {
                checkQuota()
            }
        }
    }

    private var mainTabSelection: Binding<RootTab> {
        Binding(
            get: {
                previousMainTab
            },
            set: { nextTab in
                previousMainTab = nextTab
                selectedTab = nextTab
            }
        )
    }

    private var mainTabs: [RootTab] {
        [.search, .settings]
    }

    private func toggleLibraryTab(_ tab: RootTab) {
        if selectedTab == tab {
            selectedTab = previousMainTab
            return
        }

        if selectedTab == .search || selectedTab == .settings || selectedTab == .extra {
            previousMainTab = selectedTab
        }

        selectedTab = tab
    }

    private var searchContent: some View {
        VStack(spacing: 12) {
            SearchInputView(
                urlText: $urlText,
                isSearching: isSearching,
                language: settings.language,
                searchURL: searchURL,
                searchClipboard: searchClipboard,
                chooseFile: chooseFile,
                handleDrop: handleDrop(providers:)
            )

            if let errorText: String {
                Text(errorText)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if isSearching {
                LoadingView(title: t(.searching, language: settings.language))
                    .transition(.opacity)
            }

            if let response: TraceMoeSearchResponse = searchResponse {
                SearchResultListView(
                    response: response,
                    settings: settings,
                    language: settings.language,
                    favoriteIDs: Set(favorites.map(\.id)),
                    animateEntrance: !animatedResultSetIDs.contains(resultSetID(response: response)),
                    markResultsShown: {
                        animatedResultSetIDs.insert(resultSetID(response: response))
                    },
                    toggleFavorite: toggleFavorite(_:)
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSearching)
        .animation(.easeInOut(duration: 0.2), value: errorText)
        .animation(.easeInOut(duration: 0.22), value: searchResponse?.result.count)
    }

    private func loadSettings() {
        do {
            settings = try settingsStorage.load()
        } catch {
            errorText = localizedErrorText(error, language: settings.language)
        }
    }

    private func saveSettings(_ nextSettings: AppSettings) {
        do {
            try settingsStorage.save(settings: nextSettings)
            errorText = nil
        } catch {
            errorText = localizedErrorText(error, language: settings.language)
        }
    }

    private func loadLibrary() {
        do {
            history = try libraryStorage.loadHistory()
            favorites = try libraryStorage.loadFavorites()
        } catch {
            errorText = localizedErrorText(error, language: settings.language)
        }
    }

    private func saveHistory(_ nextHistory: [SearchHistoryEntry]) {
        do {
            try libraryStorage.saveHistory(nextHistory)
        } catch {
            errorText = localizedErrorText(error, language: settings.language)
        }
    }

    private func saveFavorites(_ nextFavorites: [FavoriteResult]) {
        do {
            try libraryStorage.saveFavorites(nextFavorites)
        } catch {
            errorText = localizedErrorText(error, language: settings.language)
        }
    }

    private func addHistory(title: String, response: TraceMoeSearchResponse, sourceImage: SearchImageSnapshot?) {
        let nextEntry: SearchHistoryEntry = makeHistoryEntry(title: title, response: response, sourceImage: sourceImage)
        history = Array(([nextEntry] + history).prefix(20))
    }

    private func openHistory(_ entry: SearchHistoryEntry) {
        searchResponse = entry.response
        currentSearchImage = entry.sourceImage
        errorText = nil
        withAnimation(.easeInOut(duration: 0.18)) {
            selectedTab = .search
        }
    }

    private func deleteHistory(_ entry: SearchHistoryEntry) {
        history = history.filter { $0.id != entry.id }
    }

    private func clearHistory() {
        history = []
    }

    private func toggleFavorite(_ result: TraceMoeResult) {
        if favorites.contains(where: { $0.id == result.id }) {
            favorites = favorites.filter { $0.id != result.id }
            return
        }

        favorites = [makeFavoriteResult(result: result, sourceImage: currentSearchImage)] + favorites
    }

    private func checkQuota() {
        if isCheckingQuota {
            return
        }

        if !quotaNeedsRefresh, user != nil {
            return
        }

        quotaErrorText = nil

        Task {
            isCheckingQuota = true
            defer {
                isCheckingQuota = false
            }

            do {
                user = try await client.me(apiKey: settings.apiKey.trimmingCharacters(in: .whitespacesAndNewlines))
                quotaNeedsRefresh = false
                quotaErrorText = nil
                errorText = nil
            } catch {
                quotaErrorText = localizedErrorText(error, language: settings.language)
            }
        }
    }

    private func searchURL() {
        Task {
            do {
                let input: SearchInput = try makeURLInput(urlText: urlText)
                try await runSearch(input: input, title: urlText)
            } catch {
                errorText = localizedErrorText(error, language: settings.language)
            }
        }
    }

    private func searchClipboard() {
        Task {
            do {
                let payload: ImagePayload = try clipboardProvider.imagePayload()
                try await runSearch(input: .imageData(payload), title: t(.clipboard, language: settings.language))
            } catch {
                errorText = localizedErrorText(error, language: settings.language)
            }
        }
    }

    private func chooseFile() {
        Task {
            do {
                guard let fileURL: URL = try fileProvider.pickImageFile() else {
                    return
                }

                let payload: ImagePayload = try fileProvider.imagePayload(fileURL: fileURL)
                try await runSearch(input: .imageData(payload), title: fileURL.lastPathComponent)
            } catch {
                errorText = localizedErrorText(error, language: settings.language)
            }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider: NSItemProvider = providers.first else {
            errorText = localizedErrorText(AppError.unsupportedDrop, language: settings.language)
            return false
        }

        if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                Task { @MainActor in
                    await handleDroppedFileItem(item: item, error: error)
                }
            }
            return true
        }

        if provider.canLoadObject(ofClass: NSImage.self) {
            provider.loadObject(ofClass: NSImage.self) { object, error in
                Task { @MainActor in
                    await handleDroppedImageObject(object: object, error: error)
                }
            }
            return true
        }

        errorText = localizedErrorText(AppError.unsupportedDrop, language: settings.language)
        return false
    }

    private func handleDroppedFileItem(item: NSSecureCoding?, error: Error?) async {
        if let error: Error {
            errorText = localizedErrorText(error, language: settings.language)
            return
        }

        do {
            let fileURL: URL = try decodeDroppedFileURL(item: item)
            let payload: ImagePayload = try fileProvider.imagePayload(fileURL: fileURL)
            try await runSearch(input: .imageData(payload), title: fileURL.lastPathComponent)
        } catch {
            errorText = localizedErrorText(error, language: settings.language)
        }
    }

    private func handleDroppedImageObject(object: NSItemProviderReading?, error: Error?) async {
        if let error: Error {
            errorText = localizedErrorText(error, language: settings.language)
            return
        }

        guard let image: NSImage = object as? NSImage,
            let tiffData: Data = image.tiffRepresentation,
            let bitmap: NSBitmapImageRep = NSBitmapImageRep(data: tiffData),
            let data: Data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.92])
        else {
            errorText = localizedErrorText(AppError.unsupportedDrop, language: settings.language)
            return
        }

        do {
            let payload: ImagePayload = ImagePayload(data: data, contentType: "image/jpeg", filename: "drop.jpg")
            try await runSearch(input: .imageData(payload), title: t(.dropImage, language: settings.language))
        } catch {
            errorText = localizedErrorText(error, language: settings.language)
        }
    }

    private func runSearch(input: SearchInput, title: String) async throws {
        let options: SearchOptions = try makeSearchOptions(settings: settings)
        let sourceImage: SearchImageSnapshot? = makeSearchImageSnapshot(input: input)
        await PreviewImageCache.shared.clear()
        isSearching = true
        searchResponse = nil
        currentSearchImage = nil
        errorText = nil
        defer {
            isSearching = false
        }

        let response: TraceMoeSearchResponse = try await queue.search(input: input, options: options)
        quotaNeedsRefresh = true
        withAnimation(.easeInOut(duration: 0.22)) {
            searchResponse = response
            currentSearchImage = sourceImage
        }
        addHistory(title: title, response: response, sourceImage: sourceImage)
    }
}

func resultSetID(response: TraceMoeSearchResponse) -> String {
    response.result.map(\.id).joined(separator: "|")
}

enum RootTab: String, CaseIterable, Identifiable {
    case search
    case settings
    case extra
    case history
    case favorites

    var id: String {
        rawValue
    }

    func title(language: AppLanguage) -> String {
        switch self {
        case .search:
            return t(.searchTab, language: language)
        case .settings:
            return t(.settingsTab, language: language)
        case .extra:
            return t(.extraTab, language: language)
        case .history:
            return t(.history, language: language)
        case .favorites:
            return t(.favorites, language: language)
        }
    }

}
