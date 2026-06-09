import SwiftUI

struct EmptyDetailView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "building.columns")
                .font(.system(size: 48))
                .foregroundStyle(Color.white.opacity(0.10))
            Text("Üniversite Seçin")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.3))
            Text("Detayları görmek için listeden\nbir üniversite seçin.")
                .font(.system(size: 13))
                .foregroundStyle(Color.white.opacity(0.18))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
    }
}

struct EmptyStateView: View {
    let isSearching: Bool
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: isSearching ? "magnifyingglass" : "building.columns")
                .font(.system(size: 42))
                .foregroundStyle(Color.white.opacity(0.10))
            Text(isSearching ? "Sonuç Bulunamadı" : "Henüz Üniversite Yok")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.3))
            Text(isSearching
                 ? "Farklı anahtar kelimeler deneyin."
                 : "Araştırdığınız üniversiteleri\nburaya ekleyerek başlayın.")
                .font(.system(size: 12))
                .foregroundStyle(Color.white.opacity(0.18))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            if !isSearching {
                Button(action: onAdd) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("Üniversite Ekle")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.appBlue, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
    }
}
