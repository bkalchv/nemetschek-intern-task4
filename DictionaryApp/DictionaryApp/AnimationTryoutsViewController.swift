//
//  AnimationTryoutsViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 15.02.22.
//

import UIKit

class AnimationTryoutsViewController: UIViewController {

    @IBOutlet weak var catchyPhraseLabel: UILabel!
    @IBOutlet weak var easeAwayButton: UIButton!
    @IBOutlet weak var easeInButton: UIButton!
    @IBOutlet weak var executeAnimationCycleButton: UIButton!
    var currentCatchyPhraseIndex: Int = 0
    let catchyPhrases = ["Catchy phrase1", "Catchy phrase2", "Catchy phrase3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        easeAwayButton.isHidden = true
        easeInButton.isHidden = true
        
        currentCatchyPhraseIndex = 0
        catchyPhraseLabel.text = catchyPhrases[currentCatchyPhraseIndex]
        catchyPhraseLabel.alpha = 0.0
        // Do any additional setup after loading the view.
    }
    
    func nextCatchyPhraseIndex() -> Int {
        if (currentCatchyPhraseIndex == catchyPhrases.count - 1) {
            return 0;
        } else {
            return currentCatchyPhraseIndex + 1;
        }
    }
    
    func updateCurrentCatchyPhraseIndex() {
        currentCatchyPhraseIndex = nextCatchyPhraseIndex();
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
    
        executeAnimationCylce()
        
    }
    
    func executeAnimationCylce() {
        if (self.catchyPhraseLabel.alpha == 0.0) {
            UIView.animate(withDuration: 1.0, delay: 0.25, options: [], animations: {
                self.catchyPhraseLabel.alpha = 1.0
            }, completion: {
                (finished) in
                if (finished) {
                    UIView.animate(withDuration: 1.0, delay: 1.0, options: [],  animations: {
                        self.catchyPhraseLabel.center = CGPoint(x: self.catchyPhraseLabel.frame.width + UIScreen.main.bounds.width, y: self.catchyPhraseLabel.center.y)
                    }, completion: {
                        (finished) in
                        if (finished) {
                            
                            self.updateCurrentCatchyPhraseIndex()
                            self.catchyPhraseLabel.text = self.catchyPhrases[self.currentCatchyPhraseIndex]
                            
                            if (self.catchyPhraseLabel.center.x > UIScreen.main.bounds.width) {
                                self.catchyPhraseLabel.center.x = -self.catchyPhraseLabel.frame.width
                            }
                            
                            UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
                                self.catchyPhraseLabel.center = CGPoint(x: 1/2 * UIScreen.main.bounds.width, y: self.catchyPhraseLabel.center.y)
                            }, completion: nil)
                        }
                    })
                }
            })
        } else {
            UIView.animate(withDuration: 1.0, delay: 1.0, options: [],  animations: {
                self.catchyPhraseLabel.center = CGPoint(x: self.catchyPhraseLabel.frame.width + UIScreen.main.bounds.width, y: self.catchyPhraseLabel.center.y)
            }, completion: {
                (finished) in
                if (finished) {
                    
                    self.updateCurrentCatchyPhraseIndex()
                    self.catchyPhraseLabel.text = self.catchyPhrases[self.currentCatchyPhraseIndex]
                    
                    if (self.catchyPhraseLabel.center.x > UIScreen.main.bounds.width) {
                        self.catchyPhraseLabel.center.x = -self.catchyPhraseLabel.frame.width
                    }
                    
                    UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: {
                        self.catchyPhraseLabel.center = CGPoint(x: 1/2 * UIScreen.main.bounds.width, y: self.catchyPhraseLabel.center.y)
                    }, completion: nil)
                }
            })
        }
    }
    
    @IBAction func onExecuteAnimationCycleButtonClick(_ sender: Any) {
        executeAnimationCylce()
    }
    
    func labelFadeIn() {
        UIView.animate(withDuration: 2.0) {
            self.catchyPhraseLabel.alpha = 1.0
        }
    }
    
    func labelFadeAway() {
        UIView.animate(withDuration: 2.0) {
            self.catchyPhraseLabel.alpha = 0.0
        }
    }
    
    func labelEaseAway() {
        UIView.animate(withDuration: 0.5, animations: {
            self.catchyPhraseLabel.center = CGPoint(x: self.catchyPhraseLabel.frame.width + UIScreen.main.bounds.width, y: self.catchyPhraseLabel.center.y)
        })
    }
    
    func labelEaseIn() {
        if (self.catchyPhraseLabel.center.x > UIScreen.main.bounds.width) {
            self.catchyPhraseLabel.center.x = -self.catchyPhraseLabel.frame.width
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.catchyPhraseLabel.center = CGPoint(x: 1/2 * UIScreen.main.bounds.width, y: self.catchyPhraseLabel.center.y)
        })
    }

    
    @IBAction func onEaseAwayButtonClick(_ sender: Any) {
        labelEaseAway()
    }
    
    @IBAction func onEaseInButtonClick(_ sender: Any) {
        labelEaseIn()
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
