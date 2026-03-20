import Foundation
import SwiftUI
import Combine

class GuardStore: ObservableObject {

    @Published var children: [ChildProfile] = []
    @Published var selectedChild: ChildProfile? = nil
    @Published var alerts: [ParentalAlert] = []
    @Published var isParentAuthenticated: Bool = true
    @Published var showingPINSetup: Bool = false
    @Published var parentPIN: String = "1234"

    private let childrenKey = "guard_children_v1"

    init() {
        loadData()
        if children.isEmpty { setupSampleChildren() }
        selectedChild = children.first
    }

    // MARK: - Child Management

    func addChild(_ child: ChildProfile) {
        children.append(child)
        if selectedChild == nil { selectedChild = child }
        saveData()
    }

    func updateChild(_ child: ChildProfile) {
        if let i = children.firstIndex(where: { $0.id == child.id }) {
            children[i] = child
            if selectedChild?.id == child.id { selectedChild = child }
            saveData()
        }
    }

    func removeChild(id: UUID) {
        children.removeAll { $0.id == id }
        if selectedChild?.id == id { selectedChild = children.first }
        saveData()
    }

    func selectChild(_ child: ChildProfile) {
        selectedChild = child
    }

    var allAlerts: [ParentalAlert] {
        children.flatMap { $0.alerts }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var unreadAlertsCount: Int {
        allAlerts.filter { !$0.isRead }.count
    }

    func markAllAlertsRead() {
        for i in children.indices {
            for j in children[i].alerts.indices {
                children[i].alerts[j].isRead = true
            }
        }
        saveData()
    }

    // MARK - - Block/Allow Apps

    func toggleBlockApp(childID: UUID, appName: String) {
        if let i = children.firstIndex(where: { $0.id == childID }),
           let j = children[i].appUsage.firstIndex(where: { $0.appName == appName }) {
            children[i].appUsage[j].isBlocked.toggle()
            saveData()
        }
    }

    // MARK - - Content Filter

    func setContentFilter(childID: UUID, level: ContentFilterLevel) {
        if let i = children.firstIndex(where: { $0.id == childID }) {
            children[i].contentFilter = level
            if selectedChild?.id == childID { selectedChild = children[i] }
            saveData()
        }
    }

    // MARK - - Screen Time Limit

    func setScreenTimeLimit(childID: UUID, limit: TimeInterval) {
        if let i = children.firstIndex(where: { $0.id == childID }) {
            children[i].screenTimeLimit = limit
            if selectedChild?.id == childID { selectedChild = children[i] }
            saveData()
        }
    }

    // MARK - - Sample Data

    private func setupSampleChildren() {
        let cal = Calendar.current
        let now = Date()

        let sofia = ChildProfile(
            id: UUID(),
            name: "Sofia",
            age: 10,
            avatarColor: "#FF2D55",
            deviceName: "Sofia's iPhone",
            isOnline: true,
            lastSeen: now,
            screenTimeToday: 4800,
            screenTimeLimit: 7200,
            appUsage: [
                AppUsageRecord(id: UUID(), appName: "TikTok", appIcon: "music.note",
                               category: .social, timeSpent: 2100, launchCount: 12,
                               isBlocked: false, timeLimit: 1800, lastUsed: now),
                AppUsageRecord(id: UUID(), appName: "YouTube", appIcon: "play.rectangle.fill",
                               category: .entertainment, timeSpent: 1800, launchCount: 8,
                               isBlocked: false, timeLimit: nil, lastUsed: now),
                AppUsageRecord(id: UUID(), appName: "Minecraft", appIcon: "gamecontroller.fill",
                               category: .games, timeSpent: 900, launchCount: 3,
                               isBlocked: false, timeLimit: 3600, lastUsed: now),
                AppUsageRecord(id: UUID(), appName: "Khan Academy", appIcon: "book.fill",
                               category: .education, timeSpent: 600, launchCount: 4,
                               isBlocked: false, timeLimit: nil, lastUsed: now),
                AppUsageRecord(id: UUID(), appName: "Instagram", appIcon: "camera.fill",
                               category: .social, timeSpent: 400, launchCount: 6,
                               isBlocked: true, timeLimit: nil, lastUsed: now),
            ],
            locationHistory: [
                LocationRecord(id: UUID(), latitude: 37.785, longitude: -122.406,
                               placeName: "Home", timestamp: now, isSafeZone: true),
            ],
            alerts: [
                ParentalAlert(id: UUID(), type: .screenTimeExceeded,
                              message: "TikTok time limit exceeded by 5 minutes",
                              timestamp: cal.date(byAdding: .minute, value: -15, to: now)!,
                              isRead: false, childName: "Sofia", severity: .medium),
                ParentalAlert(id: UUID(), type: .blockedApp,
                              message: "Attempted to open Instagram (blocked)",
                              timestamp: cal.date(byAdding: .hour, value: -1, to: now)!,
                              isRead: false, childName: "Sofia", severity: .high),
            ],
            contentFilter: .moderate,
            allowedApps: ["Khan Academy", "YouTube", "TikTok", "Minecraft"],
            blockedApps: ["Instagram", "Snapchat", "Discord"],
            bedtimeStart: cal.date(bySettingHour: 21, minute: 0, second: 0, of: now)!,
            bedtimeEnd: cal.date(bySettingHour: 7, minute: 0, second: 0, of: now)!,
            bedtimeEnabled: true,
            weeklyScreenTime: [1.2, 1.8, 2.1, 1.5, 2.4, 3.1, 1.3]
        )

        let lucas = ChildProfile(
            id: UUID(),
            name: "Lucas",
            age: 14,
            avatarColor: "#007AFF",
            deviceName: "Lucas's iPhone",
            isOnline: false,
            lastSeen: cal.date(byAdding: .hour, value: -2, to: now)!,
            screenTimeToday: 9600,
            screenTimeLimit: 10800,
            appUsage: [
                AppUsageRecord(id: UUID(), appName: "Roblox", appIcon: "gamecontroller.fill",
                               category: .games, timeSpent: 3600, launchCount: 5,
                               isBlocked: false, timeLimit: 7200, lastUsed: now),
                AppUsageRecord(id: UUID(), appName: "YouTube", appIcon: "play.rectangle.fill",
                               category: .entertainment, timeSpent: 2400, launchCount: 15,
                               isBlocked: false, timeLimit: nil, lastUsed: now),
                AppUsageRecord(id: UUID(), appName: "WhatsApp", appIcon: "message.fill",
                               category: .communication, timeSpent: 1800, launchCount: 22,
                               isBlocked: false, timeLimit: nil, lastUsed: now),
                AppUsageRecord(id: UUID(), appName: "Spotify", appIcon: "music.note",
                               category: .entertainment, timeSpent: 1200, launchCount: 3,
                               isBlocked: false, timeLimit: nil, lastUsed: now),
                AppUsageRecord(id: UUID(), appName: "Duolingo", appIcon: "book.fill",
                               category: .education, timeSpent: 600, launchCount: 2,
                               isBlocked: false, timeLimit: nil, lastUsed: now),
            ],
            locationHistory: [
                LocationRecord(id: UUID(), latitude: 37.790, longitude: -122.410,
                               placeName: "School", timestamp: now, isSafeZone: true),
            ],
            alerts: [
                ParentalAlert(id: UUID(), type: .bedtimeViolation,
                              message: "Device used after bedtime at 11:30 PM",
                              timestamp: cal.date(byAdding: .hour, value: -8, to: now)!,
                              isRead: true, childName: "Lucas", severity: .high),
            ],
            contentFilter: .relaxed,
            allowedApps: ["Roblox", "YouTube", "WhatsApp", "Spotify", "Duolingo"],
            blockedApps: ["TikTok", "Discord"],
            bedtimeStart: cal.date(bySettingHour: 22, minute: 30, second: 0, of: now)!,
            bedtimeEnd: cal.date(bySettingHour: 7, minute: 30, second: 0, of: now)!,
            bedtimeEnabled: true,
            weeklyScreenTime: [2.1, 2.8, 3.2, 2.9, 3.6, 4.2, 2.7]
        )

        children = [sofia, lucas]
        saveData()
    }

    // MARK - - Persistence

    private func saveData() {
        if let d = try? JSONEncoder().encode(children) {
            UserDefaults.standard.set(d, forKey: childrenKey)
        }
    }

    private func loadData() {
        if let d = UserDefaults.standard.data(forKey: childrenKey),
           let loaded = try? JSONDecoder().decode([ChildProfile].self, from: d) {
            children = loaded
        }
    }
}
