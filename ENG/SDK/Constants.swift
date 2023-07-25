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

    func getValuesFromPlist() {
        if let plistPath = Bundle.main.path(forResource: "Constants", ofType: "plist"),
            let plistData = FileManager.default.contents(atPath: plistPath),
           let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any]{
            
             guard let sharedPurchaselyAPIKey = plist["Purchasely API Key"] as? String else {
                 fatalError("Adjust token not exist in Constants.plist")
             }
             self.purchaselyAPIKey = sharedPurchaselyAPIKey

            guard let sharedRCAPIKey = plist["RevenueCat API Key"] as? String else {
                fatalError("Adjust token not exist in Constants.plist")
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
             
             
            guard let facebookAppID = plist["FacebookAppID"] as? String  else {
                fatalError("Facebook App ID not exist in Constants.plist")
            }
            self.facebookAppID = facebookAppID
            
            guard let facebookDisplayName = plist["FacebookDisplayName"] as? String  else {
                fatalError("Facebook Display Name token not exist in Constants.plist")
            }
            self.facebookDisplayName = facebookDisplayName
            
            guard let facebookClientToken = plist["FacebookClientToken"] as? String  else {
                fatalError("Facebook Client Token not exist in Constants.plist")
            }
            self.facebookClientToken = facebookClientToken
            
            guard let mailchimpKey = plist["MailchimpKey"] as? String  else {
                fatalError("Mailchimp Key not exist in Constants.plist")
            }
            self.mailchimpKey = mailchimpKey
            
            guard let oneSignalKey = plist["OneSignalKey"] as? String  else {
                fatalError("oneSignalKey Key not exist in Constants.plist")
            }
            self.oneSignalKey = oneSignalKey
        
             
        }
    }
}
