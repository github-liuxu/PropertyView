//
//  ViewController.swift
//  PropertyView
//
//  Created by Mac-Mini on 2024/12/27.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var propertyView: NSTextView!
    @IBOutlet weak var classText: NSTextField!
    let propertyViewer = PropertyViewer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classText.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func controlTextDidChange(_ obj: Notification) {
        propertyViewer.setViewerObject(classText.stringValue)
        propertyView.string = propertyViewer.infoString() as String
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

