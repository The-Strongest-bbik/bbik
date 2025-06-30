import UIKit
import Then
import SnapKit

class QuantityControl: UIView {
    var quantity: Int = 1 {
        didSet {
            quantityLabel.text = "\(quantity)"
        }
    }

    var onQuantityChanged: ((Int) -> Void)?
    var onDecreaseToZero: (() -> Void)?

    private let minusButton = UIButton().then {
        $0.setImage(UIImage(systemName: "minus"), for: .normal)
        $0.tintColor = .systemBlue
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    }

    private let plusButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.tintColor = .systemBlue
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    }

    private let quantityLabel = UILabel().then {
        $0.text = "1"
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16)
    }

    private lazy var stackView = UIStackView(arrangedSubviews: [minusButton, quantityLabel, plusButton]).then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.spacing = 8
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupButtonActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(stackView)
        layer.borderColor = UIColor.separator.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10
    }

    private func setupConstraints() {
        minusButton.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
        plusButton.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
        quantityLabel.snp.makeConstraints {
            $0.width.equalTo(30)
        }
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        }
    }

    private func setupButtonActions() {
        minusButton.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }

    @objc private func minusButtonTapped() {
        if quantity > 1 {
            quantity -= 1
            onQuantityChanged?(quantity)
        } else if quantity == 1 {
            onDecreaseToZero?()
        }
    }

    @objc private func plusButtonTapped() {
        quantity += 1
        onQuantityChanged?(quantity)
    }
}
