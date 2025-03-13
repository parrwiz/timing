//
//  QiblaCompassViewModel.swift
//  Arkan
//
//  Created by mac on 2/3/25.
//

import Foundation
import Combine

class QiblaCompassViewModel: ObservableObject {
    @Published var qiblaDirection: Double = 0.0
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Fetches the Qibla direction for the given coordinates.
    func fetchQiblaDirection(latitude: Double, longitude: Double) {
        guard let url = URL(string: "https://api.aladhan.com/v1/qibla/\(latitude)/\(longitude)") else {
            print("Invalid URL")
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: QiblaResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching Qibla direction: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] response in
                // The API returns the Qibla direction as a degree relative to north.
                self?.qiblaDirection = response.data.direction
            }
            .store(in: &cancellables)
    }
}
