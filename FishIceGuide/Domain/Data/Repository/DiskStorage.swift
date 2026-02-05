import Foundation

final class DiskStorage: StorageProtocol {
    
    private let vault = UserDefaults(suiteName: "group.frozen.vault")!
    private let backup = UserDefaults.standard
    private var quickAccess: [String: Any] = [:]
    
    // UNIQUE: Key scheme with fr_ prefix
    private enum Store {
        static let marketing = "fr_marketing_info"
        static let routing = "fr_routing_info"
        static let url = "fr_target_url"
        static let setting = "fr_app_setting"
        static let virgin = "fr_virgin_flag"
        static let alertOK = "fr_alert_ok"
        static let alertNO = "fr_alert_no"
        static let alertDate = "fr_alert_date"
    }
    
    init() {
        warmUp()
    }
    
    func putMarketing(_ model: MarketingModel) {
        if let str = toJSON(model.info) {
            vault.set(str, forKey: Store.marketing)
            quickAccess[Store.marketing] = str
        }
    }
    
    func getAlert() -> AlertModel {
        let granted = vault.bool(forKey: Store.alertOK)
        let denied = vault.bool(forKey: Store.alertNO)
        let ts = vault.double(forKey: Store.alertDate)
        let date = ts > 0 ? Date(timeIntervalSince1970: ts / 1000) : nil
        
        return AlertModel(granted: granted, denied: denied, askedAt: date)
    }
    
    
    func getMarketing() -> MarketingModel {
        if let str = quickAccess[Store.marketing] as? String ?? vault.string(forKey: Store.marketing),
           let dict = fromJSON(str) {
            return MarketingModel(info: dict)
        }
        return .empty
    }
    
    private func fromJSON(_ str: String) -> [String: String]? {
        guard let data = str.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        
        var result: [String: String] = [:]
        for (key, value) in dict {
            result[key] = "\(value)"
        }
        return result
    }
    
    private func protect(_ str: String) -> String {
        Data(str.utf8).base64EncodedString()
            .replacingOccurrences(of: "=", with: "?")
            .replacingOccurrences(of: "+", with: ":")
    }
    
    private func unprotect(_ str: String) -> String? {
        let base64 = str
            .replacingOccurrences(of: "?", with: "=")
            .replacingOccurrences(of: ":", with: "+")
        
        guard let data = Data(base64Encoded: base64),
              let str = String(data: data, encoding: .utf8) else { return nil }
        return str
    }
    
    func putRouting(_ model: RoutingModel) {
        if let str = toJSON(model.info) {
            let protected = protect(str)
            vault.set(protected, forKey: Store.routing)
        }
    }
    
    func getRouting() -> RoutingModel {
        if let protected = vault.string(forKey: Store.routing),
           let str = unprotect(protected),
           let dict = fromJSON(str) {
            return RoutingModel(info: dict)
        }
        return .empty
    }
    
    func putURL(_ url: String) {
        vault.set(url, forKey: Store.url)
        backup.set(url, forKey: Store.url)
        quickAccess[Store.url] = url
    }
    
    func getURL() -> String? {
        quickAccess[Store.url] as? String 
            ?? vault.string(forKey: Store.url) 
            ?? backup.string(forKey: Store.url)
    }
    
    func putSetting(_ setting: String) {
        vault.set(setting, forKey: Store.setting)
    }
    
    func getSetting() -> String? {
        vault.string(forKey: Store.setting)
    }
    
    func setVirginFalse() {
        vault.set(true, forKey: Store.virgin)
    }
    
    func isVirgin() -> Bool {
        !vault.bool(forKey: Store.virgin)
    }
    
    func putAlert(_ model: AlertModel) {
        vault.set(model.granted, forKey: Store.alertOK)
        vault.set(model.denied, forKey: Store.alertNO)
        
        if let date = model.askedAt {
            vault.set(date.timeIntervalSince1970 * 1000, forKey: Store.alertDate)
        }
    }
    
    private func warmUp() {
        if let url = vault.string(forKey: Store.url) {
            quickAccess[Store.url] = url
        }
    }
    
    private func toJSON(_ dict: [String: String]) -> String? {
        let anyDict = dict.mapValues { $0 as Any }
        guard let data = try? JSONSerialization.data(withJSONObject: anyDict),
              let str = String(data: data, encoding: .utf8) else { return nil }
        return str
    }
    
}
