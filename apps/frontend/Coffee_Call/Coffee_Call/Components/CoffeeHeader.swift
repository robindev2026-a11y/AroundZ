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
                    subtitle: config.subtitle,
                    showNotificationIndicator: config.showNotificationIndicator,
                    trailingActions: config.trailingActions
                )
                
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

// MARK: - Coffee Header
struct CoffeeHeader: View {
    let title: String
    var subtitle: String? = nil
    var showNotificationIndicator: Bool = false
    var trailingActions: AnyView? = nil
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: AppConstants.Typography.sizeDisplay, weight: .black))
                    .foregroundColor(.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: AppConstants.Typography.sizeCaption + 1, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            if let actions = trailingActions {
                actions
            } else {
                NotificationIconButton(showIndicator: showNotificationIndicator)
            }
        }
        .padding(.horizontal, AppConstants.Layout.standardPadding)
        .padding(.top, AppConstants.Layout.headerTopPadding)
        .padding(.bottom, 16)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)
        }
        .overlay(
            Divider().opacity(0.1),
            alignment: .bottom
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
        .frame(height: 44) // Native detail header height
        .background(.ultraThinMaterial)
    }
}

extension SubPageHeader where Trailing == EmptyView {
    init() {
        self.init(trailing: { EmptyView() })
    }
}

// MARK: - Subcomponents
struct NotificationIconButton: View {
    var showIndicator: Bool = false
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            Image(systemName: AppIcons.bell)
                .font(.system(size: AppConstants.Typography.sizeHeadline - 1, weight: .semibold))
                .foregroundColor(.brandPurple)
                .frame(width: 48, height: 48)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: Color.textPrimary.opacity(0.04), radius: 8, x: 0, y: 2)
                .overlay(alignment: .topTrailing) {
                    if showIndicator {
                        Circle()
                            .fill(Color.brandPrimary)
                            .frame(width: 9, height: 9)
                            .overlay(Circle().stroke(Color.backgroundMain, lineWidth: 2))
                            .offset(x: -4, y: 4)
                    }
                }
        }
        .pressScale(0.90)
    }
}

struct CoffeeHeaderButton: View {
    let icon: String
    var color: Color = .brandPrimary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: AppConstants.Typography.sizeHeadline - 1, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall, style: .continuous)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: Color.textPrimary.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .pressScale(0.90)
    }
}

struct CoffeeBackButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: AppIcons.back)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.textPrimary)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.surfaceMain))
                .overlay(Circle().stroke(Color.appBorder, lineWidth: 1))
                .shadow(color: Color.textPrimary.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .pressScale(0.9)
    }
}

extension View {
    func asCoffeeScreen(config: CoffeeScreenConfiguration) -> some View {
        CoffeeBasePage(config: config) {
            self
        }
    }
}
