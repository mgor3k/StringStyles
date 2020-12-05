import Foundation

public struct FormattedStringStyle {
    private var attributes: [String: [NSAttributedString.Key: Any]] = [:]

    public init(
        _ attributes: [String: [NSAttributedString.Key: Any]]) {
        self.attributes = attributes
    }

    func attributes(
        forElement element: String,
        attributes: [String: String]
    ) -> [NSAttributedString.Key: Any]? {
        self.attributes[element]
    }
}
