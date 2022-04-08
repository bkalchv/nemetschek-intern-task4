//
//  WordOfTheDayView.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 18.02.22.
//

import Foundation
import UIKit

protocol FeelingOldViewDelegate: AnyObject {
    func hideFeelingOldView()
    func setStandardInput()
    func setT9PredictiveText()
    func setMultitapInput()
}

class FeelingOldView : UIView {
    
    weak var delegate: FeelingOldViewDelegate?
    @IBOutlet weak var buttonElderly: UIButton!
    @IBOutlet weak var buttonYouth: UIButton!
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBAction func onButtonCloseClick(_ sender: Any) {
        delegate?.hideFeelingOldView()
    }
    
    @IBAction func onButtonElderlyClick(_ sender: Any) {
        delegate?.setMultitapInput()
        //delegate?.setT9PredictiveText()
        delegate?.hideFeelingOldView()
    }
    
    @IBAction func onButtonYouthClick(_ sender: Any) {
        delegate?.setStandardInput()
        delegate?.hideFeelingOldView()
    }
    
    //TODO: Maybe add a t9 button
}
