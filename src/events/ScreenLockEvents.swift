import Cocoa

class ScreenLockEvents {
    static var isScreenLocked = false

    static func observe() {
        let dnc = DistributedNotificationCenter.default()
        dnc.addObserver(self, selector: #selector(handleLocked), name: NSNotification.Name("com.apple.screenIsLocked"), object: nil, suspensionBehavior: .deliverImmediately)
        dnc.addObserver(self, selector: #selector(handleUnlocked), name: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil, suspensionBehavior: .deliverImmediately)
        if let dict = CGSessionCopyCurrentDictionary() as? [String: Any] {
            isScreenLocked = (dict["CGSSessionScreenIsLocked"] as? Bool) ?? false
        }
    }

    @objc private static func handleLocked() {
        Logger.info { "" }
        isScreenLocked = true
    }

    @objc private static func handleUnlocked() {
        Logger.info { "" }
        isScreenLocked = false
        // a locked/idle screen can let macOS disable our event taps (kCGEventTapDisabledByTimeout); re-enable on unlock (#5723)
        SleepWakeEvents.reEnableAllTaps()
    }
}
