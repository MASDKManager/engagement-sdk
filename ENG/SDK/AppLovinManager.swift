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
    
    override init() {
        
    }
}

extension AppLovinManager {
    
    func initializeAppLovin() {
        
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
    
    func loadBannerAd(vc : UIViewController) {
        AppLovinManager.shared.adView = MAAdView(adUnitIdentifier: AdType.banner.rawValue)
        AppLovinManager.shared.adView.delegate = self
        
        // Banner height on iPhone and iPad is 50 and 90, respectively
        let height: CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 90 : 50
        
        // Stretch to the width of the screen for banners to be fully functional
        let width: CGFloat = UIScreen.main.bounds.width
        
        AppLovinManager.shared.adView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - height - 15, width: width, height: height)
        
        // Set background or background color for banners to be fully functional
        AppLovinManager.shared.adView.backgroundColor = .clear
        
        vc.view.addSubview(AppLovinManager.shared.adView)
        
        // Load the first ad
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
        if (AppLovinManager.shared.interestialAdView?.isReady ?? false) {
            AppLovinManager.shared.interestialAdView?.show()
            AppLovinManager.shared.onClose = onClose
        } else {
            print("interestial ads failed to show")
            onClose(false)
        }
    }
    
    func showRewardedAd(onClose : @escaping (Bool) -> ()) {
        if (AppLovinManager.shared.rewardedAdView?.isReady ?? false) {
            AppLovinManager.shared.rewardUser = false
            AppLovinManager.shared.rewardedAdView?.show()
            AppLovinManager.shared.onClose = onClose
        } else {
            print("rewarded ads failed to show")
            onClose(false)
        }
        
    }
}

extension AppLovinManager: MAAdDelegate {
    
    func didLoad(_ ad: MAAd) {
        print("Ad didLoad id: \(ad.adUnitIdentifier)")
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
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
