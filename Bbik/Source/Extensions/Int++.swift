import Foundation

extension Formatter {
	static let withSeparator: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.groupingSeparator = ","
		return formatter
	}()
}

extension Int {
	var formattedWithSeparator: String {
		return Formatter.withSeparator.string(from: NSNumber(value: self)) ?? "\(self)"
	}
}
