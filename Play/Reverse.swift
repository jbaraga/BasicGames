//
//  Reverse.swift
//  play
//
//  Created by Joseph Baraga on 1/11/25.
//

import Foundation

class Reverse: BasicGame {
    
    //140 REM *** N=NUMBER OF NUMBER
    private let n = 9
    
    func run() {
        printHeader(title: "Reverse")
        println("Reverse -- A Game Of Skill")
        println()
        
        if Response(input("Do you want the rules")) == .yes { printRules() }
        
        repeat {
            play()
            println()
        } while Response(input("Try again (yes or no)")) == .yes
                    
        println()
        println("O.K.  Hope you had fun!!")
        end()
    }
    
    //REM *** SUBROUTINE TO PRINT THE RULES
    private func printRules() {
        println()
        println("This is the game of 'Reverse'.  To win, all you have")
        println("to do is arrange a list of numbers (1 through \(n))")
        println("in numerical order from left to right. To move, you")
        println("tell me how many numbers (counting from the left) to")
        println("reverse.  For example, if the current list is:")
        println()
        println("2 3 4 5 1 6 7 8 9")
        println()
        println("and you reverse 4, the result will be:")
        println()
        println("5 4 3 2 1 6 7 8 9")
        println()
        println("Now if you reverse 5, you win!")
        println()
        println("1 2 3 4 5 6 7 8 9")
        println()
        println("No doubt you will like this game, but")
        println("if you want to quit, reverse 0 (zero).")
        println()
    }
    
    private func play() {
        //200 REM *** MAKE A RANDOM LIST OF A(1) TO A(N)
        let sortedList = [Int](1...9)
        var list = sortedList.shuffled()
        
        //280 REM *** PRINT ORIGINAL LIST AND START GAME
        println()
        println("Here we go ... the list is:")
        print(list: list)
        
        var turn = 0
        repeat {
            let r = Int(input("How many shall I reverse")) ?? -1
            if r == 0 { return }
            if r < 0 || r > n {
                println("Oops!  Too many!  I can reverse at most \(n)")
            } else {
                turn += 1
                //400 REM *** REVERSE R NUMBERS AND PRINT NEW LIST
                list = list[0..<r].reversed() + list[r...]
                print(list: list)
            }
        } while list != sortedList  //470 REM *** CHECK FOR A WIN
        
        println("You won it in \(turn) moves!!!")
        println()
        if turn < 15 { unlockEasterEgg(.reverse) }
    }
    
    //600 REM *** SUBROUTINE TO PRINT LIST
    private func print(list: [Int]) {
        println()
        println(" " + (list.map { "\($0)" }).joined(separator: " "))
        println()
    }
}
