//
//  MainView.swift
//  Arkan

import SwiftUI
import CoreLocation

struct MainView: View {
    @Binding var showSettings: Bool

    @StateObject var locationManager = LocationManager()
    @StateObject var prayerData = PrayerData.shared

    @AppStorage("selectedTheme") private var selectedTheme: Int = 0
    @AppStorage("dailyReminders") private var dailyReminders = true
    @AppStorage("useCurrentLocation") private var useCurrentLocation = true
    @AppStorage("prayerTimesAlerts") private var prayerTimesAlerts = true
    @AppStorage("selectedSchool") private var selectedSchool: Int = 1
    @AppStorage("selectedMethod") private var selectedMethod: Int = 2

    // Determine current prayer index using numeric hour values.
    private var currentPrayerIndex: Int {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = Double(calendar.component(.hour, from: now))
        let currentMinute = Double(calendar.component(.minute, from: now))
        let currentTimeDouble = currentHour + currentMinute / 60

        let times = prayerData.prayers.compactMap { prayerData.timings[$0] }
        for (index, timeString) in times.enumerated() {
            if let prayerHour = PrayerData.timeToHours(timeString), prayerHour > currentTimeDouble {
                return index
            }
        }
        return 0
    }

    var body: some View {
        NavigationView {
           
            ZStack {
                // Animated Gradient Background
               // AnimatedGradientView()
              //  .ignoresSafeArea()
                //RoundedRectangle(cornerRadius: 25)
                Color.appBackground
                    .ignoresSafeArea()
                   // .blendMode(.overlay)
              //  .navigationTitle("Arkan")
                // Main content in a scroll view.
                ScrollView {
                    
                    VStack(spacing: 5) {
                        Text(prayerData.prayers[currentPrayerIndex])
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                       
                        // Next Prayer Card.
                        NextPrayerCard(currentPrayerIndex: currentPrayerIndex)
                           // .scaleEffect(-99) // Subtle scale for depth

                        // Prayer Times (Chart + List) Card.
                        PrayerTimesView(currentPrayerIndex: currentPrayerIndex)
                          //  .rotation3DEffect(.degrees(99), axis: (x: 0, y: 1, z: 0), anchor: .leading) // 3D rotation effect

                        // Daily Adhkar Section.
                        DailyAdhkarView()
                            .offset(y: -15) // Slight offset for layering
                    }
                    .padding()
            
                }
            }
           
         
            .navigationBarItems(trailing: settingsButton)
            .onAppear { startDailyUpdates() }
            .alert(isPresented: $showLocationPermissionAlert) {
                Alert(
                    title: Text("Location Permission Required"),
                    message: Text("Please enable location services in Settings to provide accurate prayer times."),
                    primaryButton: .default(Text("OK")),
                    secondaryButton: .default(Text("Open Settings"), action: {
                        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(appSettings)
                        }
                    })
                )
            }
            .preferredColorScheme(selectedTheme == 1 ? .dark : .light)
        }
    }

    // Start daily updates based on location.
    private func startDailyUpdates() {
        if let loc = locationManager.location,
           locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            PrayerData.shared.startDailyUpdates(
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude,
                method: selectedMethod,
                school: selectedSchool
            )
        } else {
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                showLocationPermissionAlert = true
            }
        }
    }

    // Settings Button.
    private var settingsButton: some View {
        Button(action: { showSettings.toggle() }) {
            Image(systemName: "gearshape.fill")
                .font(.title2)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 1, x: 0, y: 1)
        }
    }

    @State private var showLocationPermissionAlert = false
}

struct NextPrayerCard: View {
    let currentPrayerIndex: Int
    @ObservedObject var prayerData = PrayerData.shared

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
            Color.appBackground
              //  .blendMode(.overlay)

            VStack(alignment: .leading, spacing: 15) {
                Text("Next Prayer")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.appFont)
                    .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)

                if currentPrayerIndex < prayerData.prayers.count {
                    let nextPrayer = prayerData.prayers[currentPrayerIndex]
                    let nextPrayerTime = prayerData.timings[nextPrayer] ?? "--:--"

                    HStack {
                        Text(nextPrayer)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 3, x: 0, y: 2)
                        Spacer()
                        Text(nextPrayerTime)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 3, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                } else {
                    Text("No upcoming prayer")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                        .padding()
                }
            }
            .padding(15)
        }
        .padding(.horizontal)
       // .rotation3DEffect(axis: (x: -5, y: 1, z: 0), anchor: .trailing) // 3D rotation effect
    }
}

struct DailyAdhkarView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
            Color.appBackground
                .blendMode(.overlay)


            VStack(alignment: .leading, spacing: 15) {
                Text("Daily Adhkar")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)

                ForEach(["Morning Adhkar", "Evening Adhkar", "Before Sleep"], id: \.self) { adhkar in
                    NavigationLink(destination: AdhkarDetailView(title: adhkar)) {
                        HStack {
                            Text(adhkar)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.blue.opacity(0.2).blendMode(.plusLighter))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

// Placeholder for Adhkar Detail View.
struct AdhkarDetailView: View {
    let title: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
            Color.appBackground
               // .blendMode(.overlay)
            .navigationTitle("Arkan")

            ScrollView {
                VStack(spacing: 25) {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .shadow(color: .black.opacity(0.7), radius: 3, x: 0, y: 2)

                    ForEach(0..<10, id: \.self) { index in
                        Text("Dua \(index + 1) - Placeholder for \(title) details. This section will eventually contain detailed Adhkar content.")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.blue.opacity(0.2).blendMode(.plusLighter))
                            )
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 3)
                    }
                }
                .padding()
            }
            .navigationTitle(title)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(showSettings: .constant(false))
    }
}
