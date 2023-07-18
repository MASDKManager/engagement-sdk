//
//  EMobiDelegate.swift
//  ENG
//
//  Created by Maarouf on 7/17/23.
//

import Foundation 

protocol EMobiDelegate: AnyObject { 
    func bannerAdDidFailToLoad(adUnitIdentifier: String, error: String)
}
