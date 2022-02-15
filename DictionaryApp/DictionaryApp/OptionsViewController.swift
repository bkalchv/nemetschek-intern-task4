//
//  OptionsViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 10.02.22.
//

import UIKit

class OptionsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var suggestionsAmountPicker: UIPickerView!
    @IBOutlet weak var keyStorkeSwitch: UISwitch!
    
    let pickerData: [Int] = [Int](1...20)
    
    override func viewWillAppear(_ animated: Bool) {
        self.suggestionsAmountPicker.selectRow(OptionsManager.shared.suggestionsToBeShown - 1, inComponent: 0, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.suggestionsAmountPicker.dataSource = self
        self.suggestionsAmountPicker.delegate = self
        // Do any additional setup after loading the view.
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
        OptionsManager.shared.changeTranslateOnEachKeyStroke()
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
