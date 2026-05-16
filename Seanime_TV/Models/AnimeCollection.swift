import Foundation

struct SeanimeResponse<T: Codable>: Codable {
    let data: T?
}

// Helper for dynamic JSON encoding
struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init<T: Encodable>(_ value: T) { _encode = { try value.encode(to: $0) } }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}

struct SeanimeSettings: Codable {
    var library: LibrarySettings?
    var mediastream: MediastreamSettings?
}

struct LibrarySettings: Codable {
    var libraryPath: String?
    var autoUpdateProgress: Bool?
}

struct MediastreamSettings: Codable {
    var transcodeEnabled: Bool?
    var transcodeHwAccel: String?
}

struct AnimeCollection: Codable {
    let lists: [AnimeList]?
}

struct AnimeList: Codable, Identifiable {
    var id: String { type ?? UUID().uuidString }
    let type: String?
    let entries: [AnimeEntry]?
}

struct AnimeEntry: Codable, Identifiable {
    var id: Int { mediaId ?? 0 }
    let mediaId: Int?
    let media: BaseAnime?
}

struct BaseAnime: Codable {
    let title: AnimeTitle?
    let coverImage: AnimeCoverImage?
    let bannerImage: String?
    let description: String?
}

struct AnimeTitle: Codable {
    let userPreferred: String?
}

struct AnimeCoverImage: Codable {
    let large: String?
}

struct Entry: Codable {
    let episodes: [Episode]?
}

struct Episode: Codable, Identifiable {
    var id: String { "\(episodeNumber ?? 0)" }
    let episodeNumber: Int?
    let episodeTitle: String?
    let localFile: LocalFile?
}

struct LocalFile: Codable {
    let path: String?
}

struct MediaContainer: Codable {
    let url: String?
}

struct StreamRequest: Codable {
    let path: String
    let streamType: String
    let clientId: String
}
