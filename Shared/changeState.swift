//
//  changeState.swift
//  carnivaladmin
//
//  Created by LegitMichel777 on 2021/5/7.
//

import Foundation
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
    var size: CGFloat
    var body: some View {
        let arrowFont=Font.system(size: size, weight: .semibold, design: .default)
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
