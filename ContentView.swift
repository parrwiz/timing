import SwiftUI
import Charts

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showSettings = false
    @State private var showQiblaView = false
    @State private var showQuranView = false
    @State private var showSunnahView = false
    
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            QuranView(isPresented: $showQuranView)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Quran")
                }
                .tag(2)
            
            
            SunnahView()
                .tabItem {
                    Image(systemName: "sun.max.fill")
                    Text("Sunnah")
                }
                .tag(3)
                
            MainView(showSettings: $showSettings)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
        
            QiblaCompassView()
                .environmentObject(locationManager)
                .tabItem {
                    Label("Qibla", systemImage: "location.north.line")
                }
                .tag(1)
          
            
            CommunityView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Community")
                }
                .tag(4)
        }
        .accentColor(.green)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

