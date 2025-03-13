import SwiftUI

struct PrayerTimesCardView: View {
    @ObservedObject var prayerData = PrayerData.shared
    
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
        VStack(alignment: .leading, spacing: 15) {
            Text("Prayer Times")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Current Prayer Highlight
            if currentPrayerIndex < prayerData.prayers.count {
                let currentPrayer = prayerData.prayers[currentPrayerIndex]
                let currentTime = prayerData.timings[currentPrayer] ?? "--:--"
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Next Prayer")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(currentPrayer)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Text(currentTime)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Prayer Times Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(prayerData.prayers.prefix(6), id: \.self) { prayer in
                    VStack {
                        Text(prayer)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(prayerData.timings[prayer] ?? "--:--")
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundColor(prayer == prayerData.prayers[currentPrayerIndex] ? .green : .primary)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(prayer == prayerData.prayers[currentPrayerIndex] ? Color.green.opacity(0.1) : Color.clear)
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
