//
//  simpleSynthClass.swift
//  touchDrawCircle
//
//  Created by Adam Shechter on 7/28/16.
//  Copyright © 2016 Adam Shechter. All rights reserved.
//
// .init(waveform: AKTable(.Sine, size: 4096), frequency: 1000, amplitude: 0.5, detuningOffset: 0, detuningMultiplier: 1);
import Foundation
import AudioKit

class simpleSynthClass {

    let oscillatorAK = AKOscillator(waveform: AKTable(.Sawtooth, size: 4096), frequency: 1000, amplitude: 0.5, detuningOffset: 0, detuningMultiplier: 1)
    let lpfSynth: AKLowPassFilter
    var delayUnitSynth: AKDelay
    var currentAmp: Double
    var currentRampTime = 0.02
    var freq: Double
    var play2: AKAudioPlayer
    var filterPlayer: AKLowPassFilter
    var filterPlayer2: AKHighPassFilter
    var delayUnit: AKDelay
    var reverbUnit: AKReverb
    var playState = false
    var paramaterState: [String: Double] = ["pitch": 0.0, "rate": 0.0, "freq1": 20000.0, "freq2": 0.0, "vol": 0.375, "delay": 0, "reverb": 0]
    
    var mixerMain: AKMixer
    
    init(amp: Double = 0.3, freq: Double)
    {
        // Synth Init----------------------------------------------------
        self.currentAmp = amp
        self.freq = freq
        oscillatorAK.rampTime = currentRampTime
        oscillatorAK.amplitude = self.currentAmp
        print("initializing synth class")
        print("amp \(amp)      freq \(freq)")
        self.lpfSynth = AKLowPassFilter(oscillatorAK)
        self.lpfSynth.resonance = 10
 
        delayUnitSynth = AKDelay(lpfSynth)
        delayUnitSynth.time = 0.1
        delayUnitSynth.feedback = 0.2
        delayUnitSynth.dryWetMix = 0.1
        
        // Synth Init----------------------------------------------------
        paramaterState["pitch"] = 1.0
        paramaterState["rate"] = 1.0
        let bundle = NSBundle.mainBundle()
        let file1 = bundle.pathForResource("loop1", ofType: "wav")
        play2 = AKAudioPlayer(file1!)
        play2.volume = paramaterState["vol"]!
        play2.looping = true
        filterPlayer = AKLowPassFilter(play2)
        filterPlayer.cutoffFrequency = paramaterState["freq1"]!
        filterPlayer.resonance = 0.0
        filterPlayer2 = AKHighPassFilter(filterPlayer)
        filterPlayer2.cutoffFrequency = paramaterState["freq2"]!
        filterPlayer2.resonance = 0.0
        delayUnit = AKDelay(filterPlayer2)
        delayUnit.time = 0.2
        delayUnit.feedback = 0.4
        delayUnit.dryWetMix = paramaterState["delay"]!
        delayUnit.start()
        reverbUnit = AKReverb(delayUnit)
        reverbUnit.dryWetMix = paramaterState["reverb"]!

        
        mixerMain = AKMixer(reverbUnit, delayUnitSynth)
        mixerMain.volume = 1.0
        startAudio()
    }
    
    func dummy()
    {
        
        
    }
    
    func lpFilterFreq(cutoff: Double)
    {
        print("filter cutoff at \(cutoff)")
        lpfSynth.cutoffFrequency = cutoff
        
    }
    
    func startAudio()
    {
        reverbUnit.start()
        self.mixerMain.start()
        self.lpfSynth.start()
        delayUnitSynth.start()
        AudioKit.output = mixerMain
        AudioKit.start()
        print("starting audio")
    }
    
    func playSamplerPlayer(startStop: Bool)
    {
        playState = startStop
        print("playState \(playState)")
        if playState
        {
            play2.play()
            
        }
        else
        {
            play2.stop()
        }
    }
    
    func noteOnSynth(freq: Double)
    {
        oscillatorAK.play()
        if oscillatorAK.amplitude == 0
        {
            oscillatorAK.rampTime = 0
        }
        self.freq = freq
        oscillatorAK.frequency = self.freq
        oscillatorAK.rampTime = currentRampTime
        oscillatorAK.amplitude = currentAmp
        oscillatorAK.play()
    }
    
    func noteOffSynth()
    {
        oscillatorAK.amplitude = 0
    }
}
