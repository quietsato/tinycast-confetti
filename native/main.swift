import AppKit
import QuartzCore

final class ConfettiView: NSView {
    private let particles: [Particle]
    private let reducedMotion: Bool
    private let started = CACurrentMediaTime()
    private let colors: [NSColor] = [
        NSColor(srgbRed: 1, green: 0.32, blue: 0.47, alpha: 1),
        NSColor(srgbRed: 1, green: 0.72, blue: 0.22, alpha: 1),
        NSColor(srgbRed: 0.98, green: 0.91, blue: 0.40, alpha: 1),
        NSColor(srgbRed: 0.30, green: 0.88, blue: 0.67, alpha: 1),
        NSColor(srgbRed: 0.28, green: 0.73, blue: 1, alpha: 1),
        NSColor(srgbRed: 0.63, green: 0.48, blue: 1, alpha: 1),
        NSColor(srgbRed: 1, green: 0.48, blue: 0.83, alpha: 1)
    ]

    init(frame: NSRect, reducedMotion: Bool) {
        self.reducedMotion = reducedMotion
        var random = SystemRandomNumberGenerator()
        particles = Particle.make(count: reducedMotion ? 65 : 360, using: &random)
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) { nil }
    override var isOpaque: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.clear(bounds)
        let elapsed = CACurrentMediaTime() - started
        let sizeScale = min(1.6, max(1, bounds.height / 900))
        for particle in particles {
            guard let frame = particle.frame(
                at: elapsed, width: bounds.width, height: bounds.height, reducedMotion: reducedMotion
            ), frame.y > -30, frame.y < bounds.height + 30 else { continue }
            context.saveGState()
            context.translateBy(x: frame.x, y: frame.y)
            context.rotate(by: frame.angle)
            context.scaleBy(x: frame.scaleX, y: 1)
            context.setFillColor(colors[particle.color].withAlphaComponent(frame.opacity).cgColor)
            let size = particle.size * sizeScale
            let rect = CGRect(x: -size / 2, y: -size / 3, width: size, height: size * 0.66)
            if particle.rounded {
                context.fillEllipse(in: rect)
            } else {
                context.fill(rect)
            }
            context.restoreGState()
        }
    }
}

final class ConfettiPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panels: [ConfettiPanel] = []
    private var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let reduced = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
            || CommandLine.arguments.contains("--reduced-motion")
        for screen in NSScreen.screens {
            let panel = ConfettiPanel(
                contentRect: screen.frame,
                styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false
            )
            panel.level = NSWindow.Level(rawValue: NSWindow.Level.statusBar.rawValue + 1)
            panel.backgroundColor = .clear
            panel.title = "TinyCast Confetti"
            panel.isOpaque = false
            panel.hasShadow = false
            panel.ignoresMouseEvents = true
            panel.hidesOnDeactivate = false
            panel.isReleasedWhenClosed = false
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
            panel.contentView = ConfettiView(
                frame: NSRect(origin: .zero, size: screen.frame.size), reducedMotion: reduced
            )
            panel.orderFrontRegardless()
            panels.append(panel)
        }
        timer = Timer(timeInterval: 1.0 / 60, repeats: true) { [weak self] _ in
            for panel in self?.panels ?? [] { panel.contentView?.needsDisplay = true }
        }
        if let timer { RunLoop.main.add(timer, forMode: .common) }
        DispatchQueue.main.asyncAfter(deadline: .now() + (reduced ? 1.3 : 5.5)) {
            NSApp.terminate(nil)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        panels.forEach { $0.close() }
    }
}

let arguments = Array(CommandLine.arguments.dropFirst())
if arguments == ["--version"] {
    print("TinyCast Confetti 1.0.0")
    exit(0)
}
guard arguments.isEmpty || arguments == ["--reduced-motion"] else {
    fputs("Usage: confetti [--reduced-motion | --version]\n", stderr)
    exit(64)
}
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
