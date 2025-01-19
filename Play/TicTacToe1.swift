//
//  TicTacToe1.swift
//  play
//
//  Created by Joseph Baraga on 1/13/25.
//

import Foundation

class TicTacToe1: GameProtocol {
    
    func run() {
        printHeader(title: "Tic Tac Toe")
        
        //100 REM   THIS PROGRAM PLAYS TIC TAC TOE
        //110 REM   THE MACHINE GOES FIRST
        
        println("The game board is numbered:")
        println()
        println("1  2  3")
        println("8  9  4")
        println("7  6  5")
        println()
        
        while true { play() }
    }
    
    private func play() {
        //200 REM  MAIN PROGRAM
        println(2)
        
        //Deterministic algorithm, can only end in computer win or draw
        let a = 9
        let p = userMove(afterComputerMove: a)
        let b = fnm(p + 1)
        let q = userMove(afterComputerMove: b)
        if q == fnm(b + 4) {
            //360
            let c = fnm(b + 2)
            let r = userMove(afterComputerMove: c)
            if r == fnm(c + 4) {
                //450
                if p % 2 > 0 {
                    //500
                    let d = fnm(c + 3)
                    let s = userMove(afterComputerMove: d)
                    let e = s == fnm(d + 4) ? fnm(d + 4) : fnm(d + 6)
                    println("Computer moves \(e)")
                    println("The game is a draw")
                    //580 REM  Bug in original code fallthrough from 560 to 590
                    unlockEasterEgg(.ticTacToe1)
                } else {
                    //460
                    let d = fnm(c + 7)
                    win(afterComputerMove: d)
                }
            } else {
                //410
                let d = fnm(c + 4)
                win(afterComputerMove: d)
            }
        } else {
            //320
            let c = fnm(b + 4)
            win(afterComputerMove: c)
        }
    }
    
    //650-710
    private func userMove(afterComputerMove m: Int) -> Int {
        println("Computer moves \(m)")
        return userMove()
    }
    
    private func win(afterComputerMove m: Int) {
        println("Computer moves \(m)")
        println("and wins ********")
    }
    
    private func userMove() -> Int {
        guard let m = Int(input("Your move")), m > 0, m < 10 else {
            return userMove()
        }
        return m
    }
    
    //returns 1...8 for 1...8 and 9...16
    private func fnm(_ x: Int) -> Int { x - 8 * Int(Double(x - 1) / 8) }
}
