import SwiftUI

// MARK: - Activity Card View
// Matches Figma Discovery feed card: full-bleed image, 4:5 aspect ratio,
// glassmorphic status badge with animated mint dot, lavender vibe pill,
// host row with initials avatar + participant count badge,
// title, meta row (distance/time), Join Moment + heart CTA row.

struct ActivityCardView: View {
    let activity: Activity
    var onJoin: () -> Void
    var onSave: () -> Void

    @State private var dotPulse = false
    private let cardAspectRatio: CGFloat = 4.0 / 5.0

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = w / cardAspectRatio

            ZStack(alignment: .bottom) {
                // MARK: Background image
                CoffeeImageView(urlString: activity.backgroundImageURL)
                    .frame(width: w, height: h)

                // MARK: Gradient overlay — dark bottom, clear top
                LinearGradient(
                    colors: [
                        .clear,
                        Color.darkOverlay.opacity(0.18),
                        Color.darkOverlay.opacity(0.92)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: w, height: h)

                // MARK: Top badges row
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
                .frame(width: w, height: h)

                // MARK: Bottom content stack
                VStack(alignment: .leading, spacing: 14) {
                    hostRow
                    activityTitle
                    metaRow
                    ctaRow
                }
                .padding(24)
                .padding(.bottom, 8)
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

    // MARK: - Status Badge
    // Glassmorphic pill with animated mint dot — matches Figma "Starting Soon" badge
    private var statusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.brandPrimary)
                .frame(width: 7, height: 7)
                .scaleEffect(dotPulse ? 1.4 : 1.0)
                .opacity(dotPulse ? 0.6 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                    value: dotPulse
                )
                .onAppear { dotPulse = true }

            Text(activity.status.rawValue)
                .font(.system(size: 10, weight: .black, design: .default))
                .foregroundColor(.white)
                .tracking(1.2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    // MARK: - Vibe Badge
    // Lavender pill — matches Figma vibe tag
    private var vibeBadge: some View {
        Text(activity.vibeTag)
            .font(.system(size: 10, weight: .black, design: .default))
            .foregroundColor(.white)
            .tracking(1.0)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.brandPurple)
            .clipShape(Capsule())
    }

    // MARK: - Host Row
    // Avatar initials circle with participant count badge + poster name
    private var hostRow: some View {
        HStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                // Initials avatar
                Text(activity.userInitials)
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(Color.surfaceMain)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))

                // Participant count badge
                if activity.attendeeCount > 0 {
                    Text("+\(activity.attendeeCount)")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(Color.brandPrimary)
                        .clipShape(Capsule())
                        .offset(x: 8, y: 8)
                }
            }

            Text(activity.userName)
                .font(.system(size: 18, weight: .black, design: .default))
                .foregroundColor(.white)
        }
    }

    // MARK: - Activity Title
    private var activityTitle: some View {
        Text(activity.title)
            .font(.system(size: 22, weight: .bold, design: .default))
            .foregroundColor(.white)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Meta Row — distance + time
    private var metaRow: some View {
        HStack(spacing: 20) {
            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.brandPrimary)
                    .font(.system(size: 13, weight: .semibold))
                Text(String(format: "%.1f km away", activity.distanceKm))
            }
            .font(.system(size: 13, weight: .bold, design: .default))
            .foregroundColor(.white.opacity(0.9))

            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .foregroundColor(.brandPurple)
                    .font(.system(size: 13, weight: .semibold))
                Text(activity.time)
            }
            .font(.system(size: 13, weight: .bold, design: .default))
            .foregroundColor(.white.opacity(0.9))
        }
    }

    // MARK: - CTA Row — Join Moment + Heart Save
    private var ctaRow: some View {
        HStack(spacing: 12) {
            // Join button
            Button(action: onJoin) {
                HStack(spacing: 6) {
                    Text(activity.isJoined
                         ? AppStrings.Discovery.joinedBtn
                         : AppStrings.Discovery.joinMomentBtn)
                        .font(.system(size: 16, weight: .black, design: .default))
                        .coffeeNumericContentTransition()  // iOS 17+: smooth text swap
                    if !activity.isJoined {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 13, weight: .bold))
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
                .shadow(
                    color: Color.brandPrimary.opacity(activity.isJoined ? 0 : 0.3),
                    radius: 12, x: 0, y: 6
                )
                .animation(CoffeeAnimation.spring, value: activity.isJoined)
            }
            .pressScale()
            .coffeeImpactFeedback(trigger: activity.isJoined)  // iOS 17+

            // Save/Heart button
            Button(action: onSave) {
                Image(systemName: activity.isSaved ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(activity.isSaved ? Color.brandPrimary : .white)
                    .coffeeBounceSymbol(trigger: activity.isSaved)  // iOS 17+
                    .scaleEffect(activity.isSaved ? 1.18 : 1.0)
                    .animation(CoffeeAnimation.springSnap, value: activity.isSaved)
                    .frame(width: 64, height: 64)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
            .pressScale(0.88)
            .coffeeImpactFeedback(trigger: activity.isSaved)  // iOS 17+
        }
    }
}
