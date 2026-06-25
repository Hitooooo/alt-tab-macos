import Cocoa
import ShortcutRecorder

enum SettingsSearchIndex {
    static var current: Builder?

    final class Builder {
        var strings: [String] = []
        var targets: [SettingsSearchHighlightTarget] = []
    }

    static func indexed<T>(_ build: () -> T) -> (result: T, builder: Builder) {
        let previous = current
        let builder = Builder()
        current = builder
        defer { current = previous }
        let result = build()
        return (result, builder)
    }

    static func registerString(_ s: String?) {
        guard let current, let s else { return }
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { current.strings.append(trimmed) }
    }

    static func registerStrings(_ strings: [String]) {
        guard let current else { return }
        for s in strings {
            let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { current.strings.append(trimmed) }
        }
    }

    static func registerTarget(_ target: SettingsSearchHighlightTarget?) {
        guard let target, let current else { return }
        current.targets.append(target)
    }
}

class Appearance {
    static var searchMatchHighlightColor: NSColor = .yellow
    static var searchMatchForegroundColor: NSColor = .black
}

enum SettingsWindow {
    static let contentWidth = CGFloat(700)
}

class IllustratedImageThemeView: NSView {}

typealias EventClosure = (NSEvent, NSView) -> Void

func noAnimation<T: CALayer>(_ make: () -> T) -> T {
    return make()
}

extension NSColor {
    class var systemAccentColor: NSColor { .alternateSelectedControlColor }
    class var tableBorderColor: NSColor { .gridColor }
    class var tableBackgroundColor: NSColor { .windowBackgroundColor }
    class var tableSeparatorColor: NSColor { .gridColor }
    class var tableHoverColor: NSColor { .selectedControlColor }
}

extension NSView {
    func addOrUpdateConstraint(_ anchor: NSLayoutDimension, _ constant: CGFloat) {
        if let constraint = constraints.first(where: { $0.firstAnchor == anchor && $0.secondAnchor == nil }) {
            constraint.constant = constant
        } else {
            anchor.constraint(equalToConstant: constant).isActive = true
        }
    }
}

enum SearchKeyResult {
    case handled
    case passToField
    case passToShortcuts
}

class TilesViewMock {
    var isSearchEditing = false
    func handleSearchEditingKeyDown(_ event: NSEvent) -> SearchKeyResult { return .passToField }
}

class TilesPanelMock {
    var tilesView = TilesViewMock()
    var isKeyWindow = false
}

class App {
    class AppMock {
        var tilesPanel = TilesPanelMock()
    }
    static let app = AppMock()
    static let bundleIdentifier = "com.lwouis.alt-tab-macos"
}

class TilesPanel {
    static let shared = TilesPanel()
    var isKeyWindow: Bool {
        get { App.app.tilesPanel.isKeyWindow }
        set { App.app.tilesPanel.isKeyWindow = newValue }
    }
}

class TilesView {
    static var isSearchEditing: Bool {
        get { App.app.tilesPanel.tilesView.isSearchEditing }
        set { App.app.tilesPanel.tilesView.isSearchEditing = newValue }
    }

    static func handleSearchEditingKeyDown(_ event: NSEvent) -> SearchKeyResult {
        return App.app.tilesPanel.tilesView.handleSearchEditingKeyDown(event)
    }
}

class ControlsTab {
    static let defaultShortcuts = [
        "holdShortcut": ATShortcut(Shortcut(keyEquivalent: "⌥")!, "holdShortcut", .global, .up, 0),
        "holdShortcut2": ATShortcut(Shortcut(keyEquivalent: "⌥")!, "holdShortcut2", .global, .up, 1),
        "holdShortcut3": ATShortcut(Shortcut(keyEquivalent: "⌥")!, "holdShortcut3", .global, .up, 2),
        "nextWindowShortcut": ATShortcut(Shortcut(keyEquivalent: "⇥")!, "nextWindowShortcut", .global, .down),
        "nextWindowShortcut2": ATShortcut(Shortcut(keyEquivalent: "`")!, "nextWindowShortcut2", .global, .down),
        "→": ATShortcut(Shortcut(keyEquivalent: "→")!, "→", .local, .down),
        "←": ATShortcut(Shortcut(keyEquivalent: "←")!, "←", .local, .down),
        "↑": ATShortcut(Shortcut(keyEquivalent: "↑")!, "↑", .local, .down),
        "↓": ATShortcut(Shortcut(keyEquivalent: "↓")!, "↓", .local, .down),
        "focusWindowShortcut": ATShortcut(Shortcut(keyEquivalent: " ")!, "focusWindowShortcut", .local, .down),
        "previousWindowShortcut": ATShortcut(Shortcut(keyEquivalent: "⇧")!, "previousWindowShortcut", .local, .down),
        "cancelShortcut": ATShortcut(Shortcut(keyEquivalent: "⎋")!, "cancelShortcut", .local, .down),
        "searchShortcut": ATShortcut(Shortcut(keyEquivalent: "s")!, "searchShortcut", .local, .down),
        "closeWindowShortcut": ATShortcut(Shortcut(keyEquivalent: "w")!, "closeWindowShortcut", .local, .down),
        "minDeminWindowShortcut": ATShortcut(Shortcut(keyEquivalent: "m")!, "minDeminWindowShortcut", .local, .down),
        "toggleFullscreenWindowShortcut": ATShortcut(Shortcut(keyEquivalent: "f")!, "toggleFullscreenWindowShortcut", .local, .down),
        "quitAppShortcut": ATShortcut(Shortcut(keyEquivalent: "q")!, "quitAppShortcut", .local, .down),
        "hideShowAppShortcut": ATShortcut(Shortcut(keyEquivalent: "h")!, "hideShowAppShortcut", .local, .down),
    ]
    static var shortcuts = defaultShortcuts

    static func executeAction(_ action: String) {
        shortcutsActionsTriggered.append(action)
        if action.starts(with: "holdShortcut") {
            SwitcherSession.current = nil
        }
        if action.starts(with: "nextWindowShortcut") {
            let session = SwitcherSession.current ?? {
                let new = SwitcherSession()
                SwitcherSession.current = new
                return new
            }()
            session.shortcutIndex = Preferences.nameToIndex(action)
        }
    }

    static var shortcutsActionsTriggered: [String] = []
}

enum ShortcutActions {
    static func execute(_ id: String) {
        ControlsTab.executeAction(id)
    }
}

class KeyRepeatTimer {
    static func stopTimerForRepeatingKey(_ shortcutName: String) {}
}

class Logger {
    static func debug(_ message: @escaping () -> Any?, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {}
    static func info(_ message: @escaping () -> Any?, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {}
    static func warning(_ message: @escaping () -> Any?, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {}
    static func error(_ message: @escaping () -> Any?, file: String = #file, function: String = #function, line: Int = #line, context: Any? = nil) {}
}

class Preferences {
    static var shortcutStyle: ShortcutStylePreference = .focusOnRelease
    static var holdShortcut = ["⌥", "⌥", "⌥"]
    static let minShortcutCount = 1
    static let maxShortcutCount = 9
    static var shortcutCount = 3

    static func indexToName(_ baseName: String, _ index: Int) -> String {
        return baseName + (index == 0 ? "" : String(index + 1))
    }

    static func nameToIndex(_ name: String) -> Int {
        guard let number = name.last?.wholeNumberValue else { return 0 }
        return number - 1
    }

    static func effectiveShortcutStyle(_ index: Int) -> ShortcutStylePreference {
        return shortcutStyle
    }
}

enum ShortcutStylePreference: CaseIterable {
    case focusOnRelease
    case doNothingOnRelease
    case searchOnRelease
}

class ModifierFlags {
    static var current: NSEvent.ModifierFlags = []
}
