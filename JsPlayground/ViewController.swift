//
//  ViewController.swift
//  JsPlayground
//
//  Created by Marc Attinasi on 11/2/17.
//  Copyright © 2017 ServiceNow. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleView: UILabel!
    
    @IBAction func doItAgain(_ sender: Any) {
        updateTitle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateTitle()
        seedData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func updateTitle() {
        titleView.text = JSManager.instance().getTitle() + "\n" + JSManager.instance().getModel()
    }

    fileprivate func seedData() {
        _ = JSManager.instance().addObject(name: "a", value: "anchovie")
        _ = JSManager.instance().addObject(name: "b", value: "bolognaise")
        _ = JSManager.instance().addObject(name: "c", value: "cookie")
        _ = JSManager.instance().addObject(name: "d", value: 3.1415)
        _ = JSManager.instance().addObject(name: "e", value: [1,2,3,4,5])
        _ = JSManager.instance().addObject(name: "f", value: ["x":100, "y":200])
        
        print("Seeded Data: ")
        _ = JSManager.instance().printModel()
    }
}

