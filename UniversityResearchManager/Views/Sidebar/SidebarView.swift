import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var selectedFilter: SidebarFilter
    @Binding var searchText: String
    @Binding var showingAddSheet: Bool
    @AppStorage("isDarkMode") private var isDarkMode = true
    @Query(sort: \University.country) private var universities: [University]

    private var countries: [String] {
        let all = Array(Set(universities.map(\.country))).sorted()
        guard !searchText.isEmpty else { return all }
        return all.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    private var favoriteCount: Int { universities.filter(\.isFavorite).count }

    private func count(for country: String) -> Int {
        universities.filter { $0.country == country }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 1) {
                navItem(
                    icon: "building.columns.fill", iconColor: .appBlue,
                    label: "Tüm Üniversiteler", badge: universities.count,
                    filter: .all
                )
                navItem(
                    icon: "star.fill", iconColor: .gold,
                    label: "Favoriler", badge: favoriteCount,
                    filter: .favorites
                )

                sectionHeader("ÜLKELER")

                ForEach(countries, id: \.self) { country in
                    countryItem(country: country, badge: count(for: country))
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
        }
        .scrollIndicators(.never)
        .safeAreaInset(edge: .top, spacing: 0) { sidebarHeader }
        .safeAreaInset(edge: .bottom, spacing: 0) { sidebarFooter }
        .background(Color.sidebarBg.ignoresSafeArea())
        .navigationTitle("")
    }

    // MARK: - Nav Items

    @ViewBuilder
    private func navItem(icon: String, iconColor: Color, label: String, badge: Int, filter: SidebarFilter) -> some View {
        let active = selectedFilter == filter
        Button { selectedFilter = filter } label: {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(iconColor.opacity(active ? 0.22 : 0.10))
                        .frame(width: 28, height: 28)
                    Image(systemName: icon)
                        .font(.system(size: 13))
                        .foregroundStyle(iconColor)
                }
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(active ? .white : Color.white.opacity(0.65))
                Spacer()
                pill(badge, active: active)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .background(
                active ? Color.appBlue.opacity(0.10) : Color.clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func countryItem(country: String, badge: Int) -> some View {
        let active = selectedFilter == .country(country)
        Button { selectedFilter = .country(country) } label: {
            HStack(spacing: 10) {
                Text(country.countryFlag)
                    .font(.system(size: 17))
                    .frame(width: 28)
                Text(country)
                    .font(.system(size: 13))
                    .foregroundStyle(active ? .white : Color.white.opacity(0.65))
                Spacer()
                pill(badge, active: active)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .background(
                active ? Color.appBlue.opacity(0.10) : Color.clear,
                in: RoundedRectangle(cornerRadius: 8)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(Color.white.opacity(0.28))
            .tracking(0.9)
            .padding(.horizontal, 9)
            .padding(.top, 14)
            .padding(.bottom, 3)
    }

    @ViewBuilder
    private func pill(_ n: Int, active: Bool) -> some View {
        Text("\(n)")
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(active ? Color.appBlue : Color.white.opacity(0.28))
            .monospacedDigit()
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(
                active ? Color.appBlue.opacity(0.14) : Color.white.opacity(0.06),
                in: Capsule()
            )
    }

    // MARK: - Header

    private var sidebarHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(Color.appBlue.opacity(0.14))
                        .frame(width: 34, height: 34)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Color.appBlue.opacity(0.18), lineWidth: 0.5)
                        )
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.appBlue)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Üniversite")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Araştırma Yöneticisi")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.white.opacity(0.35))
                }
                Spacer()
            }
            .padding(.top, 16)

            HStack(spacing: 7) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.white.opacity(0.35))
                TextField("Ara...", text: $searchText)
                    .font(.system(size: 13))
                    .textFieldStyle(.plain)
                    .foregroundStyle(Color.white.opacity(0.85))
                if searchText.isEmpty {
                    Text("⌘K")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.18))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                        )
                } else {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.white.opacity(0.35))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.stroke, lineWidth: 0.5)
            )
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .background(Color.sidebarBg)
    }

    // MARK: - Footer

    private var sidebarFooter: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.stroke)
                .frame(height: 0.5)
            VStack(spacing: 8) {
                Button {
                    showingAddSheet = true
                } label: {
                    HStack(spacing: 7) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("Üniversite Ekle")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.appBlue, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .keyboardShortcut("n", modifiers: .command)

                Button { isDarkMode.toggle() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .font(.system(size: 11))
                        Text(isDarkMode ? "Koyu Mod" : "Açık Mod")
                            .font(.system(size: 12))
                        Spacer()
                    }
                    .foregroundStyle(Color.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(Color.sidebarBg)
        }
    }
}
