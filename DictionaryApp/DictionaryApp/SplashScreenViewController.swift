//
//  SplashScreenViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 11.02.22.
//

import UIKit

class SplashScreenViewController: UIViewController {
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var catchyPhraseLabel: UILabel!
    let catchyPhrases = ["Hello translation adventurer!", "Gathering all words...", "Loading your favorite words...", "Прелистваме речника...", "Взимаме преводите от Стефан...", "Your translation adventure begins in a second!"]
    var currentCatchyPhraseIndex: Int = 0
    var catchyPhrasesDoneAnimating = false
    
    let englishAlphabetUnicodeRange = Unicode.Scalar("A").value...Unicode.Scalar("Z").value
    let bulgarianAlphabetUnicodeRange = Unicode.Scalar("А").value...Unicode.Scalar("Я").value
    
    func filenamesOfNonExistingHelperFiles(forLanguageUnicodeRange languageUnicodeRange: ClosedRange<UInt32>) -> [String] {
        
        var filenamesOfNonExistingHelperFiles = [String]()
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cachesDirectoryUrl = urls[0]
        
        for alpha in languageUnicodeRange {
            if alpha != Unicode.Scalar("Э").value, alpha != Unicode.Scalar("Ы").value, let letter = Unicode.Scalar(alpha) { // extracts russian letters
                
                let fileUrl = cachesDirectoryUrl.appendingPathComponent(String(letter))
                //print(fileUrl.absoluteString)
                
                let filePath = fileUrl.path
                print(filePath)
                
                if !fileManager.fileExists(atPath: filePath) { filenamesOfNonExistingHelperFiles.append(String(letter)) }
            }
        }
        
        return filenamesOfNonExistingHelperFiles
    }
    
    func generateRandomCatchyPhraseIndexDifferentThanCurrent() -> Int {
        
        var randomCatchyPhraseIndex = Int.random(in: 0..<catchyPhrases.count)
        
        while randomCatchyPhraseIndex == self.currentCatchyPhraseIndex {
            randomCatchyPhraseIndex = Int.random(in: 0..<catchyPhrases.count)
        }
        
        return randomCatchyPhraseIndex
    }
    
    func updateCurrentCatchyPhraseIndex() {
        currentCatchyPhraseIndex = generateRandomCatchyPhraseIndexDifferentThanCurrent();
    }
    
    func executeFirstAnimationCycle() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: { // Fade in
            self.catchyPhraseLabel.alpha = 1.0
        }, completion: {
            finished in
            if finished {
                UIView.animate(withDuration: 1.0, delay: 1.0, options: [],  animations: { // Ease away
                    self.catchyPhraseLabel.center = CGPoint(x: self.catchyPhraseLabel.frame.width + UIScreen.main.bounds.width, y: self.catchyPhraseLabel.center.y)
                }, completion: {
                    finished in
                    if finished {
                        
                        self.updateCurrentCatchyPhraseIndex()
                        self.catchyPhraseLabel.text = self.catchyPhrases[self.currentCatchyPhraseIndex]
                        // CatchyPhrase updated
                        
                        if (self.catchyPhraseLabel.center.x > UIScreen.main.bounds.width) {
                            self.catchyPhraseLabel.center.x = -self.catchyPhraseLabel.frame.width
                        }
                        
                        UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: { // Ease in
                            self.catchyPhraseLabel.center = CGPoint(x: 0.5 * UIScreen.main.bounds.width, y: self.catchyPhraseLabel.center.y)
                        }, completion: {
                            finished in
                            if finished {
                                self.catchyPhrasesDoneAnimating = true // CatchyPhrasesDoneAnimating updated
                            }
                        })
                    }
                })
            }
        })
    }
    
    func executeAnyOtherAnimationCycle() { // Removes the fade in
        UIView.animate(withDuration: 1.0, delay: 1.0, options: [],  animations: { // Ease away
            self.catchyPhraseLabel.center = CGPoint(x: self.catchyPhraseLabel.frame.width + UIScreen.main.bounds.width, y: self.catchyPhraseLabel.center.y)
        }, completion: {
            finished in
            if finished {
                
                self.updateCurrentCatchyPhraseIndex()
                self.catchyPhraseLabel.text = self.catchyPhrases[self.currentCatchyPhraseIndex]
                // CatchyPhrase updated
                
                if (self.catchyPhraseLabel.center.x > UIScreen.main.bounds.width) {
                    self.catchyPhraseLabel.center.x = -self.catchyPhraseLabel.frame.width
                }
                
                UIView.animate(withDuration: 1.0, delay: 0.0, options: [], animations: { // Ease in
                    self.catchyPhraseLabel.center = CGPoint(x: 1/2 * UIScreen.main.bounds.width, y: self.catchyPhraseLabel.center.y)
                }, completion: {
                    finished in
                    if finished {
                        self.catchyPhrasesDoneAnimating = true
                    }
                })
            }
        })
    }
    
    func executeAnimationCycle() {
        
        self.catchyPhrasesDoneAnimating = false
        
        if self.catchyPhraseLabel.alpha == 0.0 {
            executeFirstAnimationCycle()
        } else {
            executeAnyOtherAnimationCycle()
        }
    }
    
    func presentTabViewController() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    func executeAllSetAnimationAndPresentTabBarViewController() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
            self.catchyPhraseLabel.alpha = 0.0
        }, completion: {
            finished in
            if finished {
                
                self.catchyPhraseLabel.text = "All set!"
                
                UIView.animate(withDuration: 1.0, delay: 0, options: [], animations: {
                    self.catchyPhraseLabel.alpha = 1.0
                }, completion: {
                    finished in
                    if finished {
                        UIView.animate(withDuration: 1.0, delay: 0, options: [], animations: {
                            self.catchyPhraseLabel.alpha = 0.0
                            self.activityIndicator.alpha = 0.0
                        }, completion: {
                            finished in
                            if finished {
                                self.activityIndicator.stopAnimating()
                                self.presentTabViewController()
                            }
                        })
                    }
                })
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        currentCatchyPhraseIndex = 0
        catchyPhraseLabel.text = catchyPhrases[currentCatchyPhraseIndex]
        catchyPhraseLabel.alpha = 0.0
        
        tabBar.clipsToBounds = true;
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let nonExistingEnglishFilenames = self.filenamesOfNonExistingHelperFiles(forLanguageUnicodeRange:  self.englishAlphabetUnicodeRange)
        
        let nonExistingBulgarianFilenames = self.filenamesOfNonExistingHelperFiles(forLanguageUnicodeRange:  self.bulgarianAlphabetUnicodeRange)
        
        let willHaveToBeLoadingHelperFiles = !nonExistingEnglishFilenames.isEmpty || !nonExistingBulgarianFilenames.isEmpty
        
        if willHaveToBeLoadingHelperFiles {
            
            executeAnimationCycle()
            activityIndicator.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            DispatchQueue.global(qos: .default).async {
                
                if !nonExistingEnglishFilenames.isEmpty {
                    if let freader = FileReader(filename: "en_bg.dic") {
                        for filename in nonExistingEnglishFilenames {
                            
                            if self.catchyPhrasesDoneAnimating {
                                DispatchQueue.main.async { // UI updates on main thred
                                    self.executeAnimationCycle()
                                }
                            }
                            
                            freader.createFileForLetter(letter: filename)
                        }
                    }
                }
                
                if !nonExistingBulgarianFilenames.isEmpty {
                    if let freader = FileReader(filename: "bg_en.kyp") {
                        for filename in nonExistingBulgarianFilenames {
                            
                            if self.catchyPhrasesDoneAnimating {
                                DispatchQueue.main.async { // UI updates on main thred
                                    self.executeAnimationCycle()
                                }
                            }
                            
                            freader.createFileForLetter(letter: filename)
                        }
                    }
                }
                
                DispatchQueue.main.async { [weak self] in
                   // UI updates must be on main thread
                    self?.executeAllSetAnimationAndPresentTabBarViewController()
                }
            }
            
        } else {
            self.presentTabViewController()
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
