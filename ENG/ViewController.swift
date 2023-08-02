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
       
     override func viewDidLoad() {
         super.viewDidLoad()
         
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
             EMobi.shared.showInterestialAd{ success in
                 print("ad closed")
             }
         }
         
         EMobi.shared.registerMailchimpEmail(email: "test@email.com")
 
         DispatchQueue.main.asyncAfter(deadline: .now() + 3333) {
             
             // Call the showPurchaselyPaywall function
             if let paywallViewController = EMobi.shared.showPurchaselyPaywall(type: .onboarding, completionSuccess: {
                 // This block is executed when the user completes a successful purchase or restore
                 // Present the premium content or any other view controller you want to show after purchase or restore
             
             }, completionFailure: {
                 // This block is executed when the user cancels the purchase
                 // Handle the cancellation behavior or show any relevant message
                 let alert = UIAlertController(title: "Purchase Cancelled", message: "You have cancelled the purchase.", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                 self.present(alert, animated: true, completion: nil)
             }) {
                 // If the paywallViewController is not nil, it means the paywall presentation was successful
                 // You can present the paywallViewController in your desired way
                 
                 paywallViewController.modalPresentationStyle = .fullScreen
                 self.present(paywallViewController, animated: true, completion: nil)
             }
  
         }
    }
  
}
