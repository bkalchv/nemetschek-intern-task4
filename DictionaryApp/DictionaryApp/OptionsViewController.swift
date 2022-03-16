//
//  OptionsViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 10.02.22.
//

import UIKit

protocol OptionsViewControllerDelegate: AnyObject {
    func toggleSearchBarInputMode()
    func toggleSearchBarMultitapLanguage()
}

class OptionsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate: OptionsViewControllerDelegate?
    @IBOutlet weak var suggestionsAmountPicker: UIPickerView!
    @IBOutlet weak var keystorkeSwitch: UISwitch!
    @IBOutlet weak var keystrokeLabel: UILabel!
    @IBOutlet weak var multitapTextingSwitch: UISwitch!
    @IBOutlet weak var multitapCyrillicLabel: UILabel!
    @IBOutlet weak var multiTapCyrillicSwitch: UISwitch!
    
    let pickerData: [Int] = [Int](1...20)
    
    
    func enableKeystrokeIBOs() {
        keystorkeSwitch.isEnabled = true
        keystrokeLabel.isEnabled = true
    }
    
    func disableKeystrokeIBOs() {
        keystorkeSwitch.isEnabled = false
        keystrokeLabel.isEnabled = false
    }
    
    func enableMultitapCyrillicIBOs() {
        multitapCyrillicLabel.isEnabled = true
        multiTapCyrillicSwitch.isEnabled = true
    }
    
    func disableMultitapCyrillicIBOs() {
        multitapCyrillicLabel.isEnabled = false
        multiTapCyrillicSwitch.isEnabled = false
    }
    
    func handleIsMultitapTextingOn() {
        multitapTextingSwitch.isOn = true
        
        if !keystorkeSwitch.isOn {
            OptionsManager.shared.toggleTranslateOnEachKeyStroke()
            keystorkeSwitch.isOn = true
        }
        
        disableKeystrokeIBOs()
        enableMultitapCyrillicIBOs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        suggestionsAmountPicker.selectRow(OptionsManager.shared.suggestionsToBeShownAmount, inComponent: 0, animated: false)
//        multitapTextingSwitch.isOn = OptionsManager.shared.isMultitapTextingOn
        
        if  OptionsManager.shared.isMultitapTextingOn {
            handleIsMultitapTextingOn()
        } else {
            enableKeystrokeIBOs()
            disableMultitapCyrillicIBOs()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let searchTableNavVC = self.tabBarController?.viewControllers?.first(where: { $0 is UINavigationController }) as? UINavigationController,
            let searchTableVC = searchTableNavVC.viewControllers.first(where: {$0 is SearchTableViewController}) as? SearchTableViewController {
            delegate = searchTableVC
        }
        
        suggestionsAmountPicker.dataSource = self
        suggestionsAmountPicker.delegate = self
        suggestionsAmountPicker.selectRow(OptionsManager.shared.suggestionsToBeShownAmount - 1, inComponent: 0, animated: false)
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
    
    @IBAction func onMultitapCyrillicSwitchPress(_ sender: Any) {
        delegate?.toggleSearchBarMultitapLanguage()
    }
    
    @IBAction func onMultiTapTextingPress(_ sender: Any) {
        OptionsManager.shared.toggleMultiTapTexting()
        delegate?.toggleSearchBarInputMode()
        
        if  OptionsManager.shared.isMultitapTextingOn {
            handleIsMultitapTextingOn()
        } else {
            enableKeystrokeIBOs()
            disableMultitapCyrillicIBOs()
        }
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
