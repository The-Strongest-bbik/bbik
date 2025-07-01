// 테이블뷰 셀이랑.. 상품 정보랑 수량 조절 UI
import UIKit
import SnapKit
import Then

class CartItemCell: UITableViewCell {
	static let identifier = "CartItemCell"
	private var imageLoadTask: Task<Void, Never>?
	private let indicatorView = UIActivityIndicatorView()

	private let containerView = UIView().then {
        $0.layer.borderColor = UIColor.separator.cgColor
		$0.layer.borderWidth = 1
		$0.layer.cornerRadius = 16
		$0.clipsToBounds = true
	}

	private let productNameLabel = UILabel().then {
		$0.font = .systemFont(ofSize: 18, weight: .semibold)
	}

	private let priceLabel = UILabel().then {
		$0.textColor = .gray
		$0.font = .systemFont(ofSize: 14)
	}

	private let totalPriceLabel = UILabel().then {
		$0.font = .systemFont(ofSize: 16, weight: .regular)
	}

	private let productImageView = UIImageView().then {
		$0.contentMode = .scaleAspectFill
		$0.clipsToBounds = true
		$0.layer.cornerRadius = 8
	}

	let quantityControl = QuantityControl()

	private let infoStackView = UIStackView().then {
		$0.axis = .vertical
		$0.spacing = 10
		$0.alignment = .leading
	}

	private let topHStackView = UIStackView().then {
		$0.axis = .horizontal
		$0.alignment = .top
		$0.spacing = 10
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
		setupConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		productNameLabel.text = nil
		priceLabel.text = nil
		totalPriceLabel.text = nil
		productImageView.image = nil
		indicatorView.stopAnimating()
		imageLoadTask?.cancel()
		imageLoadTask = nil
	}

	func configure(with item: CartItemData) {
		productNameLabel.text = item.menu.name
		priceLabel.text = String(localized: "가격 : \(item.menu.price.formattedWithSeparator)원")
		totalPriceLabel.text = String(localized: "\((item.menu.price * item.quantity).formattedWithSeparator)원")
		quantityControl.quantity = item.quantity

		indicatorView.startAnimating()
		imageLoadTask = Task { @MainActor in
			do {
				let image = try await fetchImageAsync(from: item.menu.image)
				guard !Task.isCancelled else { return }
				productImageView.image = image
				indicatorView.stopAnimating()
			} catch let error as ImageDownloadError {
				switch error {
				case .invalidURL:
					print("URL 형식이 잘못되었습니다.")
				case .networkError(let err):
					print("네트워크 오류: \(err.localizedDescription)")
				case .invalidResponse:
					print("HTTP 응답이 유효하지 않습니다.")
				case .invalidImageData:
					print("이미지 데이터를 디코딩할 수 없습니다.")
				}
				indicatorView.stopAnimating()
				productImageView.image = UIImage(systemName: "xmark")
			} catch {
				print("알 수 없는 오류: \(error.localizedDescription)")
				indicatorView.stopAnimating()
				productImageView.image = UIImage(systemName: "xmark")
			}
		}
	}

	private func setupViews() {
		contentView.addSubview(containerView)

		containerView.addSubview(topHStackView)
		containerView.addSubview(quantityControl)
		containerView.addSubview(indicatorView)

		topHStackView.addArrangedSubview(infoStackView)
		topHStackView.addArrangedSubview(productImageView)

		infoStackView.addArrangedSubview(productNameLabel)
		infoStackView.addArrangedSubview(priceLabel)
		infoStackView.addArrangedSubview(totalPriceLabel)
	}

	private func setupConstraints() {
		containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview().inset(5)
		}

		topHStackView.snp.makeConstraints {
			$0.top.leading.trailing.equalToSuperview().inset(20)
		}

		productImageView.snp.makeConstraints {
			$0.width.height.equalTo(100)
		}

		quantityControl.snp.makeConstraints {
			$0.top.equalTo(topHStackView.snp.bottom).offset(16)
			$0.trailing.equalToSuperview().inset(20)
			$0.bottom.equalToSuperview().inset(20)
		}

		indicatorView.snp.makeConstraints { make in
			make.edges.equalTo(productImageView)
		}
	}
}
