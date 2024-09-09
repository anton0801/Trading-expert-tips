import Foundation

extension Double {
    func formattedToTwoDecimalPlaces() -> String {
            return String(format: "%.2f", self)
        }
}
