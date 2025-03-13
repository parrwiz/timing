import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme: Int = 0
    @AppStorage("dailyReminders") private var dailyReminders = true
    @AppStorage("useCurrentLocation") private var useCurrentLocation = true
    @AppStorage("prayerTimesAlerts") private var prayerTimesAlerts = true
    @AppStorage("selectedSchool") private var selectedSchool: Int = 1
    @AppStorage("selectedMethod") private var selectedMethod: Int = 2

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Prayer Calculations")) {
                    VStack {
                        Picker("School", selection: $selectedSchool) {
                            Text("Shafi").tag(0)
                            Text("Hanafi").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedSchool) { _ in
                            PrayerData.shared.fetchPrayerTimes(method: selectedMethod, school: selectedSchool)
                        }

                        Picker("Method", selection: $selectedMethod) {
                            Text("Islamic Society of North America").tag(2)
                            Text("Muslim World League").tag(3)
                            Text("Egyptian General Authority of Survey").tag(5)
                            Text("Umm Al-Qura University").tag(4)
                        }
                      //  .pickerStyle(pickersty)
                        .onChange(of: selectedMethod) { _ in
                            PrayerData.shared.fetchPrayerTimes(method: selectedMethod, school: selectedSchool)
                        }
                    }
                }
                Section(header: Text("Notifications")) {
                    Toggle("Prayer Time Alerts", isOn: $prayerTimesAlerts)
                    Toggle("Daily Reminders", isOn: $dailyReminders)
                }
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $selectedTheme) {
                        Text("Light").tag(0)
                        Text("Dark").tag(1)
                        Text("System").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedTheme) { _ in
                        updateTheme()
                    }
                }
                Section(header: Text("Location")) {
                    Toggle("Use Current Location", isOn: $useCurrentLocation)
                    Text("Set Custom Location")
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func updateTheme() {
        let theme: UIUserInterfaceStyle
        switch selectedTheme {
        case 0:
            theme = .light
        case 1:
            theme = .dark
        case 2:
            theme = .unspecified
        default:
            theme = .unspecified
        }
        UIApplication.shared.windows.forEach { window in
            window.rootViewController?.overrideUserInterfaceStyle = theme
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
