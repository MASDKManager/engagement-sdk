//
//  Utils.swift
//  ENGSDK
//
//  Created by Maarouf on 6/27/23.
//

import Foundation
import FirebaseAnalytics
 
let tag = "ENGSDK"

func getUserID() -> String {
    if let userID = UserDefaults.standard.string(forKey: "userID") {
        return userID
    } else {
        let newUserID = UUID().uuidString
        UserDefaults.standard.set(newUserID, forKey: "userID")
        return newUserID
    }
}

func logEvent(eventName: String, parameters: [String: Any]) {
    Analytics.logEvent(eventName, parameters: parameters)
}

func savePremiumStatus(isPremium: Bool) {
    let defaults = UserDefaults.standard
    defaults.set(isPremium, forKey: "IsPremiumUser")
}

func checkPremiumStatus() -> Bool {
    let defaults = UserDefaults.standard
    return defaults.bool(forKey: "IsPremiumUser")
}


func saveSubscriptionStatus(isSubscribed: Bool) {
    let defaults = UserDefaults.standard
    defaults.set(isSubscribed, forKey: "IsSubscribedUser")
}

func checkSubscriptionStatus() -> Bool {
    let defaults = UserDefaults.standard
    return defaults.bool(forKey: "IsSubscribedUser")
}
 
enum BannerPosition {
    case top
    case bottom
}
