//
//  scoreEditView.swift
//  carnival
//
//  Created by LegitMichel777 on 2021/3/31.
//

import SwiftUI

struct scoreEditView: View {
    @ObservedObject var karen: carnivalKaren
    var body: some View {
        VStack(spacing:0) {
            modalDismiss()
                .padding(.bottom,15)
            Text("Score Preferences")
                .font(.system(size: 32, weight: .semibold, design: .default))
                .multilineTextAlignment(.center)
                .padding(.bottom,20)
            HStack {
                Text("Name")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                Spacer()
                liveUpdatingTextView(text: Binding(get: {
                    karen.myName
                }, set: { (val) in
                    karen.myName=val
                }), font: .systemFont(ofSize: 18, weight: .medium), placeholder: "Name", textAlignment: .right)
                .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            }.padding(.bottom,20)
            .padding(.horizontal,17)
            HStack {
                Text("My Presets")
                    .font(.system(size: 24, weight: .semibold, design: .default))
                Spacer()
            }.padding(.bottom,10)
            .padding(.horizontal,17)
            VStack(spacing:16) {
                ForEach((0..<karen.scoreaddpresets.count/3), id:\.self) { index in
                    HStack(spacing: 8) {
                        ForEach((0..<3), id:\.self) { index2 in
                            if index*3+index2<karen.scoreaddpresets.count {
                                scoreButton(index: index*3+index2,active: true, editable: true, karen: karen)
                            }
                        }
                    }
                }
            }.padding(.horizontal,22)
            Spacer()
        }
    }
}

struct scoreEditView_Previews: PreviewProvider {
    static var previews: some View {
        scoreEditView(karen: carnivalKaren(isPreview: true))
    }
}
