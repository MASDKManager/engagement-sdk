import Foundation

final class Constant {
    static let shared = Constant()
    var rcAPIKey = String()
    var termOfUseLink = URL(string: "")
    var privacyPolicyLink = URL(string: "")
    var weeklyProductID = String()
    var monthlyProductID = String()
    var annualProductID = String()
    var restoreToken = String()
    var adjustAppToken = String()
    var adjustEventToken = String()
    var adjustSubscriptionToken = String()
    var purchaseToken = String()
    var openPaywallToken = String()
    var monthlyClickToken = String()
    var monthlyFailedToken = String()
    var monthlySuccessToken = String()
    var weeklyClickToken = String()
    var weeklyFailedToken = String()
    var weeklySuccessToken = String()
    var yearlyClickToken = String()
    var yearlyFailedToken = String()
    var yearlySuccessToken = String()
    var facebookAppID = String()
    var facebookDisplayName = String()
    var facebookClientToken = String()
    var mailchimpKey = String()
    var oneSignalKey = String()

    func getValuesFromPlist() {
        if let plistPath = Bundle.main.path(forResource: "Constants", ofType: "plist"),
            let plistData = FileManager.default.contents(atPath: plistPath),
           let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any]{
           
            

            guard let sharedRCAPIKey = plist["RevenueCat API Key"] as? String else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.rcAPIKey = sharedRCAPIKey

            guard let termOfUseLinkTemp = plist["Term of Use Link"]  as? String else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.termOfUseLink = URL(string: termOfUseLinkTemp)

            guard let privacyPolicyLinkTemp = plist["Privacy Policy Link"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.privacyPolicyLink = URL(string: privacyPolicyLinkTemp)

            guard let weeklyProductIDTemp = plist["Weekly Product ID"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.weeklyProductID = weeklyProductIDTemp

            guard let monthlyProductIDTemp = plist["Monthly Product ID"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.monthlyProductID = monthlyProductIDTemp

            guard let annualProductIDTemp = plist["Annual Product ID"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.annualProductID = annualProductIDTemp

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
            
            guard let purchaseTokenTemp = plist["in_app_purchase"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.purchaseToken = purchaseTokenTemp
            
            guard let openPaywallTemp = plist["app_open_billing_page"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.openPaywallToken = openPaywallTemp
            
            guard let monthlyClickedTemp = plist["app_monthly_subscription_click"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.monthlyClickToken = monthlyClickedTemp
            
            guard let monthlyFailedTemp = plist["app_monthly_subscription_failed"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.monthlyFailedToken = monthlyFailedTemp
            
            guard let monthlySuccessTemp = plist["app_monthly_subscription_success"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.monthlySuccessToken = monthlySuccessTemp
            
            guard let weeklyClickedTemp = plist["app_weekly_subscription_click"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.weeklyClickToken = weeklyClickedTemp
            
            guard let weeklyFailedTemp = plist["app_weekly_subscription_failed"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.weeklyFailedToken = weeklyFailedTemp
            
            guard let weeklySuccessTemp = plist["app_weekly_subscription_success"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.weeklySuccessToken = weeklySuccessTemp
            
            guard let yearlyClickedTemp = plist["app_yearly_subscription_click"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.yearlyClickToken = yearlyClickedTemp
            
            guard let yearlyFailedTemp = plist["app_yearly_subscription_failed"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.yearlyFailedToken = yearlyFailedTemp
            
            guard let yearlySuccessTemp = plist["app_yearly_subscription_success"] as? String  else {
                fatalError("Adjust token not exist in Constants.plist")
            }
            self.yearlySuccessToken = yearlySuccessTemp
                
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
