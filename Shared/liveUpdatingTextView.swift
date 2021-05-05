import SwiftUI
import UIKit

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
    var color: UIColor?
    var placeholderColor: UIColor?
    func makeUIView(context: Context) -> UITextField {
        let rturn=UITextField()
        rturn.text=text
        rturn.font=font
        if placeholderColor != nil {
            rturn.attributedPlaceholder=NSAttributedString(string: placeholder,attributes: [NSAttributedString.Key.foregroundColor: placeholderColor!])
        } else {
            rturn.placeholder=placeholder
        }
        rturn.autocorrectionType = .no
        rturn.textColor=color
        
        
//        rturn.translatesAutoresizingMaskIntoConstraints=false
        rturn.textAlignment = textAlignment
        rturn.delegate=context.coordinator
        return rturn
    }
}
