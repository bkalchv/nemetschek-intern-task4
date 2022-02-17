//
//  SearchTableViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 10.02.22.
//

import UIKit

class SearchTableViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    var tableData = [DictionaryEntry]()
    var searchEngine = SearchEngine()
    var firstInputWithNoNewSuggestions = ""
    var firstAppearance = true
    var lastSelectedCellIndexPath: IndexPath? = nil
    let selectedCellHeight = 200.0
    let unselectedCellHeight = 50.0
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var stackViewVCContent: UIStackView!
    @IBOutlet weak var wordOfTheDayView: UIView!
    @IBOutlet weak var wordOfTheDayLabel: UILabel!
    @IBOutlet weak var wordOftheDayTextView: UITextView!
    @IBOutlet weak var wordOfTheDayCloseButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        if firstAppearance {
            
            if let randomDictionaryEntry = searchEngine.randomDictionaryEntry() {
                wordOfTheDayLabel.text = randomDictionaryEntry.word
                wordOftheDayTextView.text = randomDictionaryEntry.translation
            }
            
            self.firstAppearance = false
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let searchBarText = searchBar.text, !searchBarText.isEmpty {
            
            if !tableData.isEmpty && tableData.count <= OptionsManager.shared.suggestionsToBeShown {
                tableData = searchEngine.findFollowingEntriesInDictionaryEntries(amountOfFollowingEntries: OptionsManager.shared.suggestionsToBeShown, toClosestMatch: tableData[0])
            }
            
            tableData = Array(tableData[0..<OptionsManager.shared.suggestionsToBeShown])
            collapsePreviouslySelectedCellIfVisible()
            //selectedCellIndexPath = nil // TODO: when uncommented - a bug appears :eek:
            tableView.reloadData()
            
        }
        
        if let lastSelectedRowIndexPath = self.lastSelectedCellIndexPath, let cell = tableView.cellForRow(at: lastSelectedRowIndexPath) as? WordTableViewCell  {
            cell.translationView.isHidden = false
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        if !OptionsManager.shared.translateOnEachKeyStroke, let searchBarText = searchBar.text, !searchBarText.isEmpty {
            
            collapsePreviouslySelectedCellIfVisible()
            lastSelectedCellIndexPath = nil
            
            let firstLetterOfSearchTextAsUppercasedString = searchBarText.first!.uppercased()
            if !searchEngine.doesKeyExistInWordsDictionary(key: firstLetterOfSearchTextAsUppercasedString) {
                searchEngine.letterToEntries[firstLetterOfSearchTextAsUppercasedString] = searchEngine.decodeFileForLetter(letter: firstLetterOfSearchTextAsUppercasedString) // loads words in wordsDictionary
            }
            
            if let closestMatch: DictionaryEntry = searchEngine.findClosestMatchInDictionaryEntries(toInput: searchBarText.uppercased()) {
                tableData = searchEngine.findFollowingEntriesInDictionaryEntries(amountOfFollowingEntries: OptionsManager.shared.suggestionsToBeShown, toClosestMatch: closestMatch)
            } else {
                print("NoClosestMatchNotFound")
            }
            
            tableView.reloadData()
        }
    }
    
    func hideWordOfTheDayView() {
        UIView.animate(withDuration: 0.25, delay: 0.0, options:[], animations: {
            self.wordOfTheDayView.isHidden = true
            self.stackViewVCContent.removeArrangedSubview(self.wordOfTheDayView)
            self.stackViewVCContent.layoutIfNeeded()
        }, completion: { finished in
            if finished {
               
            }
        })
    }
    
    @IBAction func onWordOfTheDayViewCloseButtonClick(_ sender: Any) {
        hideWordOfTheDayView()
    }
    
    func areNewSuggestionEntriesPresent(suggestionEntries: [DictionaryEntry]) -> Bool {
        if suggestionEntries.count != tableData.count { return true }
        
        for entryIndex in 0..<suggestionEntries.count {
            if suggestionEntries[entryIndex].word != tableData[entryIndex].word { return true }
        }
        
        return false
    }
    
    func loadEntriesForLetterIfNeeded(letter: String) {
        searchEngine.loadEntriesForLetterIfNeeded(letter: letter)
    }
    
    func updateSuggestionsIfNeeded(for input: String) {
        if let closestMatch: DictionaryEntry = searchEngine.findClosestMatchInDictionaryEntries(toInput: input.uppercased()) {
            let followingSuggestionEntries = searchEngine.findFollowingEntriesInDictionaryEntries(amountOfFollowingEntries: OptionsManager.shared.suggestionsToBeShown, toClosestMatch: closestMatch)
            if !areNewSuggestionEntriesPresent(suggestionEntries: followingSuggestionEntries) { // CATCH THERE ARE NO NEW RESULTS
                self.firstInputWithNoNewSuggestions = input
            } else {
                tableData = followingSuggestionEntries
                tableView.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if OptionsManager.shared.translateOnEachKeyStroke, !searchText.isEmpty, let firstLetterOfSearchText = searchText.first, firstLetterOfSearchText.isLetter {
            
            if self.wordOfTheDayView.isDescendant(of: self.stackViewVCContent) {
                
                DispatchQueue.main.async { // UI updates on main thred
                    self.hideWordOfTheDayView()
                }
                DispatchQueue.main.async { // UI updates on main thred
                    if !self.firstInputWithNoNewSuggestions.isEmpty {
                        if searchText.hasPrefix(self.firstInputWithNoNewSuggestions) { // TODO: PAY ATTENTION TO ME, GEORGI
                            print("No new search query, because of me!")
                            return
                        } else {
                            self.firstInputWithNoNewSuggestions = ""
                        }
                    }
                    
                    self.collapsePreviouslySelectedCellIfVisible()
                    self.lastSelectedCellIndexPath = nil

                    self.loadEntriesForLetterIfNeeded(letter: String(firstLetterOfSearchText))
                    self.updateSuggestionsIfNeeded(for: searchText)
                }

            } else {
                if !firstInputWithNoNewSuggestions.isEmpty {
                    if searchText.hasPrefix(firstInputWithNoNewSuggestions) { // TODO: PAY ATTENTION TO ME, GEORGI
                        print("No new search query, because of me!")
                        return
                    } else {
                        firstInputWithNoNewSuggestions = ""
                    }
                }
                
                collapsePreviouslySelectedCellIfVisible()
                lastSelectedCellIndexPath = nil

                loadEntriesForLetterIfNeeded(letter: String(firstLetterOfSearchText))
                updateSuggestionsIfNeeded(for: searchText)
            }
        } else {
            tableData = [DictionaryEntry]()
            tableView.reloadData()
        }
    }


    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: WordTableViewCell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordTableViewCell
        
        let entry: DictionaryEntry = self.tableData[indexPath.row]
        
        cell.wordLabel.text = entry.word
        cell.translationTextView.text = entry.translation

        //Configure the cell...

        return cell
    }
    
    func collapsePreviouslySelectedCellIfVisible() {
        if let selectedCellIndexPath = lastSelectedCellIndexPath, let previouslySelectedCell = tableView.cellForRow(at: selectedCellIndexPath) as? WordTableViewCell {
            previouslySelectedCell.translationView.isHidden.toggle()
        }
    }
    
    func presentTranslationViewController(forCell cell: WordTableViewCell) {
        if let cellWord = cell.wordLabel.text {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let translationVC: TranslationViewController = storyboard.instantiateViewController(withIdentifier: "TranslationViewController") as! TranslationViewController
            translationVC.modalPresentationStyle = .fullScreen
            translationVC.word = cellWord
            translationVC.translation = cell.translationTextView.text
            self.navigationController?.pushViewController(translationVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? WordTableViewCell {
            
            if lastSelectedCellIndexPath == indexPath {
                if !cell.translationView.isHidden { // second click
                    presentTranslationViewController(forCell: cell)
                }
                lastSelectedCellIndexPath = nil
            } else {
                collapsePreviouslySelectedCellIfVisible()
                lastSelectedCellIndexPath = indexPath
            }
            
            tableView.beginUpdates()
            
            cell.translationView.isHidden.toggle()
            
            tableView.endUpdates()
            
            if (lastSelectedCellIndexPath != nil) {
                tableView.scrollToRow(at: lastSelectedCellIndexPath!, at: .top, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.lastSelectedCellIndexPath == indexPath {
            return selectedCellHeight
        }
        return unselectedCellHeight
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showTranslation" {
//            if let indexPath:IndexPath = self.tableView.indexPathForSelectedRow {
//                let translationVC: TranslationViewController = segue.destination as! TranslationViewController
//                let entry: DictionaryEntry = self.tableData[indexPath.row]
//                translationVC.word = entry.word
//                translationVC.translation = entry.translation
//            }
//        }
//    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
