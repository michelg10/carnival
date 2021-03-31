//
//  carnivalApp.swift
//  carnival
//
//  Created by LegitMichel777 on 2021/3/30.
//

import SwiftUI

@main
struct carnivalApp: App {
    var body: some Scene {
        WindowGroup {
            let karen=carnivalKaren(isPreview: false)
//            ContentView()
            AddScoreView(karen: karen)
        }
    }
}
