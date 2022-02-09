//
//  ViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 27.01.22.
//

import UIKit

class SearchBarViewController: UIViewController, UISearchBarDelegate {

    var searchEngine: SearchEngine = SearchEngine()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translationTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        wordLabel.text = ""
        translationTextField.text = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty, let firstLetterOfSearchText = searchText.first, firstLetterOfSearchText.isLetter {
            // TODO: handle pasting
            // TODO: handle first letter not being capital letter
            // TODO: handle first not being a letter
            let firstLetterOfSearchTextAsUppercasedString = firstLetterOfSearchText.uppercased()
            if !searchEngine.doesKeyExistInWordsDictionary(key: firstLetterOfSearchTextAsUppercasedString) {
                searchEngine.wordsDictionary[firstLetterOfSearchTextAsUppercasedString] = searchEngine.decodeFileForLetter(letter: firstLetterOfSearchTextAsUppercasedString) // loads words in wordsDictionary
            }
            
            if let closestMatch: DictionaryEntry = searchEngine.findClosestMatchInWordsDictionary(toInput: searchText.uppercased()) {
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
            
            if let closestMatch: DictionaryEntry = searchEngine.findClosestMatchInWordsDictionary(toInput: searchBarText.uppercased()) {
                print(closestMatch)
                wordLabel.text = closestMatch.word
                translationTextField.text = closestMatch.translation
            } else {
                print("NoClosestMatchNotFound")
            }

        }
    }
    
}
