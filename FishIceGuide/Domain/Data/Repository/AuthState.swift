import Foundation
import Firebase
import FirebaseAuth
import Combine

enum AuthState {
    case signedOut
    case guest
    case signedIn(User)
}

class AuthManager: ObservableObject {
    @Published var authState: AuthState = .signedOut
    @Published var currentUser: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let auth = Auth.auth()
    private let database = Database.database().reference()
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    static let shared = AuthManager()
    
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                if user.isAnonymous {
                    self?.authState = .guest
                    self?.loadOrCreateGuestProfile(userId: user.uid)
                } else {
                    self?.authState = .signedIn(user)
                    self?.loadUserProfile(userId: user.uid)
                }
            } else {
                self?.authState = .signedOut
                self?.currentUser = nil
            }
        }
    }
    
    // MARK: - Guest Mode
    func continueAsGuest(completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        
        auth.signInAnonymously { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                if let user = result?.user {
                    self?.createGuestProfile(userId: user.uid)
                    completion(.success(()))
                }
            }
        }
    }
    
    private func createGuestProfile(userId: String) {
        let guestProfile = UserProfile(
            id: userId,
            username: "Guest Fisher",
            email: "",
            avatarURL: nil,
            experienceLevel: .beginner,
            joinDate: Date(),
            totalCatches: 0,
            totalSpecies: 0,
            totalLocations: 0,
            achievementPoints: 0,
            favoriteFish: [],
            favoriteBaits: [],
            favoriteLocations: [],
            preferences: createDefaultPreferences(),
            statistics: createDefaultStatistics()
        )
        
        saveUserProfile(guestProfile)
    }
    
    private func loadOrCreateGuestProfile(userId: String) {
        database.child("users").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            if snapshot.exists(),
               let dict = snapshot.value as? [String: Any],
               let jsonData = try? JSONSerialization.data(withJSONObject: dict),
               let profile = try? JSONDecoder().decode(UserProfile.self, from: jsonData) {
                DispatchQueue.main.async {
                    self?.currentUser = profile
                }
            } else {
                self?.createGuestProfile(userId: userId)
            }
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                if let user = result?.user {
                    // Update display name
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = username
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("Error updating profile: \(error.localizedDescription)")
                        }
                    }
                    
                    self?.createUserProfile(userId: user.uid, username: username, email: email)
                    completion(.success(()))
                }
            }
        }
    }
    
    private func createUserProfile(userId: String, username: String, email: String) {
        let newProfile = UserProfile(
            id: userId,
            username: username,
            email: email,
            avatarURL: nil,
            experienceLevel: .beginner,
            joinDate: Date(),
            totalCatches: 0,
            totalSpecies: 0,
            totalLocations: 0,
            achievementPoints: 0,
            favoriteFish: [],
            favoriteBaits: [],
            favoriteLocations: [],
            preferences: createDefaultPreferences(),
            statistics: createDefaultStatistics()
        )
        
        saveUserProfile(newProfile)
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try auth.signOut()
            currentUser = nil
            authState = .signedOut
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Convert Guest to Full Account
    func convertGuestToFullAccount(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = auth.currentUser, user.isAnonymous else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not a guest user"])))
            return
        }
        
        isLoading = true
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user.link(with: credential) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                // Update profile with new info
                if let user = result?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = username
                    changeRequest.commitChanges { _ in }
                    
                    self?.updateUserProfile(userId: user.uid, email: email, username: username)
                }
                
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Load User Profile
    private func loadUserProfile(userId: String) {
        database.child("users").child(userId).observeSingleEvent(of: .value) { [weak self] snapshot in
            if snapshot.exists(),
               let dict = snapshot.value as? [String: Any],
               let jsonData = try? JSONSerialization.data(withJSONObject: dict),
               let profile = try? JSONDecoder().decode(UserProfile.self, from: jsonData) {
                DispatchQueue.main.async {
                    self?.currentUser = profile
                }
            } else {
                // Create profile if doesn't exist
                if let user = self?.auth.currentUser {
                    self?.createUserProfile(
                        userId: user.uid,
                        username: user.displayName ?? "Fisher",
                        email: user.email ?? ""
                    )
                }
            }
        }
    }
    
    // MARK: - Save User Profile
    func saveUserProfile(_ profile: UserProfile) {
        guard let encoded = try? JSONEncoder().encode(profile),
              let dict = try? JSONSerialization.jsonObject(with: encoded) as? [String: Any] else {
            return
        }
        
        database.child("users").child(profile.id).setValue(dict) { [weak self] error, _ in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                DispatchQueue.main.async {
                    self?.currentUser = profile
                }
            }
        }
    }
    
    // MARK: - Update User Profile
    func updateUserProfile(userId: String, email: String, username: String) {
        guard var profile = currentUser else { return }
        
        profile.email = email
        profile.username = username
        
        saveUserProfile(profile)
    }
    
    // MARK: - Helper Methods
    private func createDefaultPreferences() -> UserPreferences {
        return UserPreferences(
            notifications: NotificationPreferences(
                enablePushNotifications: true,
                fishingReminders: true,
                weatherAlerts: true,
                achievementNotifications: true,
                bestTimeAlerts: true
            ),
            units: UnitPreferences(
                useMetric: false,
                temperatureUnit: "F",
                distanceUnit: "miles"
            ),
            privacy: PrivacySettings(
                shareLocation: true,
                shareCatches: true,
                profileVisibility: "public"
            )
        )
    }
    
    private func createDefaultStatistics() -> UserStatistics {
        return UserStatistics(
            totalFishingTrips: 0,
            totalFishCaught: 0,
            uniqueSpecies: 0,
            largestCatch: nil,
            favoriteLocation: nil,
            mostSuccessfulBait: nil,
            averageCatchSize: nil,
            totalTimeSpent: 0
        )
    }
    
    var currentUserId: String? {
        return auth.currentUser?.uid
    }
    
    var isGuest: Bool {
        return auth.currentUser?.isAnonymous ?? false
    }
    
    deinit {
        if let handle = authStateHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }
}
