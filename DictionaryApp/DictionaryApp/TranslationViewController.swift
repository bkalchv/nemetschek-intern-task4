//
//  ViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 27.01.22.
//

import UIKit

class TranslationViewController: UIViewController {

    var word: String = ""
    var translation: String = ""
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translationTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //searchBar.delegate = self
        
        wordLabel.text = word
        translationTextField.text = translation
    }
}
