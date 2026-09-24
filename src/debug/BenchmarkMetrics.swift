import Foundation

struct BenchmarkSample: Codable, Equatable {
    let cycle: Int
    let windowCount: Int
    let filteringMs: Double
    let appearanceMs: Double
    let layoutMs: Double
    let presentationMs: Double
    let totalMs: Double

    var consoleLine: String {
        String(format: "BENCHMARK showUi cycle=%d windows=%d total_ms=%.3f filtering_ms=%.3f appearance_ms=%.3f layout_ms=%.3f presentation_ms=%.3f",
            cycle, windowCount, totalMs, filteringMs, appearanceMs, layoutMs, presentationMs)
    }
}

struct BenchmarkReport: Codable, Equatable {
    let samples: [BenchmarkSample]
    let p50Ms: Double
    let p95Ms: Double
    let maxMs: Double

    init(samples: [BenchmarkSample]) {
        self.samples = samples
        let totals = samples.map(\.totalMs).sorted()
        p50Ms = Self.percentile(totals, 0.50)
        p95Ms = Self.percentile(totals, 0.95)
        maxMs = totals.last ?? 0
    }

    var consoleLine: String {
        String(format: "BENCHMARK_SUMMARY showUi count=%d p50_ms=%.3f p95_ms=%.3f max_ms=%.3f", samples.count, p50Ms, p95Ms, maxMs)
    }

    private static func percentile(_ sorted: [Double], _ percentile: Double) -> Double {
        guard !sorted.isEmpty else { return 0 }
        let index = max(0, Int(ceil(Double(sorted.count) * percentile)) - 1)
        return sorted[index]
    }
}
