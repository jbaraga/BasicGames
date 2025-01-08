//
//  EvenWins2.swift
//  EvenWins2
//
//  Created by Joseph Baraga on 1/9/23.
//

import Foundation


class EvenWins2: GameProtocol {
    
    //Adaptive computer move array
    private var r = dim(2, 6, value: 4)
    private var userWins = 0
    
    func run() {
        printHeader(title: "Game of Even Wins")
        let response = Response(input("Do you want instructions (yes or no)"))
        if response.isYes {
            println()
            println("The game is played as follows:")
            println("At the beginning of the game, a random number of chips are")
            println("placed on the board.  The number of chips always starts")
            println("as an odd number.  On each turn, a player must take one,")
            println("two, three, of four chips.  The winner is the player who")
            println("finishes with a total number of chips that is even.")
            println("The computer starts out knowing only the rules of the")
            println("game.  It gradually learns to play well.  It should be")
            println("difficult to beat the computer after twenty games in a row.")
            println("Try it!!!!")
            println()
            println("To quit at any time, type a '0' as your move.")
            println()
            
            wait(.long)
        }
        
        while true {
            play()
            if userWins == 4 { unlockEasterEgg(.evenWins2) }
        }
    }
    
    private func play() {
        //Line 70
        var a = 0  //Player's chips
        var b = 0 //Computer's chips
        var p = Int((13 * rnd(1) + 9) / 2) * 2 + 1  //Number of chips on board
        
        //e and l are indices to select computer move from array r
        var e = 0
        var l = 0
        //e1 and l1 hold values of e and l from previous iteration
        var e1 = 0
        var l1 = 0
        
        while p > 0 {
            println((p > 1 ? "There are \(p) chips" : "There is 1 chip") + " on the board.")
            
            //Lines 120-230 - computer turn
            //e = 0 or 1 if player holds even or odd number of chip
            //l = 0-5, based on how many fractional multiples of 6 chips are left;
            //e.g. if 2, 8, 14 or 20 chips are left, l = 2
            e1 = e
            l1 = l
            
            e = a % 2  //Line 140
            l = p % 6  //Line 150
            
            if r[e,l] < p {
                //Line 170 - removed extra code where m<=0, should never occur
                let m = r[e,l]
                p -= m
                print("Computer takes \(m) chip\(m > 1 ? "s" : "") leaving \(p) ... Your move")
                b += m
            } else {
                //Line 320 - last move for computer
                println("Computer takes \(p) chip\(p > 1 ? "s" : "").")
                r[e,l] = p
                b += p
                p = 0
            }
            
            //Lines 230-300 - player turn
            if p > 0 {
                var m = -1
                while m < 0 {
                    m = Int(input()) ?? -1
                    switch m {
                    case 0:
                        end()
                    case 1...(p < 4 ? p : 4):
                        break
                    default:
                        print("\(m) is an illegal move ... Your move")
                        m = -1
                    }
                }
                p -= m
                a += m
            }
        }
        
        //Line 370
        if b % 2 == 0 {
            println("Game over ... I win!!!")
            userWins += 1
        } else {
            println("Game over ... you win!!!")
            //Line 390 - learning code, modifies computer move array
            //If computer loses, decrement losing move by 1; if this move was 1 chip, decrement previous move by 1 chip, r values should always be greater than zer0
            if r[e,l] != 1 {
                r[e,l] -= 1  //Line 400
            } else {
                //Line 480
                if r[e1,l1] != 1 {
                    r[e1,l1] -= 1
                }
            }
        }
        println()
    }
}
