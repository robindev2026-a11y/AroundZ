import SwiftUI

// MARK: - Protocol Oriented Design
protocol CoffeeScreenConfiguration {
    var title: String { get }
    var subtitle: String? { get }
    var trailingActions: AnyView? { get }
    var showNotificationIndicator: Bool { get }
    var pinnedHeader: AnyView? { get }
}

extension CoffeeScreenConfiguration {
    var subtitle: String? { nil }
    var trailingActions: AnyView? { nil }
    var showNotificationIndicator: Bool { false }
    var pinnedHeader: AnyView? { nil }
}

// MARK: - Reusable Base Page
struct CoffeeBasePage<Content: View>: View {
    let config: CoffeeScreenConfiguration
    let content: () -> Content
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.backgroundMain.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    content()
                }
                .padding(.top, config.pinnedHeader == nil ? 110 : 235)
                .padding(.bottom, AppConstants.Layout.screenBottomSpacer)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CoffeeHeader(
                    title: config.title,
                    subtitle: config.subtitle ?? "",
                    notificationCount: config.showNotificationIndicator ? 3 : 0
                )
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.top, 10)
                
                if let pinned = config.pinnedHeader {
                    pinned
                        .background(.ultraThinMaterial)
                        .overlay(
                            Divider().opacity(0.1),
                            alignment: .bottom
                        )
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Social Refresh Main Header
struct CoffeeHeader: View {
    let title: String
    let subtitle: String
    var notificationCount: Int = 0
    var onNotificationTap: () -> Void = {}
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: AppConstants.Typography.sizeDisplay, weight: .black))
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: AppConstants.Typography.sizeBody - 2, weight: .bold)) // 14pt
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // Notification Button
            Button(action: onNotificationTap) {
                ZStack {
                    Circle()
                        .fill(Color.surfaceMain)
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .stroke(Color.appBorder.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: AppIcons.bell)
                        .font(.system(size: AppConstants.Typography.sizeHeadline, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    if notificationCount > 0 {
                        Circle()
                            .fill(Color.brandPrimary)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Text("\(notificationCount)")
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 12, y: -12)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(height: AppConstants.Layout.headerHeight)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.Layout.headerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - SubPage Header (For Detail Views)
struct SubPageHeader<Trailing: View>: View {
    let trailing: () -> Trailing
    
    init(@ViewBuilder trailing: @escaping () -> Trailing) {
        self.trailing = trailing
    }
    
    var body: some View {
        HStack {
            CoffeeBackButton()
            
            Spacer()
            
            HStack(spacing: 8) {
                trailing()
            }
        }
        .padding(.horizontal, AppConstants.Layout.standardPadding)
        .frame(height: 56)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusLarge, style: .continuous))
        .padding(.horizontal, 20)
    }
}

extension SubPageHeader where Trailing == EmptyView {
    init() {
        self.init(trailing: { EmptyView() })
    }
}

// MARK: - Subcomponents
struct CoffeeBackButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: AppIcons.back)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.textPrimary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.surfaceMain))
                .overlay(Circle().stroke(Color.appBorder.opacity(0.3), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .pressScale(0.9)
    }
}

struct SubHeaderButton: View {
    let icon: String
    var color: Color = .textPrimary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(Color.surfaceMain)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous)
                        .stroke(Color.appBorder.opacity(0.3), lineWidth: 1)
                )
        }
        .pressScale(0.9)
    }
}

struct CoffeeHeaderButton: View {
    let icon: String
    var color: Color = .brandPrimary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
                .frame(width: 56, height: 56)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
        .pressScale(0.9)
    }
}

struct NotificationIconButton: View {
    var showIndicator: Bool = false
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
                
                if showIndicator {
                    Circle()
                        .fill(Color.brandPrimary)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Text("3") // Mocked badge count
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(.white)
                        )
                        .offset(x: 12, y: -12)
                }
            }
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
                .font(.system(size: iconSize ?? (size * 0.4), weight: .bold))
                .foregroundColor(color)
        }
    }
}

extension View {
    func asCoffeeScreen(config: CoffeeScreenConfiguration) -> some View {
        CoffeeBasePage(config: config) {
            self
        }
    }
}
