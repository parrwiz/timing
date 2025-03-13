import SwiftUI
import Charts

struct PrayerLineChartView: View {
    @ObservedObject var prayerData: PrayerData
    var currentTime: Date

    // Define x-axis (time in hours) for prayer times
    private let prayerHours: [Double] = [5, 12, 16, 18, 19.5] // 5 AM, 12 PM, 4 PM, 6 PM, 7:30 PM

    var body: some View {
        Chart {
            // Draw a single smooth sin(x) wave from 4 AM to 8:30 PM
            ForEach(0..<60, id: \.self) { i in
                let x = 4 + (16.5 * (Double(i) / 59)) // Scale x-axis from 4 AM to 8:30 PM
                let y = sin((x - 4) / 16.5 * .pi) // Single sine cycle
                LineMark(
                    x: .value("Time", x),
                    y: .value("Wave", y)
                )
                .foregroundStyle(Color.white.opacity(0.8))
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 6))
            }

            // Add prayer points on the wave
            ForEach(prayerHours, id: \.self) { hour in
                let sineY = sin((hour - 4) / 16.5 * .pi) // Calculate sine value for prayer time
                PointMark(
                    x: .value("Time", hour),
                    y: .value("Wave", sineY)
                )
                .foregroundStyle(Color.green)
                .symbolSize(20) // Increased dot size
            }

            // Add moving dot for the current time
            let currentHour = currentTimeToHours(currentTime)
            let movingY = sin((currentHour - 4) / 16.5 * .pi) // Keep it on the wave
            PointMark(
                x: .value("Time", currentHour),
                y: .value("Wave", movingY)
            )
            .foregroundStyle(Color.red)
            .symbolSize(25) // Increased dot size

            // Add red color filling for progress
            AreaMark(
                x: .value("Time", currentHour),
                yStart: .value("Wave", -1),
                yEnd: .value("Wave", movingY)
            )
            .foregroundStyle(Color.red.opacity(0.3))
        }
        .chartXAxis(.hidden) // Hide x-axis
        .chartYAxis(.hidden) // Hide y-axis
        .frame(height: 200)
        .padding()
        .background(Color.clear)
    }

    // Convert current time to hours (e.g., 5:30 AM → 5.5)
    func currentTimeToHours(_ date: Date) -> Double {
        let calendar = Calendar.current
        let hour = Double(calendar.component(.hour, from: date))
        let minute = Double(calendar.component(.minute, from: date)) / 60.0
        return hour + minute
    }

    // Format hours into readable AM/PM times
    func formattedTime(_ hour: Double) -> String {
        let intHour = Int(hour)
        let minute = Int((hour - Double(intHour)) * 60)
        let ampm = intHour >= 12 ? "PM" : "AM"
        let displayHour = intHour > 12 ? intHour - 12 : intHour
        return "\(displayHour):\(String(format: "%02d", minute)) \(ampm)"
    }
}
