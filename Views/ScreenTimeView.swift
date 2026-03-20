import SwiftUI

struct ScreenTimeView: View {
    @EnvironmentObject var store: GuardStore
    @State private var selectedDay = 6
    @State private var showingLimitSheet = false
    @State private var tempLimit: Double = 2.0

    var child: ChildProfile? { store.selectedChild }
    let days = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#F2F3F7").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Header
                        ScreenTimeHeader()

                        if let child = child {

                            // Weekly chart
                            WeeklyChartCard(child: child, selectedDay: $selectedDay, days: days)
                                .padding(.horizontal, 20)

                            // Daily limit control
                            DailyLimitCard(child: child, showingLimitSheet: $showingLimitSheet)
                                .padding(.horizontal, 20)

                            // App limits
                            AppLimitsCard(child: child)
                                .padding(.horizontal, 20)

                            // Downtime schedule
                            DowntimeCard(child: child)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 120)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingLimitSheet) {
            if let child = child {
                LimitSetterSheet(child: child, isPresented: $showingLimitSheet)
            }
        }
    }
}

struct ScreenTimeHeader: View {
    @EnvironmentObject var store: GuardStore

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#FF9500"), Color(hex: "#FF6B00")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Screen Time")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        if let child = store.selectedChild {
                            Text(child.name + "'s usage overview")
                                .font(.system(size: 14))
                                .foregroundColor(Color.white.opacity(0.75))
                        }
                    }
                    Spacer()
                    Image(systemName: "hourglass")
                        .font(.system(size: 32))
                        .foregroundColor(Color.white.opacity(0.3))
                }

                if let child = store.selectedChild {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(child.formattedScreenTime)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("Today")
                                .font(.system(size: 12))
                                .foregroundColor(Color.white.opacity(0.7))
                        }
                        Rectangle().fill(Color.white.opacity(0.3)).frame(width: 1, height: 40)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(child.formattedLimit)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            Text("Daily limit")
                                .font(.system(size: 12))
                                .foregroundColor(Color.white.opacity(0.7))
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity)
    }
}

struct WeeklyChartCard: View {
    let child: ChildProfile
    @Binding var selectedDay: Int
    let days: [String]

    var maxVal: Double { (child.weeklyScreenTime.max() ?? 1) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Overview")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#1C1C1E"))
                Spacer()
                Text("This week")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#8E8E93"))
            }

            // Chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7) { i in
                    VStack(spacing: 6) {
                        if selectedDay == i {
                            Text(String(format: "%.1fh", child.weeklyScreenTime[i]))
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(Color(hex: "#FF9500"))
                        }
                        RoundedRectangle(cornerRadius: 6)
                            .fill(selectedDay == i
                                  ? LinearGradient(colors: [Color(hex: "#FF9500"), Color(hex: "#FFCC00")],
                                                   startPoint: .bottom, endPoint: .top)
                                  : LinearGradient(colors: [Color(hex: "#F2F3F7"), Color(hex: "#E8E9EF")],
                                                   startPoint: .bottom, endPoint: .top)
                            )
                            .frame(
                                height: max(8, CGFloat(child.weeklyScreenTime[i] / maxVal) * 90)
                            )
                            .onTapGesture { withAnimation(.spring()) { selectedDay = i } }

                        Text(days[i])
                            .font(.system(size: 11, weight: selectedDay == i ? .bold : .regular))
                            .foregroundColor(selectedDay == i ? Color(hex: "#FF9500") : Color(hex: "#C7C7CC"))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)

            // Daily limit line hint
            HStack(spacing: 6) {
                Rectangle().fill(Color(hex: "#5B5FEF")).frame(width: 16, height: 2)
                Text("Daily limit: \(child.formattedLimit)")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#8E8E93"))
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white)
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4))
    }
}

struct DailyLimitCard: View {
    @EnvironmentObject var store: GuardStore
    let child: ChildProfile
    @Binding var showingLimitSheet: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "timer")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#FF9500"))
                Text("Daily Limit")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#1C1C1E"))
                Spacer()
                Button(action: { showingLimitSheet = true }) {
                    Text("Edit")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#5B5FEF"))
                }
            }

            HStack(spacing: 16) {
                ForEach([1.0, 2.0, 3.0, 4.0], id: \.self) { hours in
                    Button(action: {
                        store.setScreenTimeLimit(childID: child.id, limit: hours * 3600)
                    }) {
                        Text("\(Int(hours))h")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(
                                child.screenTimeLimit == hours * 3600
                                    ? .white : Color(hex: "#8E8E93")
                            )
                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 12)
                                .fill(child.screenTimeLimit == hours * 3600
                                      ? Color(hex: "#FF9500") : Color(hex: "#F2F3F7")))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white)
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4))
    }
}

struct AppLimitsCard: View {
    @EnvironmentObject var store: GuardStore
    let child: ChildProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "app.badge")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#5B5FEF"))
                Text("App Controls")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#1C1C1E"))
                Spacer()
            }
            .padding(20)

            ForEach(child.appUsage) { app in
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(app.color.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: app.appIcon)
                            .font(.system(size: 17))
                            .foregroundColor(app.isBlocked ? Color(hex: "#C7C7CC") : app.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(app.appName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#1C1C1E"))
                        Text(app.category.rawValue)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#8E8E93"))
                    }

                    Spacer()

                    // Block toggle
                    Button(action: {
                        store.toggleBlockApp(childID: child.id, appName: app.appName)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: app.isBlocked ? "xmark.circle.fill" : "checkmark.circle.fill")
                                .font(.system(size: 14))
                            Text(app.isBlocked ? "Blocked" : "Allowed")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(app.isBlocked ? Color(hex: "#FF3B30") : Color(hex: "#34C759"))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Capsule().fill(
                            app.isBlocked ? Color(hex: "#FF3B30").opacity(0.1) : Color(hex: "#34C759").opacity(0.1)
                        ))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20).padding(.vertical, 8)

                if app.id != child.appUsage.last?.id {
                    Divider().padding(.horizontal, 20)
                }
            }
            Spacer().frame(height: 12)
        }
        .background(RoundedRectangle(cornerRadius: 20).fill(.white)
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4))
    }
}

struct DowntimeCard: View {
    let child: ChildProfile
    @State private var bedtimeEnabled: Bool

    init(child: ChildProfile) {
        self.child = child
        _bedtimeEnabled = State(initialValue: child.bedtimeEnabled)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#5856D6"))
                Text("Bedtime Schedule")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#1C1C1E"))
                Spacer()
                Toggle("", isOn: $bedtimeEnabled)
                    .labelsHidden()
                    .tint(Color(hex: "#5856D6"))
                    .scaleEffect(0.85)
            }

            if bedtimeEnabled {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bedtime")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "#8E8E93"))
                        Text(child.bedtimeStart.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "#5856D6"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "#5856D6").opacity(0.08)))

                    Image(systemName: "arrow.right")
                        .foregroundColor(Color(hex: "#C7C7CC"))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Wake up")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "#8E8E93"))
                        Text(child.bedtimeEnd.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: "#FF9500"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "#FF9500").opacity(0.08)))
                }
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(.white)
            .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4))
    }
}

struct LimitSetterSheet: View {
    @EnvironmentObject var store: GuardStore
    let child: ChildProfile
    @Binding var isPresented: Bool
    @State private var hours: Double = 2

    init(child: ChildProfile, isPresented: Binding<Bool>) {
        self.child = child
        _isPresented = isPresented
        _hours = State(initialValue: child.screenTimeLimit / 3600)
    }

    var body: some View {
        VStack(spacing: 24) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "#C7C7CC"))
                .frame(width: 36, height: 5)
                .padding(.top, 8)

            Text("Set Daily Limit")
                .font(.system(size: 20, weight: .bold))

            Text(String(format: "%.1f hours", hours))
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(Color(hex: "#FF9500"))

            Slider(value: $hours, in: 0.5...8, step: 0.5)
                .tint(Color(hex: "#FF9500"))
                .padding(.horizontal, 30)

            HStack {
                Text("30 min").font(.system(size: 12)).foregroundColor(Color(hex: "#C7C7CC"))
                Spacer()
                Text("8 hours").font(.system(size: 12)).foregroundColor(Color(hex: "#C7C7CC"))
            }
            .padding(.horizontal, 30)

            Button(action: {
                store.setScreenTimeLimit(childID: child.id, limit: hours * 3600)
                isPresented = false
            }) {
                Text("Save Limit")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#FF9500")))
            }
            .padding(.horizontal, 30)

            Spacer()
        }
        .presentationDetents([.medium])
    }
}
