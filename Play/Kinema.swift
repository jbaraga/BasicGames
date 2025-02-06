//
//  Kinema.swift
//  play
//
//  Created by Joseph Baraga on 1/19/25.
//

import Foundation

class Kinema: BasicGame {
    
    func run() {
        printHeader(title: "Kinema")
        
        while true {
            play()
        }
    }
    
    private var testData: [(v: Int, t: Double)] = [(35, 4.5), (25, 3.2)]
    
    private func play() {
        println(2)
        var correct = 0  //Q
        let velocity = 5 + Int(35 * rnd())
        println("A ball is thrown upwards at \(velocity) meters per second.")
        println()
        
        if getAnswer("How high will it go (in meters)", correctAnswer: 0.05 * Double(velocity * velocity)) { correct += 1 }
        if getAnswer("How long until it returns (in seconds)", correctAnswer: Double(velocity) / 5) { correct += 1}
        let time = 1 + floor(2 * Double(velocity) * rnd()) / 10
        if getAnswer("What will its velocity be after \(time.formatted(.basic)) seconds", correctAnswer: Double (velocity) - 10 * time) { correct += 1 }
        
        println()
        print("\(correct) right out of 3.")
        if correct > 1 {
            print(" Not bad.")
            unlockEasterEgg(.kinema)
        }
    }
    
    private func getAnswer(_ question: String, correctAnswer: Double) -> Bool {
        guard let answer = Double(input(question)) else { return getAnswer(question, correctAnswer: correctAnswer) }
        let isCorrect = abs((answer - correctAnswer) / correctAnswer) < 0.15
        println(isCorrect ? "Close enough." : "Not even close....")
        println("Correct answer is  \(correctAnswer.formatted(.basic))")
        println()
        return isCorrect
    }
}

