import SwiftUI

// MARK: - Location View
struct LocationView: View {
    @EnvironmentObject var store: GuardStore
    @State private var mapStyle = 0

    var child: ChildProfile? { store.selectedChild }

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F2F3F7").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Location Header
                        ZStack {
                            LinearGradient(
                                colors: [Color(hex: "#34C759"), Color(hex: "#30D158")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ).ignoresSafeArea()

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Location")
                                            .font(.system(size: 26, weight: .black, design: .rounded))
                                            .foregroundColor(.white)
                                        if let child = child {
                                            Text(child.name + "'s whereabouts")
                                                .font(.system(size: 14))
                                                .foregroundColor(Color.white.opacity(0.75))
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color.white.opacity(0.3))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 60)
                            .padding(.bottom, 28)
                        }
                        .frame(maxWidth: .infinity)

                        if let child = child {
                            // Current location card
                            CurrentLocationCard(child: child)
                                .padding(.horizontal, 20)

                            // Safe zones
                            SafeZonesCard()
                                .padding(.horizontal, 20)

                            // Location history
                            LocationHistoryCard(child: child)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 120)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct CurrentLocationCard: View {
    let child: ChildProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(child.isOnline ? Color(hex: "#34C759") : Color(hex: "#FF3B30"))
                        .frame(width: 8, height: 8)
                    Text(child.isOnline ? "Live Location" : "Last Known")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(child.isOnline ? Color(hex: "#34C759") : Color(hex: "#FF3B30"))
                }
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Capsule().fill(child.isOnline ? Color(hex: "#34C759").opacity(0.1) : Color(hex: "#FF3B30").opacity(0.1)))
                Spacer()
                Text(child.lastSeen.formatted(.relative(presentation: .named)))
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#8E8E93"))
            }

            // Map placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#E8F5E9"))
                    .frame(height: 180)

                // Grid lines for map effect
                VStack(spacing: 20) {
                    ForEach(0..<4) { _ in
                        Rectangle().fill(Color(hex: "#34C759").opacity(0.08)).frame(height: 1)
                    }
                }
                HStack(spacing: 30) {
                    ForEach(0..<5) { _ in
                        Rectangle().fill(Color(hex: "#34C759").opacity(0.08)).frame(width: 1)
                    }
                }

                // Location pin
                VStack(spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#34C759"))
                            .frame(width: 44, height: 44)
                            .shadow(color: Color(hex: "#34C759").opacity(0.4), radius: 8)
                        Text(child.initials)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Triangle()
                        .fill(Color(hex: "#34C759"))
                        .frame(width: 12, height: 8)
                }

                // Safe zone indicator
                VStack {
                    Spacer()
                    HStack {
                        HStack(spacing: 5) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "#34C759"))
                            Text("Safe Zone - Home")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(hex: "#34C759"))
                        }
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Capsule().fill(.white))
                        .shadow(color: Color.black.opacity(0.1), radius: 4)
                        Spacer()
                    }
                    .padding(12)
                }
            }

            // Address
            if let location = child.locationHistory.last {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#34C759"))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(location.placeName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#1C1C1E"))
                        Text("Updated \(location.timestamp.formatted(.relative(presentation: .named)))")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#8E8E93"))
                    }
                    Spacer()
                    if location.isSafeZone {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 12))
                            Text("Safe zone")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "#34C759"))
                    }
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white)
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4))
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct SafeZonesCard: View {
    let zones = [
        (name: "Home", icon: "house.fill", color: "#34C759", address: "123 Main Street"),
        (name: "School", icon: "building.columns.fill", color: "#007AFF", address: "Central Elementary School"),
        (name: "Grandma's", icon: "heart.fill", color: "#FF2D55", address: "456 Oak Avenue"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Safe Zones")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#1C1C1E"))
                Spacer()
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                        Text("Add")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "#5B5FEF"))
                }
            }
            .padding(20)

            ForEach(zones, id: \.name) { zone in
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: zone.color).opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: zone.icon)
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: zone.color))
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(zone.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#1C1C1E"))
                        Text(zone.address)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#8E8E93"))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#C7C7CC"))
                }
                .padding(.horizontal, 20).padding(.vertical, 10)
                if zone.name != zones.last?.name {
                    Divider().padding(.horizontal, 20)
                }
            }
            Spacer().frame(height: 12)
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(.white)
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4))
    }
}

struct LocationHistoryCard: View {
    let child: ChildProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Today's Route")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "#1C1C1E"))
                .padding(20)

            let history = [
                ("Home", "house.fill", "#34C759", "7:45 AM"),
                ("School", "building.columns.fill", "#007AFF", "8:15 AM"),
                ("School", "building.columns.fill", "#007AFF", "3:30 PM"),
                ("Home", "house.fill", "#34C759", "4:05 PM"),
            ]

            ForEach(history.indices, id: \.self) { i in
                let item = history[i]
                HStack(spacing: 12) {
                    VStack(spacing: 0) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: item.2).opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: item.1)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: item.2))
                        }
                        if i < history.count - 1 {
                            Rectangle()
                                .fill(Color(hex: "#E8E9EF"))
                                .frame(width: 2, height: 20)
                        }
                    }
                    HStack {
                        Text(item.0)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#1C1C1E"))
                        Spacer()
                        Text(item.3)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#8E8E93"))
                    }
                    .padding(.leading, 4)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
            Spacer().frame(height: 12)
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(.white)
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4))
    }
}

// MARK: - Alerts View
struct AlertsView: View {
    @EnvironmentObject var store: GuardStore

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F2F3F7").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Header
                        ZStack {
                            LinearGradient(
                                colors: [Color(hex: "#FF3B30"), Color(hex: "#FF6B6B")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ).ignoresSafeArea()

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Alerts")
                                            .font(.system(size: 26, weight: .black, design: .rounded))
                                            .foregroundColor(.white)
                                        Text("\(store.unreadAlertsCount) unread notifications")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.white.opacity(0.75))
                                    }
                                    Spacer()
                                    if store.unreadAlertsCount > 0 {
                                        Button(action: { store.markAllAlertsRead() }) {
                                            Text("Mark all read")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12).padding(.vertical, 7)
                                                .background(Capsule().fill(Color.white.opacity(0.2)))
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 60)
                            .padding(.bottom, 28)
                        }
                        .frame(maxWidth: .infinity)

                        // Alerts grouped by child
                        ForEach(store.children) { child in
                            if !child.alerts.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 8) {
                                        Text(child.initials)
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(Color(hex: child.avatarColor))
                                            .frame(width: 26, height: 26)
                                            .background(Circle().fill(Color(hex: child.avatarColor).opacity(0.15)))
                                        Text(child.name)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color(hex: "#1C1C1E"))
                                        Spacer()
                                        Text("\(child.alerts.count) alerts")
                                            .font(.system(size: 11))
                                            .foregroundColor(Color(hex: "#8E8E93"))
                                    }
                                    .padding(.horizontal, 20)

                                    VStack(spacing: 0) {
                                        ForEach(child.alerts) { alert in
                                            AlertDetailRow(alert: alert)
                                            if alert.id != child.alerts.last?.id {
                                                Divider().padding(.horizontal, 20)
                                            }
                                        }
                                    }
                                    .background(RoundedRectangle(cornerRadius: 20).fill(.white)
                                        .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4))
                                    .padding(.horizontal, 20)
                                }
                            }
                        }

                        Spacer().frame(height: 120)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct AlertDetailRow: View {
    let alert: ParentalAlert

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(alert.severity.color.opacity(alert.isRead ? 0.05 : 0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: alert.type.icon)
                    .font(.system(size: 17))
                    .foregroundColor(alert.isRead ? Color(hex: "#C7C7CC") : alert.severity.color)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alert.type.rawValue)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(alert.isRead ? Color(hex: "#8E8E93") : Color(hex: "#1C1C1E"))
                    Spacer()
                    Text(alert.formattedTime)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#C7C7CC"))
                }
                Text(alert.message)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#8E8E93"))
                    .lineLimit(2)
            }
            if !alert.isRead {
                Circle()
                    .fill(Color(hex: "#5B5FEF"))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var store: GuardStore
    @State private var showPINChange = false
    @State private var notificationsOn = true
    @State private var locationOn = true

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F2F3F7").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Header
                        ZStack {
                            LinearGradient(
                                colors: [Color(hex: "#5B5FEF"), Color(hex: "#7B61FF")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ).ignoresSafeArea()

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Settings")
                                    .font(.system(size: 26, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Manage your family's protection")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.white.opacity(0.75))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.top, 60)
                            .padding(.bottom, 28)
                        }
                        .frame(maxWidth: .infinity)

                        // Family members
                        SettingsSection(title: "Family Members") {
                            ForEach(store.children) { child in
                                ChildSettingsRow(child: child)
                            }
                            Button(action: {}) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "#F2F3F7"))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "plus")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(hex: "#5B5FEF"))
                                    }
                                    Text("Add child device")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "#5B5FEF"))
                                    Spacer()
                                }
                                .padding(.horizontal, 20).padding(.vertical, 12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)

                        // Notifications
                        SettingsSection(title: "Notifications") {
                            SettingsToggleRow(
                                icon: "bell.fill", iconColor: "#FF3B30",
                                title: "Push Notifications",
                                subtitle: "Alerts for all events",
                                isOn: $notificationsOn
                            )
                            SettingsToggleRow(
                                icon: "location.fill", iconColor: "#34C759",
                                title: "Location Alerts",
                                subtitle: "When leaving safe zones",
                                isOn: $locationOn
                            )
                        }
                        .padding(.horizontal, 20)

                        // Security
                        SettingsSection(title: "Security") {
                            Button(action: { showPINChange = true }) {
                                SettingsNavRow(
                                    icon: "lock.fill", iconColor: "#5B5FEF",
                                    title: "Parent PIN",
                                    subtitle: "Change your 4-digit PIN"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())

                            SettingsNavRow(
                                icon: "faceid", iconColor: "#1C1C1E",
                                title: "Face ID",
                                subtitle: "Unlock with Face ID"
                            )
                        }
                        .padding(.horizontal, 20)

                        // About
                        SettingsSection(title: "About") {
                            SettingsNavRow(
                                icon: "questionmark.circle.fill", iconColor: "#007AFF",
                                title: "Help & Support",
                                subtitle: nil
                            )
                            SettingsNavRow(
                                icon: "star.fill", iconColor: "#FFCC00",
                                title: "Rate ParentalGuard",
                                subtitle: nil
                            )
                            SettingsNavRow(
                                icon: "info.circle.fill", iconColor: "#8E8E93",
                                title: "Version 1.0.0",
                                subtitle: nil
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "#8E8E93"))
                .tracking(0.5)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3))
        }
    }
}

struct ChildSettingsRow: View {
    let child: ChildProfile

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: child.avatarColor).opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(child.initials)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: child.avatarColor))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(child.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#1C1C1E"))
                Text("\(child.deviceName) • Age \(child.age)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#8E8E93"))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#C7C7CC"))
        }
        .padding(.horizontal, 20).padding(.vertical, 12)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(Color(hex: iconColor))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#1C1C1E"))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#8E8E93"))
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(hex: "#5B5FEF"))
                .scaleEffect(0.85)
        }
        .padding(.horizontal, 20).padding(.vertical, 10)
    }
}

struct SettingsNavRow: View {
    let icon: String
    let iconColor: String
    let title: String
    let subtitle: String?

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(Color(hex: iconColor))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#1C1C1E"))
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#8E8E93"))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#C7C7CC"))
        }
        .padding(.horizontal, 20).padding(.vertical, 12)
    }
}
