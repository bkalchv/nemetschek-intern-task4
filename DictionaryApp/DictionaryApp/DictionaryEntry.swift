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
}
