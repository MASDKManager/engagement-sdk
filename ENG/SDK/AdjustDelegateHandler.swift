//
//  AdjustDelegate.swift
//  HTML-SDK
//
//  Created by Maarouf on 6/10/22.
//

import Foundation
import Adjust
import AppLovinSDK

class AdjustDelegateHandler: NSObject, AdjustDelegate, MAAdRevenueDelegate {

    func didPayRevenue(for ad: MAAd) {
        if let adjustAdRevenue = ADJAdRevenue(source: ADJAdRevenueSourceAppLovinMAX) {
            adjustAdRevenue.setRevenue(ad.revenue, currency: "USD")
            adjustAdRevenue.setAdRevenueNetwork(ad.networkName)
            adjustAdRevenue.setAdRevenueUnit(ad.adUnitIdentifier)
            adjustAdRevenue.setAdRevenuePlacement(ad.placement ?? "")
          
            Adjust.trackAdRevenue(adjustAdRevenue)
        }
    }

    public func adjustDeeplinkResponse(_ deeplink: URL?) -> Bool
    {
        EMobi.shared.setPremiumUser(isPremium: true)
        savePremiumStatus(isPremium: EMobi.shared.isPremiumUser()) 
      
        return true
    }
      
    public func adjustEventTrackingSucceeded(_ eventSuccessResponseData: ADJEventSuccess?)
    {
        print(eventSuccessResponseData?.jsonResponse ?? [:])
     }

    public func adjustEventTrackingFailed(_ eventFailureResponseData: ADJEventFailure?)
    {
      print(eventFailureResponseData?.jsonResponse ?? [:])
     }
    
    public func adjustSessionTrackingSucceeded(_ sessionSuccessResponseData: ADJSessionSuccess?)
    {
        print(sessionSuccessResponseData?.jsonResponse ?? [:])
     }
    
    public func adjustSessionTrackingFailed(_ sessionFailureResponseData: ADJSessionFailure?)
    {
      print(sessionFailureResponseData?.jsonResponse ?? [:])
     }
    
}
