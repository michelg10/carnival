import SwiftUI

#if os(macOS)
import AppKit

class FocusAwareTextField: NSTextField {
    var onFocusChange: (Bool) -> Void = { _ in }
    
    override func becomeFirstResponder() -> Bool {
        let textView = window?.fieldEditor(true, for: nil) as? NSTextView
        onFocusChange(true)
        return super.becomeFirstResponder()
    }
}

struct liveUpdatingTextView: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    @Binding var text: String
    @State var isFocus=false
    func updateNSView(_ nsView: NSTextField, context: Context) {
        print("View update")
        nsView.stringValue=text
        nsView.font=font
        if placeholderColor != nil {
            let tmp=NSMutableAttributedString(string: placeholder,attributes: [NSAttributedString.Key.foregroundColor: placeholderColor!, NSAttributedString.Key.font: font])
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            tmp.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: tmp.length))
            nsView.placeholderAttributedString=tmp
        } else {
            nsView.placeholderString=placeholder
        }
        nsView.textColor=color
        nsView.alignment=textAlignment
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: liveUpdatingTextView
        init(_ textField: liveUpdatingTextView) {
            self.parent=textField
        }
        func controlTextDidEndEditing(_ obj: Notification) {
            self.parent.isFocus=false
        }
        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            self.parent.text = textField.stringValue
        }
        
    }
    
    var font: NSFont
    var placeholder: String
    var textAlignment: NSTextAlignment
    var color: NSColor?
    var placeholderColor: NSColor?
    
    func makeNSView(context: Context) -> NSTextField {
        let rturn=FocusAwareTextField()
        rturn.backgroundColor = .clear
        rturn.drawsBackground=false
        rturn.isBordered=false
        rturn.stringValue=text
        rturn.font=font
        if placeholderColor != nil {
            let tmp=NSMutableAttributedString(string: placeholder,attributes: [NSAttributedString.Key.foregroundColor: placeholderColor!, NSAttributedString.Key.font: font])
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            tmp.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: tmp.length))
            rturn.placeholderAttributedString=tmp
        } else {
            rturn.placeholderString=placeholder
        }
        rturn.textColor=color
        
        
        rturn.alignment=textAlignment
        rturn.delegate=context.coordinator
        rturn.focusRingType = .none
        
        rturn.onFocusChange = { isFocus in
            self.isFocus = isFocus
        }
        return rturn
    }
}
#endif

#if os(iOS)
import UIKit
struct liveUpdatingTextView: UIViewRepresentable {
    @Binding var text: String
    func updateUIView(_ uiView: UITextField, context: Context) {
        print("View update")
        uiView.text=text
        uiView.font=font
        if placeholderColor != nil {
            uiView.attributedPlaceholder=NSAttributedString(string: placeholder,attributes: [NSAttributedString.Key.foregroundColor: placeholderColor!])
        } else {
            uiView.placeholder=placeholder
        }
        uiView.textColor=color
        uiView.textAlignment=textAlignment
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) {
            _text = text
        }
        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            text=textField.stringValue
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
#endif

struct liveupdatingtextfield_Previews: PreviewProvider {
    static var previews: some View {
        #if os(macOS)
        ZStack {
            Rectangle()
                .foregroundColor(.black)
            liveUpdatingTextView(text: .constant(""),
                                 font: NSFont.systemFont(ofSize: 18, weight: .medium),
                                 placeholder: "Placeholder",
                                 textAlignment: .center,
                                 color: .black,
                                 placeholderColor: .blue
            )
        }
        #endif
    }
}
