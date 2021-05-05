//
//  ViewController.swift
//  carnival
//
//  Created by LegitMichel777 on 2021/5/5.
//

import UIKit
import SwiftUI

class ViewController: UIViewController {

    @IBOutlet var image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let karen=carnivalKaren(isPreview: false, parentImage: image)
        let controller=UIHostingController(rootView:
                                            ContentView(karen: karen)
                                            .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        )
        controller.view.backgroundColor = .clear
        controller.view.translatesAutoresizingMaskIntoConstraints=false
        self.addChild(controller)
        self.view.addSubview(controller.view)
        controller.didMove(toParent: self)
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: guide.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
        
        // Do any additional setup after loading the view.
    }


}

