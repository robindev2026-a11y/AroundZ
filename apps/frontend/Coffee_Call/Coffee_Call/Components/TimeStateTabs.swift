import SwiftUI

struct TimeStateTabs: View {
    @Binding var selectedState: DriftsViewModel.TimeState
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(DriftsViewModel.TimeState.allCases, id: \.self) { state in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedState = state
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: state.icon)
                                .font(.system(size: 14, weight: .bold))
                            
                            Text(state.rawValue)
                                .font(.system(size: 14, weight: .bold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(selectedState == state ? Color.brandPrimary : Color.surfaceMain)
                        .foregroundColor(selectedState == state ? .white : .textSecondary)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedState == state ? Color.clear : Color.appBorder, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}
