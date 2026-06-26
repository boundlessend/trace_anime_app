import AppKit
import QuartzCore
import SwiftUI

struct ExtraView: View {
    @Binding var settings: AppSettings

    @State private var didClearCache: Bool = false

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

            Divider()

            StickyCopyrightView(text: t(.copyright, language: language))
        }
        .animation(.easeInOut(duration: 0.2), value: isCheckingQuota)
        .animation(.easeInOut(duration: 0.2), value: user?.quotaUsed)
        .onAppear {
            checkQuota()
        }
    }
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
