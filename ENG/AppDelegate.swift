//
//  AppDelegate.swift
//  ENG
//
//  Created by Maarouf on 7/9/23.
//

import UIKit 

@main
class AppDelegate: UIResponder, UIApplicationDelegate, EMobiDelegate {
  
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions  : [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
      
        guard let url = Bundle.main.url(forResource: "Constants", withExtension: "plist") else {
            fatalError("SwiftyAds could not find SwiftyAds.plist in the main bundle.")
        }
     
        if let plistData = NSDictionary(contentsOf: url) {
            EMobi.shared.start(withConstantPlist: plistData, launchOptions: launchOptions)
            EMobi.shared.delegate = self
        } else {
            print("Unable to read Constants.plist file.")
        }
   
        return true
    }
    
    func bannerAdDidFailToLoad(adUnitIdentifier: String, error: String) {
        // Callback triggered when the banner ad fails to load
        // Access the adUnitIdentifier and error parameters here
        print("Banner ad failed to load for adUnitIdentifier: \(adUnitIdentifier)")
        print("Error: \(error  )")
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

