//
//  ShopCell.swift
//  Bbik
//
//  Created by seongjun cho on 6/26/25.
//

import UIKit

import SnapKit
import Then

class ShopCell: UICollectionViewCell {

	static let identifier = "ShopCell"
	private var imageLoadTask: Task<Void, Never>?

	let imageView = UIImageView().then {
		$0.backgroundColor = .systemBackground
		$0.clipsToBounds = true
		$0.contentMode = .scaleAspectFill
		$0.layer.cornerRadius = 10
	}

	let nameLabel = UILabel().then {
		$0.font = .systemFont(ofSize: 16, weight: .semibold)
		$0.text = "임시 텍스트입니다."
	}

	let priceLabel = UILabel().then {
		$0.font = .systemFont(ofSize: 14, weight: .semibold)
		$0.textColor = .systemGray
		$0.text = "임시 텍스트입니다."
	}

	let indicatorView = UIActivityIndicatorView()

	let hotImageView = UIImageView().then {
		$0.image = UIImage(named: "hot")
		$0.contentMode = .scaleAspectFit
		$0.isHidden = true
	}

	let newImageView = UIImageView().then {
		$0.image = UIImage(named: "new")
		$0.contentMode = .scaleAspectFit
		$0.isHidden = true
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		configureConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		imageLoadTask?.cancel()
		imageLoadTask = nil
		imageView.image = nil
		nameLabel.text = nil
		hotImageView.isHidden = true
		newImageView.isHidden = true
	}

	func configure(item: MenuData) {
		self.nameLabel.text = item.name
		self.priceLabel.text = String(localized: "\(item.price) 원")

		if item.sales > 20 {
			self.hotImageView.isHidden = false
		} else if item.sales == 0 {
			self.newImageView.isHidden = false
		}

		indicatorView.startAnimating()
		imageLoadTask = Task { @MainActor in
			do {
				let image = try await fetchImageAsync(from: item.image)
				guard !Task.isCancelled else { return }
				imageView.image = image
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
			} catch {
				print("알 수 없는 오류: \(error.localizedDescription)")
				imageView.image = UIImage(systemName: "xmark")
			}
		}
	}

	private func configureConstraints() {
		contentView.addSubview(imageView)
		contentView.addSubview(nameLabel)
		contentView.addSubview(indicatorView)
		contentView.addSubview(priceLabel)
		contentView.addSubview(newImageView)
		contentView.addSubview(hotImageView)

		nameLabel.snp.makeConstraints { make in
			make.top.equalTo(imageView.snp.bottom).offset(4)
			make.leading.trailing.equalToSuperview()
		}

		priceLabel.snp.makeConstraints { make in
			make.top.equalTo(nameLabel.snp.bottom).offset(4)
			make.leading.equalToSuperview()
			make.trailing.equalTo(hotImageView.snp.leading)
		}

		imageView.snp.makeConstraints { make in
			make.top.centerX.equalToSuperview()
			make.height.equalTo(
				self.bounds.height - nameLabel.font.lineHeight - priceLabel.font.lineHeight - 8)
			make.width.equalTo(imageView.snp.height)
		}

		indicatorView.snp.makeConstraints { make in
			make.edges.equalTo(imageView)
		}

		hotImageView.snp.makeConstraints { make in
			make.bottom.trailing.equalToSuperview()
			make.top.equalTo(priceLabel)
			make.width.equalTo(priceLabel.font.lineHeight * (959 / 605))
		}

		newImageView.snp.makeConstraints { make in
			make.top.leading.equalTo(imageView)
			make.width.height.equalTo(imageView).multipliedBy(0.3)
		}
	}
}
