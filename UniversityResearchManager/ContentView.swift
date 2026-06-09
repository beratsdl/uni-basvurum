import SwiftUI

enum SidebarFilter: Hashable {
    case all
    case favorites
    case country(String)

    var title: String {
        switch self {
        case .all: return "Tüm Üniversiteler"
        case .favorites: return "Favoriler"
        case .country(let name): return name
        }
    }
}

struct ContentView: View {
    @State private var selectedFilter: SidebarFilter = .all
    @State private var selectedUniversity: University?
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var listColumnWidth: CGFloat = 380
    @State private var dragDelta: CGFloat = 0

    var body: some View {
        NavigationSplitView {
            SidebarView(
                selectedFilter: $selectedFilter,
                searchText: $searchText,
                showingAddSheet: $showingAddSheet
            )
            .navigationSplitViewColumnWidth(min: 248, ideal: 276, max: 320)
        } detail: {
            HStack(spacing: 0) {
                UniversityListView(
                    filter: selectedFilter,
                    selectedUniversity: $selectedUniversity,
                    searchText: searchText,
                    showingAddSheet: $showingAddSheet
                )
                .frame(width: listColumnWidth)
                .clipped()

                ZStack {
                    Color.appBlue.frame(width: 1)
                    ColumnDividerHandle()
                }
                .frame(width: 20)
                .offset(x: dragDelta)
                .zIndex(1)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            dragDelta = value.translation.width
                        }
                        .onEnded { value in
                            listColumnWidth = max(1, listColumnWidth + value.translation.width)
                            dragDelta = 0
                        }
                )
                .onHover { hovering in
                    if hovering {
                        NSCursor.resizeLeftRight.push()
                    } else {
                        NSCursor.pop()
                    }
                }

                Group {
                    if let university = selectedUniversity {
                        UniversityDetailView(
                            university: university,
                            selectedUniversity: $selectedUniversity
                        )
                    } else {
                        EmptyDetailView()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .animation(nil, value: listColumnWidth)
        }
        .navigationSplitViewStyle(.prominentDetail)
        .sheet(isPresented: $showingAddSheet) {
            UniversityFormView()
        }
        .onChange(of: selectedFilter) {
            selectedUniversity = nil
        }
    }
}

struct ColumnDividerHandle: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "1E3A8A"))
                .frame(width: 20, height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.appBlue.opacity(0.55), lineWidth: 0.5)
                )

            HStack(spacing: 2) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 8, weight: .semibold))
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .semibold))
            }
            .foregroundStyle(Color(hex: "93C5FD"))
        }
    }
}
