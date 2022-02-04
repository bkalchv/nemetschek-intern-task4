//
//  FileReader.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 3.02.22.
//

import UIKit

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex

        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
}

class FileReader {
    var content: String = ""
    var fromIndex: Int = 0
    var toIndex: Int = 0
    var indicesOfOccuranceOfSeparator: [Int] = []
    let currentSeparator: String = "@"

//    var content: String
//    var fromIndex: Int
//    var toIndex: Int
//    var indicesOfOccuranceOfSeparator: [Int]
//    let currentSeparator: String = "@"
    
    convenience init?(filename: String) {
        self.init()
        if let filePath = Bundle.main.url(forResource: filename, withExtension: "txt") {
            do {
                
                let probableContent = try String(contentsOf: filePath)
            
                guard !(probableContent.isEmpty), probableContent.hasPrefix(currentSeparator), probableContent.hasSuffix(currentSeparator.appending("\n")) else { return nil }
                
                self.content = probableContent
                
                guard content.indicesOf(string: currentSeparator).count > 1 else { return nil }
            
                self.indicesOfOccuranceOfSeparator = content.indicesOf(string: currentSeparator)
                self.fromIndex = self.indicesOfOccuranceOfSeparator[0] // first occurance of separator
                self.toIndex = self.indicesOfOccuranceOfSeparator[1] // second occurance of separator
            } catch {
                print("An error occurred: \(error)")
            }
        } else {
            print("Bad FilePath")
        }
    }
    
    private func updateIndices() {
        
        self.fromIndex = self.toIndex
        
        guard let toIndexOldIndex = self.indicesOfOccuranceOfSeparator.firstIndex(of: self.toIndex), toIndexOldIndex + 1 < self.indicesOfOccuranceOfSeparator.count else {
            return
        }

        self.toIndex = self.indicesOfOccuranceOfSeparator[toIndexOldIndex + 1]
    }
    
    private func nextWord(from: Int, to: Int) -> String? {
        
        if (from == self.indicesOfOccuranceOfSeparator.last) {
            return nil
        }
            
        let fromIndex = self.content.index(self.content.startIndex, offsetBy: from + currentSeparator.count)
        let toIndex = self.content.index(self.content.startIndex, offsetBy: to)
        
        let range = fromIndex..<toIndex
        
        self.updateIndices()
        
        return String(self.content[range]) // returns a substring
    }
    
    func performNextWordQuery() -> String? {
        return self.nextWord(from: self.fromIndex, to: self.toIndex)
    }
}

