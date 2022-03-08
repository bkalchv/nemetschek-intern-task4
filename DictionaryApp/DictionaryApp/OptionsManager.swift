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
    
    var multiTapTexting: Bool = false
    
    init(){
        suggestionsToBeShown = 10
        translateOnEachKeyStroke = true
        multiTapTexting = false
    }
    
    func changeSuggestionsAmount(toSuggestionsAmount suggestionsAmount: Int) {
        suggestionsToBeShown = suggestionsAmount
    }
    
    func toggleTranslateOnEachKeyStroke() {
        translateOnEachKeyStroke.toggle()
    }
    
    func toggleMultiTapTexting() {
        multiTapTexting.toggle()
    }
    
    func setMultiTapTexting(to booleanValue: Bool) {
        multiTapTexting = booleanValue
    }
}
