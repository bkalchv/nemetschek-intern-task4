//
//  DirectoryToken.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 7.02.22.
//

import Foundation

class DictionaryEntry : CustomStringConvertible, Codable {
    var word: String = ""
    var translation: String = ""
    
    var description: String {
        return "[\(word) : \(translation)]"
    }
    
    private func readWord(fromEntryAsString tokenAsString: String) -> String {
        if let firstOccuranceOfNewLine = tokenAsString.firstIndex(of: "\n") {
            let range = tokenAsString.startIndex..<firstOccuranceOfNewLine
            
            return String(tokenAsString[range])
        } else {
         return ""
        }
    }
    
    private func readTranslation(fromEntryAsString tokenAsString: String) -> String {
        if let firstOccuranceOfNewLine = tokenAsString.firstIndex(of: "\n") {
            let indexAfterNewLine = tokenAsString.index(after: firstOccuranceOfNewLine)
            let range = indexAfterNewLine..<tokenAsString.endIndex
            
            return String(tokenAsString[range])
        } else {
         return ""
        }
    }
    
    init(tokenAsString: String) {
        let readWord        = readWord(fromEntryAsString: tokenAsString)
        let readTranslation = readTranslation(fromEntryAsString: tokenAsString)
        word = readWord
        translation = readTranslation
    }
    
    private func isBulgarianLetter(letter: String) -> Bool {
        guard let uniCode = UnicodeScalar(letter) else { return false }
        
        switch uniCode {
        case "А" ... "Я":
            return true
        default:
            return false
        }
    }
    
    private func isEnglishLetter(letter: String) -> Bool {
        guard let uniCode = UnicodeScalar(letter) else { return false }
        
        switch uniCode {
        case "A" ... "Z":
            return true
        default:
            return false
        }
    }
    
    public func isEnglishEntry() -> Bool {
        if let firstLetterOfWord = word.first, firstLetterOfWord.isLetter {
            return isEnglishLetter(letter: String(firstLetterOfWord))
        }
        return false
    }
    
    public func isBulgarianEntry() -> Bool {
        if let firstLetterOfWord = word.first, firstLetterOfWord.isLetter {
            return isBulgarianLetter(letter: String(firstLetterOfWord))
        }
        return false
    }
    
}
