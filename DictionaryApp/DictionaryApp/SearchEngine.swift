//
//  SearchEngine.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 8.02.22.
//

import Foundation

class SearchEngine {
    
    var letterToEntries: [String : [DictionaryEntry]] = [String : [DictionaryEntry]]()
    let languageUnicodeRanges = [Unicode.Scalar("A").value...Unicode.Scalar("Z").value, Unicode.Scalar("А").value...Unicode.Scalar("Я").value]
    
    func chooseRandomLanguage() -> ClosedRange<UInt32> {
        let randomLanguageRangeIndex = Int.random(in: 0..<languageUnicodeRanges.count)
        return languageUnicodeRanges[randomLanguageRangeIndex]
    }
    
    func randomLetterUnicode(from languageRange: ClosedRange<UInt32>) -> UInt32 {
        var randomLetterUnicode = UInt32.random(in: languageRange)
        
        while randomLetterUnicode == Unicode.Scalar("Э").value || randomLetterUnicode == Unicode.Scalar("Ы").value {
            randomLetterUnicode = UInt32.random(in: languageRange)
        }
        
        return randomLetterUnicode
    }
    
    func randomDictionaryEntry() -> DictionaryEntry {
        let randomLanguageRange = chooseRandomLanguage()
        let randomLetterUnicode = randomLetterUnicode(from: randomLanguageRange)
        let randomLetterUnicodeScalar = Unicode.Scalar(randomLetterUnicode)!
        let randomLetterUppercased = String(randomLetterUnicodeScalar)
        loadEntriesForLetterIfNeeded(letter: randomLetterUppercased)
        return letterToEntries[randomLetterUppercased]!.randomElement()!
    }
    
    func decodeFileForLetter(letter: String) -> [DictionaryEntry] {
        
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
    
    func loadEntriesForLetterIfNeeded(letter: String) {
        let firstLetterOfSearchTextAsUppercasedString = letter.uppercased()
        if !doesKeyExistInWordsDictionary(key: firstLetterOfSearchTextAsUppercasedString) {
            letterToEntries[firstLetterOfSearchTextAsUppercasedString] = decodeFileForLetter(letter: firstLetterOfSearchTextAsUppercasedString) // loads words in letterToEntries dictionary
        }
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
    
    func findSuggestionEntries(amountOfDesiredSuggestionEntries: Int, forDictionaryEntry closestMatch: DictionaryEntry) -> [DictionaryEntry] {
        
        if let firstLetterOfClosestMatch = closestMatch.word.first?.uppercased(), let entriesForLetter = letterToEntries[firstLetterOfClosestMatch], let closestMatchIndex = entriesForLetter.firstIndex(where: {return $0.word == closestMatch.word}) {
            
            let amountOfAvailableSuggestionEntries: Int = entriesForLetter.count - (closestMatchIndex + 1)
            
            if amountOfDesiredSuggestionEntries < amountOfAvailableSuggestionEntries {
                return Array(entriesForLetter[closestMatchIndex..<(closestMatchIndex + amountOfDesiredSuggestionEntries)])
            } else {
                
                OptionsManager.shared.changeSuggestionsAmount(toSuggestionsAmount: amountOfAvailableSuggestionEntries)
                
                if amountOfAvailableSuggestionEntries == 1 {
                    return [closestMatch]
                }
                
                return Array(entriesForLetter[closestMatchIndex..<(entriesForLetter.count)])
            }
        }
        
        return [DictionaryEntry]()
    }
    
}
