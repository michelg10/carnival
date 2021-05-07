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
        let theme=karen.theme
        ZStack {
            Image("image-"+theme)
                .resizable()
                .scaledToFill()
            VStack(spacing:0) {
                Text("Leaderboards")
                    .font(.system(size: 40, weight: .semibold, design: .default))
                    .foregroundColor(.init("ldrtxt-"+theme))
                    .padding(.top,28)
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(karen: carnivalKaren(isPreview: true))
            .frame(width: 1024, height: 768, alignment: .center)
    }
}
