//
//  scoreButton.swift
//  carnival
//
//  Created by LegitMichel777 on 2021/3/31.
//

import SwiftUI

struct scoreButton: View {
    var value: Int
    var active: Bool
    var karen: carnivalKaren
    var body: some View {
        let circleDist:CGFloat=5
        HStack {
            Button(action: {
                karen.modifyScore(val: value)
            }, label: {
                ZStack {
                    Circle()
                        .frame(width:41-circleDist,height:41-circleDist)
                        .foregroundColor(.init(active ? (value < 0 ? "minus" : "plus") : "inactivemodbuttons"))
                    Image(systemName: value < 0 ? "minus" : "plus")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.init("ViewFloat"))
                }
            }).padding(.leading,circleDist/2)
            .buttonStyle(topBarButtonStyle())
            Spacer()
            Text(String(abs(value)))
                .font(.system(size: 18, weight: .medium, design: .rounded))
            Spacer()
        }.frame(height:41)
        .background(
            Rectangle()
                .foregroundColor(.init("ViewFloat"))
                .cornerRadius(.greatestFiniteMagnitude)
        )
    }
}

struct scoreButton_Previews: PreviewProvider {
    static var previews: some View {
        scoreButton(value: -50, active: true, karen: carnivalKaren(isPreview: true))
    }
}
