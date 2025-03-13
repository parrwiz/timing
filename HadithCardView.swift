import SwiftUI

struct HadithCardView: View {
    @ObservedObject var viewModel: SunnahViewModel
    
    // Maximum character count for the hadith display
    private let maxCharacterCount = 300
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hadith of the Day")
                .font(.headline)
                .foregroundColor(.black)
            
            if let hadith = viewModel.hadith {
                VStack(alignment: .leading, spacing: 16) {
                    // Only show English translation in the card view
                    // Truncate long hadiths with "Read more..." instead of "..."
                    if hadith.hadithEnglish.count > maxCharacterCount {
                        Text(hadith.hadithEnglish.prefix(maxCharacterCount) + "... (Read more)")
                            .font(.body)
                            .foregroundColor(.black.opacity(0.7))
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 8)
                    } else {
                        Text(hadith.hadithEnglish)
                            .font(.body)
                            .foregroundColor(.black.opacity(0.7))
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 8)
                    }
                    
                    HStack {
                        Spacer()
                        Text("Sahih Bukhari: \(hadith.hadithNumber)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(red: 250/255, green: 250/255, blue: 250/255))
                .cornerRadius(16)
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
                viewModel.fetchRandomHadith()
            }) {
                Text("New Hadith")
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
        .onAppear {
            if viewModel.hadith == nil {
                viewModel.fetchRandomHadith()
            } else if viewModel.hadith!.hadithEnglish.count > maxCharacterCount * 2 {
                // If the hadith is extremely long, fetch a new one
                viewModel.fetchRandomHadith()
            }
        }
    }
}