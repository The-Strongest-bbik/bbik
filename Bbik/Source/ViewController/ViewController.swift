//
//  ViewController.swift
//  Bbik
//
//  Created by 이태윤 on 6/25/25.
//

import UIKit

class ViewController: UIViewController {
    private let shopService = ShopDataService()
    override func loadView() {
        view = ShopView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadKrmenu()
    }
    func loadKrmenu() {
        shopService.loadKrMenuData { result in
            switch result {
            case .success(let categorys):
                DispatchQueue.main.async {
                    for category in categorys {
                        print(category.category)
                        for menu in category.menus {
                            print("\(menu.name) \(menu.price)원")
                        }
                    }
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
    func loadEnmenu() {
        shopService.loadKrMenuData { result in
            switch result {
            case .success(let categorys):
                DispatchQueue.main.async {
                    for category in categorys {
                        print(category)
                        for menu in category.menus {
                            print("\(menu.name) \(menu.price)won")
                        }
                    }
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
