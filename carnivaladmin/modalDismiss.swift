//
//  modalDismiss.swift
//  carnival
//
//  Created by LegitMichel777 on 2021/3/31.
//

import SwiftUI

struct modalDismiss: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    var body: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                generateHaptic(hap: .medium)
            }, label: {
                ZStack {
                    Circle()
                        .foregroundColor(.init("ButtonColorActive"))
                        .frame(width:horizontalSizeClass == .regular ? 55 : 45,height:horizontalSizeClass == .regular ? 65 : 45)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.primary)
                        .font(.system(size: horizontalSizeClass == .regular ? 27 : 22,weight: .medium))
                        .padding(.top,horizontalSizeClass == .regular ? 3 : 4)
                }.padding(.horizontal,20)
            }).buttonStyle(topBarButtonStyle())
            .hoverEffect(.lift)
            Spacer()
        }.padding(.top,20)
    }
}

struct modalDismiss_Previews: PreviewProvider {
    static var previews: some View {
        modalDismiss()
    }
}
