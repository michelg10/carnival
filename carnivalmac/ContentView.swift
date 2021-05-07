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
        GeometryReader { geometry in
            ZStack {
                Image("image-"+theme)
                    .resizable()
                    .scaledToFill()
                    .frame(width:geometry.frame(in: .global).width, height: geometry.frame(in: .global).height)
                VStack(spacing:0) {
                    Text("Leaderboards")
                        .font(.system(size: 40, weight: .semibold, design: .default))
                        .foregroundColor(.init("ldrtxt-"+theme))
                        .padding(.top,28)
                        .padding(.bottom,27)
                    HStack(spacing:23) {
                        VStack(spacing:0) {
                            Text("Top Players")
                                .font(.system(size: 32, weight: .semibold, design: .default))
                                .padding(.bottom,11)
                            VStack(spacing:0) {
                                
                            }
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                                    .foregroundColor(.init("ldrsearch-"+theme))
                                    .padding(.leading,11)
                                liveUpdatingTextView(text: $searchText,
                                                     font: NSFont.systemFont(ofSize: 18, weight: .medium),
                                                     placeholder: "Search Participants...",
                                                     textAlignment: .center,
                                                     color: .init(named: "ldrtxt-"+theme),
                                                     placeholderColor: .init(named: "ldrsearch-"+theme)
                                )
                            }.frame(maxWidth: 386.0, maxHeight:39)
                            .background(Color.init("ldrfloatsearch-"+theme))
                            .cornerRadius(.greatestFiniteMagnitude)
                            .padding(.horizontal,20)
                            RoundedRectangle(cornerRadius: 17)
                        }.frame(maxWidth:490)
                        VStack(spacing:0) {
                            Text("Recents")
                                .font(.system(size: 32, weight: .semibold, design: .default))
                                .padding(.bottom,11)
                            ScrollView {
                                
                            }.frame(maxWidth: 696)
                        }
                    }.padding(.bottom,20)
                }
            }.frame(width:geometry.frame(in: .global).width, height: geometry.frame(in: .global).height)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(karen: carnivalKaren(isPreview: true))
            .frame(width: 1280, height: 800, alignment: .center)
    }
}
