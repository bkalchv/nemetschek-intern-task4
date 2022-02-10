//
//  SearchEngine.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 8.02.22.
//

import Foundation

class SearchEngine {
    
    var letterToEntries: [String : [DictionaryEntry]] = [String : [DictionaryEntry]]()
    
    func decodeFileForLetter(letter: String) -> [DictionaryEntry] {
        
        // TODO: ask - should there be a check for the letter itself
        // or can we rely on the fact we call the function once we are sure that the
        // argument is a letter?
        
        var result = [DictionaryEntry]()

        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cachesDirectoryUrl = urls[0]

        let fileUrl = cachesDirectoryUrl.appendingPathComponent(letter)
        //print(fileUrl.absoluteString)

        let filePath = fileUrl.path

        if fileManager.fileExists(atPath: filePath) {
            do {
                let data = try Data(contentsOf: fileUrl)
                let decoder = JSONDecoder()
                result = try decoder.decode([DictionaryEntry].self, from: data)
                print("DictionaryEntries at \(filePath) read.")
                //print(dictionaryTokens)
            } catch {
                print(error)
            }
        } else {
            print("File \(filePath) doesn't exist")
        }

        return result
    }

    func doesKeyExistInWordsDictionary(key: String) -> Bool {
        return letterToEntries.keys.contains(key)
    }

    func containsWordsWithPrefix(withDictionaryEntriesArray dictionaryEntriesArray: [DictionaryEntry], prefix: String) -> Bool {
        let dictionaryEntriesWithPrefix = dictionaryEntriesArray.filter( {return $0.word.hasPrefix(prefix)} )
        return !dictionaryEntriesWithPrefix.isEmpty
    }

    func findLongestPrefixInDictionaryEntries(ofWord word: String) -> String {
        if let firstLetterOfWord = word.first, firstLetterOfWord.isLetter {
            let firstLetterOfWordsAsUppercasedString = firstLetterOfWord.uppercased()
            if let entries = letterToEntries[firstLetterOfWordsAsUppercasedString] {
                
                for backwardIndex in (1...word.count).reversed() {
                    let currentPrefix = String(word.prefix(backwardIndex))
                    if containsWordsWithPrefix(withDictionaryEntriesArray: entries, prefix: currentPrefix) {
                        return currentPrefix
                    }
                }
                return firstLetterOfWordsAsUppercasedString
            }
        }
        
        return ""
    }
    
    // TODO: optional nescesarry?
    func findClosestMatchInDictionaryEntries(toInput input: String) -> DictionaryEntry? {
        
        if let firstLetterOfInput = input.first, firstLetterOfInput.isLetter {
            let firstLetterOfInputAsUppercasedString = firstLetterOfInput.uppercased()
            if let entries = letterToEntries[firstLetterOfInputAsUppercasedString]{
                let longestPrefix = findLongestPrefixInDictionaryEntries(ofWord: input)
                let dictionaryEntriesWithLongestPrefix = entries.filter( { return $0.word.hasPrefix(longestPrefix)} )
                if let first = dictionaryEntriesWithLongestPrefix.first { return first }
            }
        }
    
        return nil
    }
    
    func findFollowingMatchesInDictionaryEntries(amountOfMatches: Int ,toClosestMatch closestMatch: DictionaryEntry) -> [DictionaryEntry] {
        
        if let firstLetterOfClosestMatch = closestMatch.word.first?.uppercased(), let entries = letterToEntries[firstLetterOfClosestMatch] {
            let closestMatchIndex = entries.firstIndex(where: {return $0.word == closestMatch.word})
            return Array(entries[closestMatchIndex!...(closestMatchIndex! + amountOfMatches)]) //
        }
        
        return [DictionaryEntry]()
    }
}
