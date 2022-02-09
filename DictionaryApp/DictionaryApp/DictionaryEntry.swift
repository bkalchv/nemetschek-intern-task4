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
    
    init(_ keyWord: String,_ valueTranslation: String) {
        word = keyWord
        translation = valueTranslation
    }
    
    init(tokenAsString: String) {
        let readWord        = readWord(fromTokenAsString: tokenAsString)
        let readTranslation = readTranslation(fromTokenAsString: tokenAsString)
        word = readWord
        translation = readTranslation
    }
}
