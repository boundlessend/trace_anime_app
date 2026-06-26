import XCTest

@testable import TraceAnime

/// живой smoke к trace.moe; запускается только при TRACE_MOE_SMOKE=1, иначе пропускается
final class TraceMoeSmokeTests: XCTestCase {
    func testMeEndpointReturnsQuota() async throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["TRACE_MOE_SMOKE"] == "1",
            "set TRACE_MOE_SMOKE=1 to run the live trace.moe smoke test"
        )

        let client: TraceMoeClient = TraceMoeClient(
            baseURL: URL(string: "https://api.trace.moe/")!,
            session: .shared,
            decoder: JSONDecoder()
        )

        let user: TraceMoeUser = try await client.me(apiKey: "")
        XCTAssertGreaterThan(user.quota, 0)
    }
}
