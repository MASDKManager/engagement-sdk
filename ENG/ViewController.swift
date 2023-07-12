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
     var purchasedProductsLabel: UILabel!
       
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
         
         // Create and configure the purchasedProductsLabel
         purchasedProductsLabel = UILabel()
         purchasedProductsLabel.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(purchasedProductsLabel)
         NSLayoutConstraint.activate([
             purchasedProductsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             purchasedProductsLabel.topAnchor.constraint(equalTo: activeUserLabel.bottomAnchor, constant: 20)
         ])
         
         // Call the logAnalyticsEvent function and update the eventLabel
         EMobi.shared.logAnalyticsEvent(name: "EventName", parameter: ["Parameter": "test"] );
     
         // Call the isActiveUser function and update the activeUserLabel
         let isActive = EMobi.shared.isActiveUser()
         activeUserLabel.text = "Is Active User: \(isActive)"
         
         EMobi.shared.getAllPurchasedProductIdentifiers { ids in
             if let ids = ids {
                 self.purchasedProductsLabel.text = "Purchased Products: \(ids)"
             }  
         }

    }


}

