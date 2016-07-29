//
//  simpleSynthClass.swift
//  touchDrawCircle
//
//  Created by Adam Shechter on 7/28/16.
//  Copyright © 2016 Adam Shechter. All rights reserved.
//

import Foundation
import AudioKit

class simpleSynthClass {
    var oscillator = AKTriangleOscillator()

    var currentamp: Double
    var currentRampTime = 0.02
    var freq: Double
    
    init(amp: Double = 0.5, freq: Double)
    {
        self.currentamp = amp
        self.freq = freq
        oscillator.rampTime = currentRampTime
        oscillator.amplitude = self.currentamp
        print("initializing synth class")
        print("amp \(amp)      freq \(freq)")
        startAudio()
    }
    
    func startAudio()
    {
        AudioKit.output = oscillator
        AudioKit.start()
        print("starting audio")
    }
    
    func noteOnSynth(freq: Double)
    {
        oscillator.play()
        if oscillator.amplitude == 0
        {
            oscillator.rampTime = 0
        }
        self.freq = freq
        oscillator.frequency = self.freq
        oscillator.rampTime = currentRampTime
        oscillator.amplitude = currentamp
        oscillator.play()
    }
    
    func noteOffSynth()
    {
        oscillator.amplitude = 0
    }
}
