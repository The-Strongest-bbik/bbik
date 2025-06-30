// View Data 연결 이벤트 처리
import UIKit
import SnapKit
import Then

class CartViewController: UIViewController {
    private let cartView = CartView()
    private let cartManager = CartManager.shared

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "텅"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textAlignment = .center
        label.textColor = .tertiaryLabel
        return label
    }()

    override func loadView() {
        view = cartView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        observeCartChanges()
        updateSummary()
        updateEmptyState()
        title = "장바구니"
        
        cartView.paymentButton.addTarget(self, action: #selector(paymentButtonTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cartView.tableView.reloadData()
        updateSummary()
        updateEmptyState()
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .cartUpdated, object: nil)
    }

    private func setupTableView() {
        cartView.tableView.dataSource = self
        cartView.tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.identifier)
    }

    private func updateSummary() {
        let totalQuantity = cartManager.totalQuantity
        let totalPrice = cartManager.totalPrice

        cartView.totalItemsLabel.text = "총 \(totalQuantity)개"
        cartView.totalPriceLabel.text = "\(totalPrice.formattedWithSeparator) 원"
    }

    private func observeCartChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleCartUpdate), name: .cartUpdated, object: nil)
    }

    @objc private func handleCartUpdate() {
        updateSummary()
        cartView.tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        if cartManager.items.isEmpty {
            cartView.tableView.backgroundView = emptyLabel
        } else {
            cartView.tableView.backgroundView = nil
        }
    }
    
    @objc private func paymentButtonTapped() {
        let alert = UIAlertController(title: nil, message: "결제하겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.cartManager.clearCart()
            self.cartView.tableView.reloadData()
            self.updateSummary()
            self.updateEmptyState()
        }))
        present(alert, animated: true)
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartManager.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.identifier, for: indexPath) as? CartItemCell else {
            return UITableViewCell()
        }

        let item = cartManager.items[indexPath.row]
        cell.configure(with: item)
        cell.selectionStyle = .none

        cell.quantityControl.onQuantityChanged = { [weak self] newQuantity in
            guard let self = self else { return }
            self.cartManager.updateQuantity(for: item.menu, quantity: newQuantity)
        }

        cell.quantityControl.onDecreaseToZero = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            cell.quantityControl.quantity = 0
            let alert = UIAlertController(title: nil, message: "장바구니에서 삭제하시겠습니까?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { _ in
                cell.quantityControl.quantity = 1
            }))
            alert.addAction(UIAlertAction(title: "예", style: .destructive, handler: { _ in
                self.cartManager.updateQuantity(for: item.menu, quantity: 0)
            }))
            self.present(alert, animated: true)
        }

        return cell
    }
}
