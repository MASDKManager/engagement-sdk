import Foundation

final class Constant {
    static let shared = Constant()
    var purchaselyAPIKey = String()
    var rcAPIKey = String()
    var restoreToken = String()
    var adjustAppToken = String()
    var adjustEventToken = String()
    var adjustSubscriptionToken = String()
    var purchaseToken = String()
    var facebookAppID = String()
    var facebookDisplayName = String()
    var facebookClientToken = String()
    var mailchimpKey = String()
    var oneSignalKey = String()
    var interstitialKey = String()
    var bannerKey = String()

    func getValuesFromPlist() {
        if let plistPath = Bundle.main.path(forResource: "Constants", ofType: "plist"),
            let plistData = FileManager.default.contents(atPath: plistPath),
            let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any]{
            
            guard let sharedPurchaselyAPIKey = plist["Purchasely API Key"] as? String else {
                fatalError("Purchasely token not exist in Constants.plist")
            }
            self.purchaselyAPIKey = sharedPurchaselyAPIKey

            guard let sharedRCAPIKey = plist["RevenueCat API Key"] as? String else {
                fatalError("RevenueCat token not exist in Constants.plist")
            }
            self.rcAPIKey = sharedRCAPIKey
   
            guard let appTokenTemp = plist["Adjust App Token"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.adjustAppToken = appTokenTemp
            
            guard let adjustEventToken = plist["Adjust Event Token"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.adjustEventToken = adjustEventToken

            guard let adjustSubscriptionToken = plist["Adjust Subscription Token"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.adjustSubscriptionToken = adjustSubscriptionToken
             
            guard let restoreTokenTemp = plist["app_restored_store_purchase"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.restoreToken = restoreTokenTemp
            
            guard let interstitialKeyKeyTemp = plist["interstitialKey"] as? String  else {
               fatalError("interestial Key not exist in Constants.plist")
            }
            self.interstitialKey = interstitialKeyKeyTemp

            guard let bannerKeyTemp = plist["bannerKey"] as? String  else {
               fatalError("banner Key not exist in Constants.plist")
            }
            self.bannerKey = bannerKeyTemp

            self.facebookAppID = plist["FacebookAppID"] as? String ?? ""
            self.facebookDisplayName = plist["FacebookDisplayName"] as? String ?? ""
            self.facebookClientToken = plist["FacebookClientToken"] as? String ?? ""
            self.mailchimpKey = plist["MailchimpKey"] as? String  ?? ""
            self.oneSignalKey = plist["OneSignalKey"] as? String  ?? ""
         
        }
    }
}
