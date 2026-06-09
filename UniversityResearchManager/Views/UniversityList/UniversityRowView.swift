import SwiftUI

struct UniversityRowView: View {
    let university: University
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                UniversityLogoView(
                    urlString: university.applicationURL,
                    size: 42,
                    cornerRadius: 9,
                    isSelected: isSelected
                )

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(university.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 4)
                        if university.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.gold)
                        }
                    }
                    if !university.department.isEmpty {
                        Text(university.department)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.appBlue)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.appBlue.opacity(0.10), in: Capsule())
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                infoRow(icon: "globe", text: university.country)
                if !university.requirements.isEmpty {
                    infoRow(icon: "doc.text", text: university.requirements)
                }
                infoRow(
                    icon: "calendar",
                    text: university.createdAt.formatted(.dateTime.day().month(.abbreviated).year())
                )
            }

            if !university.notes.isEmpty {
                notesBadge
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isSelected ? Color.appBlue.opacity(0.06) : Color.cardBg,
            in: RoundedRectangle(cornerRadius: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isSelected ? Color.appBlue : Color.stroke,
                    lineWidth: isSelected ? 1.5 : 0.5
                )
        )
    }

    @ViewBuilder
    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(Color.white.opacity(0.28))
                .frame(width: 12)
            Text(text)
                .font(.system(size: 11))
                .foregroundStyle(Color.white.opacity(0.42))
                .lineLimit(1)
        }
    }

    private var notesBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 9, weight: .bold))
            Text(university.notes)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(1)
        }
        .foregroundStyle(Color(hex: "FF7070"))
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.warning.opacity(0.10), in: RoundedRectangle(cornerRadius: 7))
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.warning.opacity(0.22), lineWidth: 0.5)
        )
    }
}
