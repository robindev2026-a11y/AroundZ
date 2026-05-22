import SwiftUI

/// Standard CoffeeCall image component.
/// Rule: Always clips to frame — NEVER overflows.
/// Use this everywhere instead of raw AsyncImage.
struct CoffeeImageView: View {
    let urlString: String
    var contentMode: ContentMode = .fill

    var body: some View {
        GeometryReader { geo in
            AsyncImage(url: URL(string: urlString)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .frame(width: geo.size.width, height: geo.size.height)

                case .failure:
                    placeholderView(size: geo.size)

                case .empty:
                    placeholderView(size: geo.size)
                        .overlay(ProgressView().tint(.brandPrimary))

                @unknown default:
                    placeholderView(size: geo.size)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()           // ← critical: always clip to GeometryReader bounds
        }
    }

    private func placeholderView(size: CGSize) -> some View {
        Color.surfaceMain
            .frame(width: size.width, height: size.height)
    }
}
