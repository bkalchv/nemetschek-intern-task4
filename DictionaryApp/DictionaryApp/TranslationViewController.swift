//
//  ViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 27.01.22.
//

import UIKit

class TranslationViewController: UIViewController, UISearchBarDelegate {

    //var searchEngine: SearchEngine = SearchEngine()
    
    //@IBOutlet weak var searchBar: UISearchBar!
    var word: String = ""
    var translation: String = ""
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var translationTextField: UITextView!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //searchBar.delegate = self
        
        wordLabel.text = word
        translationTextField.text = translation
    }
    
    @IBAction func onBackButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
