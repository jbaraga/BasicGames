//
//  Awari.swift
//  Awari
//
//  Created by Joseph Baraga on 12/10/24.
//

import Foundation


class Awari: BasicGame {
    
    private var b = [Int]()  //board, number of stones in pits - index 0-5 user side, 6 user home, 7-12 computer side, 13 computer home
    
    //For learning mechanism
    private var f = [Int]()  //tracks moves in game
    var c = 0  //move counter
    var n = 0  //index of previous games without computer win
    
    enum Player {
        case user
        case computer
        
        //Index of home for player
        var home: Int {
            return self == .user ? 6 : 13
        }
    }
    
    //e: e==0 true, e==1 false
    private var isEnd: Bool {
        if b[0...5].reduce(true, { $0 && ($1 == 0) }) { return true }
        return b[7...12].reduce(true, { $0 && ($1 == 0) })
    }
    
    func run() {
        printHeader(title: "Awari", newlines: 0)
        wait(.short)
        
        while true {
            play()
        }
    }
    
    //20-95
    private func play() {
        println(2)
        b = Array(repeating: 3, count: 14)
        b[6] = 0
        b[13] = 0
        f.append(0)
        
        while !isEnd {
            printBoard()
            
            print("Your move")
            let (_, userResult) = move(player: .user)
            printBoard()
            if isEnd { gameOver() }
            if userResult == Player.user.home {
                print("Again")
                let _ = move(player: .user)
                printBoard()
            }
            if isEnd {
                gameOver()
                return
            }
            
            let (move1, result1) = move(player: .computer)
            print("My move is \(move1 + 1)")
            if isEnd {
                gameOver()
                return
            }
            
            if result1 == Player.computer.home {
                let (move2, _) = move(player: .computer)
                print(",\(move2 + 1)")
            }
        }
        
        gameOver()
    }
    
    //80-85
    private func gameOver() {
        println()
        println("Game Over")
        let d = b[6] - b[13]
        if d < 0 {
            println("I win by \(-d) points")
        } else {
            n += 1
            if d == 0 {
                println("Drawn game")
            } else {
                println("You win by \(d) points")
                if d > 2 { unlockEasterEgg(.awari) }
            }
        }
        
        wait(.short)
    }
    
    //100-230, 800-890
    private func move(player: Player) -> (move: Int, result: Int) {
        var m = getMove(player: player)
        let result = move(player, pitIndex: m)
        
        //205-210 learning mechanism for computer moves (m in 7...12, transformed to 0...5); n is index of game, advanced if computer does not win game; first game index 0
        if m > 6 { m -= 7 }
        c += 1
        if c < 9 { f[n] *= 6 + m }  //Only first eight moves utilized in learning
        return (m, result)
    }
    
    private func getMove(player: Player) -> Int {
        switch player {
        case .user: return getUserMove()
        case .computer: return getComputerMove()
        }
    }
    
    //100-130
    private func getUserMove() -> Int {
        guard let m = Int(input()), m < 7, m > 0, b[m-1] > 0 else {
            println("Illegal move")
            print("Again")
            return getUserMove()
        }
        return m - 1
    }
    
    //800-890
    private func getComputerMove() -> Int {
        let g = b  //board copy for restoration each trial move; move function mutates board
        var q = 0  //rating to evaluate trial move
        var d = -99  //rating of previous trial move
        var a = 0  //final selected computer move
        
        //810-885 Trial moves to determine computer move
        //Iterate over possible computer pit choices
        for j in 7...12 {
            if b[j] > 0 {
                move(.computer, pitIndex: j)  //Trial move
                
                //820-845 Iterate over user pits to "score" result
                for i in 0...5 {
                    if b[i] > 0 {
                        var l = b[i] + i
                        var r = 0
                        if l > 13 {
                            l -= 14
                            r = 1
                        }
                        if b[l] == 0, l != Player.user.home, l != Player.computer.home {
                            r += b[12-l]
                        }
                        if r > q { q = r }
                    }
                }
                
                //850
                q = b[13] - b[6] - q  //game score difference minus prev rating
                
                //Computer learning adjustment of q rating from prior game losses moves, only utilized for first 8 moves
                //TODO: Understand how algorithm works, and confirm it does as intended
                if c < 9 {
                    //855 no need to test k at j > 6 as specified in j loop
                    let k = j - 7
                    if n > 0 {
                        //Iterates over previous games without computer win, probably to lower chance of choice of pit which was selected in prior game; untested as game example only single game
                        for i in 0...(n - 1) {
                            if f[n] * 6 + k == Int(Double(f[i]) / pow(6, Double(7 - c)) + 0.1) { q -= 2 }
                        }
                    }
                }
                
                //875-880
                b = g  //restore board after trial
                if q >= d {
                    //If trial scores better than prior best
                    a = j
                    d = q
                }
            }
        }
        return a
    }

    //500-585
    private func printBoard() {
        println()
        print(tab(3))
        for i in stride(from: 12, through: 7, by: -1) {
            print(String(format: "%4d", b[i]))
        }
        println()
        println(String(format: "%4d", b[13]) + String(repeatElement(" ", count: 22)) + String(format: b[6] > 9 ? "%5d" : "%4d", b[6]))
        print(tab(3))
        for i in 0...5 {
            print(String(format: "%4d", b[i]))
        }
        println(2)
    }
    
    //600-625
    @discardableResult
    private func move(_ player: Player, pitIndex move: Int) -> Int {
        var m = move
        let p = b[m]
        b[m] = 0
        //Step counterclockwise around board
        for _ in stride(from: p, through: 1, by: -1) {
            m += 1
            if m > 13 { m -= 14 }
            b[m] += 1
        }
        if b[m] == 1, m != 6, m != 13, b[12-m] != 0 {
            b[player.home] += b[12-m] + 1
            b[m] = 0
            b[12-m] = 0
        }
        
        if player == .computer {
            
        }
        return m
    }
    
    //900-999 Never executed
}
