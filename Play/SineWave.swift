//
//  SineWave.swift
//  SineWave
//
//  Created by Joseph Baraga on 12/28/24.
//

import Foundation

class SineWave: BasicGame {
    
    func run() {
        printHeader(title: "Sine Wave", newlines: 5)
        //40 REMARKABLE PROGRAM BY DAVID AHL
        wait(.short)
        play()
    }
    
    private func play() {
        var b = 0
        //100 REM  START LONG LOOP
        for t in stride(from: 0, to: 40, by: 0.25) {
            let a = Int(26 + 25 * sin(t))
            println(tab(a), b == 0 ? "Creative" : "Computing")
            b = b == 0 ? 1 : 0
        }
        
        println(5)
        unlockEasterEgg(.sineWave)
        end()
    }
}
