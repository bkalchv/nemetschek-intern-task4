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
    //TODO: what about that? var exceedingLongestValidPrefix = false
    var selectedCellIndexPath: IndexPath? = nil
    let selectedCellHeight = 200.0
    let unselectedCellHeight = 50.0
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let searchBarText = searchBar.text, !searchBarText.isEmpty {
            
            if !tableData.isEmpty && tableData.count <= OptionsManager.shared.suggestionsToBeShown {
                tableData = searchEngine.findFollowingMatchesInDictionaryEntries(amountOfMatches: OptionsManager.shared.suggestionsToBeShown, toClosestMatch: tableData[0])
            }
            
            tableData = Array(tableData[0..<OptionsManager.shared.suggestionsToBeShown])
            tableView.reloadData()
        }
        
        if let selectedRowIndexPath = self.selectedCellIndexPath, let cell = tableView.cellForRow(at: selectedRowIndexPath) as? ExpandableTableViewCell  {
            cell.descriptionView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        let cellNib = UINib(nibName: "ExpandableTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "ExpandableCell")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        if !OptionsManager.shared.translateOnEachKeyStroke, let searchBarText = searchBar.text, !searchBarText.isEmpty {
            
            deselectPreviouslySelectedCell()
            selectedCellIndexPath = nil
            
            let firstLetterOfSearchTextAsUppercasedString = searchBarText.first!.uppercased()
            if !searchEngine.doesKeyExistInWordsDictionary(key: firstLetterOfSearchTextAsUppercasedString) {
                searchEngine.letterToEntries[firstLetterOfSearchTextAsUppercasedString] = searchEngine.decodeFileForLetter(letter: firstLetterOfSearchTextAsUppercasedString) // loads words in wordsDictionary
            }
            
            if let closestMatch: DictionaryEntry = searchEngine.findClosestMatchInDictionaryEntries(toInput: searchBarText.uppercased()) {
                tableData = searchEngine.findFollowingMatchesInDictionaryEntries(amountOfMatches: OptionsManager.shared.suggestionsToBeShown, toClosestMatch: closestMatch)
            } else {
                print("NoClosestMatchNotFound")
            }
            
            tableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
        if OptionsManager.shared.translateOnEachKeyStroke, !searchText.isEmpty, let firstLetterOfSearchText = searchText.first, firstLetterOfSearchText.isLetter {
            
            deselectPreviouslySelectedCell()
            selectedCellIndexPath = nil
            
            let firstLetterOfSearchTextAsUppercasedString = firstLetterOfSearchText.uppercased()
            if !searchEngine.doesKeyExistInWordsDictionary(key: firstLetterOfSearchTextAsUppercasedString) {
                searchEngine.letterToEntries[firstLetterOfSearchTextAsUppercasedString] = searchEngine.decodeFileForLetter(letter: firstLetterOfSearchTextAsUppercasedString) // loads words in letterToEntries dictionary
            }

            if let closestMatch: DictionaryEntry = searchEngine.findClosestMatchInDictionaryEntries(toInput: searchText.uppercased()) {
                
                tableData = searchEngine.findFollowingMatchesInDictionaryEntries(amountOfMatches: OptionsManager.shared.suggestionsToBeShown, toClosestMatch: closestMatch)
                
                tableView.reloadData()
            } else {
                print("NoClosestMatchFound")
            }
        } else {
            tableData = [DictionaryEntry]()
            tableView.reloadData()
        }
    }


    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.tableData.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ExpandableTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ExpandableCell", for: indexPath) as! ExpandableTableViewCell
        
        let entry: DictionaryEntry = self.tableData[indexPath.row]
        
        cell.wordLabel.text = entry.word
        cell.translationTextView.text = entry.translation

        //Configure the cell...

        return cell
    }
    
    func deselectPreviouslySelectedCell() {
        if let selectedCellIndexPath = selectedCellIndexPath, let previouslySelectedCell = tableView.cellForRow(at: selectedCellIndexPath) as? ExpandableTableViewCell {
            tableView.deselectRow(at: selectedCellIndexPath, animated: true)
            UIView.animate(withDuration: 0.3)  { // TODO: Hacky?
                previouslySelectedCell.descriptionView.isHidden.toggle()
            }
        }
    }
    
    func presentTranslationViewController(forCell cell: ExpandableTableViewCell) {
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
        
        if let cell = tableView.cellForRow(at: indexPath) as? ExpandableTableViewCell {
            
            if selectedCellIndexPath == indexPath {
                if !cell.descriptionView.isHidden {
                    presentTranslationViewController(forCell: cell)
                }
                selectedCellIndexPath = nil
            } else {
                deselectPreviouslySelectedCell()
                selectedCellIndexPath = indexPath
            }
            
            tableView.beginUpdates()
            
            UIView.animate(withDuration: 0.3) { // TODO: Hacky? (increase duration to see what's up) Ask how to chain all the animations the way you imagine them
                cell.descriptionView.isHidden.toggle()
            }
            
            tableView.endUpdates()
            
            if (selectedCellIndexPath != nil) {
                tableView.scrollToRow(at: selectedCellIndexPath!, at: .top, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectedCellIndexPath == indexPath {
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
