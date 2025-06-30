//
//  String++.swift
//  Bbik
//
//  Created by seongjun cho on 6/30/25.
//

import Foundation

extension String {
	func localized() -> String {
		return NSLocalizedString(self, comment: "")
	}
}
