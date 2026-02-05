// CatchLogManager.swift - ИСПРАВЛЕННАЯ ВЕРСИЯ
import Foundation
import FirebaseDatabase
import FirebaseStorage
import UIKit

class CatchLogManager: ObservableObject {
    @Published var catches: [CatchEntry] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()
    private let authManager = AuthManager.shared
    
    private var currentObserverUserId: String? // НОВОЕ: отслеживаем для кого установлен observer
    
    // ИСПРАВЛЕНО: Используем только ОДИН observer
    func loadCatches(for userId: String) {
        // Если уже наблюдаем за этим пользователем, не создаем новый observer
        if currentObserverUserId == userId {
            print("⏭️ Already observing catches for user: \(userId)")
            return
        }
        
        // Останавливаем предыдущий observer
        if let previousUserId = currentObserverUserId {
            print("🛑 Stopping observer for previous user: \(previousUserId)")
            database.child("catches").child(previousUserId).removeAllObservers()
        }
        
        isLoading = true
        error = nil
        currentObserverUserId = userId
        
        print("📥 Starting observer for user: \(userId)")
        
        // ИСПОЛЬЗУЕМ .observe вместо .observeSingleEvent для автоматического обновления
        database.child("catches").child(userId)
            .observe(.value) { [weak self] snapshot in
                guard let self = self else { return }
                
                var catches: [CatchEntry] = []
                
                print("📦 Snapshot exists: \(snapshot.exists())")
                print("📦 Children count: \(snapshot.childrenCount)")
                
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let dict = snapshot.value as? [String: Any] {
                        
                        if let catchEntry = self.decodeCatchEntry(from: dict, id: snapshot.key) {
                            catches.append(catchEntry)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.catches = catches.sorted { $0.date > $1.date }
                    self.isLoading = false
                    print("✅ Loaded \(catches.count) catches")
                }
            }
    }
    
    private func decodeCatchEntry(from dict: [String: Any], id: String) -> CatchEntry? {
        guard let fishName = dict["fishName"] as? String,
              let locationName = dict["locationName"] as? String else {
            return nil
        }
        
        let date: Date
        if let timestamp = dict["date"] as? TimeInterval {
            date = Date(timeIntervalSince1970: timestamp / 1000)
        } else if let timestamp = dict["date"] as? Double {
            date = Date(timeIntervalSince1970: timestamp)
        } else {
            date = Date()
        }
        
        let time: Date
        if let timestamp = dict["time"] as? TimeInterval {
            time = Date(timeIntervalSince1970: timestamp / 1000)
        } else if let timestamp = dict["time"] as? Double {
            time = Date(timeIntervalSince1970: timestamp)
        } else {
            time = Date()
        }
        
        let createdAt: Date
        if let timestamp = dict["createdAt"] as? TimeInterval {
            createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        } else if let timestamp = dict["createdAt"] as? Double {
            createdAt = Date(timeIntervalSince1970: timestamp)
        } else {
            createdAt = Date()
        }
        
        return CatchEntry(
            id: id,
            userId: dict["userId"] as? String ?? "",
            fishId: dict["fishId"] as? String ?? "",
            fishName: fishName,
            date: date,
            time: time,
            locationName: locationName,
            latitude: dict["latitude"] as? Double,
            longitude: dict["longitude"] as? Double,
            weight: dict["weight"] as? Double,
            length: dict["length"] as? Double,
            quantity: dict["quantity"] as? Int ?? 1,
            weather: dict["weather"] as? String ?? "",
            temperature: dict["temperature"] as? Double,
            waterTemperature: dict["waterTemperature"] as? Double,
            moonPhase: dict["moonPhase"] as? String ?? "",
            windSpeed: dict["windSpeed"] as? Double,
            baitUsed: dict["baitUsed"] as? String ?? "",
            lineWeight: dict["lineWeight"] as? String,
            depth: dict["depth"] as? Double,
            photoURLs: dict["photoURLs"] as? [String] ?? [],
            notes: dict["notes"] as? String ?? "",
            isReleased: dict["isReleased"] as? Bool ?? false,
            createdAt: createdAt
        )
    }
    
    func addCatch(_ catchItem: CatchEntry, images: [UIImage] = []) {
        guard let userId = authManager.currentUserId else {
            self.error = "User not authenticated"
            print("❌ No user ID available")
            return
        }
        
        isLoading = true
        print("📤 Adding catch for user: \(userId)")
        
        uploadImages(images, catchId: catchItem.id) { [weak self] urls in
            var updatedCatch = catchItem
            updatedCatch.photoURLs = urls
            
            var dict: [String: Any] = [
                "userId": userId,
                "fishId": updatedCatch.fishId,
                "fishName": updatedCatch.fishName,
                "date": updatedCatch.date.timeIntervalSince1970 * 1000,
                "time": updatedCatch.time.timeIntervalSince1970 * 1000,
                "locationName": updatedCatch.locationName,
                "quantity": updatedCatch.quantity,
                "weather": updatedCatch.weather,
                "moonPhase": updatedCatch.moonPhase,
                "baitUsed": updatedCatch.baitUsed,
                "notes": updatedCatch.notes,
                "isReleased": updatedCatch.isReleased,
                "createdAt": updatedCatch.createdAt.timeIntervalSince1970 * 1000,
                "photoURLs": urls
            ]
            
            if let latitude = updatedCatch.latitude {
                dict["latitude"] = latitude
            }
            if let longitude = updatedCatch.longitude {
                dict["longitude"] = longitude
            }
            if let weight = updatedCatch.weight {
                dict["weight"] = weight
            }
            if let length = updatedCatch.length {
                dict["length"] = length
            }
            if let temperature = updatedCatch.temperature {
                dict["temperature"] = temperature
            }
            if let waterTemperature = updatedCatch.waterTemperature {
                dict["waterTemperature"] = waterTemperature
            }
            if let windSpeed = updatedCatch.windSpeed {
                dict["windSpeed"] = windSpeed
            }
            if let lineWeight = updatedCatch.lineWeight {
                dict["lineWeight"] = lineWeight
            }
            if let depth = updatedCatch.depth {
                dict["depth"] = depth
            }
            
            self?.database.child("catches").child(userId).child(updatedCatch.id)
                .setValue(dict) { error, _ in
                    DispatchQueue.main.async {
                        self?.isLoading = false
                        if let error = error {
                            self?.error = error.localizedDescription
                            print("❌ Error saving catch: \(error.localizedDescription)")
                        } else {
                            print("✅ Catch saved successfully!")
                            // Observer автоматически обновит данные
                        }
                    }
                }
        }
    }
    
    private func uploadImages(_ images: [UIImage], catchId: String, completion: @escaping ([String]) -> Void) {
        guard !images.isEmpty else {
            completion([])
            return
        }
        
        var uploadedURLs: [String] = []
        let group = DispatchGroup()
        
        for (index, image) in images.enumerated() {
            group.enter()
            
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                group.leave()
                continue
            }
            
            let imagePath = "catches/\(catchId)/image_\(index)_\(UUID().uuidString).jpg"
            let imageRef = storage.child(imagePath)
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if error == nil {
                    imageRef.downloadURL { url, error in
                        if let url = url {
                            uploadedURLs.append(url.absoluteString)
                        }
                        group.leave()
                    }
                } else {
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(uploadedURLs)
        }
    }
    
    func deleteCatch(_ catchItem: CatchEntry) {
        guard let userId = authManager.currentUserId else {
            print("❌ No user ID for deletion")
            return
        }
        
        print("🗑️ Deleting catch: \(catchItem.id)")
        
        database.child("catches").child(userId).child(catchItem.id).removeValue { error, _ in
            if let error = error {
                print("❌ Error deleting catch: \(error.localizedDescription)")
            } else {
                print("✅ Catch deleted successfully")
                // Observer автоматически обновит данные
            }
        }
    }
    
    func stopObserving() {
        guard let userId = currentObserverUserId else { return }
        print("🛑 Stopping all observers for user: \(userId)")
        database.child("catches").child(userId).removeAllObservers()
        currentObserverUserId = nil
    }
    
    deinit {
        stopObserving()
    }
}
