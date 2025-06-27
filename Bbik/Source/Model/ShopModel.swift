//
//  ShopModel.swift

//  Model.swift
//  Bbik
//
//  Created by 이태윤 on 6/26/25.
//

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

    var currencySymbol: String {
        switch self {
        case .korean: return "원"
        case .english: return "won"
        }
    }
    var stockText: String {
        switch self {
        case .korean: return "재고"
        case .english: return "stock"
        }
    }
    var totalText: String {
        switch self {
        case .korean: return "총합"
        case .english: return "total"
        }
    }
}
