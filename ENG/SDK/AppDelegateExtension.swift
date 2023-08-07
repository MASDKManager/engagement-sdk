//
//  AppDelegateExtension.swift
//  ENG
//
//  Created by Maarouf on 8/7/23.
//

import Foundation
import UIKit
import FBSDKCoreKit // Import the necessary module

 
extension AppDelegate {
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
}
