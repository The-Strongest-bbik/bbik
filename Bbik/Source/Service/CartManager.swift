// 장바구니 데이터 관리
import UIKit

extension Notification.Name {
    static let cartUpdated = Notification.Name("CartManager.cartUpdated")
}

final class CartManager {
    static let shared = CartManager()
    private init() {}

    private(set) var items: [CartItemData] = []

    func add(_ menu: MenuData) {
        if let index = items.firstIndex(where: { $0.menu == menu }) {
            items[index].quantity += 1
        } else {
            items.append(CartItemData(menu: menu, quantity: 1))
        }
        notifyUpdate()
    }

    func updateQuantity(for menu: MenuData, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.menu == menu }) else { return }
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = quantity
        }
        notifyUpdate()
    }

    var totalQuantity: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var totalPrice: Int {
        items.reduce(0) { $0 + ($1.menu.price * $1.quantity) }
    }

    private func notifyUpdate() {
        NotificationCenter.default.post(name: .cartUpdated, object: nil)
    }
    
    func clearCart() {
        items.removeAll()
        NotificationCenter.default.post(name: .cartUpdated, object: nil)
    }
}
