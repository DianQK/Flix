//
//  StoryboardViewController.swift
//  Example
//
//  Created by wc on 23/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import Flix

class StoryboardViewController: UIViewController {
    
    @IBOutlet weak var logoProvider: FlixStackItemProvider!
    
    @IBAction func flixLogoClicked(_ sender: FlixStackItemProvider) {
        let alert = UIAlertController(title: nil, message: "点击了 Logo", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func flixContentClicked(_ sender: FlixStackItemProvider) {
        let alert = UIAlertController(title: nil, message: "点击了内容", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func contentSwitchChanged(_ sender: UISwitch) {
        logoProvider.isHidden = !sender.isOn
    }
    
}
