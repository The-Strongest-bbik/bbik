//
//  ImageFetcher.swift
//  Bbik
//
//  Created by seongjun cho on 6/26/25.
//

import UIKit

enum ImageDownloadError: Error {
	case invalidURL
	case networkError(Error)
	case invalidResponse
	case invalidImageData
}

func fetchImageAsync(from urlString: String) async throws -> UIImage {
	guard let url = URL(string: urlString) else {
		throw ImageDownloadError.invalidURL
	}

	do {
		let (data, response) = try await URLSession.shared.data(from: url)

		guard let httpResponse = response as? HTTPURLResponse,
			  (200...299).contains(httpResponse.statusCode) else {
			throw ImageDownloadError.invalidResponse
		}

		guard let image = UIImage(data: data) else {
			throw ImageDownloadError.invalidImageData
		}

		return image
	} catch {
		throw ImageDownloadError.networkError(error)
	}
}
