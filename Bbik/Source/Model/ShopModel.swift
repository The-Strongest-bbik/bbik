import Foundation

struct CategoryData: Codable, Hashable {
    var category: String
    var menus: [MenuData]
}

struct MenuData: Codable, Hashable {
    var image: String
    var name: String
    var price: Int
    var stock: Int
    var sales: Int
}

enum Language: String {
    case korean = "krdata"
    case english = "endata"

    static var current: Language {
        if let lang = Locale.current.language.languageCode?.identifier {
            if lang == "ko" { return .korean } else if
                lang == "en" { return .english }
        }

        if let region = Locale.current.region?.identifier {
            if region == "KR" { return .korean } else if
                region == "US" || region == "GB" { return .english }
        }
        return .korean
    }
}
