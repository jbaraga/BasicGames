//
//  Batnum.swift
//  Batnum
//
//  Created by Joseph Baraga on 1/9/24.
//

import Foundation


class Batnum: GameProtocol {
    
    private var n = 0  //Pile size
    private var winOption = WinOption.undefined  //M win option: 1 take last, 2 avoid last
    private var min = 0  //A
    private var max = 0  //B
    
    func run() {
        printHeader(title: "Batnum")
        println("This program is a 'Battle of Numbers'")
        println("game, where the computer is your opponent")
        println()
        println("The game starts with an assumed pile of objects.")
        println("You and your opponent alternately remove objects from")
        println("the pile.  Winning is defined in advance as taking the")
        println("last object or not.  You can also specify some other")
        println("beginning conditions.  Don't use zero, however, in")
        println("playing the game.")
        println()

        wait(.short)
        
        while true {
            n = 0
            min = 0
            max = 0
            winOption = .undefined
            play()
        }
    }
    
    //Lines 330-
    private func play() {
        while n == 0 {
            n = Int(input("Enter pile size")) ?? 0
            if n < 0 {
                n = 0
            }
        }
        
        while winOption == .undefined {
            if let option = WinOption(rawValue: Int(input("Enter win option - 1 to take last, 2 to avoid last: ")) ?? 0) {
                winOption = option
            }
        }
        
        while min < 1 || min > max {
            (min, max) = input("Enter min and max ") ?? (0, 0)
        }
        
        var startOption = 0  //S start option - 1 computer first, 2 user first
        while !(startOption == 1 || startOption == 2) {
            startOption = input("Enter start option - 1 computer first, 2 you first ") ?? 0
        }
        
        while n > 0 {
            if startOption == 1 {
                computerMove()
                if n > 0 { userMove() }
            } else {
                userMove()
                if n > 0 { computerMove() }
            }
        }
        
        wait(.short)
        
        //220-240
        println(10)
    }
        
    //Lines 600-800
    private func computerMove() {
        if winOption == .takeLast {
            if n <= max {
                println("Computer takes \(n) and wins.")
                n = 0
                return
            }
        } else {
            if n <= min {
                println("Computer takes \(n) and loses.")
                n = 0
                unlockEasterEgg(.batnum)
                return
            }
        }
        
        let q = winOption == .takeLast ? n : n - 1
        let c = min + max
        var p = q - c * Int(Double(q) / Double(c))  //Line 720
        if p < min { p = min }
        if p > max { p = max }
        n -= p
        println("Computer takes \(p) and leaves \(n)")
    }
    
    //Lines 810-990
    private func userMove() {
        var p = Int(input("Your move ")) ?? -1
        while p < min || p > max || p > n {  //Modification to disallow removing more pieces than left
            if p == 0 {
                println("I told you not to use zero! Computer wins by forfeit.")
                n = 0
                return
            }
            p = Int(input("Illegal move, reenter it ")) ?? -1
        }
        
        n -= p
        if n == 0 {
            if winOption == .takeLast {
                println("Congratulations, you win.")
                unlockEasterEgg(.batnum)
            } else {
                println("Tough luck, you lose.")
            }
        }
    }
    
    private enum WinOption: Int {
        case undefined
        case takeLast
        case avoidLast
    }
}
