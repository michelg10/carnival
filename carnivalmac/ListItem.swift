//
//  ListItem.swift
//  carnivalmac
//
//  Created by LegitMichel777 on 2021/5/10.
//

import SwiftUI

struct lastAdd {
    var val: Int
    var from: String
}

struct ListItem: View {
    var LastAdd: lastAdd?
    var theme: String
    var change: changeState
    var rank: Int
    var name: String
    var points: Int
    var body: some View {
        HStack {
            changeArrow(change: change, theme: theme, size: 20)
                .frame(width:33,alignment: .leading)
            Text(String(rank))
                .font(.system(size: 20, weight: .semibold, design: .default))
                .foregroundColor(.init("ldrfloattxt-"+theme))
                .frame(width:60,alignment: .leading)
            Text(name)
                .font(.system(size: 20, weight: .medium, design: .default))
                .foregroundColor(.init("ldrfloattxt-"+theme))
            Spacer()
            Text(String(points)+" pts")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.init("ldrsecfloattxt-"+theme))
            if LastAdd != nil {
                let startText=(LastAdd!.val>0 ? "+" : "-")+String(LastAdd!.val)
                Text(startText+" from "+LastAdd!.from)
                    .padding(.leading,17)
                    .frame(width:217)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.init("ldr"+(LastAdd!.val>0 ? "up" : "down")+"-"+theme))
            }
        }.frame(height:49)
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(LastAdd: .init(val: 20, from: "Gender Reveal Party"),theme: "late", change: .dUp, rank: 123, name: "Mimi Yang", points: 5432)
            .frame(width:658)
    }
}
