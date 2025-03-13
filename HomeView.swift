import SwiftUI

struct HomeView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var prayerData = PrayerData.shared
    @StateObject private var sunnahViewModel = SunnahViewModel()
    @StateObject private var quranViewModel = QuranViewModel()
    
    @State private var showSettings = false
    @State private var showQiblaView = false
    @State private var showQuranReader = false
    @State private var showSunnahView = false
    @State private var isRefreshing = false
    
    var body: some View {
        ZStack {
            // Maintain background color during refresh
            Color(red: 245/255, green: 245/255, blue: 245/255).ignoresSafeArea()
            
            ScrollView {
                ZStack(alignment: .top) {
                    // This ensures the background color extends to the top during pull
                    Color(red: 220/255, green: 78/255, blue: 65/255)
                        .frame(height: 200)
                        .offset(y: -200)
                    
                    // Custom refresh control that maintains color
                    RefreshControl(isRefreshing: $isRefreshing, onRefresh: refreshData)
                        .background(Color(red: 220/255, green: 78/255, blue: 65/255))
                    
                    VStack(spacing: 24) {
                        // Prayer Times Section with Header
                        PrayerTimesHeaderView(showSettings: $showSettings)
                            .padding(.bottom, -20) // Overlap with the next section
                        
                        // Qibla Card View with animation
                        QiblaCardView(showQiblaView: $showQiblaView)
                            .padding(.horizontal)
                            .transition(.scale)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isRefreshing)
                        
                        // Hadith Card View with navigation
                        Button(action: {
                            showSunnahView = true
                        }) {
                            HadithCardView(viewModel: sunnahViewModel)
                                .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.slide)
                        .animation(.easeInOut(duration: 0.3).delay(0.1), value: isRefreshing)
                        
                        // Quran Verse Section
                        QuranVerseCardView(viewModel: quranViewModel, showQuranReader: $showQuranReader)
                            .padding(.horizontal)
                            .transition(.slide)
                            .animation(.easeInOut(duration: 0.3).delay(0.2), value: isRefreshing)
                       
                        // Community Section
                        CommunityCardView()
                            .padding(.horizontal)
                            .padding(.bottom)
                            .transition(.slide)
                            .animation(.easeInOut(duration: 0.3).delay(0.3), value: isRefreshing)
                    }
                }
            }
            .background(Color(red: 245/255, green: 245/255, blue: 245/255).ignoresSafeArea())
            .edgesIgnoringSafeArea(.top) // Allow content to extend under status bar
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showQiblaView) {
            QiblaCompassView()
                .environmentObject(locationManager)
        }
        .fullScreenCover(isPresented: $showQuranReader) {
            QuranView(isPresented: $showQuranReader)
        }
        .fullScreenCover(isPresented: $showSunnahView) {
            SunnahView()
                .environmentObject(sunnahViewModel)
        }
        .onAppear {
            if let location = locationManager.location {
                prayerData.fetchPrayerTimes(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
            sunnahViewModel.fetchRandomHadith()
            quranViewModel.fetchInitialAyah()
        }
    }
    
    func refreshData() {
        // Simulate a network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let location = locationManager.location {
                prayerData.fetchPrayerTimes(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
            sunnahViewModel.fetchRandomHadith()
            quranViewModel.fetchInitialAyah()
            isRefreshing = false
        }
    }
}

// Improved RefreshControl that maintains background color
struct RefreshControl: View {
    @Binding var isRefreshing: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: .global).minY > 50 {
                VStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white.opacity(0.7)))
                        .scaleEffect(1.5)
                    Spacer()
                }
                .frame(width: geometry.size.width, height: 50)
                .onAppear {
                    if !isRefreshing {
                        isRefreshing = true
                        onRefresh()
                    }
                }
            }
        }
        .frame(height: isRefreshing ? 50 : 0)
    }
}

struct PrayerTimesHeaderView: View {
    @Binding var showSettings: Bool
    @ObservedObject var prayerData = PrayerData.shared
    
    private var hijriMonthName: String {
        return HijriCalendarUtils.getMonthName(from: prayerData.hijriDate)
    }
    
    private var currentDay: Int {
        let calendar = Calendar.current
        return calendar.component(.day, from: Date())
    }
    
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
        VStack(spacing: 0) {
            // Top header with month and settings
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(hijriMonthName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 20) {
                            ForEach(Calendar.current.weekdaySymbols.prefix(7), id: \.self) { day in
                                Text(day.prefix(3))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .foregroundColor(.white)
                    }
                }
                
                // Calendar day selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(1...30, id: \.self) { day in
                            VStack {
                                Text("\(day)")
                                    .font(.headline)
                                    .foregroundColor(day == currentDay ? .white : .white.opacity(0.7))
                            }
                            .frame(width: 40, height: 40)
                            .background(day == currentDay ? Circle().fill(Color.white.opacity(0.3)) : nil)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal)
            .padding(.top, 60) // Extra padding for status bar
            .padding(.bottom, 20)
            .background(Color(red: 220/255, green: 78/255, blue: 65/255))
            
            // Prayer times section
            VStack(spacing: 16) {
                // All prayer times in a grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(prayerData.prayers.filter { $0 != "Midnight" }, id: \.self) { prayer in
                        let time = prayerData.timings[prayer] ?? "--:--"
                        let isNext = prayer == prayerData.prayers[currentPrayerIndex]
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(prayer)
                                    .font(.headline)
                                    .fontWeight(isNext ? .bold : .regular)
                                    .foregroundColor(isNext ? Color(red: 220/255, green: 78/255, blue: 65/255) : .black)
                                
                                Text(time)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if isNext {
                                Text("Next")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color(red: 220/255, green: 78/255, blue: 65/255))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 8)
                .padding(.bottom, 16)
            }
            .padding(.top, 20)
            .padding(.horizontal)
            .background(Color(red: 245/255, green: 245/255, blue: 245/255))
            .cornerRadius(30, corners: [.topLeft, .topRight])
            .offset(y: -30)
        }
    }
}

// Extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Preview provider
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
