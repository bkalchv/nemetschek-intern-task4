//
//  T9Trie.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 21.03.22.
//

import Foundation

class T9Trie {
    
    static let T9TRIE_ROOT_VALUE: Character = " "
    
    private let root: T9TrieNode
    
    init() {
        root = T9TrieNode(value: T9Trie.T9TRIE_ROOT_VALUE)!
    }
    
    private func determineKeyPressed(forCharacter char: Character) -> Character? {
        if char == "A" || char == "B" || char == "C" { return "2" }
        if char == "D" || char == "E" || char == "F" { return "3" }
        if char == "G" || char == "H" || char == "I" { return "4" }
        if char == "J" || char == "K" || char == "L" { return "5" }
        if char == "M" || char == "N" || char == "O" { return "6" }
        if char == "P" || char == "Q" || char == "R" || char == "S" { return "7" }
        if char == "T" || char == "U" || char == "V" { return "8" }
        if char == "W" || char == "X" || char == "Y" || char == "Z" { return "9" }
        
        return nil
    }

    private func t9String(fromString string: String) -> String? {
        
        var t9String: String = ""
        
        for currentCharacter in string.uppercased() {
            if let keyPressed = determineKeyPressed(forCharacter: currentCharacter) {
                t9String.append(keyPressed)
            } else {
                return nil
            }
        }
        
        return t9String
    }
        
    func insertWord(word: String) {
        
        guard !word.isEmpty else { return }
        
        var currentNode = root
        
        if let wordAsT9String = t9String(fromString: word) {
            for keypressValue in wordAsT9String {
                if let child = currentNode.children[keypressValue] {
                    currentNode = child
                } else {
                    currentNode.addToChildren(childValue: keypressValue)
                    currentNode = currentNode.children[keypressValue]!
                }
            }
            currentNode.isEndOfWord = true
            let newWordSuggestionCandidate = T9TrieWord(withValue: word, withFrequenceOfUsage: 1)
            if !currentNode.addWordSuggestionIfNotPresent(forWord: newWordSuggestionCandidate) { currentNode.increaseFrequenceOfUsageOfWord(ofWord: newWordSuggestionCandidate) }
        }
    }
    
    func containsWord(word: String) -> Bool {
        
        if word.isEmpty { return true }
        
        var currentNode = root
        
        if let wordAsT9String = t9String(fromString: word) {
            for keypressValue in wordAsT9String {
                if let child = currentNode.children[keypressValue] {
                    currentNode = child
                } else {
                    return false
                }
            }
            
            return currentNode.suggestedWords.contains(where: {$0.stringValue == word})
        } else {
            return false
        }
    }
    
    func hasSuchPath(forT9String t9String: String) -> Bool {

        var currentNode = root

        for keypressValue in t9String {
            if let child = currentNode.children[keypressValue] {
                currentNode = child
            } else {
                return false
            }
        }
        
        return true
    }
    
    func wordSuggestions(forT9String t9String: String) ->[T9TrieWord]? {
        
        var currentNode = root

        for keypressValue in t9String {
            if let child = currentNode.children[keypressValue] {
                currentNode = child
            } else {
                return nil
            }
        }
        
        if !currentNode.isEndOfWord { return nil }
        
        return currentNode.suggestedWords
    }
}
