import SwiftUI
import Firebase

@main
struct FishIceGuideApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}

struct AppConfig {
    static let appID = "6758463821"
    static let devKey = "3FDH7vGhEeTCRgkbmy9e5S"
}
