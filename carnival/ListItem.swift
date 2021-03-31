//
//  ListItem.swift
//  carnival
//
//  Created by LegitMichel777 on 2021/3/31.
//

import SwiftUI

struct ListItem: View {
    var name: String
    var rank: Int
    var selected: Bool
    var points: Int
    var id: String
    var karen: carnivalKaren
    @State var editPresent: Bool = false
    var body: some View {
        HStack(spacing:0) {
            Text("#"+String(rank))
                .font(.system(size: 15, weight: .semibold, design: .default))
                .frame(width:43,alignment: .leading)
            Text(name)
                .font(.system(size: 18, weight: .medium, design: .default))
            Spacer()
            Text(String(points)+" pt"+(points==1 ? "" : "s"))
                .font(.system(size: 15, weight: .medium, design: .default))
                .padding(.trailing,17)
            Button(action: {
                editPresent=true
            }, label: {
                Text("Edit...")
            }).sheet(isPresented: $editPresent, content: {
                Text("Placeholder")
            })
        }.padding(.horizontal,18)
        .padding(.vertical,12)
        .background(selected ? Color.init("Selected") : Color.init("ViewFloat"))
    }
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(name: "Max", rank: 86, selected: true, points: 123, id: "preview", karen: carnivalKaren(isPreview: true))
    }
}
