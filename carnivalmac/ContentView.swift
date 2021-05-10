//
//  ContentView.swift
//  carnivalmac
//
//  Created by LegitMichel777 on 2021/5/6.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var karen: carnivalKaren
    @State var isFocus=false
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
                                .foregroundColor(.init("ldrtxt-"+theme))
                            VStack(spacing:0) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 20, weight: .medium, design: .default))
                                        .foregroundColor(.init("ldrsearch-"+theme))
                                        .padding(.leading,11)
                                    liveUpdatingTextView(text: Binding(get: {
                                        karen.playerSearch
                                    }, set: { val in
                                        print("I set \(val)")
                                        karen.playerSearch=val
                                        karen.searchForParticipant(val: karen.playerSearch)
                                    }),
                                                         font: NSFont.systemFont(ofSize: 18, weight: .medium),
                                                         placeholder: "Search Participants...",
                                                         textAlignment: .center,
                                                         color: .init(named: "ldrtxt-"+theme),
                                                         placeholderColor: .init(named: "ldrsearch-"+theme)
                                    )
                                }.frame(maxHeight:39)
                                .background(Color.init("ldrfloatsearch-"+theme))
                                .cornerRadius(17)
                                ScrollView(.vertical, showsIndicators: false, content: {
                                    VStack(spacing:0) {
                                        ForEach((0..<karen.searchedParticipants.count), id:\.self) { index in
                                            let thisParticipant=karen.searchedParticipants[index]
                                            ListItem(LastAdd: nil,
                                                     theme: theme,
                                                     change: getChangeState(cur: thisParticipant.currentRank, lst: thisParticipant.previousRank),
                                                     rank: thisParticipant.currentRank,
                                                     name: thisParticipant.name,
                                                     points: thisParticipant.score
                                            ).padding(.horizontal,22)
                                            if index != karen.searchedParticipants.count-1 {
                                                Rectangle()
                                                    .frame(height:1)
                                                    .padding(.leading,23)
                                                    .foregroundColor(.init("ldrsep-"+theme))
                                            }
                                        }
                                    }
                                })
                            }.background(Color.init("ldrfloat-"+theme))
                            .cornerRadius(17)
                        }.frame(maxWidth:490)
                        VStack(spacing:0) {
                            Text("Recents")
                                .font(.system(size: 32, weight: .semibold, design: .default))
                                .padding(.bottom,11)
                                .foregroundColor(.init("ldrtxt-"+theme))
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
