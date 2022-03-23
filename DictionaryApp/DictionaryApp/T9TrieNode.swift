//
//  TrieNode.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 21.03.22.
//

import Foundation


extension CharacterSet {
    func containsUnicodeScalars(of character: Character) -> Bool {
        return character.unicodeScalars.allSatisfy(contains(_:))
    }
}

class T9TrieNode {
    
    static private let allowedCharacters = CharacterSet.init(charactersIn: "23456789#")
    
    var value: Character?
    var children: [Character: T9TrieNode] = [:]
    var isEndOfWord = false;
    var suggestedWords: [T9TrieWord] = []
    
    init?(value: Character? = nil) {
        if let value = value, T9TrieNode.allowedCharacters.containsUnicodeScalars(of: value) {
            self.value = value
        } else if value == T9Trie.T9TRIE_ROOT_VALUE {
            self.value = value
        } else {
            return nil
        }
    }
    
    func addToChildren(childValue: Character) {
        guard T9TrieNode.allowedCharacters.containsUnicodeScalars(of: childValue) else { return }
        guard children[childValue] == nil else { return }
        children[childValue] = T9TrieNode(value: childValue)
    }
    
    func addWordSuggestionIfNotPresent(forWord word: T9TrieWord) -> Bool {
        if suggestedWords.contains(word) {
           return false
        } else {
            suggestedWords.append(word)
            suggestedWords.sort(by: {$0.frequenceOfUsage > $1.frequenceOfUsage}) // TODO: Maybe fix by implementing a Sorted set
            return true
        }
    }
    
    func increaseFrequenceOfUsageOfWord(ofWord word: T9TrieWord) {
        if let suggestedWord = suggestedWords.first(where: {$0.stringValue == word.stringValue}) {
            suggestedWord.frequenceOfUsage += 1
        }
    }
}
