import Foundation

#if canImport(UIKit)
import UIKit
#endif

public extension NSAttributedString {
    /// Initializes the string with the given formatted string.
    ///
    /// ```
    /// let string = """
    /// <b>MacBook Pro</b>. Power, Moves. <a href='https://apple.com'>Learn more.</a>
    /// """
    /// let style = FormattedStringStyle([
    ///     "body": [.font: UIFont.systemFont(ofSize: 16)],
    ///     "b": [.font: UIFont.boldSystemFont(ofSize: 16)]
    /// ])
    /// let _ = NSAttriburedString(formatting: string, style: style)
    /// ```
    ///
    /// Thread safe.
    convenience init(formatting string: String, style: FormattedStringStyle) {
        let parser = Parser(style: style)
        let output = parser.parse(string)
        assert(output != nil, "Failed to format the given string: \(string)")
        self.init(attributedString: output ?? NSAttributedString(string: string))
    }
}

private final class Parser: NSObject {
    private var text = ""
    private let style: FormattedStringStyle
    private var elements = [Element]()
    private var attributes = [(NSRange, [NSAttributedString.Key: Any])]()

    private struct Element {
        let name: String
        let startIndex: String.Index
        let attributes: [NSAttributedString.Key: Any]
    }

    init(style: FormattedStringStyle) {
        self.style = style
    }

    func parse(_ string: String) -> NSAttributedString? {
        guard let data = preprocess(string).data(using: .utf8) else {
            return nil
        }
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return makeAttributedString()
    }

    private func preprocess(_ string: String) -> String {
        // Replaces '<br>' with "line separtor" (doesn't separate paragraphs).
        // To separate paragraphs, use '\b'.
        let string = string.replacingOccurrences(of: "<br>", with: "\u{2028}")

        // Enclose the string in a `<body>` tag to make it proper XML.
        return "<body>\(string)</body>"
    }

    private func makeAttributedString() -> NSAttributedString {
        let output = NSMutableAttributedString(string: text)
        // Apply tags in reverse, more specific tags are applied last.
        for (range, attributes) in attributes.reversed() {
            output.addAttributes(attributes, range: range)
        }
        return output
    }
}

extension Parser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        var attributes = style.attributes(forElement: elementName, attributes: attributeDict) ?? [:]
        if elementName == "a", let url = attributeDict["href"].map(URL.init(string:)) {
            #if canImport(UIKit)
            attributes[.link] = url
            #endif
        }
        let element = Element(name: elementName, startIndex: text.endIndex, attributes: attributes)
        elements.append(element)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let element = elements.popLast() else {
            return assertionFailure("No opening tag for \(elementName)")
        }
        guard element.name == elementName else {
            return assertionFailure("Closing tag mismatch. Expected: \(element.name), got: \(elementName)")
        }
        let range = NSRange(element.startIndex..<text.endIndex, in: text)
        attributes.append((range, element.attributes))
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        text.append(string)
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        // If parsing fails
    }
}
