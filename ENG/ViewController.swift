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
         
         // Call the logAnalyticsEvent function and update the eventLabel
         EMobi.shared.logAnalyticsEvent(name: "EventName", parameter: ["Parameter": "test"] );
     
         // Call the isActiveUser function and update the activeUserLabel
         let isActive = EMobi.shared.isActiveUser()
         activeUserLabel.text = "Is Active User: \(isActive)"
         
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
          
         DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
             EMobi.shared.showInterestialAd{ success in
                 print("ad closed")
             }
         }
         
         EMobi.shared.registerMailchimpEmail(email: "test@email.com")
          
    }
  
}
