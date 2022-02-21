//
//  WordOfTheDayView.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 18.02.22.
//

import Foundation
import UIKit

protocol WordOfTheDayViewDelegate: AnyObject {
    func collapseView()
}

class WordOfTheDayView : UIView {
    
    weak var delegate: WordOfTheDayViewDelegate?
    @IBOutlet weak var labelWordOfTheDay: UILabel!
    @IBOutlet weak var textViewTranslation: UITextView!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBAction func onButtonCloseClick(_ sender: Any) {
        delegate?.collapseView()
    }
}
