import SwiftUI
import SwiftData

struct UniversityDetailView: View {
    @Bindable var university: University
    @Binding var selectedUniversity: University?
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                headerCard
                    .padding(.top, 2)

                if !university.requirements.isEmpty {
                    sectionCard(icon: "doc.text.fill", iconColor: .appBlue, title: "GEREKSİNİMLER") {
                        Text(university.requirements)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.white.opacity(0.78))
                            .textSelection(.enabled)
                            .lineSpacing(5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if !university.notes.isEmpty {
                    notesCard
                }

                if let url = university.applicationURL, !url.isEmpty {
                    sectionCard(icon: "link", iconColor: .appBlue, title: "BAŞVURU BAĞLANTISI") {
                        urlRow(url)
                    }
                }

                metadataCard
                    .padding(.bottom, 4)
            }
            .padding(16)
        }
        .background(Color.appBg)
        .scrollContentBackground(.hidden)
        .navigationTitle("")
        .toolbar { toolbarContent }
        .sheet(isPresented: $showingEditSheet) {
            UniversityFormView(editing: university)
        }
        .alert("Üniversite Silinsin mi?", isPresented: $showingDeleteAlert) {
            Button("Sil", role: .destructive, action: deleteUniversity)
            Button("İptal", role: .cancel) {}
        } message: {
            Text("\"\(university.name)\" kalıcı olarak silinecek.")
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        HStack(alignment: .top, spacing: 14) {
            UniversityLogoView(
                urlString: university.applicationURL,
                size: 58,
                cornerRadius: 13
            )

            VStack(alignment: .leading, spacing: 9) {
                Text(university.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 7) {
                    HStack(spacing: 5) {
                        Text(university.country.countryFlag)
                            .font(.system(size: 13))
                        Text(university.country)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.white.opacity(0.58))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.06), in: Capsule())
                    .overlay(Capsule().stroke(Color.stroke, lineWidth: 0.5))

                    if !university.department.isEmpty {
                        Text(university.department)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.appBlue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.appBlue.opacity(0.10), in: Capsule())
                            .overlay(Capsule().stroke(Color.appBlue.opacity(0.20), lineWidth: 0.5))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.stroke, lineWidth: 0.5))
    }

    // MARK: - Generic Section Card

    @ViewBuilder
    private func sectionCard<Content: View>(
        icon: String, iconColor: Color, title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .tracking(0.6)
            }
            Rectangle().fill(Color.stroke).frame(height: 0.5)
            content()
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.stroke, lineWidth: 0.5))
    }

    // MARK: - Notes Card

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 7) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.warning)
                Text("NOTLAR")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.warning)
                    .tracking(0.6)
                Spacer()
                Text("⚠ Dikkat")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.warning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.warning.opacity(0.12), in: Capsule())
                    .overlay(Capsule().stroke(Color.warning.opacity(0.28), lineWidth: 0.5))
            }
            Rectangle().fill(Color.warning.opacity(0.22)).frame(height: 0.5)
            Text(university.notes)
                .font(.system(size: 13))
                .foregroundStyle(Color(hex: "FF7575"))
                .textSelection(.enabled)
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.warning.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.warning.opacity(0.22), lineWidth: 0.5)
        )
    }

    // MARK: - URL Row

    @ViewBuilder
    private func urlRow(_ urlString: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: "link")
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.35))

            if let url = URL(string: urlString),
               urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
                Link(destination: url) {
                    Text(urlString)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appBlue)
                        .lineLimit(1)
                }
                .buttonStyle(.plain)
                Spacer()
                Link(destination: url) {
                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            } else {
                Text(urlString)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.5))
                    .textSelection(.enabled)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Metadata Card

    private var metadataCard: some View {
        HStack(alignment: .top, spacing: 0) {
            metaItem(label: "Ekleme Tarihi", icon: "calendar.badge.plus", date: university.createdAt)
            Rectangle().fill(Color.stroke).frame(width: 0.5).padding(.vertical, 4)
            metaItem(label: "Son Güncelleme", icon: "pencil", date: university.updatedAt)
        }
        .padding(15)
        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.stroke, lineWidth: 0.5))
    }

    @ViewBuilder
    private func metaItem(label: String, icon: String, date: Date) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(label)
                    .font(.system(size: 11))
            }
            .foregroundStyle(Color.white.opacity(0.28))
            Text(date.formatted(.dateTime.day().month().year().hour().minute()))
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.58))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                university.isFavorite.toggle()
                university.updatedAt = Date()
            } label: {
                Image(systemName: university.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(university.isFavorite ? Color.gold : .secondary)
            }
            .help(university.isFavorite ? "Favorilerden kaldır" : "Favorilere ekle")

            Button { showingEditSheet = true } label: {
                Image(systemName: "pencil")
            }
            .keyboardShortcut("e", modifiers: .command)
            .help("Düzenle")

            Button { showingDeleteAlert = true } label: {
                Image(systemName: "trash")
            }
            .foregroundStyle(Color.warning)
            .help("Sil")
        }
    }

    private func deleteUniversity() {
        let remainingURLs = ((try? modelContext.fetch(FetchDescriptor<University>())) ?? [])
            .filter { $0.persistentModelID != university.persistentModelID }
            .map { $0.applicationURL }
        let urlToClean = university.applicationURL
        Task {
            await FaviconService.shared.removeFaviconIfUnused(for: urlToClean, remainingURLs: remainingURLs)
        }
        modelContext.delete(university)
        selectedUniversity = nil
    }
}
