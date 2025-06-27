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
