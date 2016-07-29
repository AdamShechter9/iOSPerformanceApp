//
//  ViewController.swift
//  touchDrawCircle
//
//  Created by Adam Shechter on 7/27/16.
//  Copyright © 2016 Adam Shechter. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let mySynth = simpleSynthClass(amp: 0.5, freq: 220)
    var swiped = false
    var lastPoint = CGPoint.zero
    
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    
    
// -----------------------------------------------------------------
    @IBOutlet var panRecognizer: UIPanGestureRecognizer!

    
    @IBAction func panGestureAction(sender: UIPanGestureRecognizer) {
        let translation = panRecognizer.translationInView(self.view)
        panRecognizer.setTranslation(CGPointZero, inView: self.view)
        print(translation.x)
        print(translation.y)
        let location = panRecognizer.locationInView(self.view)
        print(location.x)
        print(location.y)
        generateRadial(location)
        
        var note = abs(Double(location.y / view.frame.height) - 1.0)
        note = pow((note * 50), 2) + 50
        print(note)
        mySynth.noteOnSynth(note)
        print("log scale result \(note)")
        if panRecognizer.state == UIGestureRecognizerState.Ended
        {
             mySynth.noteOffSynth()
            print("fading out")
            circleFadeOut()
            backgroundAnimEnd()
            
        }
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = false
        if let touch = touches.first as UITouch! {
            let location = touch.locationInView(self.view)
            lastPoint = touch.locationInView(self.view)
            generateRadial(location)
            print("fading in")
            circleFadeIn()
            backgroundAnimStart()
            var note = abs(Double(location.y / view.frame.height) - 1.0)
            note = pow((note * 50), 2) + 50
            print(note)
            mySynth.noteOnSynth(note)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        mySynth.noteOffSynth()
        print("fading out")
        circleFadeOut()
        backgroundAnimEnd()
        
    }
// -----------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        // backgroundContinuousAnim()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


// -----------------------------------------------------------------
    func generateRadial(center: CGPoint)
    {
        //Define the gradient ----------------------
        var gradient: CGGradientRef
        var colorSpace: CGColorSpaceRef
        
        let locations_num: size_t = 3
        let locations: [CGFloat] = [0.0, 0.2, 0.4]
        let redRandom = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let grnRandom = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let bluRandom = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let components: [CGFloat] = [redRandom, grnRandom, bluRandom, 0.2,
                                     redRandom, grnRandom, bluRandom, 1.0,
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
        fadeIn.duration = 0.3
        imageView1.layer.addAnimation(fadeIn, forKey: "fade")
    }
    
    func circleFadeOut()
    {
        let fadeOut = CABasicAnimation.init(keyPath: "opacity")
        fadeOut.delegate = imageView1
        fadeOut.fromValue = 1
        fadeOut.toValue = 0
        fadeOut.duration = 0.3
        // fadeOut.fillMode = kCAFillModeForwards
        fadeOut.fillMode = kCAFillModeForwards
        fadeOut.removedOnCompletion = false
        imageView1.layer.addAnimation(fadeOut, forKey: "fade")
    }
    
    func backgroundAnimStart()
    {
        let redRandom = Float(arc4random()) / Float(UINT32_MAX)
        let grnRandom = Float(arc4random()) / Float(UINT32_MAX)
        let bluRandom = Float(arc4random()) / Float(UINT32_MAX)
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.backgroundColor = UIColor.blackColor()
            }) { (Bool) -> Void in
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.backgroundColor = UIColor.init(colorLiteralRed: redRandom, green: grnRandom, blue: bluRandom, alpha: 1)
                }, completion: nil)
            }
    }
    

    func backgroundAnimEnd()
    {
        let redRandom = Float(arc4random()) / Float(UINT32_MAX)
        let grnRandom = Float(arc4random()) / Float(UINT32_MAX)
        let bluRandom = Float(arc4random()) / Float(UINT32_MAX)
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.backgroundColor = UIColor.init(colorLiteralRed: redRandom, green: grnRandom, blue: bluRandom, alpha: 1)
            }) { (Bool) -> Void in
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.view.backgroundColor = UIColor.blackColor()
                    }, completion:nil)
        }
    }
    
    func backgroundContinuousAnim()
    {
        UIView.animateWithDuration(2, delay: 0.0, options:[UIViewAnimationOptions.Repeat, UIViewAnimationOptions.Autoreverse], animations: {
            self.view.backgroundColor = UIColor.blackColor()
            self.view.backgroundColor = UIColor.greenColor()
            self.view.backgroundColor = UIColor.grayColor()
            self.view.backgroundColor = UIColor.redColor()
            }, completion: nil)
    }
    
}

