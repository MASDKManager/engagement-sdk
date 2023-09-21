//
//  AppLovinManager.swift
//  ENG
//
//  Created by Maarouf on 7/14/23.

import Foundation
import AppLovinSDK
import AppsFlyerLib
import AppsFlyerAdRevenue
import AdSupport
import UIKit

fileprivate enum AdType  {
    case rewarded
    case interestial
    case banner
    case none
}

class AppLovinManager : NSObject {
    
    static let shared = AppLovinManager()
        
    private var interestialAdView : MAInterstitialAd?
    private var retryInterestialAttempt = 0.0
    
    private var rewardedAdView : MARewardedAd?
    private var retryRewardedAttempt = 0.0
    private var rewardUser = false
    
    private var onClose: ((Bool) -> Void)?
    
    private var adView: MAAdView!
    private var alsdk: ALSdk!
    
    private var keyExists = true
    
    override init() {
        
    }
}

extension AppLovinManager {
    
    func initializeAppLovin() {
        let settings = ALSdkSettings()
        alsdk = ALSdk.shared(withKey: Constant.shared.appLovinSdkKey,settings: settings )
       
   
#if DEBUG
        print("Not App Store build")
        let gpsadid = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        ALSdk.shared(withKey: Constant.shared.appLovinSdkKey)!.settings.testDeviceAdvertisingIdentifiers = [gpsadid]
#else
        print("App Store build")
#endif
        ALSdk.shared(withKey: Constant.shared.appLovinSdkKey)!.mediationProvider = ALMediationProviderMAX
        ALSdk.shared(withKey: Constant.shared.appLovinSdkKey)!.initializeSdk(completionHandler: { configuration in
            //         AppLovin SDK is initialized, start loading ads now or later if ad gate is reached
            print("AppLovin SDK is initialized, start loading ads now or later if ad gate is reached")
            
            if (Constant.shared.applovinInterstitialKey != "") {
                AppLovinManager.shared.loadInterestialAd()
            }
 
            
        })
    }
    
    func loadBannerAd(vc: UIViewController, adViewContainer: UIView) {
        
        if !keyExists{
            return
        }
            
        AppLovinManager.shared.adView = MAAdView(adUnitIdentifier: Constant.shared.applovinBannerKey,sdk: alsdk)
        AppLovinManager.shared.adView.delegate = self
         
        AppLovinManager.shared.adView.frame = adViewContainer.frame
        AppLovinManager.shared.adView.backgroundColor = .clear
        
        vc.view.addSubview(AppLovinManager.shared.adView)
         
        AppLovinManager.shared.adView.loadAd()
    }

    
    private func loadInterestialAd() {
        AppLovinManager.shared.interestialAdView = MAInterstitialAd(adUnitIdentifier: Constant.shared.applovinInterstitialKey,sdk: alsdk)
        AppLovinManager.shared.interestialAdView?.delegate = self
        AppLovinManager.shared.interestialAdView?.load()
    }
   
    func showInterestialAd(onClose : @escaping (Bool) -> ()) {
        
        if !keyExists{
            return
        }
            
        if (AppLovinManager.shared.interestialAdView?.isReady ?? false) {
            AppLovinManager.shared.interestialAdView?.show()
            AppLovinManager.shared.onClose = onClose
        } else {
            print("interestial ads failed to show")
            onClose(false)
        }
    }
    
    func unloadAds() {
        if !keyExists{
            return
        }
          
        // 1. Remove the loaded ad
        AppLovinManager.shared.adView?.removeFromSuperview()
        AppLovinManager.shared.adView = nil 
        AppLovinManager.shared.interestialAdView = nil
         
    }

}

extension AppLovinManager: MAAdDelegate {
    
    func didLoad(_ ad: MAAd) {
        print("Ad didLoad id: \(ad.adUnitIdentifier)")
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        EMobi.shared.delegate?.bannerAdDidFailToLoad(adUnitIdentifier: adUnitIdentifier, error: error.description)

        print("Ad didFailToLoadAd with id:\(adUnitIdentifier)")
        if (adUnitIdentifier == Constant.shared.applovinInterstitialKey) {
            // Interstitial ad failed to load
       
            AppLovinManager.shared.retryInterestialAttempt += 1
            let delaySec = pow(2.0, min(6.0, AppLovinManager.shared.retryInterestialAttempt))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
                AppLovinManager.shared.interestialAdView?.load()
            }
        }
 
    }
    
    func didDisplay(_ ad: MAAd) {
        
        if EMobi.shared.getMMP() == MMP.appsflyer {
            let adRevenueParams:[AnyHashable: Any] = [
                                kAppsFlyerAdRevenueAdUnit : ad.adUnitIdentifier,
                                kAppsFlyerAdRevenueAdType : ad.placement ?? "",
                                kAppsFlyerAdRevenuePlacement : ad.networkPlacement
                            ]
                            
            AppsFlyerAdRevenue.shared().logAdRevenue(
                monetizationNetwork: ad.networkName,
                mediationNetwork: MediationNetworkType.googleAdMob,
                eventRevenue: ad.revenue as NSNumber,
                revenueCurrency: "USD",
                additionalParameters: adRevenueParams)
            
        }
       
        print("Ad didDisplay \(ad.adUnitIdentifier)")
    }
    
    func didHide(_ ad: MAAd) {
        print("Ad didHide \(ad.adUnitIdentifier)")
        AppLovinManager.shared.onClose?(true)
    }
    
    func didClick(_ ad: MAAd) {
        print("Ad didClick \(ad.adUnitIdentifier)")
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        print("Ad didFail \(ad.adUnitIdentifier)")
        AppLovinManager.shared.onClose?(false)
    }
    
}
 
extension AppLovinManager : MARewardedAdDelegate {
    
    func didStartRewardedVideo(for ad: MAAd) {
        print("Ad didStartRewardedVideo id: \(ad.adUnitIdentifier)")
    }
    
    func didCompleteRewardedVideo(for ad: MAAd) {
        print("Ad didCompleteRewardedVideo id: \(ad.adUnitIdentifier)")
        AppLovinManager.shared.rewardUser = true
    }
    
    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        print("Ad didRewardUser id: \(ad.adUnitIdentifier)")
        AppLovinManager.shared.rewardUser = true
    }
    
}

extension AppLovinManager : MAAdViewAdDelegate {
    //Banner Delegate
    func didExpand(_ ad: MAAd) {
        print("Ad didExpand id: \(ad.adUnitIdentifier)")
    }
    
    func didCollapse(_ ad: MAAd) {
        print("Ad diddidCollapseExpand id: \(ad.adUnitIdentifier)")
    }
}
