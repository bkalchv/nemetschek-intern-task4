//
//  TrieNode.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 21.03.22.
//

import Foundation


extension CharacterSet {
    func containsUnicodeScalars(of string: String) -> Bool {
        return string.unicodeScalars.allSatisfy(contains(_:))
    }
}

class T9TrieNode : Codable {
    
    static private var allowedCharactersString = "23456789#"
    static private var allowedCharactersSet = CharacterSet.init(charactersIn: allowedCharactersString)
    
    var value: String
    var children: [String: T9TrieNode] = [:]
    var isEndOfWord: Bool = false
    var suggestedWords: [T9TrieWord] = []
    
    private enum CodingKeys: String, CodingKey {
        case value
        case children
        case isEndOfWord
        case suggestedWords
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(String.self, forKey: CodingKeys.value)
        self.children = try container.decode([String : T9TrieNode].self, forKey: CodingKeys.children)
        self.isEndOfWord = try container.decode(Bool.self, forKey: CodingKeys.isEndOfWord)
        self.suggestedWords = try container.decode([T9TrieWord].self, forKey: CodingKeys.suggestedWords)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.value, forKey: CodingKeys.value)
        try container.encode(self.children, forKey: CodingKeys.children)
        try container.encode(self.isEndOfWord, forKey: CodingKeys.isEndOfWord)
        try container.encode(self.suggestedWords, forKey: CodingKeys.suggestedWords)

    }
    
    init?(value: String) {
        if T9TrieNode.allowedCharactersSet.containsUnicodeScalars(of: value) {
            self.value = value
        } else if value == T9Trie.T9TRIE_ROOT_VALUE {
            self.value = value
        } else {
            return nil
        }
    }
    
    func addToChildren(childValue: String) {
        guard T9TrieNode.allowedCharactersSet.containsUnicodeScalars(of: childValue) else { return }
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
        if let suggestedWord = suggestedWords.first(where: {$0.value == word.value}) {
            suggestedWord.frequenceOfUsage += 1
        }
    }
}
