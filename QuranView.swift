import SwiftUI
import UIKit

struct QuranView: View {
    @StateObject private var viewModel = QuranViewModel()
    @Binding var isPresented: Bool
    
    @State private var showSurahMenu = false
    @State private var selectedSurah: Int = 1

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 245/255, green: 245/255, blue: 245/255).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if let ayah = viewModel.currentAyah {
                        VStack(alignment: .center, spacing: 16) {
                            // Display the Quranic text and ayah number in a centered layout
                            HStack(spacing: 10) {
                                Text(ayah.textUthmani)
                                    .font(.system(size: 28, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.primary)
                                Text("(\(viewModel.currentAyahNumber ?? 0))")
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundColor(.gray)
                            }
                            
                            Divider()
                            
                            // Display the translation (with HTML tags stripped)
                            if let translation = viewModel.currentTranslation {
                                Text(translation.text.htmlStripped)
                                    .font(.system(size: 20))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Loading translation...")
                                    .font(.system(size: 20))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                    } else {
                        ProgressView("Loading...")
                            .padding()
                    }
                    
                    // Navigation buttons styled similarly to SunnahView's button
                    HStack(spacing: 20) {
                        Button(action: {
                            viewModel.fetchPreviousAyah()
                        }) {
                            Text("Previous")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        
                        Button(action: {
                            viewModel.fetchNextAyah()
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // A linear progress view to indicate progress through the Quran
                    if let totalAyahs = viewModel.totalAyahs {
                        ProgressView(value: Double(viewModel.currentAyahNumber ?? 0), total: Double(totalAyahs))
                            .progressViewStyle(LinearProgressViewStyle())
                            .padding()
                            .accentColor(.green)
                    }
                }
            }
            .navigationTitle("Quran Kareem")
            .navigationBarItems(
                leading: Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(Color(red: 220/255, green: 78/255, blue: 65/255))
                },
                trailing: Button(action: {
                    showSurahMenu.toggle()
                }) {
                    Image(systemName: "list.bullet")
                        .font(.title2)
                        .foregroundColor(Color(red: 220/255, green: 78/255, blue: 65/255))
                }
            )
            .sheet(isPresented: $showSurahMenu) {
                SurahMenuView(selectedSurah: $selectedSurah, onSelectSurah: {
                    viewModel.fetchSurah(surahNumber: selectedSurah)
                    showSurahMenu = false
                })
            }
            .padding()
            .onAppear {
                viewModel.fetchInitialAyah()
            }
        }
    }
}

struct SurahMenuView: View {
    @Binding var selectedSurah: Int
    var onSelectSurah: () -> Void
    
    let surahs = (1...114).map { $0 }
    
    var body: some View {
        NavigationView {
            List(surahs, id: \.self) { surah in
                Button(action: {
                    selectedSurah = surah
                    onSelectSurah()
                }) {
                    Text("Surah \(surah)")
                        .font(.title2)
                        .padding()
                }
            }
            .navigationTitle("Select Surah")
            .navigationBarItems(trailing: Button("Done") {
                onSelectSurah()
            })
        }
    }
}
