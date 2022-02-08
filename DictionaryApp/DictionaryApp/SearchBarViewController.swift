//
//  ViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 27.01.22.
//

import UIKit

class SearchBarViewController: UIViewController, UISearchBarDelegate {

    var wordsDictionary: [String : [DictionaryToken]] = [String : [DictionaryToken]]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var DecodeAndPrintA: UIButton!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translationTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        wordLabel.text = ""
        translationTextField.text = ""
        translationTextField.isEditable = false
        translationTextField.isSelectable = false
        DecodeAndPrintA.isHidden = true
    }
    
    func decodeFileForLetter(letter: String) -> [DictionaryToken] {
        
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
    
    // TODO: redundant (had testing purposes)
    @IBAction func onDecodeAndPrintAButtonClick(_ sender: Any) {
        let tokens: [DictionaryToken] = decodeFileForLetter(letter: "A")
        print(tokens)
    }
    
    func firstLetterAsString(ofInput input: String) -> String {
        var result = ""
        
        if let firstChar = input.first?.description {
            result = firstChar
        }
        
        return result
    }
    
    func doesKeyExistInWordsDictionary(withKey key: String) -> Bool {
        return wordsDictionary.keys.contains(key)
    }
    
    func containsWordsWithPrefix(withDictionaryTokenArray dictionaryTokensArray: [DictionaryToken], withPrefix prefix: String) -> Bool {
        let dictionaryTokensWithPrefix = dictionaryTokensArray.filter( {return $0.word.hasPrefix(prefix)} )
        return !dictionaryTokensWithPrefix.isEmpty
    }
    
    func findLongestPrefixInWordsDictionary(ofWord word: String) -> String? {
        
        let firstLetterOfWord = firstLetterAsString(ofInput: word)
        
        if firstLetterOfWord != "", let words = wordsDictionary[firstLetterOfWord] {
            var endIndex = word.endIndex
            var currentRangeOfInterest = word.startIndex..<endIndex
            var currentPrefix = String(word[currentRangeOfInterest])
            
            while !containsWordsWithPrefix(withDictionaryTokenArray: words, withPrefix: currentPrefix) && endIndex != word.startIndex {
                endIndex = word.index(before: endIndex)
                currentRangeOfInterest = word.startIndex..<endIndex
                currentPrefix = String(word[currentRangeOfInterest])
            }
            
            if (endIndex == word.startIndex) { return nil }
            
            return currentPrefix
            
        } else { return nil }

    }
    
    func findClosestMatchInWordsDictionary(toInput input: String) -> DictionaryToken? {
        let firstLetterOfInput = firstLetterAsString(ofInput: input)
        if  firstLetterOfInput != "",
            let words = wordsDictionary[firstLetterOfInput],
            let longestPrefix = findLongestPrefixInWordsDictionary(ofWord: input) {
            
                let dictionaryTokensWithCurrentPrefix = words.filter( { return $0.word.hasPrefix(longestPrefix)} )
               
                if let first = dictionaryTokensWithCurrentPrefix.first { return first }
            }
        
        return nil
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            let firstLetterOfSearchText = firstLetterAsString(ofInput: searchText)
            if !doesKeyExistInWordsDictionary(withKey: firstLetterOfSearchText) {
               wordsDictionary[firstLetterOfSearchText] = decodeFileForLetter(letter: firstLetterOfSearchText) // loads words in wordsDictionary
            }
            
            if let closestMatch: DictionaryToken = findClosestMatchInWordsDictionary(toInput: searchText.uppercased()) {
                //print(closestMatch)
                wordLabel.text = closestMatch.word
                translationTextField.text = closestMatch.translation
            } else {
                print("NoClosestMatchFound")
            }
        } else {
            wordLabel.text = ""
            translationTextField.text = ""
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchBarText = searchBar.text {
            
            if let closestMatch: DictionaryToken = findClosestMatchInWordsDictionary(toInput: searchBarText.uppercased()) {
                print(closestMatch)
                wordLabel.text = closestMatch.word
                translationTextField.text = closestMatch.translation
            } else {
                print("NoClosestMatchNotFound")
            }

        }
    }
    
}
