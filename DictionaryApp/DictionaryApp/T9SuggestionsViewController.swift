//
//  CollecitonViewTryOut.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 30.03.22.
//

import UIKit

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height);

      let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

    return boundingBox.width;
    }
}

protocol SearchTableViewControllerDelegate: AnyObject {
    func updateSearchBarText(withText text: String)
    func hideT9SuggestionsContainerView()
}

class T9SuggestionsViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, T9SuggestionsViewControllerDelegate {
    
    weak var searchTableVCDelegate: SearchTableViewControllerDelegate?
    @IBOutlet weak var collectionView: UICollectionView!
    private var ENt9Trie: T9Trie? = nil
    private var suggestions: [String] = [String]()
    
    override func viewDidLoad() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.tintColor
        collectionView.layer.cornerRadius = 10
        collectionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        ENt9Trie = decodeTrie(trieFilename: "T9Trie_EN")
        
        
        if let weightedWords = UserDefaults.standard.object(forKey: "weighted_words_EN") as? [String : UInt] {
            
            weightedWords.forEach {
                let word = $0.key
                let frequenceOfUsage = $0.value
                
                ENt9Trie?.insertWord(word: word, withFrequenceOfUsage: frequenceOfUsage)
            }
        }
        
// TODO: Decide where to initialize and update the weighted_words dictionary in UserDefaults
//        } else {
//            UserDefaults.standard.set([String : UInt](), forKey: "weighted_words_EN")
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "T9CollectionViewCell", for: indexPath) as! T9CollectionViewCell
            
        let t9WordSuggestionAsString = suggestions[indexPath.row]
        cell.suggestionLabel.text = t9WordSuggestionAsString
        cell.suggestionLabel.textColor = UIColor.white
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let currentSuggestion = suggestions[indexPath.row]
        
        let width = currentSuggestion.width(withConstrainedHeight: 50, font: T9CollectionViewCell.suggestionLabelFont)
        
        return CGSize(width: width + 5, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView(self.collectionView, cellForItemAt: indexPath) as! T9CollectionViewCell
        searchTableVCDelegate?.updateSearchBarText(withText: cell.cellSuggestionAsString())
    }
    
    func searchBarTextWasChanged(searchBarText: String) {
        
        if searchBarText.isEmpty {
            suggestions = [String]()
            collectionView.reloadData()
            //searchTableVCDelegate?.hideT9SuggestionsView()
            // TODO: hide container view
        }
        
        if let ENt9Trie = ENt9Trie, let searchBarTextAsT9String = ENt9Trie.t9String(fromString: searchBarText), let suggestionsForSearchBarText = ENt9Trie.wordSuggestions(forT9String: searchBarTextAsT9String)  {
            suggestions = suggestionsForSearchBarText.map{ $0.value }
            collectionView.reloadData()
        }
    }
    
    func decodeTrie(trieFilename: String) -> T9Trie? {
        
        var result: T9Trie? = nil

        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cachesDirectoryUrl = urls[0]

        let fileUrl = cachesDirectoryUrl.appendingPathComponent(trieFilename)
        //print(fileUrl.absoluteString)

        let filePath = fileUrl.path

        if fileManager.fileExists(atPath: filePath) {
            do {
                let data = try Data(contentsOf: fileUrl)
                let decoder = JSONDecoder()
                result = try decoder.decode(T9Trie.self, from: data)
                print("Trie at \(filePath) decoded.")
            } catch {
                print(error)
            }
        } else {
            print("File \(filePath) doesn't exist")
        }

        return result
    }
    
}
