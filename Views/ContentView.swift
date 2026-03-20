import SwiftUI

// MARK: - Root View
struct RootView: View {
    @EnvironmentObject var store: GuardStore
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#F2F3F7").ignoresSafeArea()

            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(0)
                ScreenTimeView()
                    .tag(1)
                LocationView()
                    .tag(2)
                AlertsView()
                    .tag(3)
                SettingsView()
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab, unreadCount: store.unreadAlertsCount)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let unreadCount: Int

    let tabs: [(icon: String, label: String)] = [
        ("house.fill",            "Home"),
        ("hourglass",             "Screen Time"),
        ("location.fill",         "Location"),
        ("bell.fill",             "Alerts"),
        ("gearshape.fill",        "Settings"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { i in
                Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = i } }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Image(systemName: tabs[i].icon)
                                .font(.system(size: selectedTab == i ? 22 : 20))
                                .foregroundColor(selectedTab == i ? Color(hex: "#5B5FEF") : Color(hex: "#C0C0CC"))
                                .scaleEffect(selectedTab == i ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedTab)

                            // Badge for alerts
                            if i == 3 && unreadCount > 0 {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text("\(min(unreadCount, 9))")
                                            .font(.system(size: 8, weight: .black))
                                            .foregroundColor(.white)
                                            .frame(width: 14, height: 14)
                                            .background(Circle().fill(Color(hex: "#FF3B30")))
                                            .offset(x: 8, y: -8)
                                    }
                                    Spacer()
                                }
                                .frame(width: 30, height: 30)
                            }
                        }
                        .frame(height: 28)

                        Text(tabs[i].label)
                            .font(.system(size: 10, weight: selectedTab == i ? .semibold : .regular))
                            .foregroundColor(selectedTab == i ? Color(hex: "#5B5FEF") : Color(hex: "#C0C0CC"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.bottom, 20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: -4)
                .ignoresSafeArea()
        )
    }
}
