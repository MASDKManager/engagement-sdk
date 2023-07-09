//
//  Utils.swift
//  ENGSDK
//
//  Created by Maarouf on 6/27/23.
//

import Foundation
import FirebaseAnalytics


func getUserID() -> String {
    if let userID = UserDefaults.standard.string(forKey: "userID") {
        return userID
    } else {
        let newUserID = UUID().uuidString
        UserDefaults.standard.set(newUserID, forKey: "userID")
        return newUserID
    }
}

func logEvent(eventName: String, log: String) {
    let parameters = ["parameter": log]
    Analytics.logEvent(eventName, parameters: parameters as [String: Any])
}
