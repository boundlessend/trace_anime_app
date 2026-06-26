import XCTest

@testable import TraceAnime

/// проверяет числовое сравнение версий и декодирование релиза GitHub
final class VersionCheckTests: XCTestCase {
    func testNewerPatch() {
        XCTAssertTrue(isVersion("1.0.1", newerThan: "1.0.0"))
    }

    func testOlderIsNotNewer() {
        XCTAssertFalse(isVersion("1.1.0", newerThan: "1.2.0"))
    }

    func testEqualIsNotNewer() {
        XCTAssertFalse(isVersion("1.2.0", newerThan: "1.2.0"))
    }

    func testNumericNotLexicographic() {
        XCTAssertTrue(isVersion("1.10.0", newerThan: "1.9.0"))
    }

    func testDifferentLengths() {
        XCTAssertTrue(isVersion("1.0.1", newerThan: "1.0"))
        XCTAssertFalse(isVersion("1.0", newerThan: "1.0.0"))
    }

    func testNormalizedVersionStripsPrefix() {
        XCTAssertEqual(normalizedVersion("v1.2.3"), "1.2.3")
        XCTAssertEqual(normalizedVersion("1.2.3"), "1.2.3")
    }

    func testReleaseDecoding() throws {
        let json: Data = Data(
            #"{"tag_name":"v1.2.0","html_url":"https://github.com/boundlessend/trace_anime_app/releases/tag/v1.2.0"}"#
                .utf8)
        let release: GitHubRelease = try JSONDecoder().decode(GitHubRelease.self, from: json)
        XCTAssertEqual(release.tagName, "v1.2.0")
        XCTAssertEqual(
            release.htmlURL.absoluteString, "https://github.com/boundlessend/trace_anime_app/releases/tag/v1.2.0")
    }
}
