//
//  War.swift
//  play
//
//  Created by Joseph Baraga on 1/1/25.
//

import Foundation

class War: BasicGame {
    
    private struct Card: CustomStringConvertible {
        let suit: Suit
        let faceValue: FaceValue
        
        var description: String { "\(suit)-\(faceValue)" }
        var value: Int { faceValue.value }
    }
    
    private enum Suit: String, CaseIterable, CustomStringConvertible {
        case s, h, c, d
        
        var description: String { rawValue.uppercased() }
    }
    
    private enum FaceValue: Int, CaseIterable, CustomStringConvertible {
        case two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace
        
        var value: Int { rawValue + 2 }
        
        var description: String {
            switch self {
            case .jack: return "J"
            case .queen: return "Q"
            case .king: return "K"
            case .ace: return "A"
            default: return "\(value)"
            }
        }
    }
    
    func run() {
        printHeader(title: "War")
        println("This is the card game of war.  Each card is given by suit-#")
        print("as S-7 for Spade 7.  ")
        promptForDirections()
        println()
        play()
    }
    
    private func promptForDirections() {
        let response = Response(input("Do you want directions"))
        switch response {
        case .yes:
            println("The computer gives you and it a 'card'.  The higher card")
            println("(numerically) wins.  T?he game ends when you choose no to")
            println("continue or you have finished the pack.")
            wait(.short)
        case .no:
            return
        case .other:
            print("Yes or no, please.  ")
            promptForDirections()
        }
    }
    
    private func play() {
        //239-260, 660-720
        var deck = Suit.allCases.reduce(into: [Card]()) { deck, suit in
            deck += FaceValue.allCases.map { Card(suit: suit, faceValue: $0) }
        }
        //280-350
        deck.shuffle()
        
        var computerScore = 0  //A1
        var userScore = 0  //B1

        repeat {
            let userCard = deck.removeFirst()
            let computerCard = deck.removeFirst()
            println()
            println("You: \(userCard)", "Computer: \(computerCard)")
            if userCard.value < computerCard.value {
                computerScore += 1
                println("Computer wins!!! You have \(userScore)  Computer has \(computerScore)")
            } else if userCard.value > computerCard.value {
                userScore += 1
                println("You win.  You have \(userScore)  Computer has \(computerScore)")
            } else {
                println("Tie.  No score change.")
            }
            
            if deck.count > 1 {
                if !isUserContinuing() {
                    println("Thanks for playing.  It was fun.")
                    end()
                }
            }
        } while deck.count > 1
        
        //610-650
        println(2)
        println("You have run out of cards.  Final score:  You-- \(userScore);  Computer-- \(computerScore)")
        println("Thanks for playing.  It was fun.")
        if userScore > computerScore { unlockEasterEgg(.war) }
        end()
    }
    
    private func isUserContinuing() -> Bool {
        let response = Response(input("Do you want to continue"))
        switch response {
        case .yes, .no: return response.isYes
        case .other:
            print("Yes or no, please.  ")
            return isUserContinuing()
        }
    }
}
