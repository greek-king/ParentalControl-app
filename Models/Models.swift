import Foundation
import SwiftUI

// MARK: - Child Profile
struct ChildProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var age: Int
    var avatarColor: String
    var deviceName: String
    var isOnline: Bool
    var lastSeen: Date
    var screenTimeToday: TimeInterval
    var screenTimeLimit: TimeInterval
    var appUsage: [AppUsageRecord]
    var locationHistory: [LocationRecord]
    var alerts: [ParentalAlert]
    var contentFilter: ContentFilterLevel
    var allowedApps: [String]
    var blockedApps: [String]
    var bedtimeStart: Date
    var bedtimeEnd: Date
    var bedtimeEnabled: Bool
    var weeklyScreenTime: [Double]

    var screenTimePercent: Double {
        guard screenTimeLimit > 0 else { return 0 }
        return min(1.0, screenTimeToday / screenTimeLimit)
    }

    var formattedScreenTime: String {
        let h = Int(screenTimeToday) / 3600
        let m = (Int(screenTimeToday) % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    var formattedLimit: String {
        let h = Int(screenTimeLimit) / 3600
        let m = (Int(screenTimeLimit) % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    var statusColor: Color {
        if screenTimePercent >= 1.0 { return .red }
        if screenTimePercent >= 0.8 { return Color(hex: "#FF9500") }
        return Color(hex: "#34C759")
    }

    var initials: String {
        let parts = name.components(separatedBy: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))"
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Content Filter Level
enum ContentFilterLevel: String, Codable, CaseIterable {
    case strict   = "Strict"
    case moderate = "Moderate"
    case relaxed  = "Relaxed"
    case custom   = "Custom"

    var color: Color {
        switch self {
        case .strict:   return Color(hex: "#FF3B30")
        case .moderate: return Color(hex: "#FF9500")
        case .relaxed:  return Color(hex: "#34C759")
        case .custom:   return Color(hex: "#007AFF")
        }
    }

    var icon: String {
        switch self {
        case .strict:   return "shield.fill"
        case .moderate: return "shield.lefthalf.filled"
        case .relaxed:  return "shield"
        case .custom:   return "slider.horizontal.3"
        }
    }

    var description: String {
        switch self {
        case .strict:   return "Blocks all adult content, social media & games"
        case .moderate: return "Blocks adult content, limits social media"
        case .relaxed:  return "Blocks adult content only"
        case .custom:   return "Your custom settings"
        }
    }
}

// MARK: - App Usage Record
struct AppUsageRecord: Identifiable, Codable {
    let id: UUID
    var appName: String
    var appIcon: String
    var category: AppCategory
    var timeSpent: TimeInterval
    var launchCount: Int
    var isBlocked: Bool
    var timeLimit: TimeInterval?
    var lastUsed: Date

    var formattedTime: String {
        let h = Int(timeSpent) / 3600
        let m = (Int(timeSpent) % 3600) / 60
        return h > 0 ? "\(h)h \(m)m" : "\(m)m"
    }

    var color: Color { category.color }
}

enum AppCategory: String, Codable, CaseIterable {
    case social       = "Social"
    case games        = "Games"
    case education    = "Education"
    case entertainment = "Entertainment"
    case productivity = "Productivity"
    case communication = "Communication"
    case other        = "Other"

    var color: Color {
        switch self {
        case .social:        return Color(hex: "#FF2D55")
        case .games:         return Color(hex: "#FF9500")
        case .education:     return Color(hex: "#34C759")
        case .entertainment: return Color(hex: "#AF52DE")
        case .productivity:  return Color(hex: "#007AFF")
        case .communication: return Color(hex: "#00C7BE")
        case .other:         return Color(hex: "#8E8E93")
        }
    }

    var icon: String {
        switch self {
        case .social:        return "person.2.fill"
        case .games:         return "gamecontroller.fill"
        case .education:     return "book.fill"
        case .entertainment: return "tv.fill"
        case .productivity:  return "briefcase.fill"
        case .communication: return "message.fill"
        case .other:         return "square.grid.2x2.fill"
        }
    }
}

// MARK: - Location Record
struct LocationRecord: Identifiable, Codable {
    let id: UUID
    var latitude: Double
    var longitude: Double
    var placeName: String
    var timestamp: Date
    var isSafeZone: Bool

    var formattedTime: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: timestamp)
    }
}

// MARK: - Safe Zone
struct SafeZone: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var latitude: Double
    var longitude: Double
    var radius: Double
    var color: String
}

// MARK: - Parental Alert
struct ParentalAlert: Identifiable, Codable {
    let id: UUID
    var type: AlertType
    var message: String
    var timestamp: Date
    var isRead: Bool
    var childName: String
    var severity: AlertSeverity

    var formattedTime: String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: timestamp, relativeTo: Date())
    }

    enum AlertType: String, Codable {
        case screenTimeExceeded = "Screen Time"
        case locationLeft       = "Location"
        case blockedApp         = "App Blocked"
        case bedtimeViolation   = "Bedtime"
        case newContact         = "New Contact"
        case searchAlert        = "Search Alert"
        case lowBattery         = "Low Battery"
        case deviceOffline      = "Device Offline"

        var icon: String {
            switch self {
            case .screenTimeExceeded: return "clock.fill"
            case .locationLeft:       return "location.fill"
            case .blockedApp:         return "xmark.circle.fill"
            case .bedtimeViolation:   return "moon.fill"
            case .newContact:         return "person.badge.plus"
            case .searchAlert:        return "magnifyingglass"
            case .lowBattery:         return "battery.25"
            case .deviceOffline:      return "wifi.slash"
            }
        }
    }

    enum AlertSeverity: String, Codable {
        case low, medium, high

        var color: Color {
            switch self {
            case .low:    return Color(hex: "#34C759")
            case .medium: return Color(hex: "#FF9500")
            case .high:   return Color(hex: "#FF3B30")
            }
        }
    }
}

// MARK: - Screen Time Rule
struct ScreenTimeRule: Identifiable, Codable {
    let id: UUID
    var title: String
    var startTime: Date
    var endTime: Date
    var days: [Int]
    var isEnabled: Bool
    var ruleType: RuleType

    enum RuleType: String, Codable {
        case downtime   = "Downtime"
        case appLimit   = "App Limit"
        case bedtime    = "Bedtime"
        case schoolTime = "School Time"

        var icon: String {
            switch self {
            case .downtime:   return "moon.stars.fill"
            case .appLimit:   return "hourglass"
            case .bedtime:    return "bed.double.fill"
            case .schoolTime: return "building.columns.fill"
            }
        }

        var color: Color {
            switch self {
            case .downtime:   return Color(hex: "#5856D6")
            case .appLimit:   return Color(hex: "#FF9500")
            case .bedtime:    return Color(hex: "#007AFF")
            case .schoolTime: return Color(hex: "#34C759")
            }
        }
    }
}
