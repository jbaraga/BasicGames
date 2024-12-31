//
//  RockScissorsPaper.swift
//  RockScissorsPaper
//
//  Created by Joseph Baraga on 12/28/24.
//

import Foundation

class RockScissorsPaper: GameProtocol {
    
    private enum Object: Int, CaseIterable, Comparable, CustomStringConvertible {
        case paper = 1
        case scissors = 2
        case rock = 3
        
        var description: String {
            switch self {
            case .paper: return "Paper"
            case .scissors: return "Scissors"
            case .rock: return "Rock"
            }
        }
        
        static func < (lhs: RockScissorsPaper.Object, rhs: RockScissorsPaper.Object) -> Bool {
            switch (lhs, rhs) {
            case (.paper, .scissors), (.scissors, .rock), (.rock, .paper): return true
            default: return false
            }
        }
    }
    
    func run() {
        printHeader(title: "Game of Rock, Scissors, Paper")
        println(3)
        play()
    }
    
    private func play() {
        let gameCount = getGame()  //q
        if gameCount < 1 { end() }
        
        var userWins = 0  //H
        var computerWins = 0  //C
        for gameNumber in 1...gameCount {
            println()
            println("Game number \(gameNumber)")
            let computerObject = Object.allCases.randomElement() ?? .rock
            let userObject = getChoice()
            println("This is my choice...")
            wait(.short)
            println("...\(computerObject)")
            if computerObject < userObject {
                println("You win!!!")
                userWins += 1
            } else if userObject < computerObject {
                println("Wow!  I win!!!")
                computerWins += 1
            } else {
                println("Tie game.  No winner.")
            }
        }
        
        println()
        println("Here is the final game score:")
        println("I have won \(computerWins) game(s).")
        println("You have won \(userWins) game(s).")
        println("And \(gameCount - (computerWins - userWins)) game(s) ended in a tie.")
        println()
        println("Thanks for playing!!")
        
        wait(.short)
        if userWins > computerWins { unlockEasterEgg(.rockScissorsPaper) }
        end()
    }

    private func getGame() -> Int {
        guard let q = Int(input("How many games")), q < 11 else {
            println("Sorry, but we aren't allowed to play that many.")
            return getGame()
        }
        return q
    }
    
    private func getChoice() -> Object {
        println("3=Rock...2=Scissors...1=Paper")
        guard let value = Int(input("1...2...3...What's your choice")), let object = Object(rawValue: value) else {
            println("Invalid.")
            return getChoice()
        }
        return object
    }
}
