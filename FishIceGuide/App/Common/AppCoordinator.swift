import Foundation
import Combine

final class AppCoordinator: NSObject {
    var onMarketing: (([AnyHashable: Any]) -> Void)?
    var onRouting: (([AnyHashable: Any]) -> Void)?
    
    private var marketBuf: [AnyHashable: Any] = [:]
    private var routeBuf: [AnyHashable: Any] = [:]
    private var timer: Timer?
    private let key = "fr_coord_done"
    
    func receiveMarketing(_ data: [AnyHashable: Any]) {
        marketBuf = data
        scheduleTimer()
        if !routeBuf.isEmpty { combine() }
    }
    
    func receiveRouting(_ data: [AnyHashable: Any]) {
        guard !done() else { return }
        routeBuf = data
        onRouting?(data)
        timer?.invalidate()
        if !marketBuf.isEmpty { combine() }
    }
    
    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in self?.combine() }
    }
    
    private func combine() {
        var result = marketBuf
        routeBuf.forEach { k, v in
            let key = "deep_\(k)"
            if result[key] == nil { result[key] = v }
        }
        onMarketing?(result)
    }
    
    private func done() -> Bool {
        UserDefaults.standard.bool(forKey: key)
    }
}
