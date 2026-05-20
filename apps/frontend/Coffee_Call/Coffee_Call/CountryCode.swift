import Foundation

struct CountryCode: Identifiable, Hashable {
    let id: String
    let name: String
    let flag: String
    let dialCode: String

    init(id: String, name: String, flag: String, dialCode: String) {
        self.id = id
        self.name = name
        self.flag = flag
        self.dialCode = dialCode
    }
}

extension CountryCode {
    static let defaultCountry = CountryCode(id: "IN", name: AppStrings.Country.india, flag: "🇮🇳", dialCode: "+91")

    static let all: [CountryCode] = [
        defaultCountry,
        CountryCode(id: "UK", name: AppStrings.Country.uk, flag: "🇬🇧", dialCode: "+44"),
        CountryCode(id: "CA", name: AppStrings.Country.canada, flag: "🇨🇦", dialCode: "+1"),
        CountryCode(id: "AU", name: AppStrings.Country.australia, flag: "🇦🇺", dialCode: "+61"),
        CountryCode(id: "DE", name: AppStrings.Country.germany, flag: "🇩🇪", dialCode: "+49"),
        CountryCode(id: "FR", name: AppStrings.Country.france, flag: "🇫🇷", dialCode: "+33"),
        CountryCode(id: "SG", name: AppStrings.Country.singapore, flag: "🇸🇬", dialCode: "+65"),
        CountryCode(id: "AE", name: AppStrings.Country.uae, flag: "🇦🇪", dialCode: "+971"),
        CountryCode(id: "JP", name: AppStrings.Country.japan, flag: "🇯🇵", dialCode: "+81"),
        CountryCode(id: "BR", name: AppStrings.Country.brazil, flag: "🇧🇷", dialCode: "+55"),
        CountryCode(id: "MX", name: AppStrings.Country.mexico, flag: "🇲🇽", dialCode: "+52"),
        CountryCode(id: "ZA", name: AppStrings.Country.southAfrica, flag: "🇿🇦", dialCode: "+27"),
        CountryCode(id: "NG", name: AppStrings.Country.nigeria, flag: "🇳🇬", dialCode: "+234"),
        CountryCode(id: "PH", name: AppStrings.Country.philippines, flag: "🇵🇭", dialCode: "+63"),
    ]
}

