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
    var suggestedT9Words: [T9TrieWord] = []
    
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
        self.suggestedT9Words = try container.decode([T9TrieWord].self, forKey: CodingKeys.suggestedWords)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.value, forKey: CodingKeys.value)
        try container.encode(self.children, forKey: CodingKeys.children)
        try container.encode(self.isEndOfWord, forKey: CodingKeys.isEndOfWord)
        try container.encode(self.suggestedT9Words, forKey: CodingKeys.suggestedWords)

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
    
    func containsT9WordInSuggestions(forT9Word t9Word: T9TrieWord) -> Bool {
        return suggestedT9Words.contains(t9Word)
    }
    
    func insertT9WordInSuggestions(forT9Word t9Word: T9TrieWord) {
        suggestedT9Words.append(t9Word)
        suggestedT9Words.sort(by: {$0.frequenceOfUsage > $1.frequenceOfUsage})
    }
    
    func increaseFrequenceOfUsageOfT9Word(ofT9Word word: T9TrieWord) {
        if let suggestedWord = suggestedT9Words.first(where: {$0.value == word.value}) {
            suggestedWord.frequenceOfUsage += 1
        }
    }
    
    func setFrequenceOfUsageOfWord(ofWord word: T9TrieWord, frequenceOfUsage: UInt) {
        if let suggestedWord = suggestedT9Words.first(where: {$0.value == word.value}) {
            suggestedWord.frequenceOfUsage = frequenceOfUsage
        }
    }
    
}
