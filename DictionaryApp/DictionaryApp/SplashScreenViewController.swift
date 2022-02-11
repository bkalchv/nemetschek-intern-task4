//
//  SplashScreenViewController.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 11.02.22.
//

import UIKit

class SplashScreenViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
    func filenamesOfNonExistingHelperFiles() -> [String] {
        
        var filenamesOfNonExistingHelperFiles = [String]()
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cachesDirectoryUrl = urls[0]
        
        let startChar = Unicode.Scalar("A").value
        let endChar = Unicode.Scalar("Z").value
        
        for alpha in startChar...endChar {
            if let letter = Unicode.Scalar(alpha) {
                
                let fileUrl = cachesDirectoryUrl.appendingPathComponent(String(letter))
                //print(fileUrl.absoluteString)
                
                let filePath = fileUrl.path
                //print(filePath)
                
                if !fileManager.fileExists(atPath: filePath) { filenamesOfNonExistingHelperFiles.append(String(letter)) }
            }
        }
        
        return filenamesOfNonExistingHelperFiles
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        
        DispatchQueue.global(qos: .default).async {

            let nonExistingFilenames = self.filenamesOfNonExistingHelperFiles()
            
            if (!nonExistingFilenames.isEmpty) {
                if let freader = FileReader(filename: "en_bg.dic") {
                    for filename in nonExistingFilenames {
                        freader.createFileForLetter(letter: filename)
                    }
                }
            }
            
           DispatchQueue.main.async { [weak self] in
               // UI updates must be on main thread
               
               self?.activityIndicator.stopAnimating()
               vc.modalPresentationStyle = .fullScreen
               self?.present(vc, animated: false, completion: nil)
            }
        }
        
        
        
        // Do any additional setup after loading the view.
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
