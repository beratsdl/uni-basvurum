import SwiftUI
import SwiftData

// MARK: - Design Tokens

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r, g, b: UInt64
        switch h.count {
        case 6: (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b) = (0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: 1)
    }

    static let appBg     = Color(hex: "050505")
    static let sidebarBg = Color(hex: "080808")
    static let cardBg    = Color(hex: "0F0F0F")
    static let hoverBg   = Color(hex: "151515")
    static let stroke    = Color(hex: "1A1A1A")
    static let appBlue   = Color(hex: "3B82F6")
    static let warning   = Color(hex: "DC2626")
    static let gold      = Color(hex: "EAB308")
}

extension String {
    var countryFlag: String {
        let flags: [String: String] = [
            "Hollanda": "🇳🇱", "Netherlands": "🇳🇱",
            "Almanya": "🇩🇪", "Germany": "🇩🇪",
            "İtalya": "🇮🇹", "Italy": "🇮🇹",
            "İspanya": "🇪🇸", "Spain": "🇪🇸",
            "Fransa": "🇫🇷", "France": "🇫🇷",
            "Kanada": "🇨🇦", "Canada": "🇨🇦",
            "ABD": "🇺🇸", "USA": "🇺🇸", "United States": "🇺🇸",
            "İngiltere": "🇬🇧", "UK": "🇬🇧", "United Kingdom": "🇬🇧",
            "Türkiye": "🇹🇷", "Turkey": "🇹🇷",
            "Japonya": "🇯🇵", "Japan": "🇯🇵",
            "Avustralya": "🇦🇺", "Australia": "🇦🇺",
            "İsveç": "🇸🇪", "Sweden": "🇸🇪",
            "Norveç": "🇳🇴", "Norway": "🇳🇴",
            "Danimarka": "🇩🇰", "Denmark": "🇩🇰",
            "İsviçre": "🇨🇭", "Switzerland": "🇨🇭",
            "Belçika": "🇧🇪", "Belgium": "🇧🇪",
            "Avusturya": "🇦🇹", "Austria": "🇦🇹",
            "Portekiz": "🇵🇹", "Portugal": "🇵🇹",
            "Polonya": "🇵🇱", "Poland": "🇵🇱",
            "Finlandiya": "🇫🇮", "Finland": "🇫🇮",
            "Çin": "🇨🇳", "China": "🇨🇳",
            "Güney Kore": "🇰🇷", "South Korea": "🇰🇷",
            "Singapur": "🇸🇬", "Singapore": "🇸🇬",
            "Hindistan": "🇮🇳", "India": "🇮🇳",
            "Brezilya": "🇧🇷", "Brazil": "🇧🇷",
            "Meksika": "🇲🇽", "Mexico": "🇲🇽",
            "Rusya": "🇷🇺", "Russia": "🇷🇺",
            "Yeni Zelanda": "🇳🇿", "New Zealand": "🇳🇿",
            "İrlanda": "🇮🇪", "Ireland": "🇮🇪",
            "Yunanistan": "🇬🇷", "Greece": "🇬🇷",
            "Macaristan": "🇭🇺", "Hungary": "🇭🇺",
            "Çek Cumhuriyeti": "🇨🇿", "Czech Republic": "🇨🇿",
        ]
        return flags[self] ?? "🌐"
    }
}

// MARK: - App

@main
struct UniversityResearchManagerApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = true

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(for: University.self)
        .defaultSize(width: 1200, height: 760)
    }
}
