//
//  ViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 27.01.22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var FindNextWordButton: UIButton!

    let fileName = "helloWorldText"
    var fileReader: FileReader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.fileReader = FileReader(filename: fileName);
    }
    
    @IBAction func onFindNextWordButtonClick(_ sender: Any) {
        if let performedQuery = fileReader?.performNextWordQuery() {
            print(performedQuery)
        } else {
            print("Performed Query was nil.")
            print("Content between all separators most likely read.")
        }
    }
}
