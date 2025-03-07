//
//  TicTacToe2.swift
//  play
//
//  Created by Joseph Baraga on 1/13/25.
//

import Foundation

class TicTacToe2: BasicGame {
    
    private enum Player {
        case user
        case computer
    }
    
    private struct Board: CustomStringConvertible {
        private var s = [Int](repeating: 0, count: 9)  //S, zero indexed
        var userMark = "X"
        
        subscript(_ index: Int) -> Int {
            get { s[index - 1] }
            set { s[index - 1] = newValue }
        }
        
        var isSpaceOpen: Bool { (s.filter { $0 == 0 }).count > 0 }
        
        //1-indexed
        private var openSpaceIndexes: [Int] {
            return (s.indices.filter { s[$0] == 0 }).map { $0 + 1 }
        }
        
        var winner: Player? {
            for line in lines {
                let sum = line.reduce(0, +)
                if sum == 3 { return .user }
                if sum == -3 { return .computer}
            }
            return nil
        }
        
        var description: String {
            let lines = Array(0...2).map { string(for: $0) }
            return lines.joined(separator: "\n---+---+---\n")
        }
        
        //rows + columns + diagonals
        var rows: [[Int]] { (0...2).map { row(for: $0) } }
        var columns: [[Int]] { (0...2).map { column(for: $0) } }
        var diagonals: [[Int]] { [0, 2].map { diagonal(startIndex: $0) } }
        var lines: [[Int]] { rows + columns + diagonals }
        
        func row(for rowIndex: Int) -> [Int] {
            let index = rowIndex * 3
            return Array(s[index..<(index+3)])
        }
        
        func column(for columnIndex: Int) -> [Int] {
            return [s[columnIndex], s[columnIndex+3], s[columnIndex+6]]
        }
        
        func diagonal(startIndex: Int) -> [Int] {
            switch startIndex {
            case 0: return [s[0], s[4], s[8]]
            case 2: return [s[2], s[4], s[6]]
            default: fatalError("Invalid diagonal index \(startIndex)")
            }
        }
        
        func string(for rowIndex: Int) -> String {
            let computerMark = userMark == "X" ? "O" : "X"
            return (row(for: rowIndex).map { $0 == 0 ? "   " : " \($0 > 0 ? userMark : computerMark) " }).joined(separator: "!")
        }
        
        mutating func computerMove(after m: Int) {
            //Take middle if user didn't
            if s[4] == 0 {
                s[4] = -1
                return
            }
            
            //Check for winning move or block of user winning move
            //118-70
            if let m = move(for: -1) {
                s[m] = -1
                return
            }
            
            //Preferential take upper left corner if no block needed
            if s[4] == 1 && s[0] == 0 {
                s[0] = -1
                return
            }
            
            //106-109 take corner if have middle
            if s[4] == -1 {
                if s[0] == 0 && (s[1] == 1 || s[3] == 1 ) {
                    //181
                    s[0] = -1
                    return
                }
                if s[8] == 0 && (s[5] == 1 || s[7] == 1) {
                    //189
                    s[8] = -1
                    return
                }
            }
            
            //177-179 Fallthrough
            guard let index = s.firstIndex(of: 0) else { fatalError("No open spaces") }
            s[index] = -1
        }
        
        //scan rows then columns then diagonals for win (g=-1), then for block (g=1)
        private func move(for g: Int) -> Int? {
            for (rowIndex, row) in rows.enumerated() {
                if row.reduce(0, +) == 2 * g, let index = row.firstIndex(of: 0) {
                    return 3 * rowIndex + index
                }
            }
            for (columnIndex, column) in columns.enumerated() {
                if column.reduce(0, +) == 2 * g, let index = column.firstIndex(of: 0) {
                    return 3 * index + columnIndex
                }
            }
            for (diagIndex, diagonal) in diagonals.enumerated() {
                if diagonal.reduce(0, +) == 2 * g, let index = diagonal.firstIndex(of: 0) {
                    return diagIndex == 0 ? index * 4 : 2 + index * 2
                }
            }
            
            if g == -1 { return move(for: 1) }
            
            return nil
        }
        
        //MARK: Testing
        //Test result of all possibilities
        //Total: 521  User Wins: 3  Computer Wins: 354  Draws: 164
        private enum Result {
            case userWin
            case computerWin
            case draw
        }
        
        static func test() -> String {
            Swift.print("Testing all possible moves...")
            let (_, results) = testAllMoves()
            let string = ("Total: \(results.count)  User Wins: \(results.filter({ $0 == .userWin }).count)  Computer Wins: \(results.filter({ $0 == .computerWin }).count)  Draws: \(results.filter({ $0 == .draw }).count)")
            Swift.print(string)
            return string
        }
        
        private static func testAllMoves(board: Self = Board()) -> (board: Self, results: [Result]) {
            var results = [Result]()
            
            for index in board.openSpaceIndexes {
                var board = board
                board[index] = 1
                if board.isSpaceOpen, board.winner == nil {
                    board.computerMove(after: index)
                }
                if let winner = board.winner {
                    if winner == .user {
                        results.append(.userWin)
                        Swift.print(board)
                    } else {
                        results.append(.computerWin)
                    }
                } else if board.openSpaceIndexes.count == 0 {
                    results.append(.draw)
                } else {
                    let (_, newResults) = testAllMoves(board: board)
                    results += newResults
                }
            }
            return (board, results)
        }
    }
    
    private var board = Board()
    private var isCRT = false
    
    func run() {
        printHeader(title: "Tic-Tac-Toe")
        println("The board is numbered:")
        println(" 1  2  3")
        println(" 4  5  6")
        println(" 7  8  9")
        println(3)
        
        saveLinePosition()
        isCRT = Response(input("Are you running on a CRT")) == .yes  //Add on
        println()
        if isCRT { restoreLinePosition() }
        
        play()
        end()
    }
    
    private func play() {
        saveLinePosition()
        board.userMark = input("Do you want 'X' or 'O'").uppercased() == "X" ? "X" : "O"  //P$, board value 1
        
        if isCRT { restoreLinePosition() }
        
        var isGameUnfinished: Bool { return board.winner == nil && board.isSpaceOpen }
        
        repeat {
            let userMove = getUserMove()
            if userMove == 0 {
                println("Thanks for the game.")
                return
            }
            board[userMove] = 1
            printBoard()
            
            if isGameUnfinished {
                if isCRT {
                    wait(.short)
                    restoreLinePosition()
                }
                
                println("The computer moves to...")
                board.computerMove(after: userMove)
                printBoard()
            }
            
            if isGameUnfinished, isCRT {
                wait(.short)
                restoreLinePosition()
            }
        } while isGameUnfinished
        
        wait(.short)
        if let winner = board.winner {
            printWinner(winner)
        } else {
            println("It's a draw. Thank you.")
            unlockEasterEgg(.ticTacToe2)
        }
    }
    
    //500-510
    private func getUserMove() -> Int {
        if !isCRT { println() }
        guard let move = Int(input("Where do you move")), move == 0 || ((1...9).contains(move) && board[move] == 0) else {
            if isCRT {
                restoreLinePosition()
                println("That square is occupied")
                wait(.short)
                restoreLinePosition()
            } else {
                println("That square is occupied")
                println(2)
            }
            return getUserMove()
        }
        return move
    }
    
    //1000-1170, win check logic factored out
    private func printBoard() {
        println()
        println(board)
        println(2)
    }
    
    private func printWinner(_ player: Player) {
        switch player {
        case .user:
            println("You beat me!!  Good game")
            unlockEasterEgg(.ticTacToe2)
        case .computer:
            println("I win, turkey!!!")
        }
    }
    
    func test() {
        println(Board.test())
    }
}
