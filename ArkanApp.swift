//
//  ArkanApp.swift
//  Arkan
//
//  Created by mac on 2/2/25.
//asdf

import Firebase
import SwiftUI
@main
struct ArkanApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
