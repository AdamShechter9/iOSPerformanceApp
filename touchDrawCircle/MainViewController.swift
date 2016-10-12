//
//  MainViewController.swift
//  touchDrawCircle
//
//  Created by Adam Shechter on 7/27/16.
//  Copyright © 2016 Adam Shechter. All rights reserved.
//

//
//TO DO
//
//AUDIO / SOUND features
//
// - settings for change Q on filter
// - settings for change attack on instrument
// - add ability to record jam and share with friends
// - add ability to record your own loop thru microphone (if available?)
// - add "musical note" mode where it's quantized to a midi note pitch.
//
//Visual Options
// - Turn circle on/off after finger was lifted
// - Background color animation on/off
// - leaving a color/smoke trail for short bit would be pleasing
// - possible cool backgrounds displayed?
//

import UIKit
import AudioKit
import CoreMotion

class MainViewController: UIViewController, settingsViewControllerDelegate {
    
    // CoreMotion motion manager
    let manager = CMMotionManager()
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    
    let mySynth = simpleSynthClass(amp: 0.5, freq: 220)
    var swiped = false
    var lastPoint = CGPoint.zero
    
    var cutoff = 0.0
    var delayReverb = 0.0
    var loopFileSelect = 1
    var waveFormSelect = 1
    var isPlaying = false
    
    var delegateFilterQ = 10.0
    var delegateSynthAttack = 0.001
    var drawCircleBoolean = false
    var backgroundLightBoolean = false
    
    // boolean to make sure synth doesn't play when we're in settings page
    var inSettingsPage = false
    var motionSelectorSwitch = 0
    
    @IBAction func accelSwitchControlChanged(sender: UISegmentedControl) {
        motionSelectorSwitch = sender.selectedSegmentIndex
        if motionSelectorSwitch == 0
        {
            self.cutoff = 0.5
            self.delayReverb = 0.0
            mySynth.changeDelayReverb(0)
            mySynth.changeFilterCutoff(0.5)
        }
        else
        {
            print("motion activated")
        }
    }
    
    @IBAction func playButtonPressed(sender: UIBarButtonItem) {
        print("play/stop button pressed")
        isPlaying = !isPlaying
        mySynth.playSamplerPlayer(isPlaying)
    }
    

    @IBAction func loopSelectorValueChanged(sender: UIStepper) {
        loopFileSelect = Int(sender.value)
        print("loopFile \(loopFileSelect)")
        mySynth.changeLoopFile(loopFileSelect)
        
    }
    
    @IBAction func waveOscValueChange(sender: UIStepper) {
        waveFormSelect = Int(sender.value)
        print("Waveform \(waveFormSelect)")
        mySynth.waveformSynthChange(waveFormSelect)
    }

// ----- Segue movement  ------------------------------------------------------------
    @IBAction func settingsButtonPressed(sender: UIBarButtonItem) {
        // settings page
        print("settings button pressed")
        inSettingsPage = true
        performSegueWithIdentifier("settingsSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "settingsSegue"
        {
            print("preparing for segue settingsSegue")
            let navigator  = segue.destinationViewController as! UINavigationController
            let controller = navigator.topViewController as! settingsViewController
            controller.delegate = self
            controller.drawCircleBoolean = drawCircleBoolean
            controller.backgroundLightsBoolean = backgroundLightBoolean
            controller.delegateSynthAttack = delegateSynthAttack
            controller.delegateFilterQ = delegateFilterQ
        }
    }
    
    // ----- Delegate function ------------------------------------------------------------
    
    
    func pressedBackButtonFrom(controller: UIViewController, response: [String:String]) {
        inSettingsPage = false
        print("in Mainview Controller")
        print(response)
        if response["drawCircle"] == "true"
        { drawCircleBoolean = true }
        else
        { drawCircleBoolean = false }
        if response["backgroundLights"] == "true"
        { backgroundLightBoolean = true }
        else
        { backgroundLightBoolean = false }
        print("changed to draw circle \(drawCircleBoolean)")
        
        delegateSynthAttack = Double(response["synthAttack"]!)!
        delegateFilterQ = Double(response["filterQ"]!)!
        
        mySynth.lpFilterRes(delegateFilterQ)
        mySynth.synthAttackRampTime(delegateSynthAttack)
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

// -----------------------------------------------------------------
    func filterMovement(cutoffSlider:Double)
    {
        
        let newCutoff = Double(((cutoffSlider) + 1) / 2)
        self.mySynth.changeFilterCutoff(newCutoff)
    }
    
    func effectsMovement(effectsSlider:Double)
    {
        let newEFX = Double((effectsSlider))
        self.mySynth.changeDelayReverb(newEFX)
    }
    
    
    
    
// -----------------------------------------------------------------
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!

    
    @IBAction func panGestureAction(sender: UIPanGestureRecognizer) {
        // touch ended
        if panRecognizer.state == UIGestureRecognizerState.Ended
        {
            print("fading out")
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.mySynth.oscMixer.volume = 0
                self.mySynth.oscillatorTriAK.amplitude = 0
                self.mySynth.oscillatorSqrAK.amplitude = 0
                self.mySynth.oscillatorSawAK.amplitude = 0
                self.mySynth.noiseAK.amplitude = 0
            }
            self.mySynth.noteOffSynth()
            circleFadeOut()
            if backgroundLightBoolean {
                backgroundAnimEnd()
            }
            
        }
        
        if inSettingsPage == false
        {
            panRecognizer.setTranslation(CGPointZero, inView: self.view)
            let location = panRecognizer.locationInView(self.view)
            print("location x \(location.x)")
            print("location y \(location.y)")
            
            var adjustPoint = CGPoint()
            adjustPoint.x = location.x
            adjustPoint.y = location.y
            adjustPoint.y *= 1.05
            generateRadial(adjustPoint)
            
            var note = abs(Double(location.y / view.frame.height - 1.0))
            note = pow((note * 50), 2) + 50
            print(note)
            mySynth.noteOnSynth(note)
            print("log scale result \(note)")
            let cutoff = Double(adjustPoint.x * 15)
            mySynth.lpFilterFreq(cutoff)
        }
        
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = false
        if inSettingsPage == false {
            if let touch = touches.first as UITouch! {
                let location = touch.locationInView(self.view)
                print("location x \(location.x)")
                print("location y \(location.y)")
                
                var adjustPoint = CGPoint()
                adjustPoint.x = location.x
                adjustPoint.y = location.y
                adjustPoint.y *= 1.05
                generateRadial(adjustPoint)
                circleFadeIn()
                if backgroundLightBoolean {
                    backgroundAnimStart()
                }
                
                self.mySynth.oscMixer.volume = 0.5
                var note = abs(Double(location.y / view.frame.height - 1.0))
                note = pow((note * 50), 2) + 50
                print(note)
                mySynth.noteOnSynth(note)
                print("log scale result \(note)")
                let cutoff = Double(adjustPoint.x * 15)
                mySynth.lpFilterFreq(cutoff)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if inSettingsPage == false {
            print("fading out")
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.mySynth.oscMixer.volume = 0
                self.mySynth.oscillatorTriAK.amplitude = 0
                self.mySynth.oscillatorSqrAK.amplitude = 0
                self.mySynth.oscillatorSawAK.amplitude = 0
                self.mySynth.noiseAK.amplitude = 0
            }
            self.mySynth.noteOffSynth()
            circleFadeOut()
            if backgroundLightBoolean {
                backgroundAnimEnd()
            }
        }

    }
// -----------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        // imageView1.backgroundColor = UIColor.blackColor()
        // backImageView.backgroundColor = UIColor.blackColor()
        accelInit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// ------------- Graphics and animation functions-------------------------------------
    
    func generateRadial(center: CGPoint)
    {
        //Define the gradient ----------------------
        var gradient: CGGradientRef
        var colorSpace: CGColorSpaceRef
        
        let locations_num: size_t = 3
        let locations: [CGFloat] = [0.0, 0.1, 0.3]
        let redRandom = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let grnRandom = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let bluRandom = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let components: [CGFloat] = [redRandom, grnRandom, bluRandom, 0.7,
                                     redRandom, grnRandom, bluRandom, 1,
                                     redRandom, grnRandom, bluRandom, 0.0
                                    ]
//        let locations_num: size_t = 5
//        
//        let locations: [CGFloat] = [0.0, 0.2, 0.3, 0.5, 0.7]
//        
//        let components: [CGFloat] = [1.0, 0.0, 0.0, 0.2,
//                                     1.0, 0.0, 0.0, 1,
//                                     1.0, 0.0, 0.0, 0.8,
//                                     1.0, 0.0, 0.0, 0.4,
//                                     1.0, 0.0, 0.0, 0.0
//        ]
        
        colorSpace = CGColorSpaceCreateDeviceRGB()!;
        gradient = CGGradientCreateWithColorComponents (colorSpace, components,
                                                        locations, locations_num)!;
        
        
        //Define Gradient Positions ---------------
        
        //We want these exactly at the center of the view
//        var startPoint = CGPoint()
//        var endPoint = CGPoint()
//        
//        //Start point
//        startPoint.x = view.frame.size.width/2;
//        startPoint.y = view.frame.size.height/2;
//        
//        //End point
//        endPoint.x = view.frame.size.width/2;
//        endPoint.y = view.frame.size.height/2;
        
        //Generate the Image -----------------------
        //Begin an image context
        UIGraphicsBeginImageContext(view.frame.size);
        let imageContext = UIGraphicsGetCurrentContext()
        let gradientDrawingOption = CGGradientDrawingOptions(rawValue: 0)
        //Use CG to draw the radial gradient into the image context
        CGContextDrawRadialGradient(imageContext, gradient, center, 0, center, view.frame.size.width/2.5, gradientDrawingOption);
        //Get the image from the context
        imageView1.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
    }

    func circleFadeIn()
    {
        let fadeIn = CABasicAnimation.init(keyPath: "opacity")
        fadeIn.delegate = imageView1
        fadeIn.fromValue = 0
        fadeIn.toValue = 1
        fadeIn.duration = 0.15
        imageView1.layer.addAnimation(fadeIn, forKey: "fade")
    }
    
    func circleFadeOut()
    {
        let fadeOut = CABasicAnimation.init(keyPath: "opacity")
        fadeOut.delegate = imageView1
        fadeOut.fromValue = 1
        fadeOut.toValue = 0
        fadeOut.duration = 0.15
        fadeOut.fillMode = kCAFillModeForwards
        // add or remove circle depending on switch
        fadeOut.removedOnCompletion = drawCircleBoolean
        imageView1.layer.addAnimation(fadeOut, forKey: "fade")
    }
    
    func backgroundAnimStart()
    {
        let redRandom = Float(arc4random()) / Float(UINT32_MAX)
        let grnRandom = Float(arc4random()) / Float(UINT32_MAX)
        let bluRandom = Float(arc4random()) / Float(UINT32_MAX)
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.backImageView.backgroundColor = UIColor.blackColor()
            }) { (Bool) -> Void in
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.backImageView.backgroundColor = UIColor.init(colorLiteralRed: redRandom, green: grnRandom, blue: bluRandom, alpha: 1)
                }, completion: nil)
            }
    }
    

    func backgroundAnimEnd()
    {
        let redRandom = Float(arc4random()) / Float(UINT32_MAX)
        let grnRandom = Float(arc4random()) / Float(UINT32_MAX)
        let bluRandom = Float(arc4random()) / Float(UINT32_MAX)
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.backImageView.backgroundColor = UIColor.init(colorLiteralRed: redRandom, green: grnRandom, blue: bluRandom, alpha: 1)
            }) { (Bool) -> Void in
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.backImageView.backgroundColor = UIColor.blackColor()
                    }, completion:nil)
        }
    }
    
//----- this isn't connected ---------
    func backgroundContinuousAnim()
    {
        UIView.animateWithDuration(2, delay: 0.0, options:[UIViewAnimationOptions.Repeat, UIViewAnimationOptions.Autoreverse], animations: {
            self.view.backgroundColor = UIColor.blackColor()
            self.view.backgroundColor = UIColor.greenColor()
            self.view.backgroundColor = UIColor.grayColor()
            self.view.backgroundColor = UIColor.redColor()
            }, completion: nil)
    }
    
    
// ---Accelerometer and Gyroscope--------------------------------------------------------------
    
    func accelInit()
    {
        
        print ("acceloremeter initializing")
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue())
        {
            (data, error) in
//            print (data?.acceleration.x)
//            print (data?.acceleration.y)
//            print (data?.acceleration.z)
            // print (self.motionSelectorSwitch)
            if self.motionSelectorSwitch == 0
            {
                // print("accelerometer off")
            }
            else if self.motionSelectorSwitch == 1
            {
                // filter and efx controllers
                self.cutoff = ((data?.acceleration.x)! + 1) / 2
                self.delayReverb = (data?.acceleration.y)!
                // self.volSliderValue.value =  Float((data?.acceleration.y)! + 1) / 2 * 0.75
                
                let newCutoff = Double(((data?.acceleration.x)! + 1) / 2)
                self.mySynth.changeFilterCutoff(newCutoff)
                
                let newEFX = Double((data?.acceleration.y)!)
                self.mySynth.changeDelayReverb(newEFX)
                
            }
            
        }
        
    }
    
}

