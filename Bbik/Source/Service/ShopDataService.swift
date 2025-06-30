import Foundation

class ShopDataService {
    enum DataError: Error {
        case fileNotFound
        case parsingFailed
    }

    func loadMenuData(language: Language, completion: (Result<[CategoryData], Error>) -> Void) {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "json") else {
            completion(.failure(DataError.fileNotFound))
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let decoded = try decoder.decode([CategoryData].self, from: data)
            completion(.success(decoded))
        } catch {
            print("🚨 JSON 파싱 에러 : \(error)")
            completion(.failure(DataError.parsingFailed))
        }
    }
}
