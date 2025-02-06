//
//  LiteratureQuiz.swift
//  play
//
//  Created by Joseph Baraga on 1/21/25.
//

import Foundation

class LiteratureQuiz: BasicGame {
    
    private struct QuizItem {
        let question: String
        let options: [String]
        let answerNumber: Int
        let correctResponse: String
        let incorrectResponse: String
        
        var optionsString: String {
            options.enumerated().map { "\($0.offset + 1))" + $0.element }.joined(separator: ", ")
        }
    }
    
    private let quizItems: [QuizItem] = [
        QuizItem(
            question: "In Pinocchio, what was the name of the cat",
            options: ["Tigger", "Cicero", "Figaro", "Guipetto"],
            answerNumber: 3,
            correctResponse: "Very good!  Here's another.",
            incorrectResponse: "Sorry...Figaro was his name."
        ),
        QuizItem(
            question: "From whose garden did Bugs Bunney steal the carrots?",
            options: ["Mr. Nixon's", "Elmer Fudd's", "Clem Judd's", "Stromboli's"],
            answerNumber: 2,
            correctResponse: "Pretty good!",
            incorrectResponse: "Too bad...it was Elmer Fudd's garden."
        ),
        QuizItem(
            question: "In the Wizard of Oz, Dorothy's dog was named",
            options: [" Cicero", " Trixie", " King", " Toto"],
            answerNumber: 4,
            correctResponse: "Yea!  You're a real literature giant.",
            incorrectResponse: "Back to the books,...Toto was his name."
        ),
        QuizItem(
            question: "Who was the fair maiden who ate the poison apple",
            options: ["Sleeping Beauty", "Cinderella", "Snow White", "Wendy"],
            answerNumber: 3,
            correctResponse: "Good memory!",
            incorrectResponse: "Oh, come on now...it was Snow White."
        )
    ]
    
    func run() {
        printHeader(title: "Literature Quiz")
        println("Test your knowledge of children's literature.")
        println()
        println("This is a multiple-choice quiz.")
        println("Type a 1, 2, 3, 4 after the question mark.")
        println()
        println("Good luck!")
        
        play()
        end()
    }
    
    private func play() {
        var correct = 0  //R
        for item in quizItems {
            println(2)
            println(item.question)
            if Int(input(item.optionsString)) ?? 0 == item.answerNumber {
                println(item.correctResponse)
                correct += 1
            } else {
                println(item.incorrectResponse)
            }
        }
        
        println(2)
        if correct == 4 {
            println("Wow!  That's super!  You really know your nursery")
            println("Your next quiz will be 2nd century Chinese")
            println("literature (ha, ha, ha)")
            unlockEasterEgg(.literatureQuiz)
        } else if correct < 2 {
            println("Ugh.  That was definitely not too swift.  Back to")
            println("nursery school for you, my friend.")
        } else {
            println("Not bad, but you might spend a little more time")
            println("reading the nursery greats.")
        }
    }
}
