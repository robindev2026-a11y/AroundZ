import SwiftUI

// MARK: - Reusable Base Page

struct CoffeeBasePage<Header: View, Content: View>: View {
    private let topPadding: CGFloat
    private let header: Header
    private let content: Content
    private let scrollable: Bool

    init(
        topPadding: CGFloat = 156,
        scrollable: Bool = true,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.topPadding = topPadding
        self.scrollable = scrollable
        self.header = header()
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.backgroundMain.ignoresSafeArea()

            if scrollable {
                ScrollView(showsIndicators: false) {
                    content
                        .padding(.top, topPadding)
                        .padding(.bottom, AppConstants.Layout.screenBottomSpacer)
                }
                .ignoresSafeArea()
            } else {
                content
                    .padding(.top, topPadding)
            }

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
                            .font(.system(size: AppConstants.Typography.sizeCaption , weight: .bold))
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
    let subtitle: String?
    let categoryIcon: String?
    let categoryColor: Color?
    let trailing: Trailing

    init(
        title: String? = nil,
        subtitle: String? = nil,
        categoryIcon: String? = nil,
        categoryColor: Color? = nil,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.categoryIcon = categoryIcon
        self.categoryColor = categoryColor
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

              

                if let categoryIcon, let categoryColor {
//
                    
                    // Rich Middle Content Capsule (Generic layout for chats/rich subpages)
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(categoryColor.opacity(AppConstants.UI.opacityLight))
                                .frame(width: 42, height: 42)
                            Image(systemName: categoryIcon)
                                .font(.system(size: 18))
                                .foregroundColor(categoryColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            if let title {
                                Text(title)
                                    .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                                    .foregroundColor(.textPrimary)
                                    .lineLimit(1)
                            }
                            
                            if let subtitle {
                                TruncatableSubtitleView(
                                    subtitle: subtitle,
                                    font: .system(size: AppConstants.Typography.sizeCaption, weight: .bold),
                                    color: .textSecondary
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
//                    .background(Color.surfaceMain)
                    .cornerRadius(AppConstants.UI.cornerRadiusLarge - 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge - 6)
                            .stroke(Color.appBorder.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                    
//                    Spacer()
                } else {
                    
                    Spacer() // only this needed spacer
                    
                    // Standard Title Text with Optional Subtitle
                    VStack(alignment: .leading, spacing: 2) {
                        if let title {
                            Text(title)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.textPrimary)
                                .lineLimit(1)
                        }
                        
                        if let subtitle {
                            TruncatableSubtitleView(
                                subtitle: subtitle,
                                font: .system(size: 12, weight: .semibold),
                                color: .textSecondary
                            )
                        }
                    }
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
    var maxSize: CGFloat = 40
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

struct CrossFadingText: View {
    let part1: String
    let part2: String
    let font: Font
    let color: Color
    
    @State private var showPart2 = false
    private let timer = Timer.publish(every: 3.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack(alignment: .leading) {
            if !showPart2 {
                Text(part1)
                    .font(font)
                    .foregroundColor(color)
                    .lineLimit(1)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        )
                    )
            } else {
                Text(part2)
                    .font(font)
                    .foregroundColor(color)
                    .lineLimit(1)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        )
                    )
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                showPart2.toggle()
            }
        }
    }
}

struct TruncatableSubtitleView: View {
    let subtitle: String
    let font: Font
    let color: Color
    
    @State private var isTruncated = false
    @State private var containerWidth: CGFloat = 0
    @State private var naturalWidth: CGFloat = 0
    
    var body: some View {
        Group {
            if subtitle.contains(" • ") && isTruncated {
                let parts = subtitle.components(separatedBy: " • ")
                if parts.count >= 2 {
                    CrossFadingText(
                        part1: parts[0],
                        part2: parts[1],
                        font: font,
                        color: color
                    )
                } else {
                    staticTextView
                }
            } else {
                staticTextView
            }
        }
        // Helper hidden overlay to measure full unconstrained width
        .background(
            Text(subtitle)
                .font(font)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .background(
                    GeometryReader { textGeo in
                        Color.clear
                            .onAppear {
                                naturalWidth = textGeo.size.width
                                checkTruncation()
                            }
                    }
                )
                .opacity(0)
        )
        // Measure active container width
        .background(
            GeometryReader { containerGeo in
                Color.clear
                    .onAppear {
                        containerWidth = containerGeo.size.width
                        checkTruncation()
                    }
                    .onChange(of: containerGeo.size.width) { newWidth in
                        containerWidth = newWidth
                        checkTruncation()
                    }
            }
        )
    }
    
    private var staticTextView: some View {
        Text(subtitle)
            .font(font)
            .foregroundColor(color)
            .lineLimit(1)
    }
    
    private func checkTruncation() {
        if naturalWidth > 0 && containerWidth > 0 {
            isTruncated = naturalWidth > containerWidth
        }
    }
}

// MARK: - Convenience Extensions

enum CoffeePageStyle {
    case main
    case sub
}

extension View {
    // 1. New Unified Page Modifier
    func asCoffeePage<RightView: View>(
        _ style: CoffeePageStyle,
        title: String,
        subtitle: String = "",
        categoryIcon: String? = nil,
        categoryColor: Color? = nil,
        topPadding: CGFloat? = nil,
        scrollable: Bool = true,
        @ViewBuilder rightView: @escaping () -> RightView = { EmptyView() }
    ) -> some View {
        let resolvedTopPadding: CGFloat = topPadding ?? {
            switch style {
            case .main: return 156
            case .sub: return (categoryIcon != nil) ? 110 : 96
            }
        }()
        
        return CoffeeBasePage(topPadding: resolvedTopPadding, scrollable: scrollable) {
            Group {
                switch style {
                case .main:
                    CoffeeHeader(
                        title: title,
                        subtitle: subtitle,
                        rightView: rightView
                    )
                case .sub:
                    CoffeeSubHeader<RightView>(
                        title: title.isEmpty ? nil : title,
                        subtitle: subtitle.isEmpty ? nil : subtitle,
                        categoryIcon: categoryIcon,
                        categoryColor: categoryColor,
                        trailing: rightView
                    )
                }
            }
        } content: {
            self
        }
    }
    
    // Convenience overload for page without right view
    func asCoffeePage(
        _ style: CoffeePageStyle,
        title: String,
        subtitle: String = "",
        categoryIcon: String? = nil,
        categoryColor: Color? = nil,
        topPadding: CGFloat? = nil,
        scrollable: Bool = true
    ) -> some View {
        self.asCoffeePage(style, title: title, subtitle: subtitle, categoryIcon: categoryIcon, categoryColor: categoryColor, topPadding: topPadding, scrollable: scrollable) {
            EmptyView()
        }
    }

}

// MARK: - Preview

#Preview {
    VStack {
        Text("Discover content here")
    }
    .asCoffeePage(
        .sub,
        title: AppStrings.Discovery.title,
        subtitle: "People nearby are Open to plans",
        categoryIcon: "d",
        categoryColor: .red,
        rightView: {
       
//                CoffeeHeaderButton(icon: AppIcons.search) {}
                CoffeeHeaderButton(icon: AppIcons.filter) {}
        }
    )
}

