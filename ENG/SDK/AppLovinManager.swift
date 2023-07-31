//
//  AppLovinManager.swift
//  ENG
//
//  Created by Maarouf on 7/14/23.

import Foundation
import AppLovinSDK
import AdSupport
import UIKit

fileprivate enum AdType: String {
    case rewarded = ""
    case interestial = "894ed9e547ea2abf"
    case banner = "511b3c3305a7e86b"
    case none = "none"
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
    
    private var keyExists = true
    
    override init() {
        
    }
}

extension AppLovinManager {
    
    func initializeAppLovin() {
  
        if let value = Bundle.main.infoDictionary?["AppLovinSdkKey"] as? String, !value.isEmpty {
            keyExists =  true
        } else {
            keyExists = false
            return
        }
         
#if DEBUG
        print("Not App Store build")
        let gpsadid = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        ALSdk.shared()!.settings.testDeviceAdvertisingIdentifiers = [gpsadid]
#else
        print("App Store build")
#endif
        
        ALSdk.shared()!.mediationProvider = ALMediationProviderMAX
        ALSdk.shared()!.initializeSdk(completionHandler: { configuration in
            //         AppLovin SDK is initialized, start loading ads now or later if ad gate is reached
            print("AppLovin SDK is initialized, start loading ads now or later if ad gate is reached")
            
            if (AdType.interestial.rawValue != "") {
                AppLovinManager.shared.loadInterestialAd()
            }
            if (AdType.rewarded.rawValue != "") {
                AppLovinManager.shared.loadRewardedAd()
            }
            
        })
    }
    
    func loadBannerAd(vc: UIViewController, adViewContainer: UIView) {
        
        if !keyExists{
            return
        }
            
        AppLovinManager.shared.adView = MAAdView(adUnitIdentifier: AdType.banner.rawValue)
        AppLovinManager.shared.adView.delegate = self
         
        AppLovinManager.shared.adView.frame = adViewContainer.frame
        AppLovinManager.shared.adView.backgroundColor = .clear
        
        vc.view.addSubview(AppLovinManager.shared.adView)
         
        AppLovinManager.shared.adView.loadAd()
    }

    
    private func loadInterestialAd() {
        AppLovinManager.shared.interestialAdView = MAInterstitialAd(adUnitIdentifier: AdType.interestial.rawValue)
        AppLovinManager.shared.interestialAdView?.delegate = self
        AppLovinManager.shared.interestialAdView?.load()
    }
    
    private func loadRewardedAd() {
        AppLovinManager.shared.rewardedAdView = MARewardedAd.shared(withAdUnitIdentifier: AdType.rewarded.rawValue)
        AppLovinManager.shared.rewardedAdView?.delegate = self
        AppLovinManager.shared.rewardedAdView?.load()
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
      //  EMobi.shared.delegate?.bannerAdDidLoad(adUnitIdentifier: ad.adUnitIdentifier)
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        EMobi.shared.delegate?.bannerAdDidFailToLoad(adUnitIdentifier: adUnitIdentifier, error: error.description)

        print("Ad didFailToLoadAd with id:\(adUnitIdentifier)")
        if (adUnitIdentifier == AdType.interestial.rawValue) {
            // Interstitial ad failed to load
            // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
            
            AppLovinManager.shared.retryInterestialAttempt += 1
            let delaySec = pow(2.0, min(6.0, AppLovinManager.shared.retryInterestialAttempt))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
                AppLovinManager.shared.interestialAdView?.load()
            }
        } else if (adUnitIdentifier == AdType.rewarded.rawValue) {
            // Interstitial ad failed to load
            // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
            
            AppLovinManager.shared.retryRewardedAttempt += 1
            let delaySec = pow(2.0, min(6.0, AppLovinManager.shared.retryRewardedAttempt))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) {
                AppLovinManager.shared.rewardedAdView?.load()
            }
        }
    }
    
    func didDisplay(_ ad: MAAd) {
        print("Ad didDisplay \(ad.adUnitIdentifier)")
    }
    
    func didHide(_ ad: MAAd) {
        print("Ad didHide \(ad.adUnitIdentifier)")
        if (ad.adUnitIdentifier == AdType.rewarded.rawValue) {
            AppLovinManager.shared.onClose?(AppLovinManager.shared.rewardUser)
        } else {
            AppLovinManager.shared.onClose?(true)
        }
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
