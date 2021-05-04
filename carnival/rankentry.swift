//
//  rankentry.swift
//  carnival
//
//  Created by LegitMichel777 on 2021/5/4.
//

import SwiftUI

enum changeState {
    case dUp
    case up
    case nochange
    case down
    case dDown
}

struct changeArrow: View {
    var change: changeState
    var theme: String
    let arrowFont=Font.system(size: 18, weight: .semibold, design: .default)
    var body: some View {
        switch change {
        case .dUp:
            ZStack(alignment: .bottom) {
                Image(systemName: "chevron.up")
                    .foregroundColor(.init("ldrup-"+theme))
                    .font(arrowFont)
                Image(systemName: "chevron.up")
                    .foregroundColor(.init("ldrup-"+theme))
                    .font(arrowFont)
                    .padding(.bottom,7)
            }
        case .up:
            Image(systemName: "chevron.up")
                .foregroundColor(.init("ldrup-"+theme))
                .font(arrowFont)
        case .nochange:
            Image(systemName: "minus")
                .foregroundColor(.init("ldrnochange-"+theme))
                .font(arrowFont)
        case .down:
            Image(systemName: "chevron.down")
                .foregroundColor(.init("ldrdown-"+theme))
                .font(arrowFont)
        case .dDown:
            ZStack(alignment: .bottom) {
                Image(systemName: "chevron.down")
                    .foregroundColor(.init("ldrdown-"+theme))
                    .font(arrowFont)
                Image(systemName: "chevron.down")
                    .foregroundColor(.init("ldrdown-"+theme))
                    .font(arrowFont)
                    .padding(.bottom,7)
            }
        }
    }
}

struct rankentry: View {
    var theme: String
    var change: changeState
    var rank: Int
    var name: String
    @Binding var pinned: Bool
    var points: Int
    var body: some View {
        HStack(spacing:0) {
            HStack(spacing:0) {
                changeArrow(change: change, theme: theme)
                    .padding(.leading,15)
                Spacer()
            }.frame(width:48)
            HStack(spacing:0) {
                Text(String(rank))
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.init("ldrfloattxt-"+theme))
                Spacer()
            }.frame(width:43)
            Text(name)
                .foregroundColor(.init("ldrfloattxt-"+theme))
                .font(.system(size: 18, weight: .medium, design: .default))
            Spacer()
            Button(action: {
                pinned.toggle()
            }, label: {
                Image(systemName: "pin"+(pinned ? ".fill" : ""))
                    .foregroundColor(.init("ldrpin-"+theme))
            }).buttonStyle(topBarButtonStyle())
            HStack {
                Spacer()
                Text(String(points)+" pts")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.init("ldrsecfloattxt-"+theme))
                    .padding(.trailing,14)
            }.frame(width:96)
        }.frame(height:43)
    }
}

struct rankentry_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Rectangle()
            rankentry(theme: "mid",change: .up, rank: 153, name: "Mimi Yang", pinned: .constant(true), points: 5432)
        }
    }
}
