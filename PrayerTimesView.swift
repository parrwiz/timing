//
//  PrayerTimesView.swift
//  Arkan

import SwiftUI
import Charts

struct PrayerTimesView: View {
    var currentPrayerIndex: Int
    @ObservedObject var prayerData = PrayerData.shared

    private var orderedPrayerTimes: [String] {
        prayerData.prayers.map { prayerData.timings[$0] ?? "--:--" }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
            Color.appBackground
                .blendMode(.overlay)


            VStack(spacing: 30) {
                // Prayer Intervals Chart.
                VStack(alignment: .leading, spacing: 10) {
                    Text("Prayer Intervals")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)


                    PrayerLineChartView(prayerData: prayerData, currentTime: Date())
                }
                .padding(.vertical)


                // All Prayer Times List.
                VStack(alignment: .leading, spacing: 10) {
                    Text("All Prayer Times")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)

                    ForEach(0..<prayerData.prayers.count, id: \.self) { index in
                        PrayerRow(
                            prayerName: prayerData.prayers[index],
                            time: prayerData.timings[prayerData.prayers[index]] ?? "--:--",
                            isPast: index < currentPrayerIndex
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .padding(30)
        }
        .padding()
    }
}

// Reusable Prayer Row.
struct PrayerRow: View {
    let prayerName: String
    let time: String
    var isPast: Bool = false

    var body: some View {
        HStack {
            Text(prayerName)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .opacity(isPast ? 0.7 : 1.0)
                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
            Spacer()
            Text(time)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .opacity(isPast ? 0.7 : 1.0)
                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(colors: [Color.blue.opacity(isPast ? 0.1 : 0.2), Color.clear], startPoint: .leading, endPoint: .trailing))
                .blendMode(.plusLighter)
        )
    }
}
