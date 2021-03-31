//
//  AddScoreView.swift
//  carnival
//
//  Created by LegitMichel777 on 2021/3/30.
//

import SwiftUI

struct liveUpdatingTextView: UIViewRepresentable {
    @Binding var text: String
    func updateUIView(_ uiView: UITextField, context: Context) {
        print("View update")
        uiView.text = text
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) {
            _text = text
        }
        func textFieldDidChangeSelection(_ textField: UITextField) {
            print("Text select changed")
            text = textField.text ?? ""
        }
        func textFieldDidBeginEditing(_ textField: UITextField) {
            print("Begins editing")
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            print("Should return")
            return true
        }
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            print("End editing")
            return true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    var font: UIFont
    var placeholder: String
    var textAlignment: NSTextAlignment
    func makeUIView(context: Context) -> UITextField {
        let rturn=UITextField()
        rturn.text=text
        rturn.font=font
        rturn.placeholder=placeholder
        rturn.autocorrectionType = .no
        
//        rturn.translatesAutoresizingMaskIntoConstraints=false
        rturn.textAlignment = textAlignment
        rturn.delegate=context.coordinator
        return rturn
    }
}

struct nilButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}

struct topBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .saturation(configuration.isPressed ? 0.95 : 1)
            .brightness(configuration.isPressed ? 0.03 : 0) //0.05
    }
}

struct AddScoreView: View {
    @ObservedObject var karen: carnivalKaren
    @State var playerSearch=""
    var body: some View {
        VStack(spacing:0) {
            Text("Add Score")
                .font(.system(size: 32, weight: .semibold, design: .default))
                .padding(.bottom,13)
                .padding(.top,10)
            liveUpdatingTextView(text: Binding(get: {
                playerSearch
            }, set: { (val) in
                playerSearch=val
                karen.searchForParticipant(val: playerSearch)
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
                                karen.selectedParticipant = currentParticipant.id
                            }, label: {
                                ListItem(name: currentParticipant.name, rank: currentParticipant.currentRank, selected: karen.selectedParticipant == currentParticipant.id, points: currentParticipant.score,id:currentParticipant.id, karen: karen)
                            }).buttonStyle(topBarButtonStyle())
                            if index != karen.searchedParticipants.count-1 {
                                Rectangle()
                                    .frame(height:1)
                                    .padding(.leading,18)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .background(Color.init("ViewFloat"))
                .cornerRadius(12)
                .padding(.horizontal,13)
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
                                scoreButton(value: karen.scoreaddpresets[index*3+index2],active: karen.selectedParticipant != nil, karen: karen)
                            }
                        }
                    }
                }
            }.padding(.horizontal,22)
            .padding(.bottom,22)
            ZStack {
                Rectangle()
                    .frame(width:110,height:40)
                    .cornerRadius(.greatestFiniteMagnitude)
                    .foregroundColor(.init("EditButton"))
                Text("Edit")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(.init("EditText"))
            }.padding(.bottom,16)
        }
    }
}

struct AddScoreView_Previews: PreviewProvider {
    static var previews: some View {
        AddScoreView(karen: carnivalKaren(isPreview: true))
    }
}
