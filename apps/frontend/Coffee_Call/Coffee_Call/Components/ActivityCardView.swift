import SwiftUI

// MARK: - Activity Card with Animations

struct ActivityCardView: View {
    let activity: Activity
    var onJoin: () -> Void
    var onSave: () -> Void

    private let cardAspectRatio: CGFloat = 4.0 / 5.0

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                CoffeeImageView(urlString: activity.backgroundImageURL)
                    .frame(width: proxy.size.width, height: proxy.size.width / cardAspectRatio)

                LinearGradient(
                    colors: [.clear, Color.darkOverlay.opacity(0.2), Color.darkOverlay.opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: proxy.size.width, height: proxy.size.width / cardAspectRatio)

                VStack {
                    HStack(alignment: .top) {
                        statusBadge
                        Spacer()
                        vibeBadge
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    Spacer()
                }
                .frame(width: proxy.size.width, height: proxy.size.width / cardAspectRatio)

                VStack(alignment: .leading, spacing: 14) {
                    hostRow
                    activityTitle
                    metaRow
                    ctaRow
                }
                .padding(24)
                .padding(.bottom, 6)
            }
        }
        .aspectRatio(cardAspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: Color.textPrimary.opacity(0.06), radius: 24, x: 0, y: 10)
    }

    // MARK: - Subviews

    private var statusBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color.statusSuccess)
                .frame(width: 6, height: 6)
            Text(activity.status.rawValue)
                .font(.system(size: 10, weight: .black, design: .default))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }

    private var vibeBadge: some View {
        Text(activity.vibeTag)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color.brandPurple)
            .cornerRadius(20)
    }

    private var hostRow: some View {
        HStack(spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.surfaceMain)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(activity.userInitials)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.textPrimary)
                    )
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))

                if activity.attendeeCount > 0 {
                    Text("+\(activity.attendeeCount)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.brandPrimary)
                        .cornerRadius(8)
                        .offset(x: 6, y: 6)
                }
            }

            Text(activity.userName)
                .font(.system(size: 18, weight: .black, design: .default))
                .foregroundColor(.white)
        }
    }

    private var activityTitle: some View {
        Text(activity.title)
            .font(.system(size: 24, weight: .bold, design: .default))
            .foregroundColor(.white)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var metaRow: some View {
        HStack(spacing: 24) {
            HStack(spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.brandPrimary)
                Text(String(format: "%.1f km away", activity.distanceKm))
            }
                .font(.system(size: 14, weight: .bold, design: .default))
                .foregroundColor(.white.opacity(0.85))

            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundColor(.brandPurple)
                Text(activity.time)
            }
                .font(.system(size: 14, weight: .bold, design: .default))
                .foregroundColor(.white.opacity(0.85))
        }
    }

    private var ctaRow: some View {
        HStack(spacing: 12) {
            // Join button with press scale feedback
            Button(action: onJoin) {
                HStack(spacing: 6) {
                    Text(activity.isJoined
                         ? AppStrings.Discovery.joinedBtn
                         : AppStrings.Discovery.joinMomentBtn)
                        .font(.system(size: 16, weight: .bold))
                    if !activity.isJoined {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    activity.isJoined
                    ? Color.white.opacity(0.2)
                    : Color.brandPrimary
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .animation(CoffeeAnimation.spring, value: activity.isJoined)
            }
            .pressScale()

            // Save button
            Button(action: onSave) {
                Image(systemName: activity.isSaved ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(activity.isSaved ? Color.brandPrimary : .white)
                    .scaleEffect(activity.isSaved ? 1.15 : 1.0)
                    .animation(CoffeeAnimation.springSnap, value: activity.isSaved)
                    .frame(width: 64, height: 64)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
            }
            .pressScale(0.88)
        }
    }
}
