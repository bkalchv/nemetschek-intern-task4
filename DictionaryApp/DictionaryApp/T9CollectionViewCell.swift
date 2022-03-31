//
//  T9CollectionViewCell.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 29.03.22.
//

import UIKit

class T9CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var suggestionLabel: UILabel!
    
    static let suggestionLabelFont:UIFont = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold);
    
    func configureSuggestionLabel(suggestion: String) {
        suggestionLabel.text = suggestion
    }
}
