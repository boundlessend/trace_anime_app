import XCTest

@testable import TraceAnime

/// проверяет декодирование капризного JSON trace.moe (числа-строки, разнотипные поля)
final class TraceMoeDecodingTests: XCTestCase {
    private let decoder: JSONDecoder = JSONDecoder()

    func testUserQuotaUsedAsInt() throws {
        let json: Data = Data(
            #"{"id":"1.2.3.4","priority":0,"concurrency":1,"quota":1000,"quotaUsed":42}"#.utf8)
        let user: TraceMoeUser = try decoder.decode(TraceMoeUser.self, from: json)
        XCTAssertEqual(user.quotaUsed, 42)
    }

    func testUserQuotaUsedAsString() throws {
        let json: Data = Data(
            #"{"id":"1.2.3.4","priority":0,"concurrency":1,"quota":1000,"quotaUsed":"42"}"#.utf8)
        let user: TraceMoeUser = try decoder.decode(TraceMoeUser.self, from: json)
        XCTAssertEqual(user.quotaUsed, 42)
    }

    func testAnilistReferenceAsID() throws {
        let reference: AnilistReference = try decoder.decode(AnilistReference.self, from: Data("21".utf8))
        XCTAssertEqual(anilistID(anilist: reference), 21)
        XCTAssertNil(malID(anilist: reference))
    }

    func testAnilistReferenceAsInfo() throws {
        let json: Data = Data(
            #"{"id":21,"idMal":20,"isAdult":false,"synonyms":["NARUTO"],"title":{"romaji":"NARUTO","english":"Naruto","native":"ナルト"}}"#
                .utf8)
        let reference: AnilistReference = try decoder.decode(AnilistReference.self, from: json)
        XCTAssertEqual(anilistID(anilist: reference), 21)
        XCTAssertEqual(malID(anilist: reference), 20)
        XCTAssertEqual(displayTitle(anilist: reference), "Naruto")
    }

    func testEpisodeNumber() throws {
        let episode: EpisodeReference = try decoder.decode(EpisodeReference.self, from: Data("5".utf8))
        XCTAssertEqual(displayEpisode(episode, language: .english), "Episode 5")
    }

    func testEpisodeText() throws {
        let episode: EpisodeReference = try decoder.decode(EpisodeReference.self, from: Data(#""OVA""#.utf8))
        XCTAssertEqual(displayEpisode(episode, language: .english), "Episode OVA")
    }

    func testEpisodeList() throws {
        let episode: EpisodeReference = try decoder.decode(EpisodeReference.self, from: Data("[1,2]".utf8))
        XCTAssertEqual(displayEpisode(episode, language: .english), "Episode 1, 2")
    }

    func testSearchResponse() throws {
        let json: Data = Data(
            #"{"frameCount":100,"error":"","result":[{"anilist":{"id":21,"idMal":20,"isAdult":false,"synonyms":[],"title":{"romaji":"NARUTO","english":"Naruto","native":"ナルト"}},"filename":"naruto.mkv","episode":5,"from":10.0,"to":12.0,"at":11.0,"similarity":0.95,"video":"https://media.trace.moe/video/21/naruto.mkv","image":"https://media.trace.moe/image/21/naruto.jpg"}]}"#
                .utf8)
        let response: TraceMoeSearchResponse = try decoder.decode(TraceMoeSearchResponse.self, from: json)
        XCTAssertEqual(response.result.count, 1)
        XCTAssertEqual(response.result[0].similarity, 0.95, accuracy: 0.0001)
        XCTAssertEqual(malID(anilist: response.result[0].anilist), 20)
    }
}
