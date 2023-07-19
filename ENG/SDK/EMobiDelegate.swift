//
//  EMobiDelegate.swift
//  ENG
//
//  Created by Maarouf on 7/17/23.
//

import Foundation 

public protocol EMobiDelegate: AnyObject { 
    func bannerAdDidFailToLoad(adUnitIdentifier: String, error: String)
}
