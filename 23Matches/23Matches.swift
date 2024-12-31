//
//  23Matches.swift
//  23Matches
//
//  Created by Joseph Baraga on 12/30/24.
//

import Foundation

class TwentyThreeMatches: GameProtocol {
    
    private enum Player {
        case user
        case computer
        
        init() {
            self = Int.random(in: 1...2) == 1 ? .computer : .user
        }
    }
    
    func run() {
        printHeader(title: "23 Matches")
        println(3)
        println(" This is a game called '23 matches'.")
        println()
        println("When it is your turn, you may take one, two, or three")
        println("matches. The object of the game is not to have to take")
        println("the last match.")
        println()
        println("Let's flip a coin to see who goes first.")
        println("If it comes up heads, I will win the toss.")
        println()
        //160 REM
        wait(.short)
        play()
    }
    
    private func play() {
        var player = Player()
        if player == .user {
            println("Tails ! You go first.")
        } else {
            println("Heads! I win! Ha! Ha!")
            println("Prepare to lose, meatball-nose !!")
            println()
        }
        
        var n = 23
        var k = 0  //user choice
        while n > 1 {
            switch player {
            case .user:
                print("How many do you wish to remove", tab(42))
                k = getUserChoice()
                n -= k
                println("There are now \(n) matches remaining")
                player = .computer
                
            case .computer:
                //250-260
                if n == 23 {
                    println(" I take 2 matches")
                    n -= 2
                } else {
                    //351-400
                    let z = n == 23 ? 2 : (n < 5 ? n - 1 : 4 - k)
                    println("My turn ! I remove \(z) matches")
                    n -= z
                }

                if n > 1 {
                    println("The number of matches is now \(n)")
                    println()
                    println("Your turn -- you may take 1,2,or 3 matches.")
                }
                player = .user
            }
        }
        
        //Fallthrough,  with 1 left next player is loser; does not account for deliberately loosing by taking last 2 or 3
        if player == .computer {
            //530-550
            println("You won, floppy ears !")
            println("Think you're pretty smart !")
            println("Let's play again and I'll blow your shoes off !!")
            unlockEasterEgg(.twentyThreeMatches)
        } else {
            //470-510
            println()
            println("You poor boob ! You took the last match ! I gotcha !")
            println("Ha ! Ha ! I beat you !!!")
            println()
            println("Good bye loser!")
        }
        
        wait(.short)
        end()
    }

    
    private func getUserChoice() -> Int {
        guard let number = Int(input()), number > 0 && number < 4 else {
            //430-460
            println("Very Funny ! Dummy!")
            println("Do you want to play or goof around ?")
            print("Now how many matches do you want", tab(42))
            return getUserChoice()
        }
        return number
    }
}
