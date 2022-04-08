//
//  SearchTableViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 10.02.22.
//

import UIKit
import NumberPad
import Toast

protocol T9SuggestionsViewControllerDelegate: AnyObject {
    func searchBarTextWasChanged()
}

class SearchTableViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, FeelingOldViewDelegate, OptionsViewControllerDelegate, SearchTableViewControllerDelegate {
       
    weak var t9SuggestionsDelegate: T9SuggestionsViewControllerDelegate?
    var searchEngine = SearchEngine()
    var tableData = [DictionaryEntry]()
    var shouldShowFeelingOldViewInSectionHeader = false
    let feelingOldViewHeaderSectionHeight = 150.0
    let t9SuggestionsContainerViewHeight = 100.0
    var didSearchTableVCAppearOnce = false
    var firstInputWithNoNewSuggestions = ""
    var lastSelectedCellIndexPath: IndexPath? = nil
    let selectedCellHeight = 200.0
    let unselectedCellHeight = 50.0
    var searchBarTextAsT9String: String {
        get {
            if let searchBarText = searchBar.text, OptionsManager.shared.isT9PredictiveTextingOn {
                return T9Trie.t9Stringify(text: searchBarText)
            }
            return ""
        }
    }
    
    var wordOfTheDayDictionaryEntry: DictionaryEntry? = nil
    var feelingOldView: FeelingOldView?
    
    @IBOutlet var t9SuggestionsContainerView: UIView!
    @IBOutlet weak var searchBar: NumberPad.CustomSearchBar!
    @IBOutlet weak var tableView: UITableView!

    func createFeelingOldViewFromNib() -> FeelingOldView  {
        let feelingOldViewFromNib: FeelingOldView = Bundle.main.loadNibNamed("feelingOldView", owner: self, options: nil)?.first as! FeelingOldView
        
        feelingOldViewFromNib.layer.cornerRadius = 10
        feelingOldViewFromNib.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        feelingOldViewFromNib.heightConstraint.constant = 0
        feelingOldViewFromNib.delegate = self
        
        return feelingOldViewFromNib
    }
    
    func setCustomSearchBarSearchButtonClickedClosure() {
        self.searchBar.setDefaultSearchButtonClickedClosure(closure: {
            if let searchBarText = self.searchBar.text, !searchBarText.isEmpty, let firstLetterOfSearchText = searchBarText.first, firstLetterOfSearchText.isLetter {
                
                if OptionsManager.shared.isT9PredictiveTextingOn { self.t9SuggestionsDelegate?.searchBarTextWasChanged() }
                
                if !self.firstInputWithNoNewSuggestions.isEmpty {
                    if searchBarText.hasPrefix(self.firstInputWithNoNewSuggestions) {
                        return
                    } else {
                        self.firstInputWithNoNewSuggestions = ""
                    }
                }
            
                self.loadEntriesForLetterIfNeeded(letter: String(firstLetterOfSearchText))
                self.updateSuggestionsIfNeeded(for: searchBarText)
                
            } else {
                self.tableData = [DictionaryEntry]()
                self.tableView.reloadData()
            }
        })
    }
    
    func setCustomSearchBarTextDidChangeClosure() { 
        
        self.searchBar.setDefaultSearchBarTextDidChangeClosure(closure: { searchBarText in
            
            if OptionsManager.shared.shouldTranslateOnEachKeyStroke, !searchBarText.isEmpty, let firstLetterOfSearchBarText = searchBarText.first, firstLetterOfSearchBarText.isLetter {
                // TODO: Ask if updating closures like that if fine.
                if OptionsManager.shared.isT9PredictiveTextingOn { self.t9SuggestionsDelegate?.searchBarTextWasChanged() }
                
                if !self.firstInputWithNoNewSuggestions.isEmpty {
                    if searchBarText.hasPrefix(self.firstInputWithNoNewSuggestions) && !self.areWordsWithSamePrefixInTableDataPresent() {
                        return
                    } else {
                        self.firstInputWithNoNewSuggestions = ""
                    }
                }
                
                self.loadEntriesForLetterIfNeeded(letter: String(firstLetterOfSearchBarText))
                self.updateSuggestionsIfNeeded(for: searchBarText)
            } else {
                self.tableData = [DictionaryEntry]()
                self.tableView.reloadData()
            }
            
            
        })
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderTopPadding = 0
    }
    
    func setupWordOfTheDay() {
        feelingOldView = self.createFeelingOldViewFromNib()
        wordOfTheDayDictionaryEntry = searchEngine.randomDictionaryEntry()
        shouldShowFeelingOldViewInSectionHeader = true
    }
    
    func setupTapGestureDismissingKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // TODO: Ask if updating closures like that if fine.
    func updateCustomSearchBarClosures() {
        setCustomSearchBarSearchButtonClickedClosure()
        setCustomSearchBarTextDidChangeClosure()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupWordOfTheDay()
        setupTapGestureDismissingKeyboard()
        updateCustomSearchBarClosures() // TODO: Ask if updating closures like that if fine.
        self.t9SuggestionsContainerView.frame.size.height = 0 // TODO: Ask how to do these animations otherwise
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        
        if let wordOfTheDayEntry = wordOfTheDayDictionaryEntry, !didSearchTableVCAppearOnce {
            tableData = searchEngine.findSuggestionEntries(amountOfDesiredSuggestionEntries: OptionsManager.shared.suggestionsToBeShownAmount, forDictionaryEntry: wordOfTheDayEntry)
            searchBar.searchTextField.text = wordOfTheDayEntry.word
                        
            if wordOfTheDayEntry.isBulgarianEntry() {
                setSearchBarT9PredictiveTextingLanguage(to: .BG)
            }

        }
        
        if let searchBarText = searchBar.text, !searchBarText.isEmpty, didSearchTableVCAppearOnce {
            
            if !tableData.isEmpty && OptionsManager.shared.suggestionsToBeShownAmount > tableData.count {
                tableData = searchEngine.findSuggestionEntries(amountOfDesiredSuggestionEntries: OptionsManager.shared.suggestionsToBeShownAmount, forDictionaryEntry: tableData[0])
            }
            
            tableData = Array(tableData[0...OptionsManager.shared.suggestionsToBeShownAmount - 1])
            
            collapsePreviouslySelectedCellIfVisible()
            tableView.reloadData()
        }
        
        if let lastSelectedRowIndexPath = self.lastSelectedCellIndexPath, let cell = tableView.cellForRow(at: lastSelectedRowIndexPath) as? WordTableViewCell  {
            cell.translationView.isHidden = false
            cell.isExpanded = true
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if shouldShowFeelingOldViewInSectionHeader {
            return feelingOldViewHeaderSectionHeight
        }
        
        if OptionsManager.shared.isT9PredictiveTextingOn && searchBar.text != nil && !searchBar.text!.isEmpty {
            
            if t9SuggestionsContainerView.frame.size.height == 0 {
                showT9SuggestionsContainerView()
            }
            
            return t9SuggestionsContainerViewHeight
        }
        
        if OptionsManager.shared.isT9PredictiveTextingOn && searchBar.text != nil && searchBar.text!.isEmpty {
            
            if t9SuggestionsContainerView.frame.size.height == t9SuggestionsContainerViewHeight {
                hideT9SuggestionsContainerView()
            }
            
            return 0
        }
    
        if !OptionsManager.shared.isT9PredictiveTextingOn {

            if t9SuggestionsContainerView.frame.size.height != 0 {
                hideT9SuggestionsContainerView()
            }

        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if shouldShowFeelingOldViewInSectionHeader {
            return self.feelingOldView
        }
        
        if OptionsManager.shared.isT9PredictiveTextingOn {
            
            if searchBar.text != nil && searchBar.text!.isEmpty {
                t9SuggestionsDelegate?.searchBarTextWasChanged()
            }
    
            return self.t9SuggestionsContainerView
        }
        
        return nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !didSearchTableVCAppearOnce {
            showFeelingOldView()
            didSearchTableVCAppearOnce = true
        }
        
        if shouldShowFeelingOldViewInSectionHeader && OptionsManager.shared.isT9PredictiveTextingOn {
            hideFeelingOldView()
        }

    }
    
    func showT9SuggestionsContainerView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            self.t9SuggestionsContainerView.frame.size.height = self.t9SuggestionsContainerViewHeight
            self.view.layoutIfNeeded()
        }, completion: {
            finished in
            if finished {
                self.tableView.reloadData()
            }
        })
    }
    
    func hideT9SuggestionsContainerView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            self.t9SuggestionsContainerView.frame.size.height = 0.0
            self.view.layoutIfNeeded()
        }, completion: {
            finished in
            if finished {
                print("Hello, it me")
            }
        })
        // TODO: Ask why does the app crash when finished block added?
//        {
//            finished in
//            if finished {
//                self.tableView.reloadData()
//            }
//        })
    }

    func showFeelingOldView() {
        if self.feelingOldView != nil {
            self.feelingOldView!.heightConstraint.constant = feelingOldViewHeaderSectionHeight
            UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
//MARK: - FeelingOldViewDelegate
    func hideFeelingOldView() {
        if self.feelingOldView != nil {
            self.feelingOldView!.heightConstraint.constant = 0
            UIView.animate(withDuration: 0.5, delay: 0.25, options:[], animations: {
                self.view.layoutIfNeeded()
            }, completion: {
                finished in
                if finished {
                    self.shouldShowFeelingOldViewInSectionHeader = false
                    self.feelingOldView = nil
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func showToast(withText text: String) {
        self.tableView.makeToast(text)
    }
    
    func setMultitapInput() {
        if !OptionsManager.shared.isMultitapTextingOn {
            searchBar.changeInputMode(toInputMode: NumpadDelegateObject.SearchBarInputMode.multiTap)
            OptionsManager.shared.setMultiTapTexting(to: true)
            OptionsManager.shared.setT9PredictiveTexting(to: false)
            showToast(withText: "Setting somewhere a change!")
        }
    }
    
    func setStandardInput() {
        searchBar.changeInputMode(toInputMode: NumpadDelegateObject.SearchBarInputMode.normal)
        OptionsManager.shared.setMultiTapTexting(to: false)
        OptionsManager.shared.setT9PredictiveTexting(to: false)
        showToast(withText: "Setting somewhere a change!")
    }
    
    func setT9PredictiveText() {
        if !OptionsManager.shared.isT9PredictiveTextingOn {
            searchBar.changeInputMode(toInputMode: NumpadDelegateObject.SearchBarInputMode.t9PredictiveTexting)
            OptionsManager.shared.setT9PredictiveTexting(to: true)
            OptionsManager.shared.setMultiTapTexting(to: false)
        }
    }
    
//MARK: - OptionsViewDelegate
    
    func toggleSearchBarMultitapLanguage() {
        searchBar.toggleMultitapLanguage()
    }
    
    func setSearchBarT9PredictiveTextingLanguage(to language: T9TrieLanguage) {
        CustomSearchBar.changeCurrentT9TrieLanguage(to: language)
    }
    
    func toggleSearchBarT9PredictiveTextingLanguage() {
        CustomSearchBar.toggleCurrentT9TrieLanguage()
    }

    func setSearchBarInputMode(toMode mode: NumpadDelegateObject.SearchBarInputMode) {
        searchBar.changeInputMode(toInputMode: mode)
    }
    
    func suggestionEntries(forInput input: String) -> [DictionaryEntry] {
        if let closestMatch: DictionaryEntry = searchEngine.findClosestMatchInDictionaryEntries(toInput: input.uppercased()) {
            let followingSuggestionEntries = searchEngine.findSuggestionEntries(amountOfDesiredSuggestionEntries: OptionsManager.shared.suggestionsToBeShownAmount, forDictionaryEntry: closestMatch)
            return followingSuggestionEntries
        } else {
            return [DictionaryEntry]()
        }
    }
    
    func areNewSuggestionEntriesPresent(suggestionEntries: [DictionaryEntry]) -> Bool {
        if suggestionEntries.count != tableData.count { return true }
        
        for entryIndex in 0..<suggestionEntries.count {
            if suggestionEntries[entryIndex].word != tableData[entryIndex].word { return true }
        }
        
        return false
    }
    
    func areNewSuggestionEntriesPresent(forInput input: String) -> Bool {
        let suggestionEntries = suggestionEntries(forInput: input)
        if !suggestionEntries.isEmpty {
            return areNewSuggestionEntriesPresent(suggestionEntries: suggestionEntries)
        }
        return false
    }
    
    func loadEntriesForLetterIfNeeded(letter: String) {
        searchEngine.loadEntriesForLetterIfNeeded(letter: letter)
    }
    
    func updateSuggestionsIfNeeded(for input: String) {
        if !didSearchTableVCAppearOnce {
            tableData = suggestionEntries(forInput: input)
            tableView.reloadData()
        } else {
            if areNewSuggestionEntriesPresent(forInput: input) {
                collapsePreviouslySelectedCellIfVisible()
                lastSelectedCellIndexPath = nil
                tableData = suggestionEntries(forInput: input)
                tableView.reloadData()
            } else {
                self.firstInputWithNoNewSuggestions = input
            }
        }
    }
    
    func areWordsWithSamePrefixInTableDataPresent() -> Bool {
        return self.tableData.contains { $0.word.hasPrefix(self.firstInputWithNoNewSuggestions) }
    }
    
    // MARK: - SearchTableVCDelegate's methods
    
    func updateSearchBarText(withText text: String) {
        searchBar.text = text
        searchBar.executeDefaultSearchButtonClickedClosure()
        
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
        
        if entry.word == wordOfTheDayDictionaryEntry?.word {
            cell.lightbulbImage.isHidden = false
        } else {
            cell.lightbulbImage.isHidden = true
            cell.translationView.isHidden = true
            cell.isExpanded = false
        }

        
        if indexPath.row == 0 && entry.word == wordOfTheDayDictionaryEntry?.word {
            
            if !didSearchTableVCAppearOnce {
                cell.translationView.isHidden = false
                cell.isExpanded = true
                lastSelectedCellIndexPath = indexPath
            } else {
                if let lastSelectedCellIndexPath = lastSelectedCellIndexPath, lastSelectedCellIndexPath == indexPath {
                    cell.translationView.isHidden = false
                    cell.isExpanded = true
                }
            }
            
        }

        return cell
    }
    
    func collapsePreviouslySelectedCellIfVisible() {
        if let selectedCellIndexPath = lastSelectedCellIndexPath, let previouslySelectedCell = tableView.cellForRow(at: selectedCellIndexPath) as? WordTableViewCell {
            previouslySelectedCell.translationView.isHidden.toggle()
            previouslySelectedCell.isExpanded = false
        }
    }
    
    func presentTranslationViewController(forCell cell: WordTableViewCell) {
        if let cellWord = cell.wordLabel.text {
            presentTranslationViewController(forWord: cellWord, forTranslation: cell.translationTextView.text)
        }
    }
    
    func presentTranslationViewController(forWord word: String, forTranslation translation: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let translationVC: TranslationViewController = storyboard.instantiateViewController(withIdentifier: "TranslationViewController") as! TranslationViewController
        translationVC.modalPresentationStyle = .fullScreen
        translationVC.word = word
        translationVC.translation = translation
        self.navigationController?.pushViewController(translationVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? WordTableViewCell {
            
            if lastSelectedCellIndexPath == indexPath {
                if cell.isExpanded { // second click
                    presentTranslationViewController(forCell: cell)
                }
                lastSelectedCellIndexPath = nil
            } else {
                collapsePreviouslySelectedCellIfVisible()
                lastSelectedCellIndexPath = indexPath
            }
            
            tableView.beginUpdates()
            
            cell.translationView.isHidden.toggle()
            cell.isExpanded = true
            
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        super.prepare(for: segue, sender: sender)
        
        if let collectionVC = segue.destination as? T9SuggestionsCollectionViewController {
            self.t9SuggestionsDelegate = collectionVC
            collectionVC.searchTableVCDelegate = self
        }
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
