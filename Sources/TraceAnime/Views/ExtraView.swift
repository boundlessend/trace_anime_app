import AppKit
import QuartzCore
import SwiftUI

struct ExtraView: View {
    @Binding var settings: AppSettings

    @State private var didClearCache: Bool = false
    @State private var isCheckingUpdate: Bool = false
    @State private var updateResult: UpdateCheckResult?
    @State private var showUpdateAlert: Bool = false

    private let updateCheckService: UpdateCheckService = UpdateCheckService(
        session: .shared,
        releasesURL: URL(string: "https://api.github.com/repos/boundlessend/trace_anime_app/releases/latest")!,
        decoder: JSONDecoder()
    )

    let user: TraceMoeUser?
    let isCheckingQuota: Bool
    let quotaErrorText: String?
    let language: AppLanguage
    let checkQuota: () -> Void
    let clearCache: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SecureField(t(.apiKey, language: language), text: $settings.apiKey)
                .textFieldStyle(.roundedBorder)

            TextField(t(.anilistIDFilter, language: language), text: $settings.anilistIDText)
                .textFieldStyle(.roundedBorder)

            if isCheckingQuota {
                LoadingView(title: t(.checkingQuota, language: language))
                    .transition(.opacity)
            }

            if let user: TraceMoeUser {
                VStack(alignment: .center, spacing: 4) {
                    Text("ID: \(user.id)")
                    Text("\(t(.quota, language: language)): \(user.quotaUsed)/\(user.quota)")
                    Text("\(t(.concurrency, language: language)): \(user.concurrency)")
                    Text("\(t(.priority, language: language)): \(user.priority)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            if !isCheckingQuota, user == nil, quotaErrorText == nil {
                Text(t(.checkingQuota, language: language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            if let quotaErrorText: String {
                Text(quotaErrorText)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Button {
                clearCache()
                didClearCache = true
                Task {
                    try? await Task.sleep(nanoseconds: 1_600_000_000)
                    await MainActor.run {
                        didClearCache = false
                    }
                }
            } label: {
                Label(t(.clearCache, language: language), systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .symbolEffect(.bounce, value: didClearCache)
            }
            .buttonStyle(TracePressButtonStyle())

            if didClearCache {
                Text(t(.cacheCleared, language: language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.opacity)
            }

            VStack(spacing: 6) {
                Text("\(t(.version, language: language)) \(currentAppVersion())")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    checkForUpdate()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .rotationEffect(.degrees(isCheckingUpdate ? 360 : 0))
                            .animation(
                                isCheckingUpdate
                                    ? .linear(duration: 0.9).repeatForever(autoreverses: false) : .default,
                                value: isCheckingUpdate
                            )
                        Text(t(.checkUpdates, language: language))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(TracePressButtonStyle())
                .disabled(isCheckingUpdate)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            Divider()

            StickyCopyrightView(text: t(.copyright, language: language))
        }
        .animation(.easeInOut(duration: 0.2), value: isCheckingQuota)
        .animation(.easeInOut(duration: 0.2), value: user?.quotaUsed)
        .animation(.easeInOut(duration: 0.2), value: isCheckingUpdate)
        .sensoryFeedback(trigger: updateResult) { _, newValue in
            guard let newValue: UpdateCheckResult else {
                return nil
            }

            switch newValue {
            case .available, .upToDate:
                return .success
            case .failed:
                return .error
            }
        }
        .onAppear {
            checkQuota()
        }
        .alert(t(.checkUpdates, language: language), isPresented: $showUpdateAlert, presenting: updateResult) {
            result in
            updateAlertButtons(result)
        } message: { result in
            Text(updateAlertMessage(result))
        }
    }

    @ViewBuilder
    private func updateAlertButtons(_ result: UpdateCheckResult) -> some View {
        switch result {
        case .available(let release):
            Button(t(.download, language: language)) {
                openURL(release.url)
            }
            Button(t(.cancel, language: language), role: .cancel) {}
        case .upToDate, .failed:
            Button("OK", role: .cancel) {}
        }
    }

    private func updateAlertMessage(_ result: UpdateCheckResult) -> String {
        switch result {
        case .available(let release):
            return "\(t(.updateAvailable, language: language)): \(release.version)"
        case .upToDate:
            return "\(t(.upToDate, language: language)) (\(currentAppVersion()))"
        case .failed:
            return t(.updateFailed, language: language)
        }
    }

    private func checkForUpdate() {
        isCheckingUpdate = true
        Task { @MainActor in
            let result: UpdateCheckResult

            do {
                if let release: AppRelease = try await updateCheckService.availableUpdate(
                    currentVersion: currentAppVersion())
                {
                    result = .available(release)
                } else {
                    result = .upToDate
                }
            } catch {
                result = .failed
            }

            isCheckingUpdate = false
            updateResult = result
            showUpdateAlert = true
        }
    }
}

enum UpdateCheckResult: Equatable {
    case upToDate
    case available(AppRelease)
    case failed
}

struct StickyCopyrightView: View {
    let text: String

    var body: some View {
        StickyCopyrightButton(text: text)
            .frame(width: 132, height: 28)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

/// мостит копирайт в нативный слой, чтобы его можно было тянуть за пределы окна
struct StickyCopyrightButton: NSViewRepresentable {
    let text: String

    func makeNSView(context: Context) -> StickyCopyrightNSButton {
        let button: StickyCopyrightNSButton = StickyCopyrightNSButton()
        button.title = text
        return button
    }

    func updateNSView(_ nsView: StickyCopyrightNSButton, context: Context) {
        nsView.title = text
    }
}

final class StickyCopyrightNSButton: NSButton {
    private var floatingPanel: NSPanel?
    private var floatingView: NSHostingView<StickyFloatingCopyrightView>?
    private var isFloating: Bool = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        isBordered = false
        bezelStyle = .regularSquare
        focusRingType = .none
        font = .systemFont(ofSize: NSFont.smallSystemFontSize)
        contentTintColor = .secondaryLabelColor
        wantsLayer = true
        layer?.cornerRadius = 14.0
        layer?.masksToBounds = false
        layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.16).cgColor
        layer?.borderColor = NSColor.white.withAlphaComponent(0.28).cgColor
        layer?.borderWidth = 0.7
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        dirtyRect.fill()
        super.draw(dirtyRect)
    }

    override func mouseDown(with event: NSEvent) {
        isFloating = true
        alphaValue = 0.0
        showFloatingPanel(at: NSEvent.mouseLocation)

        while true {
            guard let nextEvent: NSEvent = window?.nextEvent(matching: [.leftMouseDragged, .leftMouseUp]) else {
                break
            }

            switch nextEvent.type {
            case .leftMouseDragged:
                moveFloatingPanel(to: NSEvent.mouseLocation)
            case .leftMouseUp:
                finishFloating()
                return
            default:
                break
            }
        }

        finishFloating()
    }

    private func showFloatingPanel(at point: NSPoint) {
        let hostingView: NSHostingView<StickyFloatingCopyrightView> = NSHostingView(
            rootView: StickyFloatingCopyrightView(text: title))
        hostingView.setFrameSize(hostingView.fittingSize)

        let panel: NSPanel = NSPanel(
            contentRect: NSRect(origin: .zero, size: hostingView.fittingSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = hostingView
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.level = .statusBar
        panel.ignoresMouseEvents = true
        floatingPanel = panel
        floatingView = hostingView
        moveFloatingPanel(to: point)
        panel.orderFront(nil)
    }

    private func moveFloatingPanel(to point: NSPoint) {
        guard let panel: NSPanel = floatingPanel else {
            return
        }

        let size: NSSize = panel.frame.size
        panel.setFrameOrigin(NSPoint(x: point.x - size.width / 2.0, y: point.y - size.height / 2.0))
    }

    private func finishFloating() {
        guard isFloating else {
            return
        }

        isFloating = false
        floatingPanel?.orderOut(nil)
        floatingPanel = nil
        floatingView = nil

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.28
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animator().alphaValue = 1.0
        }
    }
}

struct StickyFloatingCopyrightView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.white.opacity(0.28), lineWidth: 0.7)
            }
            .shadow(color: .black.opacity(0.18), radius: 10, y: 3)
            .fixedSize()
    }
}
