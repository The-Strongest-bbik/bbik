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
    let categoryscrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false // 수평 스크롤바 안보이게 설정
        $0.showsVerticalScrollIndicator = false // 수직 스크롤바 안보이게 설정
    }
    let categoryStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.spacing = 12
        $0.alignment = .center
    }

    let topSeparatorView = UIView().then {
        $0.backgroundColor = .separator
    }

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

    let bottomSeparatorView = UIView().then {
        $0.backgroundColor = .separator
    }

    let bottomStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 12
    }

    let totalLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.text = "0 원"
    }

    let cartButton = UIButton().then {
        $0.backgroundColor = .mainBlue
        $0.layer.cornerRadius = 8
    }

    let cartStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .equalCentering
        $0.isUserInteractionEnabled = false
    }

    let cartCountLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 14)
        $0.backgroundColor = .white
        $0.textColor = .mainBlue
        $0.text = "0"
        $0.textAlignment = .center
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }

    let cartLabel = UILabel().then {
        $0.text = "장바구니 보기"
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .white
    }

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = .systemBackground
        setCategoryViewUI()
		setCollectionViewUI()
		setPageControlUI()
        bottomCartStackViewUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    private func setCategoryViewUI() {
        addSubview(categoryscrollView)
        categoryscrollView.addSubview(categoryStackView)

        addSubview(topSeparatorView)

        categoryscrollView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(24)
            make.height.equalTo(categoryStackView.snp.height)
            make.bottom.equalTo(categoryStackView.snp.bottom)
        }

        categoryStackView.snp.makeConstraints { make in
            make.directionalEdges.equalToSuperview()
        }

        topSeparatorView.snp.makeConstraints { make in
            make.top.equalTo(categoryStackView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1) // 선의 두께
        }
    }

	private func setCollectionViewUI() {
		addSubview(shopCollectionView)

		shopCollectionView.snp.makeConstraints { make in
            make.top.equalTo(topSeparatorView.snp.bottom)
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

    private func bottomCartStackViewUI() {
        addSubview(bottomSeparatorView)
        addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(totalLabel)
        bottomStackView.addArrangedSubview(cartButton)

        cartButton.addSubview(cartStackView)

        cartStackView.addArrangedSubview(cartCountLabel)
        cartStackView.addArrangedSubview(cartLabel)

        bottomSeparatorView.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1) // 선의 두께
        }

        bottomStackView.snp.makeConstraints { make in
            make.top.equalTo(bottomSeparatorView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        cartButton.snp.makeConstraints { make in
            make.height.equalTo(45)
        }

        cartStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        cartCountLabel.snp.makeConstraints { make in
            make.width.height.equalTo(20)
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

    func setCategoryButtonsConfigure(_ categorys: [CategoryData]) {
        categoryStackView.addArrangedSubview(createCategoryButton(title: "전체", tag: -1))

        for (index, category) in categorys.enumerated() {
            let button = createCategoryButton(title: category.category, tag: index)
            categoryStackView.addArrangedSubview(button)
        }
    }

    private func createCategoryButton(title: String, tag: Int) -> UIButton {
        let button = UIButton().then {
            $0.setTitle(title, for: .normal)
            $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
            $0.titleLabel?.textAlignment = .center
            $0.setTitleColor(.label, for: .normal)
            $0.tag = tag
        }
        return button
    }

    func updateCart(count: Int, price: Int) {
        cartCountLabel.text = "\(count)"
        totalLabel.text = "\(price)원"
    }
}
