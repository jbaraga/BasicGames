//
//  EvenWins1.swift
//  EvenWins1
//
//  Created by Joseph Baraga on 1/8/23.
//

import Foundation

class EvenWins1: GameProtocol {
    
    func run() {
        printHeader(title: "Even Wins")
        println("     This is a two person game called 'Even Wins.'")
        println("To play the game, the players need 27 marbles or")
        println("other objects on a table.")
        println(2)
        println("     The 2 players alternate turns, with each player")
        println("removing from 1 to 4 marbles on each move.  The game")
        println("ends when there are no marbles left, and the winner")
        println("is the one with an even number of marbles.")
        println(2)
        println("     The only rules are that (1) you must alternate turns,")
        println("(2) you must take between 1 and 4 marbles each turn,")
        println("and (3) you cannot skip a turn.")
        println(3)
        
        wait(.long)
        
        repeat {
            play()
            println("  Do you want to play")
            println("again?  Type 1 for yes and 0 for no.")
        } while Int(input()) == 1
        
        println()
        println("Ok.  See you later.")
        end()
    }
    
    private func play() {
        //Lines 200-260
        println("     Type a 1 if you want to go first, and type")
        println("a 0 if you want me to go first.")
        var c = Int(input()) ?? 0  //Turn tracker - c=0 for computer, c=1 for player
        
        var t = 27  //Line 250 - remaining marbles
        var m1 = 0  //Computer marbles
        var y1 = 0  //Player marbles
        
        while t > 0 {
            if c == 0 {
                //Computer turn
                let m: Int  //Computer pick
                if t == 27 {
                    //Line 270
                    println("Total= \(t)")
                    //First turn, computer picks 2
                    m = 2
                } else {
                    //Computer picking logic
                    //Lines 500-600
                    let r = t - 6 * Int(t / 6)
                    if y1 % 2 == 0 {
                        //700 REM     I AM READY TO ENCODE THE STRAT FOR WHEN OPP TOT IS EVEN
                        m = (r < 2 || r > 5) ? 1 : r - 1
                    } else {
                        //Line 520
                        if t < 5 {
                            m = t
                            //830 REM    250 IS WHERE I WIN
                        } else {
                            if r < 4 {
                                //Line 540
                                m = r + 1
                            } else {
                                //Line 620
                                m = r == 4 ? 4 : 1
                            }
                        }
                    }
                }
                m1 += m
                t -= m
                c = 1
                
                println("I pick up \(m) marbles.")
                if t == 0 {
                    println()
                    //Line 860 - only executes if computer has won on last pick
                    if m1 % 2 == 0 {
                        println("Total = 0")
                    }
                }
            } else {
                //Player turn
                if t == 27 {
                    //Lines 1070-1130
                    println(3)
                    println("Total = \(t)")
                    println(2)
                    println("     What is your first move?")
                } else {
                    //Lines 320-340
                    println("Total= \(t)")
                    println()
                    println("     And what is your next move, my total is \(m1)")
                }
                
                var y = 0
                while y == 0 {
                    y = Int(input()) ?? 0
                    println()
                    switch y {
                    case 1...4:
                        if y > t {
                            //Line 400
                            println("     You have tried to take more marbles than there are")
                            println("left.  Try again.")
                            y = 0
                        } else {
                            //Lines 430-480 - valid choice
                            y1 += y
                            t -= y
                            if t > 0 {
                                println("Total= \(t)")
                                println()
                                println("     Your total is \(y1)")
                            }
                        }
                    default:
                        //Lines 1160-1210
                        println("The number of marbles you take must be a positive")
                        println("integer between 1 and 4.")
                        println()
                        println("     What is your next move?")
                        println()
                        y = 0
                    }
                }
                c = 0
            }
        }
        
        //Lines 880-1050
        //End of game
        println("That is all of the marbles.")
        println()
        println(" My total is \(m1)   your total is \(y1)")
        println()
        
        let userWon = y1 % 2 == 0
        print("     \(userWon ? "You" : "I") won.")
        if userWon { unlockEasterEgg(.evenWins1) }
    }
}
    
