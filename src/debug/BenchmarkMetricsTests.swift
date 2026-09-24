import XCTest

final class BenchmarkMetricsTests: XCTestCase {
    func testReportCalculatesNearestRankPercentiles() {
        let report = BenchmarkReport(samples: [sample(40), sample(10), sample(30), sample(20)])
        XCTAssertEqual(report.p50Ms, 20)
        XCTAssertEqual(report.p95Ms, 40)
        XCTAssertEqual(report.maxMs, 40)
    }

    func testReportHandlesNoSamples() {
        let report = BenchmarkReport(samples: [])
        XCTAssertEqual(report.p50Ms, 0)
        XCTAssertEqual(report.p95Ms, 0)
        XCTAssertEqual(report.maxMs, 0)
    }

    func testReportRoundTripsThroughJson() throws {
        let report = BenchmarkReport(samples: [sample(12.5)])
        let decoded = try JSONDecoder().decode(BenchmarkReport.self, from: JSONEncoder().encode(report))
        XCTAssertEqual(decoded, report)
    }

    private func sample(_ totalMs: Double) -> BenchmarkSample {
        BenchmarkSample(cycle: 1, windowCount: 10, filteringMs: 1, appearanceMs: 2,
            layoutMs: 3, presentationMs: 4, totalMs: totalMs)
    }
}
