//
//  ShopDataService.swift
//  Bbik
//
//  Created by 이태윤 on 6/27/25.
//
import Foundation

class ShopDataService {
    enum DataError: Error {
        case fileNotFound
        case parsingFailed
    }
    // 한국어데이터
    func loadKrMenuData(completion: (Result<[CategoryData], Error>) -> Void) {
        guard let path = Bundle.main.path(forResource: "krdata", ofType: "json") else {
            completion(.failure(DataError.fileNotFound))
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path)) // 파일위치
            let decoder = JSONDecoder()
            let decoded = try decoder.decode([CategoryData].self, from: data)
            completion(.success(decoded))
        } catch {
            print("🚨 JSON 파싱 에러 : \(error)")
            completion(.failure(DataError.parsingFailed))
        }
    }
    // 영어데이터
    func loadEnMenuData(completion: (Result<[CategoryData], Error>) -> Void) {
        guard let path = Bundle.main.path(forResource: "krdata", ofType: "json") else {
            completion(.failure(DataError.fileNotFound))
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path)) // 파일위치
            let decoder = JSONDecoder()
            let decoded = try decoder.decode([CategoryData].self, from: data)
            completion(.success(decoded))
        } catch {
            print("🚨 JSON 파싱 에러 : \(error)")
            completion(.failure(DataError.parsingFailed))
        }
    }
}
