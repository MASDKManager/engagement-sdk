//
//  ViewController.swift
//  ENG
//
//  Created by Maarouf on 7/9/23.
//

import UIKit

class ViewController: UIViewController {
    
    var eventLabel: UILabel!
    var activeUserLabel: UILabel!
    var premUserLabel:UILabel!
    var purchasedProductsLabel: UILabel!
    var showButton: UIButton!
    var sdkInitializedObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkInitializedObserver = NotificationCenter.default.addObserver(forName: .sdkInitializedNotification, object: nil, queue: .main) { [weak self] _ in
            self?.handleSDKInitialized()
        }
        
    }
    
    func handleSDKInitialized() {
        
        // Create and configure the eventLabel
        eventLabel = UILabel()
        eventLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(eventLabel)
        NSLayoutConstraint.activate([
            eventLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eventLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        ])
        
        // Create and configure the activeUserLabel
        activeUserLabel = UILabel()
        activeUserLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activeUserLabel)
        NSLayoutConstraint.activate([
            activeUserLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activeUserLabel.topAnchor.constraint(equalTo: eventLabel.bottomAnchor, constant: 20)
        ])
        
        // Create and configure the activeUserLabel
        premUserLabel = UILabel()
        premUserLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(premUserLabel)
        NSLayoutConstraint.activate([
            premUserLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            premUserLabel.topAnchor.constraint(equalTo: activeUserLabel.bottomAnchor, constant: 20)
        ])
        
        // Create and configure the purchasedProductsLabel
        purchasedProductsLabel = UILabel()
        purchasedProductsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(purchasedProductsLabel)
        NSLayoutConstraint.activate([
            purchasedProductsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            purchasedProductsLabel.topAnchor.constraint(equalTo: premUserLabel.bottomAnchor, constant: 20)
        ])
        
        EMobi.shared.restorePurchases(success: {
            // Success callback: Reload content and display a success / thank you message to the user
            print("Products successfully restored!")
        }, failure: { error in
            // Failure callback: Display error
            print("Error restoring purchases: \(error.localizedDescription)")
        })
        
        // Call the logAnalyticsEvent function and update the eventLabel
        EMobi.shared.logAnalyticsEvent(name: "EventName", parameter: ["Parameter": "test"] );
        EMobi.shared.sendConversionEvent(  eventData: ["TransID": "1223"] );
        
        // Call the isActiveUser function and update the activeUserLabel
        let isActive = EMobi.shared.isSubscribedUser()
        activeUserLabel.text = "Is Subscribed User: \(isActive)"
        
        let isPremium = EMobi.shared.isPremiumUser()
        premUserLabel.text = "Is Premium User: \(isPremium)"
        
        EMobi.shared.getAllPurchasedProductIdentifiers { ids in
            if let ids = ids {
                self.purchasedProductsLabel.text = "Purchased Products: \(ids)"
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            
            // Banner height on iPhone and iPad is 50 and 90, respectively
            let height: CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 90 : 50
            
            // Stretch to the width of the screen for banners to be fully functional
            let width: CGFloat = UIScreen.main.bounds.width
            
            let frame = CGRect(x: 0, y: UIScreen.main.bounds.height - height - 15, width: width, height: height)
            
            let bannerView = UIView(frame: frame)
            bannerView.backgroundColor = UIColor.red // Set your desired background color
            
            
            EMobi.shared.loadBannerAd(vc: self, bannerView: bannerView  )
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
//            EMobi.shared.showInterestialAd{ success in
//                print("ad closed")
//            }
        }
        
        EMobi.shared.registerEmail(email: "test@email.com")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            
            // Call the showPaywall function
            EMobi.shared.showPaywall(type: .paywall, completionSuccess: { visualPaywall in
            
                print("Success")
                let isActive = EMobi.shared.isSubscribedUser()
                self.activeUserLabel.text = "Is Subscribed User: \(isActive)"
                
                if let paywallViewController = visualPaywall { 
                    paywallViewController.modalPresentationStyle = .fullScreen
                    self.present(paywallViewController, animated: true, completion: nil)
                }
                
            }, completionFailure: {
                // This block is executed when the user cancels the purchase 
                print("Purchase Cancelled")
            })
            
        } 
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissPaywall), name: Notification.Name("DismissPaywall"), object: nil)

    }
    
    @objc func dismissPaywall() {
        // Dismiss the paywall view controller
       print("dismiss Paywall")
    }

    deinit {
        // Remove observer when the view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
}
