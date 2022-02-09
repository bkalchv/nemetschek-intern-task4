//
//  SearchEngine.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 8.02.22.
//

import Foundation

class SearchEngine {
    
    var wordsDictionary: [String : [DictionaryToken]] = [String : [DictionaryToken]]()
    
    func decodeFileForLetter(letter: String) -> [DictionaryToken] {
        
        // TODO: ask - should there be a check for the letter itself
        // or can we rely on the fact we call the function once we are sure that the
        // argument is a letter?
        
        var result = [DictionaryToken]()

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
                result = try decoder.decode([DictionaryToken].self, from: data)
                print("DictionaryTokens at \(filePath) read.")
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
        return wordsDictionary.keys.contains(key)
    }

    func containsWordsWithPrefix(withDictionaryTokenArray dictionaryTokensArray: [DictionaryToken], prefix: String) -> Bool {
        let dictionaryTokensWithPrefix = dictionaryTokensArray.filter( {return $0.word.hasPrefix(prefix)} )
        return !dictionaryTokensWithPrefix.isEmpty
    }

    func findLongestPrefixInWordsDictionary(ofWord word: String) -> String? {

        if let firstLetterOfWord = word.first, firstLetterOfWord.isLetter {
            let firstLetterOfWordsAsUppercasedString = firstLetterOfWord.uppercased()
            if let words = wordsDictionary[firstLetterOfWordsAsUppercasedString] {
                var endIndex = word.endIndex
                var currentRangeOfInterest = word.startIndex..<endIndex
                var currentPrefix = String(word[currentRangeOfInterest])

                while !containsWordsWithPrefix(withDictionaryTokenArray: words, prefix: currentPrefix) && endIndex != word.startIndex {
                    endIndex = word.index(before: endIndex)
                    currentRangeOfInterest = word.startIndex..<endIndex
                    currentPrefix = String(word[currentRangeOfInterest])
                }

                if (endIndex == word.startIndex) { return nil }

                return currentPrefix

            } else {
                return nil
                
            }
        } else {
            return nil
        }
    }

    func findClosestMatchInWordsDictionary(toInput input: String) -> DictionaryToken? {
        
        if let firstLetterOfInput = input.first, firstLetterOfInput.isLetter {
            let firstLetterOfInputAsUppercasedString = firstLetterOfInput.uppercased()
            if  firstLetterOfInputAsUppercasedString != "",
                let words = wordsDictionary[firstLetterOfInputAsUppercasedString],
                let longestPrefix = findLongestPrefixInWordsDictionary(ofWord: input) {

                    let dictionaryTokensWithCurrentPrefix = words.filter( { return $0.word.hasPrefix(longestPrefix)} )

                    if let first = dictionaryTokensWithCurrentPrefix.first { return first }
                }
        }
    
        return nil
    }
}
