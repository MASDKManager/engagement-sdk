//
//  AppDelegateExtension.swift
//  ENG
//
//  Created by Maarouf on 8/7/23.
//

import Foundation
import UIKit
import FBSDKCoreKit

// Make sure the following import points to the correct module where AppDelegate is defined
// import YourModuleName // Replace "YourModuleName" with the actual module name

// If AppDelegate is part of your current module, you can directly extend it
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
