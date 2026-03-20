import SwiftUI

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var store: GuardStore
    @State private var scrollOffset: CGFloat = 0
    @State private var animateCards = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F2F3F7").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // Hero header
                        DashboardHeader()
                            .padding(.bottom, 24)

                        // Child selector
                        ChildSelectorStrip()
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)

                        if let child = store.selectedChild {

                            // Status card
                            ChildStatusCard(child: child)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 16)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: animateCards)

                            // Quick stats row
                            QuickStatsRow(child: child)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 16)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: animateCards)

                            // Recent alerts
                            if !child.alerts.filter({ !$0.isRead }).isEmpty {
                                RecentAlertsCard(alerts: child.alerts.filter({ !$0.isRead }))
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 16)
                                    .opacity(animateCards ? 1 : 0)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: animateCards)
                            }

                            // Top apps
                            TopAppsCard(child: child)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 16)
                                .opacity(animateCards ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: animateCards)

                            // Quick controls
                            QuickControlsCard(child: child)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 120)
                                .opacity(animateCards ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5), value: animateCards)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateCards = true
            }
        }
    }
}

// MARK: - Dashboard Header
struct DashboardHeader: View {
    @EnvironmentObject var store: GuardStore

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color(hex: "#5B5FEF"), Color(hex: "#7B61FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decorative circles
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 200, height: 200)
                    .offset(x: geo.size.width - 80, y: -60)
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 140, height: 140)
                    .offset(x: -40, y: 20)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Good \(timeOfDay)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.75))
                        Text("ParentalGuard")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    // Notification bell
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 42, height: 42)
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                        if store.unreadAlertsCount > 0 {
                            Circle()
                                .fill(Color(hex: "#FF3B30"))
                                .frame(width: 10, height: 10)
                                .offset(x: 12, y: -12)
                        }
                    }
                }

                // Family status chips
                HStack(spacing: 8) {
                    ForEach(store.children) { child in
                        HStack(spacing: 5) {
                            Circle()
                                .fill(child.isOnline ? Color(hex: "#34C759") : Color.white.opacity(0.3))
                                .frame(width: 6, height: 6)
                            Text(child.name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(0.15)))
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity)
    }

    var timeOfDay: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Morning" }
        if h < 17 { return "Afternoon" }
        return "Evening"
    }
}

// MARK: - Child Selector Strip
struct ChildSelectorStrip: View {
    @EnvironmentObject var store: GuardStore

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(store.children) { child in
                    Button(action: { store.selectChild(child) }) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: child.avatarColor).opacity(0.15))
                                    .frame(width: 52, height: 52)
                                Circle()
                                    .strokeBorder(
                                        store.selectedChild?.id == child.id
                                            ? Color(hex: child.avatarColor) : Color.clear,
                                        lineWidth: 2.5
                                    )
                                    .frame(width: 52, height: 52)
                                Text(child.initials)
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: child.avatarColor))

                                // Online indicator
                                Circle()
                                    .fill(child.isOnline ? Color(hex: "#34C759") : Color(hex: "#C7C7CC"))
                                    .frame(width: 12, height: 12)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .offset(x: 18, y: 18)
                            }

                            Text(child.name)
                                .font(.system(size: 12, weight: store.selectedChild?.id == child.id ? .bold : .regular))
                                .foregroundColor(store.selectedChild?.id == child.id ? Color(hex: "#5B5FEF") : Color(hex: "#8E8E93"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Add child button
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#F2F3F7"))
                            .frame(width: 52, height: 52)
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "#C7C7CC"))
                    }
                    Text("Add")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#C7C7CC"))
                }
            }
        }
    }
}

// MARK: - Child Status Card
struct ChildStatusCard: View {
    @EnvironmentObject var store: GuardStore
    let child: ChildProfile

    var body: some View {
        VStack(spacing: 0) {
            // Top section
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color(hex: child.avatarColor).opacity(0.12))
                        .frame(width: 56, height: 56)
                    Text(child.initials)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: child.avatarColor))
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(child.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "#1C1C1E"))
                        Text("Age \(child.age)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "#5B5FEF"))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Capsule().fill(Color(hex: "#5B5FEF").opacity(0.1)))
                    }
                    HStack(spacing: 4) {
                        Circle()
                            .fill(child.isOnline ? Color(hex: "#34C759") : Color(hex: "#C7C7CC"))
                            .frame(width: 7, height: 7)
                        Text(child.isOnline ? "Online now" : "Last seen \(child.lastSeen.formatted(.relative(presentation: .named)))")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#8E8E93"))
                    }
                    Text(child.deviceName)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#C7C7CC"))
                }

                Spacer()

                // Filter badge
                VStack(spacing: 3) {
                    Image(systemName: child.contentFilter.icon)
                        .font(.system(size: 16))
                        .foregroundColor(child.contentFilter.color)
                    Text(child.contentFilter.rawValue)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(child.contentFilter.color)
                }
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(child.contentFilter.color.opacity(0.1)))
            }
            .padding(20)

            Divider().padding(.horizontal, 20)

            // Screen time progress
            VStack(spacing: 10) {
                HStack {
                    Text("Screen Time Today")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#8E8E93"))
                    Spacer()
                    Text("\(child.formattedScreenTime) / \(child.formattedLimit)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(child.statusColor)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "#F2F3F7"))
                            .frame(height: 10)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(
                                colors: progressColors(for: child.screenTimePercent),
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .frame(width: max(10, geo.size.width * child.screenTimePercent), height: 10)
                            .shadow(color: child.statusColor.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
                .frame(height: 10)

                if child.screenTimePercent >= 0.8 {
                    HStack(spacing: 5) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(child.statusColor)
                        Text(child.screenTimePercent >= 1 ? "Daily limit reached" : "Approaching daily limit")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(child.statusColor)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(.white)
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4))
    }

    func progressColors(for percent: Double) -> [Color] {
        if percent >= 1.0 { return [Color(hex: "#FF3B30"), Color(hex: "#FF6B6B")] }
        if percent >= 0.8 { return [Color(hex: "#FF9500"), Color(hex: "#FFCC00")] }
        return [Color(hex: "#5B5FEF"), Color(hex: "#7B61FF")]
    }
}

// MARK: - Quick Stats Row
struct QuickStatsRow: View {
    let child: ChildProfile

    var body: some View {
        HStack(spacing: 12) {
            QuickStatCard(
                icon: "app.badge.fill",
                label: "Apps Used",
                value: "\(child.appUsage.filter { !$0.isBlocked }.count)",
                color: "#5B5FEF"
            )
            QuickStatCard(
                icon: "xmark.circle.fill",
                label: "Blocked",
                value: "\(child.appUsage.filter { $0.isBlocked }.count)",
                color: "#FF3B30"
            )
            QuickStatCard(
                icon: "bell.fill",
                label: "Alerts",
                value: "\(child.alerts.filter { !$0.isRead }.count)",
                color: "#FF9500"
            )
        }
    }
}

struct QuickStatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: color).opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: color))
            }
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(Color(hex: "#1C1C1E"))
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "#8E8E93"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 16).fill(.white)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 3))
    }
}

// MARK: - Recent Alerts Card
struct RecentAlertsCard: View {
    let alerts: [ParentalAlert]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Alerts")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#1C1C1E"))
                Spacer()
                Text("View all")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#5B5FEF"))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            ForEach(alerts.prefix(3)) { alert in
                AlertRowCompact(alert: alert)
                    .padding(.horizontal, 20)
            }

            Spacer().frame(height: 4)
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(.white)
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4))
    }
}

struct AlertRowCompact: View {
    let alert: ParentalAlert

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(alert.severity.color.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: alert.type.icon)
                    .font(.system(size: 15))
                    .foregroundColor(alert.severity.color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#1C1C1E"))
                    .lineLimit(1)
                Text(alert.formattedTime)
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#8E8E93"))
            }
            Spacer()
            if !alert.isRead {
                Circle()
                    .fill(Color(hex: "#5B5FEF"))
                    .frame(width: 7, height: 7)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Top Apps Card
struct TopAppsCard: View {
    let child: ChildProfile

    var sortedApps: [AppUsageRecord] {
        child.appUsage.sorted { $0.timeSpent > $1.timeSpent }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Top Apps Today")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#1C1C1E"))
                Spacer()
                Text("See all")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "#5B5FEF"))
            }
            .padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 14)

            ForEach(sortedApps.prefix(4)) { app in
                AppUsageRow(app: app, totalTime: child.screenTimeToday)
                    .padding(.horizontal, 20)
                if app.id != sortedApps.prefix(4).last?.id {
                    Divider().padding(.horizontal, 20)
                }
            }
            Spacer().frame(height: 16)
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(.white)
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4))
    }
}

struct AppUsageRow: View {
    let app: AppUsageRecord
    let totalTime: TimeInterval

    var percent: Double {
        guard totalTime > 0 else { return 0 }
        return min(1.0, app.timeSpent / totalTime)
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(app.color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: app.appIcon)
                    .font(.system(size: 17))
                    .foregroundColor(app.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(app.appName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(app.isBlocked ? Color(hex: "#C7C7CC") : Color(hex: "#1C1C1E"))
                    if app.isBlocked {
                        Text("BLOCKED")
                            .font(.system(size: 8, weight: .black))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(Capsule().fill(Color(hex: "#FF3B30")))
                    }
                    if let limit = app.timeLimit {
                        let limitH = Int(limit) / 3600
                        let limitM = (Int(limit) % 3600) / 60
                        let limitStr = limitH > 0 ? "\(limitH)h" : "\(limitM)m"
                        Text("limit: \(limitStr)")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(Color(hex: "#FF9500"))
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(Capsule().fill(Color(hex: "#FF9500").opacity(0.1)))
                    }
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(hex: "#F2F3F7"))
                            .frame(height: 5)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(app.isBlocked ? Color(hex: "#FF3B30") : app.color)
                            .frame(width: max(5, geo.size.width * percent), height: 5)
                    }
                }
                .frame(height: 5)
            }

            Spacer()

            Text(app.formattedTime)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(hex: "#8E8E93"))
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Quick Controls Card
struct QuickControlsCard: View {
    @EnvironmentObject var store: GuardStore
    let child: ChildProfile
    @State private var bedtimeOn: Bool

    init(child: ChildProfile) {
        self.child = child
        _bedtimeOn = State(initialValue: child.bedtimeEnabled)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Quick Controls")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "#1C1C1E"))
                .padding(.horizontal, 20).padding(.top, 18).padding(.bottom, 14)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ControlButton(
                    icon: "moon.stars.fill",
                    title: "Bedtime",
                    subtitle: bedtimeOn ? "Enabled" : "Disabled",
                    color: "#5856D6",
                    isOn: bedtimeOn
                ) { bedtimeOn.toggle() }

                ControlButton(
                    icon: "shield.fill",
                    title: "Content Filter",
                    subtitle: child.contentFilter.rawValue,
                    color: "#FF9500",
                    isOn: true
                ) {}

                ControlButton(
                    icon: "location.fill",
                    title: "Location",
                    subtitle: "Tracking on",
                    color: "#34C759",
                    isOn: true
                ) {}

                ControlButton(
                    icon: "bell.fill",
                    title: "Alerts",
                    subtitle: "All enabled",
                    color: "#FF3B30",
                    isOn: true
                ) {}
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(.white)
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4))
    }
}

struct ControlButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isOn ? Color(hex: color).opacity(0.12) : Color(hex: "#F2F3F7"))
                        .frame(width: 38, height: 38)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(isOn ? Color(hex: color) : Color(hex: "#C7C7CC"))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#1C1C1E"))
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#8E8E93"))
                }
                Spacer()
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "#F8F8FC")))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

