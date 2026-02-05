import Foundation
import FirebaseDatabase
import AppsFlyerLib
import FirebaseCore
import FirebaseMessaging
import WebKit

// MARK: - Storage Service
protocol StorageProtocol {
    func putMarketing(_ model: MarketingModel)
    func getMarketing() -> MarketingModel
    func putRouting(_ model: RoutingModel)
    func getRouting() -> RoutingModel
    func putURL(_ url: String)
    func getURL() -> String?
    func putSetting(_ setting: String)
    func getSetting() -> String?
    func setVirginFalse()
    func isVirgin() -> Bool
    func putAlert(_ model: AlertModel)
    func getAlert() -> AlertModel
}

protocol CheckProtocol {
    func run() async throws -> Bool
}

protocol RemoteProtocol {
    func pullMarketing(device: String) async throws -> [String: Any]
    func pullURL(marketing: [String: Any]) async throws -> String
}

final class HTTPRemote: RemoteProtocol {
    
    private let session: URLSession
    
    init() {
        let conf = URLSessionConfiguration.ephemeral
        conf.timeoutIntervalForRequest = 30
        conf.timeoutIntervalForResource = 90
        conf.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        conf.urlCache = nil
        
        self.session = URLSession(configuration: conf)
    }
    
    func pullMarketing(device: String) async throws -> [String: Any] {
        let base = "https://gcdsdk.appsflyer.com/install_data/v4.0"
        let app = "id\(AppConfig.appID)"
        
        var comp = URLComponents(string: "\(base)/\(app)")
        comp?.queryItems = [
            URLQueryItem(name: "devkey", value: AppConfig.devKey),
            URLQueryItem(name: "device_id", value: device)
        ]
        
        guard let url = comp?.url else {
            throw RemoteError.badURL
        }
        
        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, resp) = try await session.data(for: req)
        
        guard let http = resp as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw RemoteError.badResponse
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw RemoteError.decodeFailed
        }
        
        return json
    }
    
    private var agent: String = WKWebView().value(forKey: "userAgent") as? String ?? ""
    
    func pullURL(marketing: [String: Any]) async throws -> String {
        guard let url = URL(string: "https://frozenguiide.com/config.php") else {
            throw RemoteError.badURL
        }
        
        var body: [String: Any] = marketing
        body["os"] = "iOS"
        body["af_id"] = AppsFlyerLib.shared().getAppsFlyerUID()
        body["bundle_id"] = Bundle.main.bundleIdentifier ?? ""
        body["firebase_project_id"] = FirebaseApp.app()?.options.gcmSenderID
        body["store_id"] = "id\(AppConfig.appID)"
        body["push_token"] = UserDefaults.standard.string(forKey: "push_token") ?? Messaging.messaging().fcmToken
        body["locale"] = Locale.preferredLanguages.first?.prefix(2).uppercased() ?? "EN"
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(agent, forHTTPHeaderField: "User-Agent")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        var lastErr: Error?
        let waits: [Double] = [4.5, 9.0, 18.0]
        
        for (idx, wait) in waits.enumerated() {
            do {
                let (data, resp) = try await session.data(for: req)
                
                guard let http = resp as? HTTPURLResponse else {
                    throw RemoteError.badResponse
                }
                
                if (200...299).contains(http.statusCode) {
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let ok = json["ok"] as? Bool,
                          ok,
                          let url = json["url"] as? String else {
                        throw RemoteError.decodeFailed
                    }
                    
                    return url
                } else if http.statusCode == 429 {
                    let backoff = wait * Double(idx + 1)
                    try await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
                    continue
                } else {
                    throw RemoteError.badResponse
                }
            } catch {
                lastErr = error
                if idx < waits.count - 1 {
                    try await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
                }
            }
        }
        
        throw lastErr ?? RemoteError.badResponse
    }
}

enum RemoteError: Error {
    case badURL
    case badResponse
    case decodeFailed
}

