import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let popover: NSPopover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        configurePopover()
        configureStatusItem()
    }

    private func configurePopover() {
        let rootView: MenuBarRootView = MenuBarRootView { [weak self] size in
            self?.resizePopover(contentSize: size)
        }
        let hostingController: NSHostingController<MenuBarRootView> = NSHostingController(rootView: rootView)
        popover.contentViewController = hostingController
        popover.behavior = .applicationDefined
        popover.animates = true
        popover.contentSize = NSSize(width: 430, height: 260)
    }

    private func configureStatusItem() {
        let item: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = menuBarImage()
        item.button?.target = self
        item.button?.action = #selector(togglePopover(_:))
        statusItem = item
    }

    private func menuBarImage() -> NSImage? {
        if let image: NSImage = NSImage(named: "MenuBarIcon") {
            image.isTemplate = false
            image.size = NSSize(width: 18, height: 18)
            return image
        }

        return NSImage(systemSymbolName: "sparkle.magnifyingglass", accessibilityDescription: "Trace Anime")
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
            return
        }

        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        popover.contentViewController?.view.window?.level = .normal
        popover.contentViewController?.view.window?.makeKey()
    }

    private func resizePopover(contentSize: CGSize) {
        let width: CGFloat = 430
        let height: CGFloat = min(max(contentSize.height, 220), 680)
        let nextSize: NSSize = NSSize(width: width, height: height)

        if abs(popover.contentSize.height - nextSize.height) > 1 {
            popover.contentSize = nextSize
        }
    }
}

@main
struct TraceAnimeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate: AppDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
