import SwiftUI

struct QuranVerseCardView: View {
    @ObservedObject var viewModel: QuranViewModel
    @Binding var showQuranReader: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quran Verse")
                .font(.headline)
                .foregroundColor(.black)
            
            if let ayah = viewModel.currentAyah, let translation = viewModel.currentTranslation {
                Button(action: {
                    showQuranReader = true
                }) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(ayah.textUthmani)
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        Text(translation.text.htmlStripped)
                            .font(.body)
                            .foregroundColor(.black.opacity(0.7))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 8)
                        
                        HStack {
                            Spacer()
                            Text(ayah.verseKey)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(red: 250/255, green: 250/255, blue: 250/255))
                    .cornerRadius(16)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding()
                    Spacer()
                }
                .frame(height: 200)
                .background(Color(red: 250/255, green: 250/255, blue: 250/255))
                .cornerRadius(16)
            }
            
            Button(action: {
                viewModel.fetchNextAyah()
            }) {
                Text("New Verse")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(Color(red: 220/255, green: 78/255, blue: 65/255))
                    .cornerRadius(12)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
