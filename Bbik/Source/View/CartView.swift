// 전체 UI TabelView

import UIKit
import SnapKit
import Then

class CartView: UIView {
    let tableView = UITableView().then {
        $0.separatorStyle = .none
    }

    private let summaryContainer = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowOffset = .init(width: 0, height: -2)
        $0.layer.shadowRadius = 4
    }

    let totalItemsLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
    }

    let totalPriceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
    }

    let paymentButton = UIButton(type: .system).then {
        $0.setTitle("결제하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 25
        $0.clipsToBounds = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        addSubview(tableView)
        addSubview(summaryContainer)

        summaryContainer.addSubview(totalItemsLabel)
        summaryContainer.addSubview(totalPriceLabel)
        summaryContainer.addSubview(paymentButton)
    }

    private func setupConstraints() {
        summaryContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
        }

        tableView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalTo(summaryContainer.snp.top)
        }

        totalItemsLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalToSuperview().inset(20)
        }

        totalPriceLabel.snp.makeConstraints {
            $0.centerY.equalTo(totalItemsLabel)
            $0.trailing.equalToSuperview().inset(20)
        }

        paymentButton.snp.makeConstraints {
            $0.top.equalTo(totalItemsLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(50)
        }
    }
}
