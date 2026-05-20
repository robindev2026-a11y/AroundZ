import SwiftUI

struct CountryPickerView: View {
    @Binding var selected: CountryCode
    @Environment(\.presentationMode) var presentationMode
    @State private var search: String = ""

    var filtered: [CountryCode] {
        if search.isEmpty { return CountryCode.all }
        return CountryCode.all.filter {
            $0.name.localizedCaseInsensitiveContains(search) ||
            $0.dialCode.contains(search)
        }
    }

    var body: some View {
        NavigationView {
            List(filtered) { country in
                Button(action: {
                    selected = country
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: AppConstants.Auth.countryItemSpacing) {
                        Text(country.flag).font(.system(size: AppConstants.Auth.countryItemFlagSize))
                        VStack(alignment: .leading, spacing: AppConstants.Layout.miniPadding / 2) {
                            Text(country.name)
                                .font(.bodyStandard)
                                .foregroundColor(.textPrimary)
                            Text(country.dialCode)
                                .font(.captionText)
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                        if selected.id == country.id {
                            AppIcons.checkmarkImage
                                .foregroundColor(.brandPrimary)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, AppConstants.Auth.countryItemVerticalPadding)
                }
            }
            .searchable(text: $search, prompt: AppStrings.Auth.searchCountry)
            .navigationTitle(AppStrings.Auth.selectCountry)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

