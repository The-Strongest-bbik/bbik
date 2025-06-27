//
//  ViewController.swift
//  Bbik
//
//  Created by 이태윤 on 6/25/25.
//

import UIKit

class ViewController: UIViewController {
    private let shopService = ShopDataService()
    private var selecteLanguage = Language.korean
    private var selectedMenu = 0

	let shopView = ShopView()
	var shopData = [CategoryData]()

	private lazy var dataSource = makeCollectionViewDataSource(shopView.shopCollectionView)

	override func loadView() {
		view = shopView
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		shopView.shopCollectionView.delegate = self
        loadKrmenu()
    }

    func loadKrmenu() {
        shopService.loadMenuData(language: selecteLanguage) { result in
            switch result {
            case .success(let categorys):
                DispatchQueue.main.async {
					self.shopData = categorys
                    self.updateData(self.shopData[self.selectedMenu].menus)
                }

            case .failure(let error):
                print("❌ 에러 발생: \(error)")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "데이터를 불러오지 못했습니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let shopItem = dataSource.itemIdentifier(for: indexPath) else {
			return
		}

		print("touch \(shopItem.name)")
	}
}

extension ViewController {
	private func updateData(_ data: [MenuData]) {
		var snapshot = NSDiffableDataSourceSnapshot<Int, MenuData>()
		snapshot.appendSections([0])
		snapshot.appendItems(data, toSection: 0)
		dataSource.apply(snapshot)

		shopView.pageControl.numberOfPages = Int(ceil(Double(data.count) / 6.0))
	}

	private func makeCollectionViewDataSource(
		_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, MenuData> {
			let cellRegistration = UICollectionView.CellRegistration<ShopCell, MenuData> { cell, _, item in
				cell.configure(item: item)
			}

			return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
				collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
			}
		}
}

@available(iOS 17.0, *)
#Preview {
	ViewController()
}
