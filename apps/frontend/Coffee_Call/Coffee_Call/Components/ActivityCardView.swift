import SwiftUI

// MARK: - Activity Card View
// Matches Figma Discovery feed card: full-bleed image, 4:5 aspect ratio,
// glassmorphic status badge with animated mint dot, lavender vibe pill,
// host row with initials avatar + participant count badge,
// title, meta row (distance/time), Join Moment + heart CTA row.

struct ActivityCardView: View {
    let drift: Drift
    var onJoin: () -> Void = {}
    var onSave: () -> Void = {}

    @State private var dotPulse = false
    private let cardAspectRatio: CGFloat = 4.0 / 5.0

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = w / cardAspectRatio

            ZStack(alignment: .bottom) {
                // MARK: Background image
                CoffeeImageView(urlString: drift.imageUrl ?? "")
                    .frame(width: w, height: h)

                // MARK: Gradient overlay — dark bottom, clear top
                LinearGradient(
                    colors: [
                        .clear,
                        Color.darkOverlay.opacity(0.18),
                        Color.darkOverlay.opacity(AppConstants.UI.opacityOverlay)
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
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    .padding(.top, AppConstants.Layout.standardPadding)
                    Spacer()
                }
                .frame(width: w, height: h)

                // MARK: Bottom content stack
                VStack(alignment: .leading, spacing: AppConstants.Layout.elementSpacing - 2) {
                    hostRow
                    activityTitle
                    metaRow
                    ctaRow
                }
                .padding(AppConstants.Layout.standardPadding)
                .padding(.bottom, 8)
            }
        }
        .aspectRatio(cardAspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge + 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge + 8, style: .continuous)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(color: Color.textPrimary.opacity(AppConstants.UI.opacitySubtle + 0.01), radius: 24, x: 0, y: 10)
    }

    // MARK: - Status Badge
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

            Text(drift.status.rawValue)
                .font(.system(size: AppConstants.Typography.sizeMicro, weight: .black, design: .default))
                .foregroundColor(.white)
                .tracking(1.2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    // MARK: - Vibe Badge
    private var vibeBadge: some View {
        Text(drift.vibeTags.first?.uppercased() ?? "VIBE")
            .font(.system(size: AppConstants.Typography.sizeMicro, weight: .black, design: .default))
            .foregroundColor(.white)
            .tracking(1.0)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.brandPurple)
            .clipShape(Capsule())
    }

    // MARK: - Host Row
    private var hostRow: some View {
        HStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                // Initials avatar
                Text(drift.host.initials)
                    .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .bold, design: .default))
                    .foregroundColor(.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(Color.surfaceMain)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))

                // Participant count badge
                if drift.peopleGoing > 0 {
                    Text("+\(drift.peopleGoing)")
                        .font(.system(size: AppConstants.Typography.sizeMicro - 1, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(Color.brandPrimary)
                        .clipShape(Capsule())
                        .offset(x: 8, y: 8)
                }
            }

            Text(drift.host.name)
                .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .black, design: .default))
                .foregroundColor(.white)
        }
    }

    // MARK: - Activity Title
    private var activityTitle: some View {
        Text(drift.title)
            .font(.system(size: AppConstants.Typography.sizeTitle + 2, weight: .bold, design: .default))
            .foregroundColor(.white)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Meta Row
    private var metaRow: some View {
        HStack(spacing: 20) {
            HStack(spacing: 6) {
                Image(systemName: AppIcons.mappin)
                    .foregroundColor(.brandPrimary)
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .semibold))
                Text(String(format: "%.1f km away", drift.distance))
            }
            .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold, design: .default))
            .foregroundColor(.white.opacity(0.9))

            HStack(spacing: 6) {
                Image(systemName: AppIcons.clock)
                    .foregroundColor(.brandPurple)
                    .font(.system(size: AppConstants.Typography.sizeCaption, weight: .semibold))
                Text(drift.time)
            }
            .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold, design: .default))
            .foregroundColor(.white.opacity(0.9))
        }
    }

    // MARK: - CTA Row
    private var ctaRow: some View {
        HStack(spacing: 12) {
            // Join button
            Button(action: onJoin) {
                HStack(spacing: 6) {
                    Text(AppStrings.Discovery.joinMomentBtn)
                        .font(.system(size: AppConstants.Typography.sizeBody, weight: .black, design: .default))
                    Image(systemName: AppIcons.arrowUpRight)
                        .font(.system(size: AppConstants.Typography.sizeCaption, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(Color.brandPrimary)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
                .shadow(color: Color.brandPrimary.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .pressScale()

            // Save/Heart button
            Button(action: onSave) {
                Image(systemName: AppIcons.heart)
                    .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(Color.white.opacity(AppConstants.UI.opacityLight))
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusMedium, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
            .pressScale(0.88)
        }
    }
}
