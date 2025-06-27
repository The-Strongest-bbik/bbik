//
//  ShopView.swift
//  Bbik
//
//  Created by seongjun cho on 6/26/25.
//

import UIKit

import SnapKit
import Then

final class ShopView: UIView {

	lazy var shopCollectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout()).then {
		$0.backgroundColor = .systemBackground
		$0.showsHorizontalScrollIndicator = false
	}

	let pageControl = UIPageControl().then {
		$0.currentPage = 0
		$0.pageIndicatorTintColor = UIColor(red: 179 / 255, green: 216 / 255, blue: 1.0, alpha: 1.0)
		$0.currentPageIndicatorTintColor = .mainBlue
		$0.isUserInteractionEnabled = true
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = .systemBackground
		setCollectionViewUI()
		setPageControlUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setCollectionViewUI() {
		addSubview(shopCollectionView)

		shopCollectionView.snp.makeConstraints { make in
			make.top.equalTo(self.safeAreaLayoutGuide)
			make.leading.trailing.equalToSuperview().inset(24)
			make.height.equalTo(shopCollectionView.snp.width).multipliedBy(1.5)
		}
	}

	private func setPageControlUI() {
		addSubview(pageControl)

		pageControl.snp.makeConstraints { make in
			make.top.equalTo(shopCollectionView.snp.bottom).offset(16)
			make.leading.trailing.equalToSuperview()
		}
	}

	private func makeCollectionViewLayout() -> UICollectionViewLayout {

		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(0.5),
			heightDimension: .fractionalHeight(1.0)
		)

		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 9, bottom: 10, trailing: 10)

		let rowGroupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalHeight(1.0/3.0)
		)

		let rowGroup = NSCollectionLayoutGroup.horizontal(
			layoutSize: rowGroupSize,
			repeatingSubitem: item, count: 2
		)

		let pageGroupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalHeight(1.0)
		)

		let pageGroup = NSCollectionLayoutGroup.vertical(
			layoutSize: pageGroupSize,
			repeatingSubitem: rowGroup, count: 3
		)

		let section = NSCollectionLayoutSection(group: pageGroup)
		section.orthogonalScrollingBehavior = .groupPagingCentered
		section.visibleItemsInvalidationHandler = { [weak self] _, offset, _ in
			let pageIndex = round(offset.x / (self?.shopCollectionView.frame.width)!)
			self?.pageControl.currentPage = Int(pageIndex)
		}

		return UICollectionViewCompositionalLayout(section: section)
	}
}
