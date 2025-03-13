//
//  SunnahView.swift
//  Arkan
//

import SwiftUI

struct SunnahView: View {
    @EnvironmentObject var viewModel: SunnahViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background color matching HomeView
            Color(red: 245/255, green: 245/255, blue: 245/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with gradient background
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Text("Hadith of the Day")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Empty view for balance
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.clear)
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                }
                .background(Color(red: 220/255, green: 78/255, blue: 65/255))
                .edgesIgnoringSafeArea(.top)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if let hadith = viewModel.hadith {
                            // Hadith number card
                            HStack {
                                Text("Hadith Number: \(hadith.hadithNumber)")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("Sahih Bukhari")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            
                            // Arabic text card
                            VStack(alignment: .trailing) {
                                Text(hadith.hadithArabic)
                                    .font(.system(size: 20, design: .serif))
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.black.opacity(0.8))
                                    .padding()
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            
                            // Translation card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Translation")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Text(hadith.hadithEnglish)
                                    .font(.body)
                                    .foregroundColor(.black.opacity(0.7))
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            
                        } else if viewModel.isLoading {
                            // Loading state
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .padding()
                                Text("Loading Hadith...")
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        } else {
                            // Empty state
                            VStack {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                    .padding()
                                
                                Text("Tap 'New Hadith' to load a hadith")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                            .frame(height: 300)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        }
                        
                        // New Hadith button
                        Button(action: {
                            viewModel.fetchRandomHadith()
                        }) {
                            Text("New Hadith")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 220/255, green: 78/255, blue: 65/255))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

// MARK: - Preview
struct SunnahView_Preview: PreviewProvider {
    static var previews: some View {
        SunnahView()
    }
}
