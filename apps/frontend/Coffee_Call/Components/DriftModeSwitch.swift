import SwiftUI

struct DriftModeSwitch: View {
    @Binding var selectedMode: DriftsViewModel.DriftMode
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(DriftsViewModel.DriftMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedMode = mode
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: AppConstants.Typography.sizeBody, weight: .bold))
                        .foregroundColor(selectedMode == mode ? .brandPrimary : .textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .overlay(alignment: .bottom) {
                            if selectedMode == mode {
                                Rectangle()
                                    .fill(Color.brandPrimary)
                                    .frame(height: 3)
                                    .cornerRadius(1.5)
                                    .matchedGeometryEffect(id: "underline", in: animation)
                            }
                        }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                .fill(Color.backgroundMain)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadiusSmall)
                .stroke(Color.appBorder.opacity(AppConstants.UI.opacityNormal), lineWidth: 1)
        )
    }
}
