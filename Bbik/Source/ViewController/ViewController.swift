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
    private var selectedMenu = -1
    private var cartCount = 0
    private var totalPrice: Int = 0

    let shopView = ShopView()
    var shopData = [CategoryData]()

    private lazy var dataSource = makeCollectionViewDataSource(shopView.shopCollectionView)

    override func loadView() {
        view = shopView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        shopView.shopCollectionView.delegate = self
        loadmenu()
    }

    func loadmenu() {
        shopService.loadMenuData(language: selecteLanguage) { result in
            switch result {
            case .success(let categorys):
                DispatchQueue.main.async {
                    self.shopData = categorys
                    self.shopView.setCategoryButtonsConfigure(self.shopData)
                    self.setupCategoryButtons()
                    self.updateSelectedMenuData()
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

        cartCount += 1
        totalPrice += shopItem.price
        shopView.updateCart(count: cartCount, price: totalPrice)
        print("touch \(shopItem.name)")
    }
}

extension ViewController {
    // 전체 카테고리 처리를 위한 함수
    private func updateSelectedMenuData() {
        if selectedMenu == -1 {
            let allMenus = shopData.flatMap { $0.menus }
            updateData(allMenus)
        } else {
            updateData(shopData[selectedMenu].menus)
        }
    }

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
    // 카테고리 버튼에 액션을 연결하고, 현재 선택된 메뉴 상태를 초기 설정
    private func setupCategoryButtons() {
            shopView.categoryStackView.arrangedSubviews.forEach {
                guard let button = $0 as? UIButton else { return }
                button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
            }
            updateCategorySelection(for: selectedMenu)
        }

    // 선택된 메뉴를 업데이트하고 해당 메뉴에 맞는 데이터를 표시
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        selectedMenu = sender.tag
        updateCategorySelection(for: selectedMenu)
        updateSelectedMenuData()
        print("선택된 카테고리 태그: \(selectedMenu)")
    }

    // 선택된 카테고리 버튼의 텍스트 색상을 변경
    private func updateCategorySelection(for tag: Int) {
        shopView.categoryStackView.arrangedSubviews.forEach {
            guard let button = $0 as? UIButton else { return }
            let isSelected = (button.tag == tag)
            button.setTitleColor(isSelected ? .mainBlue : .label, for: .normal)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    ViewController()
}
