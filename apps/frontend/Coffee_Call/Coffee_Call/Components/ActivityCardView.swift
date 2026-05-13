import SwiftUI

// MARK: - Activity Card with Animations

struct ActivityCardView: View {
    let activity: Activity
    var onJoin: () -> Void
    var onSave: () -> Void

    private let cardHeight: CGFloat = 380

    var body: some View {
        ZStack(alignment: .bottom) {

            // Background image — CoffeeImageView, never overflows
            CoffeeImageView(urlString: activity.backgroundImageURL)
                .frame(maxWidth: .infinity)
                .frame(height: cardHeight)

            // Gradient overlay
            LinearGradient(
                colors: [.clear, Color.black.opacity(0.78)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity)
            .frame(height: cardHeight)

            // Top badges
            VStack {
                HStack(alignment: .top) {
                    statusBadge
                    Spacer()
                    vibeBadge
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                Spacer()
            }
            .frame(height: cardHeight)

            // Bottom content
            VStack(alignment: .leading, spacing: 12) {
                hostRow
                activityTitle
                metaRow
                ctaRow
            }
            .padding(16)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Subviews

    private var statusBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color.statusSuccess)
                .frame(width: 6, height: 6)
            Text(activity.status.rawValue)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }

    private var vibeBadge: some View {
        Text(activity.vibeTag)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color.brandPrimary)
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
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    private var activityTitle: some View {
        Text(activity.title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var metaRow: some View {
        HStack(spacing: 16) {
            Label(String(format: "%.1f km away", activity.distanceKm),
                  systemImage: "mappin.and.ellipse")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.85))

            Label(activity.time, systemImage: "clock")
                .font(.system(size: 13, weight: .medium))
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
                .padding(.vertical, 14)
                .background(
                    activity.isJoined
                    ? Color.white.opacity(0.2)
                    : Color.brandPrimary
                )
                .cornerRadius(30)
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
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
            .pressScale(0.88)
        }
    }
}
