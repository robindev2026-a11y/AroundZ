import SwiftUI

// MARK: - Reusable Base Page

struct CoffeeBasePage<Header: View, Content: View>: View {
    private let topPadding: CGFloat
    private let header: Header
    private let content: Content

    init(
        topPadding: CGFloat = 156,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.topPadding = topPadding
        self.header = header()
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.backgroundMain.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                content
                    .padding(.top, topPadding)
                    .padding(.bottom, AppConstants.Layout.screenBottomSpacer)
            }
            .ignoresSafeArea()

            header
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Main Header

struct CoffeeHeader<RightView: View>: View {
    let title: String
    let subtitle: String
    let rightView: () -> RightView

    init(
        title: String,
        subtitle: String,
        @ViewBuilder rightView: @escaping () -> RightView
    ) {
        self.title = title
        self.subtitle = subtitle
        self.rightView = rightView
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                // Top Safe Area Glassmorphic Blur Backing Strip
                Color.clear
                    .background(.ultraThinMaterial)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .black, location: 0.0),
                                .init(color: .black, location: 0.65),
                                .init(color: .black.opacity(0), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea(edges: .top)
                    .frame(height: AppConstants.Layout.headerHeight)

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: AppConstants.Typography.sizeDisplay, weight: .black))
                            .foregroundColor(.textPrimary)

                        Text(subtitle)
                            .font(.system(size: AppConstants.Typography.sizeBody - 2, weight: .bold))
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    HStack(spacing: 2) {
                        rightView()
                    }
                    .fixedSize(horizontal: true, vertical: true)
                }
                .padding(.horizontal, 20)
                .frame(height: AppConstants.Layout.headerHeight)
                .background(
                    RoundedRectangle(
                        cornerRadius: AppConstants.Layout.headerRadius,
                        style: .continuous
                    )
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 5)
                )
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.top, AppConstants.Layout.headerTopPadding - 6)
            }

            Spacer()
        }
        .zIndex(20)
    }
}

// MARK: - Default Notification Header Extension

extension CoffeeHeader where RightView == NotificationIconButton {
    init(
        title: String,
        subtitle: String,
        notificationCount: Int = 0,
        onNotificationTap: @escaping () -> Void = {}
    ) {
        self.title = title
        self.subtitle = subtitle
        self.rightView = {
            NotificationIconButton(
                count: notificationCount,
                action: onNotificationTap
            )
        }
    }
}

// MARK: - Sub Page Header

struct CoffeeSubHeader<Trailing: View>: View {
    let title: String?
    let trailing: Trailing

    init(
        title: String? = nil,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.trailing = trailing()
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Top Safe Area Glassmorphic Blur Backing Strip (Rule 8 & premium scroll alignment)
            Color.clear
                .background(.ultraThinMaterial)
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black, location: 0.0),
                            .init(color: .black, location: 0.65),
                            .init(color: .black.opacity(0), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea(edges: .top)
                .frame(height: AppConstants.Layout.headerTopPadding)

            HStack(spacing: 12) {
                CoffeeBackButton()

                if let title {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                }

                Spacer()

                trailing
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            .frame(height: 56)
            .background(.ultraThinMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppConstants.UI.cornerRadiusLarge,
                    style: .continuous
                )
            )
            .padding(.horizontal, 20)
            .padding(.top, AppConstants.Layout.headerTopPadding)
            .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 6)
        }
        .zIndex(20)
    }
}

// MARK: - Buttons

struct CoffeeBackButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: AppIcons.back)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.textPrimary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.surfaceMain))
                .overlay(
                    Circle()
                        .stroke(Color.appBorder.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .pressScale(0.9)
    }
}

struct NotificationIconButton: View {
    var count: Int = 0
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.surfaceMain)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(Color.appBorder.opacity(0.3), lineWidth: 1)
                    )

                Image(systemName: AppIcons.bell)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.textPrimary)

                if count > 0 {
                    Text("\(min(count, 99))")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(Color.brandPrimary)
                        .clipShape(Circle())
                        .offset(x: 12, y: -12)
                }
            }
        }
        .pressScale(0.9)
    }
}

struct HeaderIconButton: View {
    let icon: String
    var color: Color = .brandPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(Color.surfaceMain)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppConstants.UI.cornerRadiusSmall,
                        style: .continuous
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: AppConstants.UI.cornerRadiusSmall,
                        style: .continuous
                    )
                    .stroke(Color.appBorder.opacity(0.3), lineWidth: 1)
                )
        }
        .pressScale(0.9)
    }
}

struct CoffeeHeaderButton: View {
    let icon: String
    var minSize: CGFloat = 40
    var maxSize: CGFloat = 120
    var iconSize: CGFloat = 16
    var color: Color = .brandPrimary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .bold))
                .foregroundColor(color)
                .padding(12) // Dynamic padding for safe interior bounds
                .frame(minWidth: minSize,maxWidth: maxSize,minHeight: minSize, maxHeight: minSize) // Guarantees comfortable tap area
//                .frame(maxWidth: maxSize, maxHeight: minSize) // Prevents oversized expanding
                .background(.ultraThinMaterial)
                .clipShape(Circle()) // Keep Circle shape!
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.09), radius: 8, x: 0, y: 4)
        }
        .pressScale(0.9)
    }
}

struct IconCircle: View {
    let icon: String
    var size: CGFloat = 56
    var color: Color = .brandPrimary
    var iconSize: CGFloat? = nil

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(AppConstants.UI.opacityLight))
                .frame(width: size, height: size)

            Image(systemName: icon)
                .font(.system(size: iconSize ?? size * 0.4, weight: .bold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Convenience Extensions

extension View {
    // 1. General Main Page Extension supporting ANY Custom Right Hand View (e.g. Search, Settings)
    func asCoffeeMainPage<RightView: View>(
        title: String,
        subtitle: String,
        @ViewBuilder rightView: @escaping () -> RightView
    ) -> some View {
        CoffeeBasePage {
            CoffeeHeader(
                title: title,
                subtitle: subtitle,
                rightView: rightView
            )
        } content: {
            self
        }
    }

    // 2. Convenience Overload utilizing your default Notification bell
    func asCoffeeMainPage(
        title: String,
        subtitle: String,
        notificationCount: Int = 0,
        onNotificationTap: @escaping () -> Void = {}
    ) -> some View {
        self.asCoffeeMainPage(title: title, subtitle: subtitle) {
            NotificationIconButton(
                count: notificationCount,
                action: onNotificationTap
            )
        }
    }

    // 3. Sub Page Extension
    func asCoffeeSubPage<Trailing: View>(
        title: String? = nil,
        topPadding: CGFloat = 96,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) -> some View {
        CoffeeBasePage(topPadding: topPadding) {
            CoffeeSubHeader(title: title, trailing: trailing)
        } content: {
            self
        }
    }
}

// MARK: - Legacy Compatibility Typealiases (Rule 8)

typealias SubPageHeader<Trailing: View> = CoffeeSubHeader<Trailing>
typealias SubHeaderButton = HeaderIconButton

// MARK: - Preview

#Preview {
    VStack {
        Text("Discover content here")
    }
    .asCoffeeMainPage(
        title: AppStrings.Discovery.title,
        subtitle: AppStrings.Discovery.subtitleDefault,
        rightView: {
            CoffeeHeaderButton(icon: AppIcons.search) {}
            CoffeeHeaderButton(icon: AppIcons.filter) {}
        }
    )
}

