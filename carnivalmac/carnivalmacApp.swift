//
//  carnivalmacApp.swift
//  carnivalmac
//
//  Created by LegitMichel777 on 2021/5/6.
//

import SwiftUI

@main
struct carnivalmacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(karen: carnivalKaren(isPreview: false))
        }
    }
}
