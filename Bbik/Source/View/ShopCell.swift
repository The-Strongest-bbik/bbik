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
		$0.font = .systemFont(ofSize: 14, weight: .medium)
		$0.text = "testtt"
	}

	let indicatorView = UIActivityIndicatorView()

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
	}

	func configure(imageURLStr: String, name: String) {
		self.nameLabel.text = name
		indicatorView.startAnimating()
		imageLoadTask = Task { @MainActor in
			do {
				let image = try await fetchImageAsync(from: imageURLStr)
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

		nameLabel.snp.makeConstraints { make in
			make.leading.equalToSuperview()
			make.bottom.trailing.equalToSuperview()
			make.height.equalTo(20)
		}

		imageView.snp.makeConstraints { make in
			make.height.equalTo(imageView.snp.width)
			make.leading.trailing.equalToSuperview()
			make.bottom.equalTo(nameLabel.snp.top)
		}

		indicatorView.snp.makeConstraints { make in
			make.edges.equalTo(imageView)
		}
	}
}
