import Foundation

final class BenchmarkRunner {
    enum Stage {
        case windowsReady
        case appearanceReady
        case layoutReady
        case visible
    }

    static let launchDuration = 10000
    static let startupDelay = 5000
    static let showDuration = 500
    static let hideDuration = 500
    static let shortcutIndex = 0
    private static var config: BenchmarkConfig?
    private static var remainingCycles = 0
    private static var currentCycle: BenchmarkCycle?
    private static var samples = [BenchmarkSample]()

    static func startIfNeeded() {
        guard let config = BenchmarkConfig.parse(CommandLine.arguments) else { return }
        self.config = config
        switch config.mode {
        case .launch:
            scheduleTerminate(after: launchDuration)
        case .showUi(let count):
            remainingCycles = count
            scheduleShow(after: startupDelay)
        }
    }

    private static func scheduleShow(after delay: Int) {
        guard remainingCycles > 0 else { scheduleTerminate(after: hideDuration); return }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
            currentCycle = BenchmarkCycle(number: samples.count + 1, startedAt: DispatchTime.now().uptimeNanoseconds)
            App.showUi(shortcutIndex)
            scheduleHide(after: showDuration)
        }
    }

    static func mark(_ stage: Stage) {
        guard var cycle = currentCycle else { return }
        let now = DispatchTime.now().uptimeNanoseconds
        switch stage {
            case .windowsReady: cycle.windowsReadyAt = now
            case .appearanceReady: cycle.appearanceReadyAt = now
            case .layoutReady: cycle.layoutReadyAt = now
            case .visible:
                cycle.visibleAt = now
                let sample = cycle.sample(windowCount: Windows.list.count)
                samples.append(sample)
                currentCycle = nil
                print(sample.consoleLine)
                return
        }
        currentCycle = cycle
    }

    private static func scheduleHide(after delay: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
            App.hideUi()
            remainingCycles -= 1
            scheduleShow(after: hideDuration)
        }
    }

    private static func scheduleTerminate(after delay: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delay)) {
            reportResults()
            App.shared.terminate(nil)
        }
    }

    private static func reportResults() {
        guard !samples.isEmpty else { return }
        let report = BenchmarkReport(samples: samples)
        print(report.consoleLine)
        guard let outputUrl = config?.outputUrl else { return }
        do {
            let data = try JSONEncoder().encode(report)
            try data.write(to: outputUrl, options: .atomic)
            print("BENCHMARK_OUTPUT \(outputUrl.path)")
        } catch {
            print("BENCHMARK_OUTPUT_ERROR \(error)")
        }
    }
}

private struct BenchmarkCycle {
    let number: Int
    let startedAt: UInt64
    var windowsReadyAt: UInt64?
    var appearanceReadyAt: UInt64?
    var layoutReadyAt: UInt64?
    var visibleAt: UInt64?

    func sample(windowCount: Int) -> BenchmarkSample {
        let windows = windowsReadyAt ?? startedAt
        let appearance = appearanceReadyAt ?? windows
        let layout = layoutReadyAt ?? appearance
        let visible = visibleAt ?? layout
        return BenchmarkSample(cycle: number, windowCount: windowCount,
            filteringMs: milliseconds(startedAt, windows), appearanceMs: milliseconds(windows, appearance),
            layoutMs: milliseconds(appearance, layout), presentationMs: milliseconds(layout, visible),
            totalMs: milliseconds(startedAt, visible))
    }

    private func milliseconds(_ start: UInt64, _ end: UInt64) -> Double {
        Double(end - start) / 1_000_000
    }
}

struct BenchmarkConfig {
    enum Mode {
        case launch
        case showUi(Int)
    }

    let mode: Mode
    let outputUrl: URL?

    static func parse(_ args: [String]) -> BenchmarkConfig? {
        guard let index = args.firstIndex(of: "--benchmark"), index + 1 < args.count else { return nil }
        let mode = args[index + 1]
        let outputUrl = parseOutputUrl(args)
        if mode == "launch" { return BenchmarkConfig(mode: .launch, outputUrl: outputUrl) }
        if mode == "showUi" { return parseShowUi(args, index) }
        print("Unsupported benchmark mode: \(mode)")
        return nil
    }

    private static func parseShowUi(_ args: [String], _ index: Int) -> BenchmarkConfig? {
        guard index + 2 < args.count, let count = Int(args[index + 2]), count > 0 else {
            print("Invalid benchmark showUi count")
            return nil
        }
        return BenchmarkConfig(mode: .showUi(count), outputUrl: parseOutputUrl(args))
    }

    private static func parseOutputUrl(_ args: [String]) -> URL? {
        guard let index = args.firstIndex(of: "--benchmark-output"), index + 1 < args.count else { return nil }
        return URL(fileURLWithPath: args[index + 1])
    }
}
