//
//  QiblaResponse.swift
//  Arkan
//
//  Created by mac on 2/3/25.
//

import Foundation

struct QiblaData: Decodable {
    let latitude: Double
    let longitude: Double
    let direction: Double
}

struct QiblaResponse: Decodable {
    let code: Int
    let status: String
    let data: QiblaData
}
