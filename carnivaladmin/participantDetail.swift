//
//  participantDetail.swift
//  carnival
//
//  Created by LegitMichel777 on 2021/4/1.
//

import SwiftUI

func dateDiff(from: Date, to: Date) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .full
    formatter.allowedUnits=[.hour,.minute,.second]
    let elapsedTime = formatter.string(from: from, to: to)
    
    return elapsedTime!
}

struct participantDetail: View {
    var id: String
    @ObservedObject var karen: carnivalKaren
    var body: some View {
        let detail=karen.getPlayerDetail(id: id)
        VStack(spacing:0) {
            modalDismiss()
                .padding(.bottom,15)
            Text(detail.name)
                .font(.system(size: 32, weight: .semibold, design: .default))
                .padding(.bottom,8)
            VStack(spacing:0) {
                HStack {
                    Text("Player ID")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                    Spacer()
                    Text(detail.playerID)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                }.padding(.bottom,12)
                HStack {
                    Text("Total Score")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                    Spacer()
                    Text(String(detail.totalScore)+" pt"+(detail.totalScore == 1 ? "" : "s"))
                        .font(.system(size: 18, weight: .medium, design: .default))
                }
            }.padding(.horizontal,20)
            .padding(.bottom,15)
            Text("Player Entries")
                .font(.system(size: 24, weight: .medium, design: .default))
                .padding(.bottom,15)
            VStack {
                if detail.playerEntries.count == 0 {
                    ZStack {
                        Rectangle()
                            .cornerRadius(12)
                            .foregroundColor(.init("ViewFloat"))
                        Text("There are no entries for \(detail.name)")
                            .padding(.horizontal,50)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 18, weight: .medium, design: .default))
                    }
                } else {
                    ScrollView {
                        VStack(spacing:0) {
                            ForEach((0..<detail.playerEntries.count), id:\.self) { index in
                                let dis=detail.playerEntries[index]
                                HStack(spacing:0) {
                                    VStack(alignment: .leading, spacing:4) {
                                        Text((dis.marginalScore >= 0 ? "+" : "") + String(dis.marginalScore)+" from "+dis.addSource)
                                            .font(.system(size: 18, weight: .medium, design: .default))
                                        Text("Added \(dateDiff(from: dis.lastUpdated,to: Date())) ago")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 14, weight: .medium, design: .default))
                                    }
                                    Spacer()
                                    Button(action: {
                                        karen.removeEntry(id: dis.id)
                                        generateHaptic(hap: .rigid)
                                    }, label: {
                                        ZStack {
                                            Rectangle()
                                                .foregroundColor(.init("DeleteBg"))
                                                .cornerRadius(12)
                                                .frame(width:71,height:24)
                                            Text("Delete")
                                                .font(.system(size: 15, weight: .medium, design: .default))
                                                .foregroundColor(.init("DeleteText"))
                                        }
                                    }).buttonStyle(topBarButtonStyle())
                                }.padding(.vertical,12)
                                .padding(.horizontal,13)
                                if index != detail.playerEntries.count-1 {
                                    Rectangle()
                                        .frame(height:1)
                                        .padding(.leading,17)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }.background(Color.init("ViewFloatModal"))
                    .cornerRadius(12)
                }
            }.padding(.horizontal,17)
        }.padding(.bottom,40)
    }
}

struct participantDetail_Previews: PreviewProvider {
    static var previews: some View {
        participantDetail(id: "nil", karen: carnivalKaren(isPreview: true))
    }
}
