//
//  OptionsViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 10.02.22.
//

import UIKit

protocol OptionsViewControllerDelegate: AnyObject {
    func toggleSearchBarInputMode()
}

class OptionsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate: OptionsViewControllerDelegate?
    @IBOutlet weak var suggestionsAmountPicker: UIPickerView!
    @IBOutlet weak var keyStorkeSwitch: UISwitch!
    @IBOutlet weak var multiTapTextingSwitch: UISwitch!
    
    let pickerData: [Int] = [Int](1...20)
    
    override func viewWillAppear(_ animated: Bool) {
        self.suggestionsAmountPicker.selectRow(OptionsManager.shared.suggestionsToBeShown - 1, inComponent: 0, animated: false)
        self.multiTapTextingSwitch.isOn = OptionsManager.shared.multiTapTexting
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let searchTableNavVC = self.tabBarController?.viewControllers?.first(where: { $0 is UINavigationController }) as? UINavigationController,
            let searchTableVC = searchTableNavVC.viewControllers.first(where: {$0 is SearchTableViewController}) as? SearchTableViewController {
            self.delegate = searchTableVC
        }
        
        self.suggestionsAmountPicker.dataSource = self
        self.suggestionsAmountPicker.delegate = self
        self.suggestionsAmountPicker.selectRow(OptionsManager.shared.suggestionsToBeShown - 1, inComponent: 0, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerData[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        OptionsManager.shared.changeSuggestionsAmount(toSuggestionsAmount: pickerData[row])
    }
    @IBAction func onKeyStrokeSwitchPress(_ sender: Any) {
        OptionsManager.shared.toggleTranslateOnEachKeyStroke()
    }
    @IBAction func onMultiTapTextingPress(_ sender: Any) {
        OptionsManager.shared.toggleMultiTapTexting()
        delegate?.toggleSearchBarInputMode()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
