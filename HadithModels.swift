import Foundation

// MARK: - Hadith Models
struct HadithResponse: Decodable {
    let hadiths: HadithsData
}

struct HadithsData: Decodable {
    let data: [Hadith]
}

struct Hadith: Decodable {
    let hadithNumber: Int
    let hadithArabic: String
    let hadithEnglish: String
    
    // Custom decoding to handle "hadithNumber" as String or Int
    enum CodingKeys: String, CodingKey {
        case hadithNumber, hadithArabic, hadithEnglish
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode hadithNumber as Int first
        if let number = try? container.decode(Int.self, forKey: .hadithNumber) {
            hadithNumber = number
        }
        // If it fails, try decoding as String and convert to Int
        else {
            let numberString = try container.decode(String.self, forKey: .hadithNumber)
            guard let number = Int(numberString) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .hadithNumber,
                    in: container,
                    debugDescription: "hadithNumber is not a valid integer"
                )
            }
            hadithNumber = number
        }
        
        hadithArabic = try container.decode(String.self, forKey: .hadithArabic)
        hadithEnglish = try container.decode(String.self, forKey: .hadithEnglish)
    }
}

// Extension to help with String to Int conversion if needed
extension String {
    var asInt: Int? {
        return Int(self)
    }
}