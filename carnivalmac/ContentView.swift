//
//  ContentView.swift
//  carnivalmac
//
//  Created by LegitMichel777 on 2021/5/6.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var karen: carnivalKaren
    @State var searchText=""
    var body: some View {
        ZStack {
            Image("image-"+karen.theme)
                .resizable()
                .scaledToFill()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(karen: carnivalKaren(isPreview: true))
    }
}
