//
//  ViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 27.01.22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var SearchBar: UISearchBar!
    
    @IBOutlet weak var DecodeAndPrintA: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func decodePlistForLetter(letter: String) -> [DictionaryToken] {
        
        var result = [DictionaryToken]()
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cachesDirectoryUrl = urls[0]
        
        let fileUrl = cachesDirectoryUrl.appendingPathComponent(letter)
        //print(fileUrl.absoluteString)
        
        let filePath = fileUrl.path
        
        if fileManager.fileExists(atPath: filePath) {
            do {
                let data = try Data(contentsOf: fileUrl)
                let decoder = PropertyListDecoder()
                result = try decoder.decode([DictionaryToken].self, from: data)
                print("DictionaryTokens at \(filePath) read.")
                //print(dictionaryTokens)
            } catch {
                print(error)
            }
        } else {
            print("File \(filePath) doesn't exist")
        }
        
        return result
    }
    
    @IBAction func onDecodeAndPrintAButtonClick(_ sender: Any) {
        let tokens: [DictionaryToken] = decodePlistForLetter(letter: "A")
        print(tokens)
    }
    
}
