//
//  AppDelegate.swift
//  DictionaryApp
//
//  Created by Bogdan Kalchev on 27.01.22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func doHelperFilesExist() -> Bool {
        
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
                
                if !fileManager.fileExists(atPath: filePath) { return false }
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        
        if (!doHelperFilesExist()) {
            if let freader = FileReader(filename: "en_bg.dic") {
                
                let startChar = Unicode.Scalar("A").value
                let endChar = Unicode.Scalar("Z").value

                for alpha in startChar...endChar {
                    if let letter = Unicode.Scalar(alpha) {
                        freader.createFileForLetter(letter: String(letter))
                    }
                }
                return true
            } else {
                return false
            }
        }
        
        return true
}
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

