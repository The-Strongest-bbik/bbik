// 장바구니 아이템 모델
import Foundation

struct CartItemData: Codable, Hashable {
    var menu: MenuData
    var quantity: Int
}
