import Foundation
import SwiftUI

class SunnahViewModel: ObservableObject {
    @Published var hadith: Hadith? = nil
    @Published var isLoading: Bool = false
    
    init() {
        fetchRandomHadith()
    }
    
    func fetchRandomHadith() {
        isLoading = true
        let randomNumber = Int.random(in: 1...6638)
        let apiKey = "$2y$10$n8BLRq7hqkYiAwCsLHVEfOgCuxMDZHScHylse2AWHWyxPnrwfVa"
        let urlString = "https://www.hadithapi.com/api/hadiths?apiKey=\(apiKey)&hadithNumber=\(randomNumber)&book=sahih-bukhari"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        print("Fetching hadith from: \(urlString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("Error fetching hadith: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(HadithResponse.self, from: data)
                    if result.hadiths.data.isEmpty {
                        print("No Hadith found for number \(randomNumber)")
                        self.hadith = nil
                        // Try again with a different number
                        self.fetchRandomHadith()
                    } else {
                        self.hadith = result.hadiths.data.first
                        print("Successfully fetched hadith: \(self.hadith?.hadithNumber ?? 0)")
                    }
                } catch {
                    print("Failed to decode Hadith: \(error)")
                    
                    // Debug the JSON response
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON: \(jsonString.prefix(200))")
                    }
                    
                    self.hadith = nil
                    // Try again with a different number
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.fetchRandomHadith()
                    }
                }
            }
        }.resume()
    }
} 