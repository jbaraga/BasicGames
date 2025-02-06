//
//  Word.swift
//  play
//
//  Created by Joseph Baraga on 12/31/24.
//

import Foundation

class Word: BasicGame {
    
    private let words = ["dinky", "smoke", "water", "grass", "train", "might", "first", "candy", "champ", "would", "clump", "dopey"]
    
    func run() {
        printHeader(title: "Word")
        println("I am thinking of a word -- you guess it.  I will give you")
        println("clues to help you get it.  Good luck!!")
        println(2)
        wait(.short)
        
        repeat {
            play()
        } while Response(input("Want to play again")).isYes
        
        end()
    }
    
    private func play() {
        //20 REM
        repeat {
            println(2)
            println("You are starting a new game...")
        } while guess()
        
        end()
    }
    
    //Returns true for play again - for giving up, or for yes response to try again after correct guess
    private func guess() -> Bool {
        let word = words.randomElement()!.uppercased()  //S$
        var exactMatches = "-----"
        var guess = ""
        var count = 0
        repeat {
            count += 1
            repeat {
                guess = input("Guess a five letter word").uppercased()
                if guess == "?" {
                    println("The secret word is " + word)
                    println()
                    return true
                }
                
                if guess.count != 5 {
                    println("You must guess a five letter word.  Start again.")
                    println()
                }
            } while guess.count != 5
            
            let matches = word.reduce(into: "") { matches, char in matches.append(guess.filter { $0 == char }) }
            let newExactMatches = String(zip(word, guess).map { $0 == $1 ? $0 : "-" })
            exactMatches = String(zip(exactMatches, newExactMatches).map { $0 == "-" ? ($1 == "-" ? "-" : $1 ) : $0 })
            
            println("There were \(matches.count) matches and the common letters were..." + matches)
            println("From the exact letter matches, you know" + String(repeating: ".", count: 16) + exactMatches)
            if matches.count < 2 {
                println()
                println("If you give up, type '?' for you next guess.")
            }
            println()
        } while guess != word
        
        println("You have guessed the word.  It took \(count) guesses!")
        println()
        defer { if count < 5 { unlockEasterEgg(.word) } }
        return Response(input("Want to play again")).isYes
    }
}
