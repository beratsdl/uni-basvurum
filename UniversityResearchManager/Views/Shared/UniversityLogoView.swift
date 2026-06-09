import SwiftUI
import AppKit

struct UniversityLogoView: View {
    let urlString: String?
    let size: CGFloat
    var cornerRadius: CGFloat = 9
    var isSelected: Bool = false

    @State private var image: NSImage? = nil

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    image != nil
                        ? Color.white.opacity(0.06)
                        : (isSelected ? Color.appBlue.opacity(0.14) : Color.white.opacity(0.05))
                )
                .frame(width: size, height: size)

            if let img = image {
                Image(nsImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.62, height: size * 0.62)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius * 0.4))
            } else {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: size * 0.38))
                    .foregroundStyle(isSelected ? Color.appBlue : Color.white.opacity(0.28))
            }
        }
        .task(id: urlString) {
            image = nil
            image = await FaviconService.shared.favicon(for: urlString)
        }
    }
}
