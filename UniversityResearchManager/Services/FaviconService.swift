import AppKit
import Foundation

actor FaviconService {
    static let shared = FaviconService()

    private var memoryCache: [String: NSImage] = [:]
    private let cacheDir: URL
    private let session: URLSession

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDir = caches.appendingPathComponent("UniversityResearchManager/favicons", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8
        config.httpAdditionalHeaders = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"]
        session = URLSession(configuration: config)
    }

    func favicon(for urlString: String?) async -> NSImage? {
        guard let urlString, !urlString.isEmpty,
              let domain = extractDomain(from: urlString) else { return nil }

        if let cached = memoryCache[domain] { return cached }

        let diskURL = cacheDir.appendingPathComponent("\(domain).png")
        if FileManager.default.fileExists(atPath: diskURL.path),
           let data = try? Data(contentsOf: diskURL),
           let image = NSImage(data: data) {
            memoryCache[domain] = image
            return image
        }

        guard let url = URL(string: "https://www.google.com/s2/favicons?domain=\(domain)&sz=64") else { return nil }

        guard let (data, response) = try? await session.data(from: url),
              (response as? HTTPURLResponse)?.statusCode == 200,
              let image = NSImage(data: data),
              image.size.width > 1 else { return nil }

        try? data.write(to: diskURL)
        memoryCache[domain] = image
        return image
    }

    func removeFaviconIfUnused(for urlString: String?, remainingURLs: [String?]) async {
        guard let urlString, let domain = extractDomain(from: urlString) else { return }
        let usedDomains = Set(remainingURLs.compactMap { $0.flatMap { extractDomain(from: $0) } })
        guard !usedDomains.contains(domain) else { return }
        let diskURL = cacheDir.appendingPathComponent("\(domain).png")
        try? FileManager.default.removeItem(at: diskURL)
        memoryCache.removeValue(forKey: domain)
    }

    private func extractDomain(from urlString: String) -> String? {
        var s = urlString.trimmingCharacters(in: .whitespaces)
        if !s.hasPrefix("http://") && !s.hasPrefix("https://") { s = "https://" + s }
        return URL(string: s)?.host
    }
}
