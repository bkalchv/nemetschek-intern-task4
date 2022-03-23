//
//  T9TrieWord.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 23.03.22.
//

import Foundation

class T9TrieWord: Equatable, CustomStringConvertible, Hashable {
    
    var stringValue: String
    var frequenceOfUsage: UInt
    
    init(withValue value: String, withFrequenceOfUsage frequence: UInt) {
        self.stringValue = value
        self.frequenceOfUsage = frequence
    }
    
    var description: String {
        return "[\(stringValue)] : \(frequenceOfUsage)"
    }
    
    static func == (lhs: T9TrieWord, rhs: T9TrieWord) -> Bool {
        return lhs.stringValue == rhs.stringValue
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
    }
}
