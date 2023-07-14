//
//  AdjustDelegate.swift
//  HTML-SDK
//
//  Created by Maarouf on 6/10/22.
//

import Foundation
import Adjust

class AdjustDelegateHandler: NSObject, AdjustDelegate {
 
    public func adjustDeeplinkResponse(_ deeplink: URL?) -> Bool
    {
        UserDefaults.standard.setValue(true, forKey: "IsPremium")
        UserDefaults.standard.synchronize()
       
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
