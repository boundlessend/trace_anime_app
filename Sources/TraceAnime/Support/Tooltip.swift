import AppKit
import QuartzCore
import SwiftUI

struct TooltipIconButton: NSViewRepresentable {
    let text: String
    let systemImage: String
    let fontSize: CGFloat
    let action: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    func makeNSView(context: Context) -> TooltipButton {
        let button: TooltipButton = TooltipButton()
        button.isBordered = false
        button.imagePosition = .imageOnly
        button.target = context.coordinator
        button.action = #selector(Coordinator.performAction)
        button.setButtonType(.momentaryChange)
        button.contentTintColor = .labelColor
        button.bezelStyle = .regularSquare
        button.focusRingType = .none
        button.tooltipText = text
        button.image = makeImage()
        button.wantsLayer = true
        return button
    }

    func updateNSView(_ nsView: TooltipButton, context: Context) {
        nsView.tooltipText = text
        nsView.image = makeImage()
        context.coordinator.action = action
    }

    private func makeImage() -> NSImage? {
        let configuration: NSImage.SymbolConfiguration = NSImage.SymbolConfiguration(pointSize: fontSize, weight: .regular)
        return NSImage(systemSymbolName: systemImage, accessibilityDescription: text)?
            .withSymbolConfiguration(configuration)
    }

    final class Coordinator: NSObject {
        var action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func performAction() {
            action()
        }
    }
}

final class TooltipButton: NSButton {
    var tooltipText: String = ""

    private var trackingAreaReference: NSTrackingArea?
    private var tooltipTask: Task<Void, Never>?
    private var tooltipPanel: NSPanel?

    override func updateTrackingAreas() {
        if let trackingAreaReference: NSTrackingArea {
            removeTrackingArea(trackingAreaReference)
        }

        let trackingArea: NSTrackingArea = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
        trackingAreaReference = trackingArea
        super.updateTrackingAreas()
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        scheduleTooltip()
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        hideTooltip()
    }

    override func mouseDown(with event: NSEvent) {
        animatePress(isPressed: true)
        super.mouseDown(with: event)
        animatePress(isPressed: false)
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        if window == nil {
            hideTooltip()
        }
    }

    private func scheduleTooltip() {
        tooltipTask?.cancel()
        tooltipTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 800_000_000)

            guard !Task.isCancelled else {
                return
            }

            await MainActor.run {
                self?.showTooltip()
            }
        }
    }

    private func showTooltip() {
        guard let window: NSWindow, !tooltipText.isEmpty else {
            return
        }

        hideTooltipPanel()

        let hostingView: NSHostingView<TooltipBubble> = NSHostingView(rootView: TooltipBubble(text: tooltipText))
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

        let localRect: NSRect = convert(bounds, to: nil)
        let screenRect: NSRect = window.convertToScreen(localRect)
        let screenFrame: NSRect = window.screen?.visibleFrame ?? NSScreen.main?.visibleFrame ?? .zero
        let size: NSSize = hostingView.fittingSize
        let preferredX: CGFloat = screenRect.midX - size.width / 2.0
        let x: CGFloat = min(max(preferredX, screenFrame.minX + 6.0), screenFrame.maxX - size.width - 6.0)
        let preferredY: CGFloat = screenRect.maxY + 8.0
        let y: CGFloat = preferredY + size.height < screenFrame.maxY ? preferredY : screenRect.minY - size.height - 8.0

        panel.setFrameOrigin(NSPoint(x: x, y: y))
        panel.orderFront(nil)
        tooltipPanel = panel
    }

    private func hideTooltip() {
        tooltipTask?.cancel()
        tooltipTask = nil
        hideTooltipPanel()
    }

    private func hideTooltipPanel() {
        tooltipPanel?.orderOut(nil)
        tooltipPanel = nil
    }

    private func animatePress(isPressed: Bool) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.18
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            let transform: CGAffineTransform = isPressed
                ? CGAffineTransform(translationX: 0.0, y: 2.0).scaledBy(x: 1.12, y: 1.12)
                : .identity
            animator().layer?.setAffineTransform(transform)
        }
    }
}

struct TooltipBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2.weight(.medium))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.45), lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.16), radius: 8, y: 3)
            .fixedSize()
    }
}
