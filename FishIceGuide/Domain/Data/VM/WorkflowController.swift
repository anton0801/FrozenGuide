import Foundation
import Combine
import UIKit
import UserNotifications
import Network
import AppsFlyerLib

@MainActor
final class WorkflowController: ObservableObject {
    
    @Published private(set) var workflow: WorkflowModel = .initial
    @Published var displayAlert: Bool = false
    @Published var displayOffline: Bool = false
    @Published var goToContentView: Bool = false
    @Published var goToFrozenView: Bool = false
    
    private let storage: StorageProtocol
    private let checker: CheckProtocol
    private let remote: RemoteProtocol
    
    private var marketing: MarketingModel = .empty
    private var routing: RoutingModel = .empty
    private var alert: AlertModel = .initial
    private var setup: SetupModel = .initial
    
    private var countdown: Task<Void, Never>?
    private var processing = false
    
    private let network = NWPathMonitor()
    
    init(
        storage: StorageProtocol = DiskStorage(),
        checker: CheckProtocol = FirebaseCheck(),
        remote: RemoteProtocol = HTTPRemote()
    ) {
        self.storage = storage
        self.checker = checker
        self.remote = remote
        
        restore()
        watchNetwork()
        start()
    }
    
    func onMarketing(_ data: [String: Any]) {
        let converted = convert(data)
        marketing = MarketingModel(info: converted)
        storage.putMarketing(marketing)
        
        Task {
            await verify()
        }
    }
    
    func onRouting(_ data: [String: Any]) {
        let converted = convert(data)
        routing = RoutingModel(info: converted)
        storage.putRouting(routing)
    }
    
    func allowAlerts() {
        askPermission { [weak self] ok in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                self.alert = AlertModel(
                    granted: ok,
                    denied: !ok,
                    askedAt: Date()
                )
                
                self.storage.putAlert(self.alert)
                
                if ok {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                self.displayAlert = false
                self.goToFrozenView = true
            }
        }
    }
    
    func skipAlerts() {
        alert = AlertModel(
            granted: false,
            denied: false,
            askedAt: Date()
        )
        
        storage.putAlert(alert)
        displayAlert = false
    }
    
    private func restore() {
        marketing = storage.getMarketing()
        routing = storage.getRouting()
        alert = storage.getAlert()
        
        setup = SetupModel(
            virgin: storage.isVirgin(),
            storedURL: storage.getURL(),
            setting: storage.getSetting()
        )
    }
    
    private func start() {
        updateWorkflow(.processing)
        schedule()
    }
    
    private func schedule() {
        countdown = Task {
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            
            guard !processing else { return }
            
            await MainActor.run {
                self.updateWorkflow(.standby)
                self.goToContentView = true
            }
        }
    }
    
    private func watchNetwork() {
        network.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self = self, !self.processing else { return }
                
                if path.status == .satisfied {
                    self.displayOffline = false
                } else {
                    self.displayOffline = true
                }
            }
        }
        network.start(queue: .global(qos: .background))
    }
    
    private func verify() async {
        guard workflow.targetURL == nil else { return }
        
        updateWorkflow(.verifying)
        
        do {
            let valid = try await checker.run()
            
            if valid {
                updateWorkflow(.verified)
                await execute()
            } else {
                updateWorkflow(.standby)
                goToContentView = true
            }
        } catch {
            updateWorkflow(.standby)
            goToContentView = true
        }
    }
    
    private func execute() async {
        guard marketing.hasData else {
            loadStored()
            return
        }
        
        if let temp = UserDefaults.standard.string(forKey: "temp_url") {
            complete(url: temp)
            return
        }
        
        if needsVirginFlow() {
            await runVirginFlow()
            return
        }
        
        await fetchURL()
    }
    
    private func needsVirginFlow() -> Bool {
        setup.virgin && marketing.isOrganic
    }
    
    private func runVirginFlow() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        do {
            let device = AppsFlyerLib.shared().getAppsFlyerUID()
            let pulled = try await remote.pullMarketing(device: device)
            
            var combined = pulled
            let routingDict = unconvert(routing.info)
            
            for (key, val) in routingDict {
                if combined[key] == nil {
                    combined[key] = val
                }
            }
            
            let converted = convert(combined)
            marketing = MarketingModel(info: converted)
            storage.putMarketing(marketing)
            
            await fetchURL()
        } catch {
            updateWorkflow(.standby)
            goToContentView = true
        }
    }
    
    private func fetchURL() async {
        do {
            let marketingDict = unconvert(marketing.info)
            let url = try await remote.pullURL(marketing: marketingDict)
            
            storage.putURL(url)
            storage.putSetting("Active")
            storage.setVirginFalse()
            
            setup = SetupModel(
                virgin: false,
                storedURL: url,
                setting: "Active"
            )
            
            complete(url: url)
        } catch {
            loadStored()
        }
    }
    
    private func loadStored() {
        if let stored = setup.storedURL {
            complete(url: stored)
        } else {
            updateWorkflow(.standby)
            goToContentView = true
        }
    }
    
    private func complete(url: String) {
        guard !processing else { return }
        
        countdown?.cancel()
        processing = true
        
        workflow = WorkflowModel(
            status: .active,
            targetURL: url,
            locked: true
        )
        
        if alert.shouldAsk {
            displayAlert = true
        } else {
            goToFrozenView = true
        }
    }
    
    private func updateWorkflow(_ status: WorkflowModel.WorkflowStatus) {
        workflow = WorkflowModel(
            status: status,
            targetURL: workflow.targetURL,
            locked: workflow.locked
        )
    }
    
    private func askPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { ok, _ in
            completion(ok)
        }
    }
    
    private func convert(_ dict: [String: Any]) -> [String: String] {
        var result: [String: String] = [:]
        for (key, val) in dict {
            result[key] = "\(val)"
        }
        return result
    }
    
    private func unconvert(_ dict: [String: String]) -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, val) in dict {
            result[key] = val
        }
        return result
    }
    
}
