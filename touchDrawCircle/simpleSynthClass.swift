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

    let oscillatorTriAK = AKOscillator(waveform: AKTable(.Triangle, size: 4096), frequency: 1000, amplitude: 0.2, detuningOffset: 0, detuningMultiplier: 1)
    let oscillatorSawAK = AKOscillator(waveform: AKTable(.Sawtooth, size: 4096), frequency: 1000, amplitude: 0.2, detuningOffset: 0, detuningMultiplier: 1)
    let oscillatorSqrAK = AKOscillator(waveform: AKTable(.Square, size: 4096), frequency: 1000, amplitude: 0.2, detuningOffset: 0, detuningMultiplier: 1)
    let noiseAK = AKWhiteNoise(amplitude: 0.2)
    
    let oscMixer: AKMixer
    
    let lpfSynth: AKLowPassFilter
    var delayUnitSynth: AKDelay
    var currentAmp: Double
    var currentRampTime = 0.001
    var freq: Double
    var play2: AKAudioPlayer
    var filterPlayer: AKLowPassFilter
    var filterPlayer2: AKHighPassFilter
    var delayUnit: AKDelay
    var reverbUnit: AKReverb
    var playState = false
    var synthLPFResonance = 10.0
    var paramaterState: [String: Double] = ["freq1": 20000.0, "freq2": 0.0, "vol": 0.7, "delay": 0, "reverb": 0]
    var waveformSwitchVal = 1
    
    var mixerMain: AKMixer
    
    init(amp: Double = 0.3, freq: Double)
    {
        // Synth Init----------------------------------------------------
        self.currentAmp = 0.1
        self.freq = freq
        oscillatorTriAK.rampTime = currentRampTime
        oscillatorTriAK.amplitude = self.currentAmp + 0.2
        oscillatorSawAK.rampTime = currentRampTime
        oscillatorSawAK.amplitude = self.currentAmp
        oscillatorSqrAK.rampTime = currentRampTime
        oscillatorSqrAK.amplitude = self.currentAmp
        noiseAK.rampTime = currentRampTime
        print("initializing synth class")
        print("amp \(currentAmp)      freq \(freq)")
        
        oscMixer = AKMixer(oscillatorTriAK, oscillatorSawAK, oscillatorSqrAK, noiseAK)
        oscMixer.volume = 0.5
        
        self.lpfSynth = AKLowPassFilter(oscMixer)
        self.lpfSynth.resonance = synthLPFResonance
        
        delayUnitSynth = AKDelay(lpfSynth)
        delayUnitSynth.time = 0.1
        delayUnitSynth.feedback = 0.2
        delayUnitSynth.dryWetMix = 0.1
        
        // Synth Init----------------------------------------------------
        let bundle = NSBundle.mainBundle()
        let file1 = bundle.pathForResource("loop1", ofType: "wav")
        play2 = AKAudioPlayer(file1!)
        play2.volume = paramaterState["vol"]!
        play2.looping = true
        
        mixerMain = AKMixer(play2, delayUnitSynth)
        mixerMain.volume = 1.0
        
        filterPlayer = AKLowPassFilter(mixerMain)
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
    
    func lpFilterRes(resonance: Double)
    {
        print("filter resonance")
        lpfSynth.resonance = resonance
    }
    
    func synthAttackRampTime(attack: Double)
    {
        print("synth attack time \(attack)")
        currentRampTime = attack
    }
    
    func startAudio()
    {
        reverbUnit.start()
        self.mixerMain.start()
        self.lpfSynth.start()
        delayUnitSynth.start()
        AudioKit.output = reverbUnit
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
    
    func waveformSynthChange(waveformSwitch: Int)
    {
        waveformSwitchVal = waveformSwitch
        
    }
    
    func noteOnSynth(freq: Double)
    {
        switch waveformSwitchVal
        {
        case 1:
            if oscillatorTriAK.amplitude == 0
            {
                oscillatorTriAK.rampTime = 0
            }
            self.freq = freq
            oscillatorTriAK.frequency = self.freq
            oscillatorTriAK.rampTime = currentRampTime
            oscillatorTriAK.amplitude = self.currentAmp + 0.2
            oscillatorTriAK.play()
        case 2:
            if oscillatorSawAK.amplitude == 0
            {
                oscillatorSawAK.rampTime = 0
            }
            self.freq = freq
            oscillatorSawAK.frequency = self.freq
            oscillatorSawAK.rampTime = currentRampTime
            oscillatorSawAK.amplitude = currentAmp
            oscillatorSawAK.play()
        case 3:
            if oscillatorSqrAK.amplitude == 0
            {
                oscillatorSqrAK.rampTime = 0
            }
            self.freq = freq
            oscillatorSqrAK.frequency = self.freq
            oscillatorSqrAK.rampTime = currentRampTime
            oscillatorSqrAK.amplitude = currentAmp
            oscillatorSqrAK.play()
        case 4:
            if noiseAK.amplitude == 0
            {
                noiseAK.rampTime = 0
            }
            self.freq = freq
            noiseAK.rampTime = currentRampTime
            noiseAK.amplitude = currentAmp
            noiseAK.play()
        default:
            if oscillatorTriAK.amplitude == 0
            {
                oscillatorTriAK.rampTime = 0
            }
            self.freq = freq
            oscillatorTriAK.frequency = self.freq
            oscillatorTriAK.rampTime = currentRampTime
            oscillatorTriAK.amplitude = self.currentAmp + 0.2
            oscillatorTriAK.play()
        }

    }
    
    func noteOffSynth()
    {
        self.oscillatorTriAK.amplitude = 0
        self.oscillatorSqrAK.amplitude = 0
        self.oscillatorSawAK.amplitude = 0
        self.noiseAK.amplitude = 0
    }
    
    func changeLoopFile(loopFile: Int)
    {
        play2.stop()
        AudioKit.stop()
        let bundle = NSBundle.mainBundle()
        switch loopFile {
        case 1:
            let file1 = bundle.pathForResource("loop1", ofType: "wav")
            play2 = AKAudioPlayer(file1!)
        case 2:
            let file2 = bundle.pathForResource("loop2", ofType: "wav")
            play2 = AKAudioPlayer(file2!)
        case 3:
            let file3 = bundle.pathForResource("loop3", ofType: "wav")
            play2 = AKAudioPlayer(file3!)
        case 4:
            let file4 = bundle.pathForResource("loop4", ofType: "wav")
            play2 = AKAudioPlayer(file4!)
        default:
            let file1 = bundle.pathForResource("loop1", ofType: "wav")
            play2 = AKAudioPlayer(file1!)
        }
        play2.volume = paramaterState["vol"]!
        mixerMain = AKMixer(play2, delayUnitSynth)
        mixerMain.volume = 1.0
        filterPlayer = AKLowPassFilter(mixerMain)
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
        play2.looping = true
        AudioKit.output = reverbUnit
        AudioKit.start()
        self.playSamplerPlayer(playState)
    }
    
    func changeFilterCutoff(cutoff: Double)
    {
        // print("filterCutoff \(cutoff)")
        if cutoff > 0.5
            // High Pass Filter Activated
        {
            paramaterState["freq2"] = ((cutoff - 0.5) * 2) * 4000
            filterPlayer2.cutoffFrequency = paramaterState["freq2"]!
            if paramaterState["freq2"] > 5000
            {
                filterPlayer2.resonance = 5
            }
            else if paramaterState["freq2"] > 500
            {
                filterPlayer2.resonance = 8
            }
            else
            {
                filterPlayer2.resonance = 10
            }
            paramaterState["freq1"] = 20000
            filterPlayer.cutoffFrequency = paramaterState["freq1"]!
            filterPlayer.resonance = 0.0
        }
        else if cutoff < 0.5
            // LowPass Filter Activated
        {
            paramaterState["freq1"] = cutoff * 9000
            filterPlayer.cutoffFrequency = paramaterState["freq1"]!
            if paramaterState["freq1"] > 5000
            {
                filterPlayer.resonance = 5
            }
            else if paramaterState["freq1"] > 500
            {
                filterPlayer.resonance = 8
            }
            else
            {
                filterPlayer.resonance = 10
            }
            paramaterState["freq2"] = 0
            filterPlayer2.cutoffFrequency = paramaterState["freq2"]!
            filterPlayer2.resonance = 0.0
        }
        else
        {
            paramaterState["freq1"] = 20000
            filterPlayer.cutoffFrequency = paramaterState["freq1"]!
            filterPlayer.resonance = 0.0
            paramaterState["freq2"] = 0
            filterPlayer2.cutoffFrequency = paramaterState["freq2"]!
            filterPlayer2.resonance = 0.0
        }

    }
    
    func changeDelayReverb(delayReverb: Double)
    {
        // print("delayReverb \(delayReverb)")
        if delayReverb > 0
            // delay activated reverb off
        {
            paramaterState["delay"] = delayReverb
            paramaterState["reverb"] = 0.0
            if delayReverb > 0.7
            {
                delayUnit.feedback = 0.6
            }
            else if delayReverb > 0.4
            {
                delayUnit.feedback = 0.5
            }
            else
            {
                delayUnit.feedback = 0.3
            }
            delayUnit.dryWetMix = paramaterState["delay"]!
            reverbUnit.dryWetMix = paramaterState["reverb"]!
        }
        else if delayReverb < 0
            // reverb activated delay off
        {
            paramaterState["reverb"] = abs(delayReverb)
            paramaterState["delay"] = 0.0
            reverbUnit.dryWetMix = paramaterState["reverb"]!
            delayUnit.dryWetMix = paramaterState["delay"]!
        }
        else
        {
            paramaterState["reverb"] = 0.0
            paramaterState["delay"] = 0.0
            reverbUnit.dryWetMix = paramaterState["reverb"]!
            delayUnit.dryWetMix = paramaterState["delay"]!
        }
    }
}
