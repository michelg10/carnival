//
//  scoreButton.swift
//  carnival
//
//  Created by LegitMichel777 on 2021/3/31.
//

import SwiftUI

struct scoreButton: View {
    var index: Int
    var active: Bool
    var editable: Bool
    @ObservedObject var karen: carnivalKaren
    var body: some View {
        let circleDist:CGFloat=5
        HStack {
            Button(action: {
                generateHaptic(hap: .medium)
                if editable {
                    karen.scoreaddpresets[index] *= -1
                    karen.saveData()
                } else {
                    karen.modifyScore(val: karen.scoreaddpresets[index])
                }
            }, label: {
                ZStack {
                    Circle()
                        .frame(width:41-circleDist,height:41-circleDist)
                        .foregroundColor(.init(active ? (karen.scoreaddpresets[index] < 0 ? "minus" : "plus") : "inactivemodbuttons"))
                    Image(systemName: karen.scoreaddpresets[index] < 0 ? "minus" : "plus")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.init("ViewFloat"))
                }
            }).padding(.leading,circleDist/2)
            .buttonStyle(topBarButtonStyle())
            Spacer()
            if editable {
                liveUpdatingTextView(text: Binding(get: {
                    String(abs(karen.scoreaddpresets[index]))
                }, set: { (val) in
                    karen.scoreaddpresets[index]=abs(Int(val) ?? 0)
                    karen.saveData()
                }), font: .systemFont(ofSize: 18, weight: .medium), placeholder: "Pts", textAlignment: .center)
            } else {
                Text(String(abs(karen.scoreaddpresets[index])))
                    .font(.system(size: 18, weight: .medium, design: .default))
            }
            Spacer()
        }.frame(height:41)
        .background(
            Rectangle()
                .foregroundColor(.init("ViewFloat"+(editable ? "Modal" : "")))
                .cornerRadius(.greatestFiniteMagnitude)
        )
    }
}

struct scoreButton_Previews: PreviewProvider {
    static var previews: some View {
        scoreButton(index: 0, active: true, editable: false, karen: carnivalKaren(isPreview: true))
    }
}
