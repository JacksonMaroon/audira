import Foundation
import NaturalLanguage

enum FormattingStyle: String, CaseIterable, Identifiable {
    case plain = "Plain"
    case sentencePerLine = "Sentence per line"
    case paragraphs = "Paragraphs"
    case wrapped = "Wrapped"

    var id: String { rawValue }
}

enum TextFormatter {
    static func format(
        _ text: String,
        style: FormattingStyle,
        paragraphSentenceCount: Int,
        wrapWidth: Int
    ) -> String {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return "" }

        switch style {
        case .plain:
            return cleaned
        case .sentencePerLine:
            return splitIntoSentences(cleaned).joined(separator: "\n")
        case .paragraphs:
            let sentences = splitIntoSentences(cleaned)
            let count = max(1, paragraphSentenceCount)
            var paragraphs: [String] = []
            var current: [String] = []
            for sentence in sentences {
                current.append(sentence)
                if current.count >= count {
                    paragraphs.append(current.joined(separator: " "))
                    current.removeAll()
                }
            }
            if !current.isEmpty {
                paragraphs.append(current.joined(separator: " "))
            }
            return paragraphs.joined(separator: "\n\n")
        case .wrapped:
            return wrapText(cleaned, width: max(20, wrapWidth))
        }
    }

    private static func splitIntoSentences(_ text: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = text
        var sentences: [String] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
            let sentence = text[range].trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty {
                sentences.append(sentence)
            }
            return true
        }
        if sentences.isEmpty {
            return [text]
        }
        return sentences
    }

    private static func wrapText(_ text: String, width: Int) -> String {
        let words = text.split(whereSeparator: \.isWhitespace)
        var lines: [String] = []
        var current = ""

        for word in words {
            let token = String(word)
            if current.isEmpty {
                current = token
                continue
            }
            let candidate = "\(current) \(token)"
            if candidate.count > width {
                lines.append(current)
                current = token
            } else {
                current = candidate
            }
        }
        if !current.isEmpty {
            lines.append(current)
        }
        return lines.joined(separator: "\n")
    }
}
