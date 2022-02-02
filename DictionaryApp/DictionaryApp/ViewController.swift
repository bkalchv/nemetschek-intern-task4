//
//  ViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 27.01.22.
//

import UIKit

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex

        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }

        return indices
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var FindNextWordButton: UIButton!
    
    var content: String = ""
    var fromIndex: Int = 0
    var toIndex: Int = 0
    var indicesOfOccuranceOfSeparator: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let fileName = "helloWorldText"
        
        if let filePath = Bundle.main.url(forResource: fileName, withExtension: "txt") {
            do {
                self.content = try String(contentsOf: filePath)
                self.indicesOfOccuranceOfSeparator = content.indicesOf(string: "@")
                self.fromIndex = self.indicesOfOccuranceOfSeparator[0]
                self.toIndex = self.indicesOfOccuranceOfSeparator[1]
            } catch {
                print("An error occurred: \(error)")
            }
        }
    }
    
    func nextWord(string: String, from: Int, to: Int) -> String {
        let fromIndex = string.index(string.startIndex, offsetBy: from + 1)
        let toIndex = string.index(string.startIndex, offsetBy: to)
        // TODO: GUARD THAT SHIT
        let range = fromIndex..<toIndex
        
        return String(string[range])
    }
    
    @IBAction func onFindNextWordButtonClick(_ sender: Any) {
        
        print(nextWord(string: self.content, from: self.fromIndex, to: self.toIndex))
        
        self.fromIndex = self.toIndex
        
        guard let toIndexOldIndex = self.indicesOfOccuranceOfSeparator.firstIndex(of: self.toIndex), toIndexOldIndex + 1 < self.indicesOfOccuranceOfSeparator.count else {
            return
        }

        self.toIndex = self.indicesOfOccuranceOfSeparator[toIndexOldIndex + 1]
    }
}
