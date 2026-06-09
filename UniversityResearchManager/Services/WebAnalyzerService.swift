import Foundation

enum WebAnalyzerService {

    static func fetchUniversityName(from urlString: String) async -> String? {
        var cleaned = urlString.trimmingCharacters(in: .whitespaces)
        if !cleaned.hasPrefix("http://") && !cleaned.hasPrefix("https://") {
            cleaned = "https://" + cleaned
        }
        guard let url = URL(string: cleaned) else { return nil }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36",
            forHTTPHeaderField: "User-Agent"
        )

        guard let (data, _) = try? await URLSession.shared.data(for: request) else { return nil }
        let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) ?? ""

        return extractTitle(from: html)
    }

    private static func extractTitle(from html: String) -> String? {
        guard let openRange = html.range(of: "<title", options: .caseInsensitive),
              let gtRange = html.range(of: ">", range: openRange.upperBound..<html.endIndex),
              let closeRange = html.range(of: "</title>", options: .caseInsensitive, range: gtRange.upperBound..<html.endIndex)
        else { return nil }

        let raw = String(html[gtRange.upperBound..<closeRange.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !raw.isEmpty else { return nil }
        return cleanTitle(raw)
    }

    private static func cleanTitle(_ title: String) -> String {
        let separators = [" | ", " - ", " – ", " — ", " :: ", " » "]
        let genericWords = ["home", "welcome", "homepage", "official site", "official website", "ana sayfa", "hoş geldiniz"]

        for sep in separators where title.contains(sep) {
            let parts = title.components(separatedBy: sep)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { part in
                    !part.isEmpty && !genericWords.contains(part.lowercased())
                }
            if let best = parts.max(by: { $0.count < $1.count }), best.count > 3 {
                return best
            }
        }
        return title
    }
}
