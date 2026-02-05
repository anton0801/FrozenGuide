import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import AppTrackingTransparency
import UserNotifications
import AppsFlyerLib

final class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    private let coordinator = AppCoordinator()
    private let pusher = PushCoordinator()
    private var tracker: TrackCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        coordinator.onMarketing = { [weak self] in self?.broadcast(marketing: $0) }
        coordinator.onRouting = { [weak self] in self?.broadcast(routing: $0) }
        tracker = TrackCoordinator(coord: coordinator)
        
        setupFirebase()
        setupPush()
        setupTracker()
        
        if let push = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            pusher.handle(payload: push)
        }
        
        observe()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
    }
    
    private func setupPush() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func setupTracker() {
        tracker?.setup()
    }
    
    private func observe() {
        NotificationCenter.default.addObserver(self, selector: #selector(active), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func active() {
        tracker?.launch()
    }
    
    private func broadcast(marketing data: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Notification.Name("ConversionDataReceived"), object: nil, userInfo: ["conversionData": data])
    }
    
    private func broadcast(routing data: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Notification.Name("deeplink_values"), object: nil, userInfo: ["deeplinksData": data])
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, error in
            guard error == nil, let token = token else { return }
            UserDefaults.standard.set(token, forKey: "fcm_token")
            UserDefaults.standard.set(token, forKey: "push_token")
            UserDefaults(suiteName: "group.frozen.vault")?.set(token, forKey: "shared_fcm")
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "fcm_time")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        pusher.handle(payload: notification.request.content.userInfo)
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        pusher.handle(payload: response.notification.request.content.userInfo)
        completionHandler()
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        pusher.handle(payload: userInfo)
        completionHandler(.newData)
    }
}
