import SwiftUI
import UIKit

// MARK: - HTML Stripping Extension

extension String {
    /// Converts an HTML string into plain text by rendering it as an attributed string.
    var htmlStripped: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSAttributedString(data: data,
                                                          options: options,
                                                          documentAttributes: nil) {
            return attributedString.string
        }
        return self
    }
}

// MARK: - Model Definitions

struct Ayah: Decodable {
    let verseKey: String
    let textUthmani: String

    enum CodingKeys: String, CodingKey {
        case verseKey = "verse_key"
        case textUthmani = "text_uthmani"
    }
}

struct Translation: Decodable {
    let text: String
}

struct QuranResponse: Decodable {
    let verses: [Ayah]
}

struct TranslationResponse: Decodable {
    let translations: [Translation]
}

struct SurahInfo: Decodable {
    let chapter: Chapter

    struct Chapter: Decodable {
        let versesCount: Int

        enum CodingKeys: String, CodingKey {
            case versesCount = "verses_count"
        }
    }
}

// MARK: - ViewModel
class QuranViewModel: ObservableObject {
    @Published var currentAyah: Ayah?
    @Published var currentTranslation: Translation?
    @Published var totalAyahs: Int?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil

    var currentAyahNumber = 1
    private var currentSurah = 1
    private var lastAyahNumber = 1

    init() {
        fetchInitialAyah()
    }

    func fetchInitialAyah() {
        fetchAyah(surah: currentSurah, ayah: currentAyahNumber)
        fetchSurahInfo(surahNumber: currentSurah)
    }

    private func fetchAyah(surah: Int, ayah: Int) {
        isLoading = true
        errorMessage = nil

        let expectedKey = "\(surah):\(ayah)"

        Task {
            do {
                let (ayah, translation) = try await fetchAyahAndTranslation(verseKey: expectedKey)

                await MainActor.run {
                    if ayah.verseKey == expectedKey {
                        self.currentAyah = ayah
                        self.currentTranslation = translation
                    } else {
                        let actualKey = ayah.verseKey
                        print("Mismatch! Expected: \(expectedKey), Actual: \(actualKey)")
                        self.errorMessage = "Data Mismatch. Please try again."
                        self.currentAyah = nil
                        self.currentTranslation = nil
                    }
                    self.isLoading = false
                }
            } catch {
                let nsError = error as NSError
                if nsError.code == -1009 { // No Internet Connection
                    await MainActor.run {
                        self.errorMessage = "No Internet Connection."
                        self.isLoading = false
                        self.currentAyah = nil
                        self.currentTranslation = nil
                    }
                } else {
                    print("Error fetching or decoding data: \(error)")
                    await MainActor.run {
                        self.errorMessage = "Error loading content. Please try again."
                        self.isLoading = false
                        self.currentAyah = nil
                        self.currentTranslation = nil
                    }
                }
            }
        }
    }

    private func fetchAyahAndTranslation(verseKey: String) async throws -> (Ayah, Translation) {
           async let ayahResult: QuranResponse? = fetchData(from: "https://api.quran.com/api/v4/quran/verses/uthmani?verse_key=\(verseKey)", type: QuranResponse.self)
           async let translationResult: TranslationResponse? = fetchData(from: "https://api.quran.com/api/v4/quran/translations/131?verse_key=\(verseKey)", type: TranslationResponse.self)

           guard let ayahResponse = try await ayahResult, let ayah = ayahResponse.verses.first else {
               throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error fetching Ayah"])
           }

           guard let translationResponse = try await translationResult, let translation = translationResponse.translations.first else {
               throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error fetching Translation"])
           }

           return (ayah, translation)
       }

    private func fetchData<T: Decodable>(from urlString: String, type: T.Type) async throws -> T? {
            guard let url = URL(string: urlString) else {
                throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            }

            let (data, _) = try await URLSession.shared.data(from: url)

            let decoder = JSONDecoder()
            // Remove the keyDecodingStrategy to prevent double conversion.
            // decoder.keyDecodingStrategy = .convertFromSnakeCase

            do {
                return try decoder.decode(type, from: data)
            } catch let DecodingError.keyNotFound(key, context) {
                let errorString = "Key '\(key.stringValue)' not found: \(context.debugDescription) \(urlString)"
                print("Decoding error: \(errorString)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(jsonString)")
                }
                throw DecodingError.keyNotFound(key, context) // Re-throw the error
            } catch {
                print("Decoding error: \(error) \(urlString)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(jsonString)")
                }
                throw error
            }
        }
    
    private func fetchSurahInfo(surahNumber: Int, completion: (() -> Void)? = nil) {
        let surahInfoURL = "https://api.quran.com/api/v4/chapters/\(surahNumber)"
        Task {
            do {
                let surahInfoResponse = try await fetchData(from: surahInfoURL, type: SurahInfo.self)
                await MainActor.run {
                    self.totalAyahs = surahInfoResponse?.chapter.versesCount // Access versesCount correctly
                    self.lastAyahNumber = surahInfoResponse?.chapter.versesCount ?? 1
                    completion?()
                }
            } catch {
                print("Error fetching surah info: \(error)")
                await MainActor.run {
                    completion?()
                }
            }
        }
    }

    func fetchNextAyah() {
        if currentAyahNumber == lastAyahNumber {
            if currentSurah < 114 {
                currentSurah += 1
                currentAyahNumber = 1
                fetchSurahInfo(surahNumber: currentSurah) {
                    self.fetchAyah(surah: self.currentSurah, ayah: self.currentAyahNumber)
                }
            }
        } else {
            currentAyahNumber += 1
            fetchAyah(surah: currentSurah, ayah: currentAyahNumber)
        }
    }

    func fetchPreviousAyah() {
        if currentAyahNumber == 1 {
            if currentSurah > 1 {
                currentSurah -= 1
                fetchSurahInfo(surahNumber: currentSurah) {
                    self.currentAyahNumber = self.lastAyahNumber
                    self.fetchAyah(surah: self.currentSurah, ayah: self.currentAyahNumber)
                }
            }
        } else {
            currentAyahNumber -= 1
            fetchAyah(surah: currentSurah, ayah: currentAyahNumber)
        }
    }

    func fetchSurah(surahNumber: Int) {
        currentSurah = surahNumber
        currentAyahNumber = 1
        fetchSurahInfo(surahNumber: surahNumber) {
            self.fetchAyah(surah: self.currentSurah, ayah: self.currentAyahNumber)
        }
    }
}
