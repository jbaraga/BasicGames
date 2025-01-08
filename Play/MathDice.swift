//
//  MathDice.swift
//  MathDice
//
//  Created by Joseph Baraga on 12/27/24.
//

import Foundation

class MathDice: GameProtocol {
    
    private struct Die {
        let value: Int
        
        var rows: [String] {
            var lines = [" ----- "]
            switch value {
            case 1:     lines.append("I     I")
            case 2,3:   lines.append("I *   I")
            case 4,5,6: lines.append("I * * I")
            default: fatalError("Invalid dice number \(value)")
            }
            switch value {
            case 1,3,5: lines.append("I  *  I")
            case 2,4:   lines.append("I     I")
            case 6:     lines.append("I * * I")
            default: fatalError("Invalid dice number \(value)")
            }
            switch value {
            case 1:     lines.append("I     I")
            case 2,3:   lines.append("I   * I")
            case 4,5,6: lines.append("I * * I")
            default: fatalError("Invalid dice number \(value)")
            }
            lines.append(" ----- ")
            return lines
        }
        
        init() {
            value = Int.random(in: 1...6)
        }
    }
    
    func run() {
        printHeader(title: "Math Dice")
        println("This program generates successive pictures of two dice.")
        println("When two dice and an equal sign followed by a question")
        println("mark have been printed, type your answer and the return key.")
        println("To conclude the lesson, type control-c as your answer.")
        println(2)
        wait(.short)
        play()
    }
    
    //100-620
    private func play() {
        var score = 0
        
        while true {
            let d = Die()
            let a = Die()
            let total = d.value + a.value
            
            for row in d.rows { println(row) }
            println()
            println("   +")
            println()
            for row in a.rows { println(row) }
            println()
            
            let isCorrect = getAnswer(total: total)
            println(isCorrect ? "Right!" : "No, the answer is \(total)")
            if isCorrect { score += 1 }
            println()
            
            if score > 9 { unlockEasterEgg(.mathDice) }
            
            println("The dice roll again...")
            println()
        }
    }
    
    private func getAnswer(total: Int, isFirstAnswer: Bool = true) -> Bool {
        let t1 = input("     =") ?? 0
        if isFirstAnswer {
            if t1 == total { return true }
            println("No, count the spots and give another answer.")
            return getAnswer(total: total, isFirstAnswer: false)
        } else {
            return t1 == total
        }
    }
}
