import UIKit

class ViewController: UIViewController {
    private let shopService = ShopDataService()

    private var selectedMenu = -1

    private let cartManager = CartManager.shared

    let shopView = ShopView()
    var shopData = [CategoryData]()

    private lazy var dataSource = makeCollectionViewDataSource(shopView.shopCollectionView)

    override func loadView() {
        view = shopView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        shopView.shopCollectionView.delegate = self

        shopView.darkModeButton.addTarget(self, action: #selector(setDarkModeButtonConfigure), for: .touchUpInside)
        shopView.languageButton.addTarget(self, action: #selector(setLanguageButtonConfigure), for: .touchUpInside)

        setupCartButton()
        observeCartChanges()
        loadmenu()

        navigationItem.backButtonTitle = "이전"
    }

    func loadmenu() {
        shopService.loadMenuData(language: Language.current) { result in
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

    private func setupCartButton() {
        shopView.cartButton.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
    }

    @objc private func cartButtonTapped() {
        let cartViewController = CartViewController()
        navigationController?.pushViewController(cartViewController, animated: true)
    }

    // MARK: - Cart Observer
    private func observeCartChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleCartUpdate), name: .cartUpdated, object: nil)
        // 초기 UI 세팅
        handleCartUpdate()
    }

    @objc private func handleCartUpdate() {
        shopView.updateCart(count: cartManager.totalQuantity, price: cartManager.totalPrice)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ShopView 에서는 네비게이션 바를 숨깁니다.
        navigationController?.setNavigationBarHidden(true, animated: false)
        handleCartUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 다른 화면으로 이동할 때 네비게이션 바를 다시 표시합니다.
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let shopItem = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        cartManager.add(shopItem)
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
        let firstIndexPath = IndexPath(item: 0, section: 0)
        shopView.shopCollectionView.scrollToItem(at: firstIndexPath, at: .left, animated: false)
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
    @objc func setDarkModeButtonConfigure() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let currentStyle = window.overrideUserInterfaceStyle
            window.overrideUserInterfaceStyle = (currentStyle == .dark) ? .light : .dark
        }
    }

    @objc func setLanguageButtonConfigure() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    ViewController()
}
