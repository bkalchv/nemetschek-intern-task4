//
//  DirectoryToken.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 7.02.22.
//

import Foundation

class DictionaryToken : CustomStringConvertible, Codable {
    var word: String = ""
    var translation: String = ""
    
    var description: String {
        return "[\(word) : \(translation)]"
    }
    
    private func readWord(fromTokenAsString tokenAsString: String) -> String {
        if let firstOccuranceOfNewLine = tokenAsString.firstIndex(of: "\n") {
            let range = tokenAsString.startIndex..<firstOccuranceOfNewLine
            
            return String(tokenAsString[range])
        } else {
         return ""
        }
    }
    
    private func readTranslation(fromTokenAsString tokenAsString: String) -> String {
        if let firstOccuranceOfNewLine = tokenAsString.firstIndex(of: "\n") {
            let indexAfterNewLine = tokenAsString.index(after: firstOccuranceOfNewLine)
            let range = indexAfterNewLine..<tokenAsString.endIndex
            
            return String(tokenAsString[range])
        } else {
         return ""
        }
    }
    
    init(withWord: String, withTranslation: String) {
        word = withWord
        translation = withTranslation
    }
    
    init(withTokenAsString tokenAsString: String) {
        let readWord        = readWord(fromTokenAsString: tokenAsString)
        let readTranslation = readTranslation(fromTokenAsString: tokenAsString)
        word = readWord
        translation = readTranslation
    }
}
