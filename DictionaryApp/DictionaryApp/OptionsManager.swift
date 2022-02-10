//
//  OptionsSingleton.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 10.02.22.
//

import Foundation
class OptionsManager {
    
    static let shared = OptionsManager()
    
    var suggestionsToBeShown: Int = 10
    
    var translateOnEachKeyStroke: Bool = true
    
    init(){
        suggestionsToBeShown = 10
        translateOnEachKeyStroke = true
    }
    
    func changeSuggestionsAmount(toSuggestionsAmount suggestionsAmount: Int) {
        suggestionsToBeShown = suggestionsAmount
    }
    
    func changeTranslateOnEachKeyStroke() {
        translateOnEachKeyStroke = !translateOnEachKeyStroke
    }
}
