import SwiftUI
import SwiftData

struct UniversityListView: View {
    let filter: SidebarFilter
    @Binding var selectedUniversity: University?
    let searchText: String
    @Binding var showingAddSheet: Bool

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \University.name) private var allUniversities: [University]

    private var universities: [University] {
        let base: [University]
        switch filter {
        case .all:
            base = allUniversities
        case .favorites:
            base = allUniversities.filter(\.isFavorite)
        case .country(let c):
            base = allUniversities.filter { $0.country == c }
        }

        guard !searchText.isEmpty else { return base }
        let q = searchText.lowercased()
        return base.filter {
            $0.name.lowercased().contains(q) ||
            $0.country.lowercased().contains(q) ||
            $0.department.lowercased().contains(q) ||
            $0.notes.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            listHeader

            Rectangle()
                .fill(Color.stroke)
                .frame(height: 0.5)

            List {
                ForEach(universities) { university in
                    UniversityRowView(
                        university: university,
                        isSelected: isSelected(university)
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                    .onTapGesture { selectedUniversity = university }
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.appBg)
            .overlay {
                if universities.isEmpty {
                    EmptyStateView(
                        isSearching: !searchText.isEmpty,
                        onAdd: { showingAddSheet = true }
                    )
                }
            }
        }
        .background(Color.appBg)
        .navigationTitle("")
    }

    private var listHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(filter.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                Text("\(universities.count) üniversite")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.white.opacity(0.35))
            }
            Spacer()
            Button {
                showingAddSheet = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.appBlue)
                        .frame(width: 28, height: 28)
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .keyboardShortcut("n", modifiers: .command)
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(Color.appBg)
    }

    private func isSelected(_ university: University) -> Bool {
        selectedUniversity?.persistentModelID == university.persistentModelID
    }

    private func deleteItems(at offsets: IndexSet) {
        let toDelete = offsets.map { universities[$0] }
        let toDeleteIDs = Set(toDelete.map { $0.persistentModelID })
        let remainingURLs = allUniversities
            .filter { !toDeleteIDs.contains($0.persistentModelID) }
            .map { $0.applicationURL }
        for u in toDelete {
            if isSelected(u) { selectedUniversity = nil }
            let urlToClean = u.applicationURL
            Task {
                await FaviconService.shared.removeFaviconIfUnused(for: urlToClean, remainingURLs: remainingURLs)
            }
            modelContext.delete(u)
        }
    }
}
