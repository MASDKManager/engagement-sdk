//
//  OSSubscriptionObserver.swift
//  ENG
//
//  Created by Maarouf on 7/11/23.
//

import Foundation
import RevenueCat
import OneSignal

extension EMobi: OSSubscriptionObserver {
    public func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges) {
        if !stateChanges.from.isSubscribed && stateChanges.to.isSubscribed {
            // The user is subscribed
            // Either the user subscribed for the first time
            Purchases.shared.attribution.setOnesignalID(stateChanges.to.userId)
        }
    }
}
