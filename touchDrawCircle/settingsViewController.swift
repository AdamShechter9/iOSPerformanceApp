//
//  settingsViewController.swift
//  touchDrawCircle
//
//  Created by Adam Shechter on 7/29/16.
//  Copyright © 2016 Adam Shechter. All rights reserved.
//

import UIKit

protocol settingsViewControllerDelegate: class
{
    func pressedBackButtonFrom(controller: UIViewController, response: [String:String])
}

class settingsViewController: UIViewController {
    var delegate: settingsViewControllerDelegate?
    
    @IBOutlet weak var filterResonanceSliderValue: UISlider!
    @IBOutlet weak var synthAttackSliderValue: UISlider!
    @IBOutlet weak var drawCircleSwitch: UISwitch!
    @IBOutlet weak var backgroundLightSwitch: UISwitch!
    
    var drawCircleBoolean = false
    var backgroundLightsBoolean = false
    var delegateFilterQ = 10.0
    var delegateSynthAttack = 0.001
    
    @IBAction func backButtonPressedAction(sender: UIBarButtonItem) {
        print("back button pressed")
        let responseOut = [
            "drawCircle": String(drawCircleSwitch.on),
            "backgroundLights": String(backgroundLightSwitch.on),
            "filterQ": String(filterResonanceSliderValue.value),
            "synthAttack": String(synthAttackSliderValue.value)
        ]
        delegate?.pressedBackButtonFrom(self, response: responseOut)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("circle ")
        drawCircleSwitch.on = drawCircleBoolean
        print(drawCircleSwitch.on)
        print("background light")
        backgroundLightSwitch.on = backgroundLightsBoolean
        print(backgroundLightSwitch.on)
        filterResonanceSliderValue.value = Float(delegateFilterQ)
        synthAttackSliderValue.value = Float(delegateSynthAttack)
    }
    
    
    
    
}
