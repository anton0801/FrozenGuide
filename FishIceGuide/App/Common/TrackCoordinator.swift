import AppsFlyerLib
import AppTrackingTransparency

final class TrackCoordinator: NSObject, AppsFlyerLibDelegate, DeepLinkDelegate {
    private var coord: AppCoordinator
    
    init(coord: AppCoordinator) {
        self.coord = coord
    }
    
    func setup() {
        let sdk = AppsFlyerLib.shared()
        sdk.appsFlyerDevKey = AppConfig.devKey
        sdk.appleAppID = AppConfig.appID
        sdk.delegate = self
        sdk.deepLinkDelegate = self
        sdk.isDebug = false
    }
    
    func launch() {
        if #available(iOS 14.0, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    AppsFlyerLib.shared().start()
                    UserDefaults.standard.set(status.rawValue, forKey: "att_code")
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "att_time")
                }
            }
        } else {
            AppsFlyerLib.shared().start()
        }
    }
    
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        coord.receiveMarketing(data)
    }
    
    func onConversionDataFail(_ error: Error) {
        var data: [AnyHashable: Any] = [:]
        data["error"] = true
        data["error_message"] = error.localizedDescription
        coord.receiveMarketing(data)
    }
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard case .found = result.status, let deepLink = result.deepLink else { return }
        coord.receiveRouting(deepLink.clickEvent)
    }
}
