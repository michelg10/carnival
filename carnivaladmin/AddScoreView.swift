//
//  AddScoreView.swift
//  carnival
//
//  Created by LegitMichel777 on 2021/3/30.
//

import SwiftUI

struct AddScoreView: View {
    @ObservedObject var karen: carnivalKaren
    @State var editViewPresent=false
    @State var detailView: String?
    var body: some View {
        VStack(spacing:0) {
            Text("Add Score")
                .font(.system(size: 32, weight: .semibold, design: .default))
                .padding(.top,10)
            Text("Posting as \(karen.myName)")
                .font(.system(size: 15, weight: .medium, design: .default))
                .padding(.bottom,13)
            liveUpdatingTextView(text: Binding(get: {
                karen.playerSearch
            }, set: { (val) in
                karen.playerSearch=val
                karen.searchForParticipant(val: karen.playerSearch)
            }), font: .systemFont(ofSize: 18, weight: .semibold), placeholder: "Search participants...", textAlignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical,10)
                .background(Color.init("ViewFloat"))
                .cornerRadius(.greatestFiniteMagnitude)
                .padding(.horizontal,40)
                .padding(.bottom,18)
            if karen.searchedParticipants.count == 0 {
                VStack {
                    Spacer()
                    HStack(spacing:0) {
                        Spacer()
                        Text("No participants matched your search")
                            .font(.system(size: 18, weight: .medium, design: .default))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    Spacer()
                }.background(Color.init("ViewFloat"))
                .cornerRadius(12)
                .padding(.horizontal,13)
            } else {
                ScrollView {
                    VStack(spacing:0) {
                        ForEach((0..<karen.searchedParticipants.count), id:\.self) { index in
                            let currentParticipant=karen.searchedParticipants[index]
                            Button(action: {
                                if karen.selectedParticipant != currentParticipant.id {
                                    karen.selectedParticipant = currentParticipant.id
                                    generateHaptic(hap: .light)
                                }
                            }, label: {
                                ListItem(name: currentParticipant.name, rank: currentParticipant.currentRank, selected: karen.selectedParticipant == currentParticipant.id, points: currentParticipant.score,id:currentParticipant.id, karen: karen, edit: $detailView)
                                    .id(currentParticipant.id)
                            }).buttonStyle(topBarButtonStyle())
                            if index != karen.searchedParticipants.count-1 {
                                Rectangle()
                                    .frame(height:1)
                                    .padding(.leading,18)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }.background(Color.init("ViewFloat"))
                .cornerRadius(12)
                .padding(.horizontal,13)
                .sheet(isPresented: Binding(get: {
                    detailView != nil
                }, set: { (val) in
                    if !val {
                        detailView=nil
                    }
                }), content: {
                    participantDetail(id: detailView ?? "", karen: karen)
                })
            }
            Text("Score")
                .font(.system(size: 24, weight: .medium, design: .default))
                .padding(.bottom,12)
                .padding(.top,20)
            VStack(spacing:16) {
                ForEach((0..<karen.scoreaddpresets.count/3), id:\.self) { index in
                    HStack(spacing: 8) {
                        ForEach((0..<3), id:\.self) { index2 in
                            if index*3+index2<karen.scoreaddpresets.count {
                                scoreButton(index: index*3+index2,active: karen.selectedParticipant != nil, editable: false, karen: karen)
                            }
                        }
                    }
                }
            }.padding(.horizontal,22)
            .padding(.bottom,22)
            Button(action: {
                editViewPresent=true
                generateHaptic(hap: .medium)
            }, label: {
                ZStack {
                    Rectangle()
                        .frame(width:110,height:40)
                        .cornerRadius(.greatestFiniteMagnitude)
                        .foregroundColor(.init("EditButton"))
                    Text("Edit")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.init("EditText"))
                }.padding(.bottom,16)
            }).buttonStyle(topBarButtonStyle())
            .sheet(isPresented: $editViewPresent, content: {
                scoreEditView(karen: karen)
            })
        }.background(Color.init("overrideBgColor"))
        .onAppear(perform: {
            UIApplication.shared.handleKeyboard()
        })
    }
}

struct AddScoreView_Previews: PreviewProvider {
    static var previews: some View {
        AddScoreView(karen: carnivalKaren(isPreview: true))
    }
}
