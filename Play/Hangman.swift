//
//  Hangman.swift
//  Hangman
//
//  Created by Joseph Baraga on 12/26/24.
//

import Foundation

class Hangman: GameProtocol {
    
    private var words = ["Gum", "Sin", "For", "Cry", "Lug", "Bye", "Fly", "Ugly", "Each", "From", "Work", "Talk", "With", "Self", "Pizza", "Thing", "Feign", "Fiend", "Elbow", "Fault", "Dirty", "Budget", "Spirit", "Quaint", "Maiden", "Escort", "Pickax", "Example", "Tension", "Quinine", "Kidney", "Replica", "Sleeper", "Triangle", "Kangaroo", "Mahogany", "Sergeant", "Sequence", "Moustache", "Dangerous", "Scientist", "Different", "Quiescent", "Magistrate", "Erroneously", "Loudspeaker", "Phytotoxic", "Matrimonial", "Parasympathomimetic", "Thigmotropism"]
    
    enum BodyPart: CaseIterable {
        case head, body, rightArm, leftArm, rightLeg, leftLeg, leftHand, rightHand, leftFoot, rightFoot
    }
    
    struct StickFigure {
        private var p$ = dim(12, 12, value: " ")
        
        init() {
            for i in 0...11 { p$[i,1] = "X" }
            for i in 1...6 { p$[0,i] = "X" }
            p$[1,6] = "X"
        }
        
        var rows: [String] {
            return p$.reduce(into: [String]()) { $0.append($1.joined()) }
        }
        
        mutating func add(_ part: BodyPart) -> String {
            switch part {
            case .head:
                for i in 5...7 {
                    p$[2,i] = "-"
                    p$[4,i] = "-"
                }
                p$[3,4] = "("
                p$[3,5] = "."
                p$[3,7] = "."
                p$[3,8] = ")"
                return "First, we draw a head"
            case .body:
                for i in 5...8 { p$[i,6] = "X" }
                return "Now we draw a body."
            case .rightArm:
                for i in 3...6 { p$[i,i-1] = "\\" }
                return "Next we draw an arm."
            case .leftArm:
                for i in 3...6 { p$[i,13-i] = "/" }
                return "This time it's the other arm."
            case .rightLeg:
                for i in 9...10 { p$[i,14-i] = "/" }
                return "Now, let's draw the right leg."
            case .leftLeg:
                for i in 9...10 { p$[i,i-2] = "\\" }
                return "This time we draw the left leg."
            case .leftHand:
                p$[2,10] = "\\"
                return "Now we put up a hand."
            case .rightHand:
                p$[2,2] = "/"
                return "Next the other hand."
            case .leftFoot:
                p$[11,9] = "\\"
                p$[11,10] = "-"
                return "Now we draw one foot"
            case .rightFoot:
                p$[11,2] = "-"
                p$[11,3] = "/"
                return "Here's the other foot -- you're hung!!"
            }
        }
    }
    
    func run() {
        printHeader(title: "Hangman")
        wait(.short)
        play()
    }
    
    private func play() {
        var response = Response.yes
        while response.isYes, let word = words.randomElement()?.uppercased() {
            words.removeAll(where: { $0.uppercased() == word })
            
            var figure = StickFigure()
            var missingParts = BodyPart.allCases
            var lettersUsed = [String]()
            var guessedLetters: String { word.reduce("") { $0 + (lettersUsed.contains(String($1)) ? String($1) : "-") }}
            
            //170-590
            while missingParts.count > 0 {
                println("Here are the letters you used:")
                println(lettersUsed.joined(separator: ","))
                println()
                println(guessedLetters)
                println()
                let guess = input("What is your guess").uppercased()
                if lettersUsed.contains(guess) {
                    println("You guessed that letter before!")
                } else {
                    lettersUsed.append(guess)
                    if guess.count == 1, word.contains(guess) {
                        //300-320 minor variation to print word if all letters guessed
                        println()
                        println(guessedLetters)
                        println()
                        
                        if (word.filter { !lettersUsed.contains(String($0)) }).isEmpty {
                            println("You found the word!")
                            print("Want another word")
                            missingParts = []
                        } else {
                            if input("What is your guess for the word").uppercased() == word {
                                println("Right!!  It took you \(lettersUsed.count) guesses!")
                                print("Want another word")
                                missingParts = []
                                unlockEasterEgg(.hangman)
                            } else {
                                println("Wrong.  Try another letter.")
                                println()
                            }
                        }
                    } else {
                        println(2)
                        println("Sorry, that letter isn't in the word.")
                        println(figure.add(missingParts.removeFirst()))
                        for row in figure.rows { println(row) }
                        println(2)
                        if missingParts.count == 0 {
                            println("Sorry, you lose.  The word was " + word)
                            print("You missed that one.  Do you want another word")
                        }
                    }
                }
            }
            
            response = Response(input())
        }
        
        if words.count == 0 {
            println("You did all the words!!")
        } else {
            println()
            println("It's been fun!  Bye for now.")
        }
        
        end()
    }
}

