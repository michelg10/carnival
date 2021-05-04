//
//  ContentView.swift
//  carnival
//
//  Created by LegitMichel777 on 2021/3/30.
//

import SwiftUI
let theme="mid"
func getChangeState(cur: Int, lst: Int) -> changeState {
    if cur==lst {
        return .nochange
    }
    print("Calc")
    print(cur,lst)
    if cur>lst {
        if cur>lst+10 {
            return .dUp
        } else {
            print("i return up")
            return .up
        }
    } else {
        if cur<lst-10 {
            return .dDown
        } else {
            return .down
        }
    }
}
struct ContentView: View {
    @ObservedObject var karen: carnivalKaren
    var body: some View {
        ZStack {
            Image("image-mid")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
            VStack(spacing:0) {
                Text("Leaderboards")
                    .font(.system(size: 40, weight: .semibold, design: .default))
                    .foregroundColor(.init("ldrtxt-"+theme))
                    .padding(.bottom,24)
                    .padding(.top,30)
                HStack(spacing:0) {
                    Text("Pins")
                        .font(.system(size: 24, weight: .semibold, design: .default))
                        .foregroundColor(.init("ldrtxt-"+theme))
                    Spacer()
                    Text("\(karen.pinnedIDs.count)/5 Pinned")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(.init("ldrsectxt-"+theme))
                }.padding(.bottom,8)
                VStack {
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
                                        if !karen.pinnedIDs.contains(thisParticipant.id) {
                                            karen.pinnedIDs.append(thisParticipant.id)
                                        }
                                    } else {
                                        if karen.pinnedIDs.contains(thisParticipant.id) {
                                            karen.pinnedIDs.remove(at: karen.pinnedIDs.firstIndex(of: thisParticipant.id)!)
                                        }
                                    }
                                  }),
                                  points: thisParticipant.score
                        )
                    }
                }.background(Color.init("ldrfloat-"+theme))
                .cornerRadius(11, antialiased: true)
                Spacer()
            }.padding(.horizontal,15)
            .frame(width:UIScreen.main.bounds.width)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(karen: carnivalKaren(isPreview: true))
    }
}
