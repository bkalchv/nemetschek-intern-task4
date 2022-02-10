//
//  FileReader.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 7.02.22.
//

import Foundation

let pathToResoruces = "/Users/bkalchev/MyPlayground2.playground/Resources"

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
    
    var tokens: [DictionaryEntry] {
        let result = self.entries.map {
            return DictionaryEntry(tokenAsString: $0)
        }
        return result
    }
    
    private func isLetterFromAlphabet(letter: String) -> Bool {
        guard let uniCode = UnicodeScalar(letter) else { return false }
        
        switch uniCode {
        case "A" ... "Z":
            return true
        default:
            return false
        }
    }
    
    func entriesStartingWithLetter(letter: String) -> [DictionaryEntry] {
        if (isLetterFromAlphabet(letter: letter)) {
            return tokens.filter{ $0.word.hasPrefix(letter) }
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
            
        let tokensForLetter = entriesStartingWithLetter(letter: letter)
        
        let encoder = JSONEncoder()
        
        if !fileManager.fileExists(atPath: filePath) {
            do {
                let data = try encoder.encode(tokensForLetter)
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
