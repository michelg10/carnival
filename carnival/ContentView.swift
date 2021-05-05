//
//  ContentView.swift
//  carnival
//
//  Created by LegitMichel777 on 2021/3/30.
//

import SwiftUI
let theme="late"
func getChangeState(cur: Int, lst: Int) -> changeState {
    if cur==lst {
        return .nochange
    }
    if cur>lst {
        if cur>lst+10 {
            return .dDown
        } else {
            return .down
        }
    } else {
        if cur<lst-10 {
            return .dUp
        } else {
            return .up
        }
    }
}
struct ContentView: View {
    @ObservedObject var karen: carnivalKaren
    @State var searchText=""
    var body: some View {
        ZStack {
            VStack(spacing:0) {
                Text("Leaderboards")
                    .font(.system(size: 40, weight: .semibold, design: .default))
                    .foregroundColor(.init("ldrtxt-"+theme))
                    .padding(.bottom,24)
                    .padding(.top,30)
                if karen.pinnedIDs.count > 0 {
                    HStack(spacing:0) {
                        Text("Pins")
                            .font(.system(size: 24, weight: .semibold, design: .default))
                            .foregroundColor(.init("ldrtxt-"+theme))
                        Spacer()
                        Button(action: {
                            generateHaptic(hap: .soft)
                            karen.pinnedIDs.removeAll()
                            karen.saveData()
                        }, label: {
                            Text("\(karen.pinnedIDs.count)/5 Pinned")
                                .font(.system(size: 18, weight: .semibold, design: .default))
                                .foregroundColor(.init("ldrsectxt-"+theme))
                        }).buttonStyle(topBarButtonStyle())
                    }.padding(.bottom,8)
                    VStack(spacing:0) {
                        ForEach((0..<karen.pinnedParticipants.count), id:\.self) { index in
                            let thisParticipant=karen.pinnedParticipants[index]
                            rankentry(theme: theme,
                                      change: getChangeState(cur: thisParticipant.currentRank, lst: thisParticipant.previousRank),
                                      rank: thisParticipant.currentRank,
                                      name: thisParticipant.name,
                                      pinned: Binding(get: {
                                        karen.pinnedIDs.contains(thisParticipant.id)
                                      }, set: { val in
                                        if val {
                                            if !karen.pinnedIDs.contains(thisParticipant.id) && karen.pinnedIDs.count<5 {
                                                karen.pinnedIDs.append(thisParticipant.id)
                                                karen.refreshPinnedList()
                                                generateHaptic(hap: .light)
                                            }
                                        } else {
                                            if karen.pinnedIDs.contains(thisParticipant.id) {
                                                karen.pinnedIDs.remove(at: karen.pinnedIDs.firstIndex(of: thisParticipant.id)!)
                                                karen.refreshPinnedList()
                                                generateHaptic(hap: .light)
                                            }
                                        }
                                        karen.saveData()
                                      }),
                                      points: thisParticipant.score
                            )
                            if index != karen.pinnedParticipants.count-1 {
                                Rectangle()
                                    .frame(height:1)
                                    .padding(.leading,14)
                                    .foregroundColor(.init("ldrsep-"+theme))
                            }
                        }
                    }.background(Color.init("ldrfloat-"+theme))
                    .cornerRadius(11, antialiased: true)
                    .padding(.bottom,17)
                }
                HStack(spacing:0) {
                    Text("Ranked")
                        .font(.system(size: 24, weight: .semibold, design: .default))
                        .foregroundColor(.init("ldrtxt-"+theme))
                    Spacer()
                }.padding(.bottom,8)
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .foregroundColor(.init("ldrsearch-"+theme))
                            .padding(.leading,14)
                        liveUpdatingTextView(text: Binding(get: {
                            karen.playerSearch
                        }, set: { val in
                            karen.playerSearch=val
                            karen.searchForParticipant(val: karen.playerSearch)
                        }), font: UIFont.systemFont(ofSize: 18, weight: .medium),
                        placeholder: "Search Participants...",
                        textAlignment: .left,
                        color: UIColor.init(named: "ldrtxt-"+theme),
                        placeholderColor: UIColor.init(named: "ldrsearch-"+theme)
                        )
                        .fixedSize(horizontal:false,vertical:true)
                    }.frame(height:44)
                    .background(Color.init("ldrfloatsearch-"+theme))
                    .cornerRadius(13, antialiased: true)
                    RefreshableScrollView(refreshing: Binding(get: {
                        karen.refreshing
                    }, set: { (val) in
                        karen.updateData()
                        generateHaptic(hap: .heavy)
                    }), arrowColor: .init("ldrtxt-"+theme),
                    content: {
                        VStack(spacing:0) {
                            ForEach((0..<karen.searchedParticipants.count), id:\.self) { index in
                                let thisParticipant=karen.searchedParticipants[index]
                                rankentry(theme: theme,
                                          change: getChangeState(cur: thisParticipant.currentRank, lst: thisParticipant.previousRank),
                                          rank: thisParticipant.currentRank,
                                          name: thisParticipant.name,
                                          pinned: Binding(get: {
                                            karen.pinnedIDs.contains(thisParticipant.id)
                                          }, set: { val in
                                            if val {
                                                if !karen.pinnedIDs.contains(thisParticipant.id) && karen.pinnedIDs.count<5 {
                                                    karen.pinnedIDs.append(thisParticipant.id)
                                                    karen.refreshPinnedList()
                                                    generateHaptic(hap: .light)
                                                }
                                            } else {
                                                if karen.pinnedIDs.contains(thisParticipant.id) {
                                                    karen.pinnedIDs.remove(at: karen.pinnedIDs.firstIndex(of: thisParticipant.id)!)
                                                    karen.refreshPinnedList()
                                                    generateHaptic(hap: .light)
                                                }
                                            }
                                            karen.saveData()
                                          }),
                                          points: thisParticipant.score
                                )
                                if index != karen.searchedParticipants.count-1 {
                                    Rectangle()
                                        .frame(height:1)
                                        .padding(.leading,14)
                                        .foregroundColor(.init("ldrsep-"+theme))
                                }
                            }
                        }
                    })
                }.background(Color.init("ldrfloat-"+theme))
                .cornerRadius(13, antialiased: true)
            }.padding(.horizontal,15)
            .padding(.bottom,29)
        }.ignoresSafeArea(.keyboard)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(karen: carnivalKaren(isPreview: true))
    }
}
