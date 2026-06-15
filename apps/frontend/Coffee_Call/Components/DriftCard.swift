import SwiftUI
import FirebaseAuth

/// Immersive, photo-forward Drift card matching the Figma "Social Refresh" design.
/// Tasteful native adaptation: full-bleed image with a dark gradient, floating
/// glass status/vibe badges, and the host + meta + join action over the image.
/// Falls back to a category-tinted gradient when no image is available.
struct DriftCard: View {
    let drift: Drift
    let isFeatured: Bool
    let onJoin: () -> Void

    private var cardHeight: CGFloat { isFeatured ? 320 : 280 }

    private var isJoined: Bool {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            guard let currentUid = Auth.auth().currentUser?.uid else { return false }
            return drift.participantIds?.contains(currentUid) == true
        }

        let userInitStr = (UserDefaults.standard.string(forKey: "profile_initials") ?? "U")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        guard !userInitStr.isEmpty else { return false }

        return drift.participantInitials.contains {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() == userInitStr
        }
    }

    private var buttonText: String {
        if drift.isMine {
            return "Hosting"
        } else if isJoined {
            return "Joined"
        } else {
            return AppStrings.Drifts.imIn
        }
    }

    private var buttonColor: Color {
        if drift.isMine {
            return .brandPurple
        } else if isJoined {
            return .brandSecondary
        } else {
            return .brandPrimary
        }
    }

    var body: some View {
        ZStack {
            imageLayer

            // Bottom-anchored legibility gradient.
            LinearGradient(
                colors: [.clear, Color.textPrimary.opacity(0.35), Color.textPrimary.opacity(0.92)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 0) {
                topBadges
                Spacer(minLength: AppConstants.Layout.elementSpacing)
                bottomContent
            }
            .padding(AppConstants.Layout.standardPadding)
        }
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusXLarge, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusXLarge, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.textPrimary.opacity(0.10), radius: 16, x: 0, y: 8)
    }

    // MARK: - Image / Fallback

    @ViewBuilder
    private var imageLayer: some View {
        if let urlString = drift.imageUrl,
           !urlString.trimmingCharacters(in: .whitespaces).isEmpty,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    fallbackLayer
                }
            }
        } else {
            fallbackLayer
        }
    }

    private var fallbackLayer: some View {
        ZStack {
            LinearGradient(
                colors: [drift.category.color, drift.category.color.opacity(0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: drift.category.icon)
                .font(.system(size: 72, weight: .semibold))
                .foregroundColor(.white.opacity(0.18))
        }
    }

    // MARK: - Top Badges

    private var topBadges: some View {
        HStack(alignment: .top, spacing: AppConstants.Layout.subElementSpacing) {
            HStack(spacing: 8) {
                if isFeatured {
                    glassBadge {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: AppConstants.Typography.sizeMicro, weight: .black))
                            Text(AppStrings.Drifts.bestMatch)
                                .font(.system(size: AppConstants.Typography.sizeMicro, weight: .black))
                        }
                    }
                }

                glassBadge {
                    HStack(spacing: 6) {
                        if drift.status != .ended {
                            Circle()
                                .fill(Color.brandPrimary)
                                .frame(width: 6, height: 6)
                        }
                        Text(drift.status.rawValue)
                            .font(.system(size: AppConstants.Typography.sizeMicro, weight: .black))
                            .textCase(.uppercase)
                    }
                }
            }

            Spacer(minLength: 0)

            if let vibe = drift.vibeTags.first {
                Text(vibe)
                    .font(.system(size: AppConstants.Typography.sizeMicro, weight: .black))
                    .textCase(.uppercase)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.brandPurple))
                    .lineLimit(1)
            }
        }
    }

    private func glassBadge<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
            )
            .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
    }

    // MARK: - Bottom Content

    private var bottomContent: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing) {
            // Host row
            HStack(spacing: AppConstants.Layout.subElementSpacing) {
                avatar
                Text(drift.host.name)
                    .font(.outfitBold(size: AppConstants.Typography.sizeBody, relativeTo: .subheadline))
                    .foregroundColor(.white)
                    .lineLimit(1)

                if drift.peopleGoing > 1 {
                    Text("+\(drift.peopleGoing - 1)")
                        .font(.system(size: AppConstants.Typography.sizeMicro, weight: .black))
                        .foregroundColor(.textPrimary)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.white))
                        .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1.5))
                }
            }

            // Title
            Text(drift.title)
                .font(.outfitBlack(size: AppConstants.Typography.sizeTitle, relativeTo: .title3))
                .foregroundColor(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            // Meta row
            HStack(spacing: AppConstants.Layout.elementSpacing) {
                metaItem(icon: AppIcons.mappin, tint: .brandPrimary, text: "\(String(format: "%.1f", drift.distance)) km")
                metaItem(icon: AppIcons.clock, tint: .brandPurple, text: drift.time)
            }

            // Actions
            HStack(spacing: AppConstants.Layout.subElementSpacing) {
                Button(action: onJoin) {
                    Text(buttonText)
                        .font(.outfitBlack(size: AppConstants.Typography.sizeHeadline, relativeTo: .headline))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppConstants.Layout.minTouchTarget + 4)
                        .background(buttonColor)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
                        .shadow(color: buttonColor.opacity(0.4), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .pressScale(0.96)
            }
            .padding(.top, AppConstants.Layout.miniPadding)
        }
    }

    private var avatar: some View {
        Group {
            if let urlString = drift.host.imageUrl,
               !urlString.trimmingCharacters(in: .whitespaces).isEmpty,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
                    } else {
                        avatarFallback
                    }
                }
            } else {
                avatarFallback
            }
        }
        .frame(width: 36, height: 36)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 2))
    }

    private var avatarFallback: some View {
        ZStack {
            Circle().fill(drift.category.color)
            Text(drift.host.initials.prefix(2))
                .font(.system(size: AppConstants.Typography.sizeCaption, weight: .black))
                .foregroundColor(.white)
        }
    }

    private func metaItem(icon: String, tint: Color, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                .foregroundColor(tint)
            Text(text)
                .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
        }
    }
}
