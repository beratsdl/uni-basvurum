import SwiftUI
import SwiftData

struct UniversityFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \University.country) private var allUniversities: [University]

    var editing: University?

    @State private var name = ""
    @State private var country = ""
    @State private var department = ""
    @State private var requirements = ""
    @State private var notes = ""
    @State private var applicationURL = ""
    @State private var isFetchingName = false
    @State private var fetchTask: Task<Void, Never>? = nil

    private var isEditing: Bool { editing != nil }

    private var existingCountries: [String] {
        Array(Set(allUniversities.map(\.country))).sorted()
    }

    private var countrySuggestions: [String] {
        guard !country.isEmpty else { return [] }
        return existingCountries.filter {
            $0.localizedCaseInsensitiveContains(country) &&
            $0.lowercased() != country.lowercased()
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !country.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(editing: University? = nil) {
        self.editing = editing
    }

    var body: some View {
        VStack(spacing: 0) {
            formHeader
            Rectangle().fill(Color.stroke).frame(height: 0.5)
            ScrollView {
                formContent
                    .padding(24)
            }
            .scrollContentBackground(.hidden)
        }
        .frame(width: 500)
        .frame(minHeight: 540, maxHeight: 640)
        .background(Color(hex: "0A0A0A"))
        .onAppear {
            guard let u = editing else { return }
            name = u.name
            country = u.country
            department = u.department
            requirements = u.requirements
            notes = u.notes
            applicationURL = u.applicationURL ?? ""
        }
        .onChange(of: applicationURL) { _, newURL in
            scheduleFetch(for: newURL)
        }
        .onDisappear {
            fetchTask?.cancel()
        }
    }

    private var formHeader: some View {
        HStack(spacing: 12) {
            Text(isEditing ? "Üniversiteyi Düzenle" : "Üniversite Ekle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Button("İptal") { dismiss() }
                .foregroundStyle(Color.white.opacity(0.45))
                .keyboardShortcut(.escape, modifiers: [])
                .buttonStyle(.plain)
            Button(isEditing ? "Kaydet" : "Ekle") { save() }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isValid ? Color.appBlue : Color.appBlue.opacity(0.35), in: RoundedRectangle(cornerRadius: 8))
                .disabled(!isValid)
                .keyboardShortcut(.return, modifiers: .command)
                .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: 18) {
            FormFieldView(label: "ÜNİVERSİTE ADI", required: true) {
                HStack(spacing: 0) {
                    darkTextField("örn. TU Munich", text: $name)
                    if isFetchingName {
                        ProgressView()
                            .scaleEffect(0.6)
                            .padding(.trailing, 8)
                            .padding(.leading, -32)
                    }
                }
            }

            FormFieldView(label: "ÜLKE", required: true) {
                VStack(alignment: .leading, spacing: 8) {
                    darkTextField("örn. Almanya", text: $country)
                    if !countrySuggestions.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(countrySuggestions.prefix(6), id: \.self) { suggestion in
                                    Button(suggestion) { country = suggestion }
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.appBlue)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.appBlue.opacity(0.10), in: Capsule())
                                        .overlay(Capsule().stroke(Color.appBlue.opacity(0.20), lineWidth: 0.5))
                                        .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }

            FormFieldView(label: "BÖLÜM") {
                darkTextField("örn. Bilgisayar Mühendisliği", text: $department)
            }

            FormFieldView(label: "BAŞVURU URL'Sİ") {
                darkTextField("https://...", text: $applicationURL)
            }

            FormFieldView(label: "GEREKSİNİMLER") {
                DarkMultilineTextField(
                    text: $requirements,
                    placeholder: "GPA, dil gereksinimleri, belgeler…"
                )
            }

            FormFieldView(label: "NOTLAR") {
                DarkMultilineTextField(
                    text: $notes,
                    placeholder: "Kişisel notlar, son tarihler, hatırlatıcılar…"
                )
            }
        }
    }

    @ViewBuilder
    private func darkTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .textFieldStyle(.plain)
            .font(.system(size: 13))
            .foregroundStyle(Color.white.opacity(0.85))
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.stroke, lineWidth: 0.5)
            )
    }

    private func scheduleFetch(for url: String) {
        fetchTask?.cancel()
        guard name.trimmingCharacters(in: .whitespaces).isEmpty, !url.isEmpty else { return }

        fetchTask = Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            guard !Task.isCancelled else { return }

            isFetchingName = true
            if let fetched = await WebAnalyzerService.fetchUniversityName(from: url),
               !fetched.isEmpty,
               name.trimmingCharacters(in: .whitespaces).isEmpty {
                name = fetched
            }
            isFetchingName = false
        }
    }

    private func save() {
        let trimName    = name.trimmingCharacters(in: .whitespaces)
        let trimCountry = country.trimmingCharacters(in: .whitespaces)
        let trimDept    = department.trimmingCharacters(in: .whitespaces)
        let trimURL     = applicationURL.trimmingCharacters(in: .whitespaces)

        if let u = editing {
            u.name = trimName
            u.country = trimCountry
            u.department = trimDept
            u.requirements = requirements
            u.notes = notes
            u.applicationURL = trimURL.isEmpty ? nil : trimURL
            u.updatedAt = Date()
        } else {
            let new = University(
                country: trimCountry,
                name: trimName,
                department: trimDept,
                requirements: requirements,
                notes: notes,
                applicationURL: trimURL.isEmpty ? nil : trimURL
            )
            modelContext.insert(new)
        }
        dismiss()
    }
}

struct FormFieldView<Content: View>: View {
    let label: String
    var required: Bool = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 3) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.35))
                    .tracking(0.6)
                if required {
                    Text("*")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.warning)
                }
            }
            content()
        }
    }
}

struct DarkMultilineTextField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.18))
                    .padding(.top, 9)
                    .padding(.leading, 11)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $text)
                .frame(minHeight: 80)
                .font(.system(size: 13))
                .foregroundStyle(Color.white.opacity(0.82))
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
        }
        .background(Color.cardBg, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.stroke, lineWidth: 0.5)
        )
    }
}
