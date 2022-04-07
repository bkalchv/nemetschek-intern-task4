//
//  T9SuggestionsCollectionViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 7.04.22.
//

import UIKit
import NumberPad

extension String {
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height);

      let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

    return boundingBox.width;
    }
}

protocol SearchTableViewControllerDelegate: AnyObject {
    func updateSearchBarText(withText text: String) //TODO delete
    func hideT9SuggestionsContainerView()
    var  t9String: String { get }
}

private let reuseIdentifier = "T9CollectionViewCell"

class T9SuggestionsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, T9SuggestionsViewControllerDelegate {
    
    weak var searchTableVCDelegate: SearchTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = UIColor.tintColor
        collectionView.layer.cornerRadius = 10
        collectionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        let t9WordStrings = CustomSearchBar.T9SuggestionsDataSourceEN(forT9String: self.searchTableVCDelegate!.t9String)
        return t9WordStrings.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! T9CollectionViewCell
        
        let t9WordStrings = CustomSearchBar.T9SuggestionsDataSourceEN(forT9String: self.searchTableVCDelegate!.t9String)
        let suggestedString = t9WordStrings[indexPath.row]
        cell.suggestionLabel.text = suggestedString
        cell.suggestionLabel.textColor = UIColor.white
    
        // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.collectionView(self.collectionView, cellForItemAt: indexPath) as! T9CollectionViewCell
        let wordSuggestionInCell = cell.cellSuggestionAsString()
        
        CustomSearchBar.updateWeight(forWord: wordSuggestionInCell)
        
        // TODO: How to rework this?
        searchTableVCDelegate?.updateSearchBarText(withText: wordSuggestionInCell)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let t9WordStrings =  CustomSearchBar.T9SuggestionsDataSourceEN(forT9String: self.searchTableVCDelegate!.t9String)
        
        let currentSuggestion = t9WordStrings[indexPath.row]
        
        let width = currentSuggestion.width(withConstrainedHeight: 50, font: T9CollectionViewCell.suggestionLabelFont)
        
        return CGSize(width: width + 5, height: 50)
    }
    
    func searchBarTextWasChanged() {
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
