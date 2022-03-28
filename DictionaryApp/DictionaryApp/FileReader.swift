//
//  FileReader.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 7.02.22.
//

import Foundation

class FileReader {

    let wordTag = "@"
    var content: String = ""

    init() {
        content = ""
    }
    
    init?(filename: String) {
        if let filePath = Bundle.main.path(forResource: filename, ofType: ""), let dataOfFile = FileManager.default.contents(atPath: filePath), let probableContent = String(data: dataOfFile, encoding: String.Encoding.utf8) {
            self.content = probableContent
        } else {
            return nil
        }
    }
    
    var entries: [String] {
        let indexAfterSeparator = self.content.index(self.content.startIndex, offsetBy: 1)
        let rangeOfInterest = indexAfterSeparator..<self.content.endIndex
        let contentWithoutFirstSeparator = String(self.content[rangeOfInterest])
        let entries = contentWithoutFirstSeparator.components(separatedBy: wordTag)
        return entries
    }
    
    var dictionaryEntries: [DictionaryEntry] {
        let result = self.entries.map {
            return DictionaryEntry(tokenAsString: $0)
        }
        return result
    }
    
    var words: [String] {
        self.dictionaryEntries.map { $0.word }
    }
    
    func doesTrieExist(t9TrieFilename: String) -> Bool {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cachesDirectoryUrl = urls[0]
        
        // TODO: decide what extension
        let fileUrl = cachesDirectoryUrl.appendingPathComponent(t9TrieFilename)
                
        let filePath = fileUrl.path
        
        return fileManager.fileExists(atPath: filePath)
    }
    
    func createTrie() -> T9Trie {
               
        let t9Trie = T9Trie()
        
        for word in words {
            t9Trie.insertWord(word: word)
        }
        
        return t9Trie
    }
    
    func encodeAndCacheTrie(t9Trie: T9Trie, t9TrieFilename: String) {
        if !doesTrieExist(t9TrieFilename: t9TrieFilename) {
            let fileManager = FileManager.default
            let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            let cachesDirectoryUrl = urls[0]
            // TODO: decide what extension
            let fileUrl = cachesDirectoryUrl.appendingPathComponent(t9TrieFilename)
            let filePath = fileUrl.path
            
            let encoder = JSONEncoder()
            
            do {
                let data = try encoder.encode(t9Trie)
                try data.write(to: fileUrl)
                print("File \(filePath) created")
            } catch {
                print(error)
            }
        }
    }
    
    private func isLetterFromAlphabet(letter: String) -> Bool {
        guard let uniCode = UnicodeScalar(letter) else { return false }
        
        switch uniCode {
        case "A" ... "Z":
            return true
        case "А" ... "Я":
            return true
        default:
            return false
        }
    }
    
    func entriesStartingWithLetter(letter: String) -> [DictionaryEntry] {
        if (isLetterFromAlphabet(letter: letter)) {
            return dictionaryEntries.filter{ $0.word.hasPrefix(letter) }
        } else {
            return [DictionaryEntry]()
        }
    }
    
    func createFileForLetter(letter: String) {
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cachesDirectoryUrl = urls[0]
        
        // TODO: decide what extension
        let fileUrl = cachesDirectoryUrl.appendingPathComponent(letter)
        //print(fileUrl.absoluteString)
        
        let filePath = fileUrl.path
        //print(filePath)
            
        let entriesForLetter = entriesStartingWithLetter(letter: letter)
        
        let encoder = JSONEncoder()
        
        if !fileManager.fileExists(atPath: filePath) {
            do {
                let data = try encoder.encode(entriesForLetter)
                try data.write(to: fileUrl)
                print("File \(filePath) created")
            } catch {
                print(error)
            }
        } else {
            print("File \(filePath) already exists")
        }
    }
}
