//
//  OptionsViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 10.02.22.
//

import UIKit
import NumberPad

protocol OptionsViewControllerDelegate: AnyObject {
    func setSearchBarInputMode(toMode mode: NumpadDelegateObject.SearchBarInputMode)
    func toggleSearchBarMultitapLanguage()
}

class OptionsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate: OptionsViewControllerDelegate?
    @IBOutlet weak var suggestionsAmountPicker: UIPickerView!
    @IBOutlet weak var keystrokeSwitch: UISwitch!
    @IBOutlet weak var keystrokeLabel: UILabel!
    @IBOutlet weak var multitapTextingSwitch: UISwitch!
    @IBOutlet weak var multitapCyrillicLabel: UILabel!
    @IBOutlet weak var multiTapCyrillicSwitch: UISwitch!
    @IBOutlet weak var T9PredictiveTextingLabel: UILabel!
    @IBOutlet weak var T9PredictiveTextingSwitch: UISwitch!
    
    let pickerData: [Int] = [Int](1...20)
    
    
    func enableKeystrokeIBOs() {
        keystrokeSwitch.isEnabled = true
        keystrokeLabel.isEnabled = true
    }
    
    func disableKeystrokeIBOs() {
        keystrokeSwitch.isEnabled = false
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
    
    func toggleIBOsOnIsMultitapTextingOn() {
        multitapTextingSwitch.setOn(true, animated: true)
        
        if !OptionsManager.shared.shouldTranslateOnEachKeyStroke && !keystrokeSwitch.isOn {
            OptionsManager.shared.toggleTranslateOnEachKeyStroke()
            keystrokeSwitch.setOn(true, animated: true)
        }
        
        if T9PredictiveTextingSwitch.isOn {
            T9PredictiveTextingSwitch.setOn(false, animated: true)
        }
        
        disableKeystrokeIBOs()
        enableMultitapCyrillicIBOs()
    }
    
    func toggleIBOsOnIsT9PredictiveTextingOn() {
        T9PredictiveTextingSwitch.isOn = true
        
        if !OptionsManager.shared.shouldTranslateOnEachKeyStroke && !keystrokeSwitch.isOn {
            OptionsManager.shared.toggleTranslateOnEachKeyStroke()
            keystrokeSwitch.setOn(true, animated: true)
        }
        
        if multitapTextingSwitch.isOn {
            multitapTextingSwitch.setOn(false, animated: true)
        }
        
        disableKeystrokeIBOs()
        disableMultitapCyrillicIBOs()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        suggestionsAmountPicker.selectRow(OptionsManager.shared.suggestionsToBeShownAmount - 1, inComponent: 0, animated: false)
        
        //TODO: Rework
        if OptionsManager.shared.isMultitapTextingOn {
            toggleIBOsOnIsMultitapTextingOn()
        } else if OptionsManager.shared.isT9PredictiveTextingOn {
            toggleIBOsOnIsT9PredictiveTextingOn()
        } else {
                        
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
        
        if OptionsManager.shared.isMultitapTextingOn {
            delegate?.setSearchBarInputMode(toMode: NumpadDelegateObject.SearchBarInputMode.multiTap)
            OptionsManager.shared.setT9PredictiveTexting(to: false)
            toggleIBOsOnIsMultitapTextingOn()
        } else {
            if !OptionsManager.shared.isT9PredictiveTextingOn && !T9PredictiveTextingSwitch.isOn {
                delegate?.setSearchBarInputMode(toMode: NumpadDelegateObject.SearchBarInputMode.normal)
            }
            enableKeystrokeIBOs()
            disableMultitapCyrillicIBOs()
        }
    }
    
    @IBAction func onT9PredictiveTextingSwitchPress(_ sender: Any) {
        OptionsManager.shared.toggleT9PredictiveTexting()
        
        if OptionsManager.shared.isT9PredictiveTextingOn {
            delegate?.setSearchBarInputMode(toMode: NumpadDelegateObject.SearchBarInputMode.t9PredictiveTexting)
            OptionsManager.shared.setMultiTapTexting(to: false)
            toggleIBOsOnIsT9PredictiveTextingOn()
        } else {
            if !OptionsManager.shared.isMultitapTextingOn && !multitapTextingSwitch.isOn {
                delegate?.setSearchBarInputMode(toMode: NumpadDelegateObject.SearchBarInputMode.normal)
            }
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
