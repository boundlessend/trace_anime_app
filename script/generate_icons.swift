import AppKit
import CoreGraphics
import Foundation

let rootPath: String = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : FileManager.default.currentDirectoryPath
let assetsURL: URL = URL(fileURLWithPath: rootPath).appendingPathComponent("Assets")
let iconsetURL: URL = assetsURL.appendingPathComponent("TraceAnime.iconset")
let fileManager: FileManager = FileManager.default

try fileManager.createDirectory(at: assetsURL, withIntermediateDirectories: true)
try? fileManager.removeItem(at: iconsetURL)
try fileManager.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

func writePNG(image: NSImage, url: URL) throws {
    guard let tiffData: Data = image.tiffRepresentation,
          let bitmap: NSBitmapImageRep = NSBitmapImageRep(data: tiffData),
          let pngData: Data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "TraceAnimeIcon", code: 1)
    }

    try pngData.write(to: url)
}

func resizedImage(source: NSImage, size: CGFloat) -> NSImage {
    let output: NSImage = NSImage(size: NSSize(width: size, height: size))
    output.lockFocus()
    source.draw(in: NSRect(x: 0, y: 0, width: size, height: size), from: .zero, operation: .copy, fraction: 1)
    output.unlockFocus()
    return output
}

func readableMenuBarImage(source: NSImage, size: CGFloat) -> NSImage {
    let resized: NSImage = resizedImage(source: source, size: size)
    let output: NSImage = NSImage(size: NSSize(width: size, height: size))
    output.lockFocus()

    let rect: NSRect = NSRect(x: 0, y: 0, width: size, height: size)
    NSColor.clear.setFill()
    rect.fill()

    let backingRect: NSRect = NSRect(x: size * 0.04, y: size * 0.04, width: size * 0.92, height: size * 0.92)
    let backingPath: NSBezierPath = NSBezierPath(roundedRect: backingRect, xRadius: size * 0.18, yRadius: size * 0.18)
    NSColor(calibratedWhite: 0.96, alpha: 0.92).setFill()
    backingPath.fill()

    resized.draw(in: NSRect(x: size * 0.08, y: size * 0.08, width: size * 0.84, height: size * 0.84), from: .zero, operation: .sourceOver, fraction: 1)

    output.unlockFocus()
    output.isTemplate = false
    return output
}

func appIcon(size: CGFloat) -> NSImage {
    let sourceURL: URL = assetsURL.appendingPathComponent("AppIconSource.png")
    if let source: NSImage = NSImage(contentsOf: sourceURL) {
        return resizedImage(source: source, size: size)
    }

    let image: NSImage = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let rect: NSRect = NSRect(x: 0, y: 0, width: size, height: size)
    let background: NSBezierPath = NSBezierPath(roundedRect: rect, xRadius: size * 0.18, yRadius: size * 0.18)
    NSColor(calibratedRed: 0.08, green: 0.09, blue: 0.12, alpha: 1).setFill()
    background.fill()

    let frameRect: NSRect = NSRect(x: size * 0.2, y: size * 0.30, width: size * 0.52, height: size * 0.40)
    let framePath: NSBezierPath = NSBezierPath(roundedRect: frameRect, xRadius: size * 0.035, yRadius: size * 0.035)
    NSColor(calibratedRed: 0.93, green: 0.96, blue: 0.98, alpha: 1).setStroke()
    framePath.lineWidth = size * 0.035
    framePath.stroke()

    for index in 0..<3 {
        let dotRect: NSRect = NSRect(x: frameRect.minX + CGFloat(index) * size * 0.13 + size * 0.05, y: frameRect.maxY - size * 0.08, width: size * 0.045, height: size * 0.035)
        NSColor(calibratedRed: 0.17, green: 0.78, blue: 0.86, alpha: 1).setFill()
        NSBezierPath(roundedRect: dotRect, xRadius: size * 0.01, yRadius: size * 0.01).fill()
    }

    let lensRect: NSRect = NSRect(x: size * 0.43, y: size * 0.25, width: size * 0.27, height: size * 0.27)
    let lensPath: NSBezierPath = NSBezierPath(ovalIn: lensRect)
    NSColor(calibratedRed: 0.14, green: 0.78, blue: 0.88, alpha: 1).setStroke()
    lensPath.lineWidth = size * 0.045
    lensPath.stroke()

    let handlePath: NSBezierPath = NSBezierPath()
    handlePath.move(to: NSPoint(x: lensRect.maxX - size * 0.02, y: lensRect.minY + size * 0.03))
    handlePath.line(to: NSPoint(x: size * 0.79, y: size * 0.16))
    NSColor(calibratedRed: 0.94, green: 0.30, blue: 0.56, alpha: 1).setStroke()
    handlePath.lineWidth = size * 0.055
    handlePath.lineCapStyle = .round
    handlePath.stroke()

    let sparklePath: NSBezierPath = NSBezierPath()
    sparklePath.move(to: NSPoint(x: size * 0.73, y: size * 0.74))
    sparklePath.line(to: NSPoint(x: size * 0.76, y: size * 0.66))
    sparklePath.line(to: NSPoint(x: size * 0.84, y: size * 0.63))
    sparklePath.line(to: NSPoint(x: size * 0.76, y: size * 0.60))
    sparklePath.line(to: NSPoint(x: size * 0.73, y: size * 0.52))
    sparklePath.line(to: NSPoint(x: size * 0.70, y: size * 0.60))
    sparklePath.line(to: NSPoint(x: size * 0.62, y: size * 0.63))
    sparklePath.line(to: NSPoint(x: size * 0.70, y: size * 0.66))
    sparklePath.close()
    NSColor(calibratedRed: 1.0, green: 0.84, blue: 0.33, alpha: 1).setFill()
    sparklePath.fill()

    image.unlockFocus()
    return image
}

func menuBarIcon(size: CGFloat) -> NSImage {
    let sourceURL: URL = assetsURL.appendingPathComponent("MenuBarIconSource.png")
    if let source: NSImage = NSImage(contentsOf: sourceURL) {
        return readableMenuBarImage(source: source, size: size)
    }

    let image: NSImage = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    let frameRect: NSRect = NSRect(x: size * 0.10, y: size * 0.30, width: size * 0.56, height: size * 0.38)
    let framePath: NSBezierPath = NSBezierPath(roundedRect: frameRect, xRadius: size * 0.05, yRadius: size * 0.05)
    NSColor.black.setStroke()
    framePath.lineWidth = size * 0.08
    framePath.stroke()

    let eyePath: NSBezierPath = NSBezierPath()
    eyePath.move(to: NSPoint(x: frameRect.minX + size * 0.10, y: frameRect.midY))
    eyePath.curve(to: NSPoint(x: frameRect.maxX - size * 0.12, y: frameRect.midY), controlPoint1: NSPoint(x: frameRect.minX + size * 0.22, y: frameRect.maxY - size * 0.03), controlPoint2: NSPoint(x: frameRect.maxX - size * 0.24, y: frameRect.maxY - size * 0.03))
    eyePath.curve(to: NSPoint(x: frameRect.minX + size * 0.10, y: frameRect.midY), controlPoint1: NSPoint(x: frameRect.maxX - size * 0.24, y: frameRect.minY + size * 0.03), controlPoint2: NSPoint(x: frameRect.minX + size * 0.22, y: frameRect.minY + size * 0.03))
    eyePath.lineWidth = size * 0.045
    eyePath.stroke()

    let pupilRect: NSRect = NSRect(x: frameRect.midX - size * 0.045, y: frameRect.midY - size * 0.045, width: size * 0.09, height: size * 0.09)
    NSBezierPath(ovalIn: pupilRect).fill()

    let lensRect: NSRect = NSRect(x: size * 0.48, y: size * 0.20, width: size * 0.28, height: size * 0.28)
    NSBezierPath(ovalIn: lensRect).stroke()

    let handlePath: NSBezierPath = NSBezierPath()
    handlePath.move(to: NSPoint(x: lensRect.maxX - size * 0.02, y: lensRect.minY + size * 0.02))
    handlePath.line(to: NSPoint(x: size * 0.88, y: size * 0.10))
    handlePath.lineWidth = size * 0.09
    handlePath.lineCapStyle = .round
    handlePath.stroke()

    image.unlockFocus()
    image.isTemplate = true
    return image
}

let iconSizes: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for item in iconSizes {
    try writePNG(image: appIcon(size: item.1), url: iconsetURL.appendingPathComponent(item.0))
}

try writePNG(image: menuBarIcon(size: 36), url: assetsURL.appendingPathComponent("MenuBarIcon.png"))
