//
//  OptionsSingleton.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 10.02.22.
//

import Foundation
class OptionsManager {
    
    static let shared = OptionsManager()
    
    var suggestionsToBeShownAmount: Int = 10
    
    var shouldTranslateOnEachKeyStroke: Bool = true
    
    var isMultitapTextingOn: Bool = false
    
    init(){
        suggestionsToBeShownAmount = 10
        shouldTranslateOnEachKeyStroke = true
        isMultitapTextingOn = false
    }
    
    func changeSuggestionsAmount(toSuggestionsAmount suggestionsAmount: Int) {
        suggestionsToBeShownAmount = suggestionsAmount
    }
    
    func toggleTranslateOnEachKeyStroke() {
        shouldTranslateOnEachKeyStroke.toggle()
    }
    
    func toggleMultiTapTexting() {
        isMultitapTextingOn.toggle()
    }
    
    func setMultiTapTexting(to booleanValue: Bool) {
        isMultitapTextingOn = booleanValue
    }
}
