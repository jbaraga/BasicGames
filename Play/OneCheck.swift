//
//  OneCheck.swift
//  play
//
//  Created by Joseph Baraga on 1/25/25.
//

import Foundation


class OneCheck: BasicGame {
    
    private enum Square: Int, CustomStringConvertible {
        case empty, checker
        
        var description: String { "\(rawValue)" }
    }
    
    private struct Board {
        private var a: Matrix<Square>  //A
        
        var indices: [Int] { return [Int](1...64) }
        
        var rowStrings: [String] {
            a.rows.map { row in (row.map { " \($0) " }).joined() }
        }
        
        var checkerCount: Int {
            a.rows.reduce(0) { $0 + ($1.filter { square in square == .checker }).count }
        }
        
        static var numericalRows: [String] {
            (1...8).reduce(into: [String]()) { array, rowIndex in
                array.append(((1...8).map {
                    let index = (rowIndex - 1) * 8 + $0
                    return index < 10 ? " \(index) " : " \(index)"
                }).joined(separator: " "))
            }
        }
        
        init() {
            a = Matrix(rows: 8, columns: 8, value: .checker)
            for rowIndex in 2...5 {
                for columnIndex in 2...5 {
                    a[rowIndex, columnIndex] = .empty
                }
            }
        }
        
        subscript(_ index: Int) -> Square {
            get { a[matrixIndexes(for: index)] }
            set { a[matrixIndexes(for: index)] = newValue }
        }
        
        private func matrixIndexes(for index: Int) -> (row: Int, column: Int) {
            return ((index - 1) / 8, (index - 1) % 8)
        }
        
        func isIndexValid(_ index: Int) -> Bool {
            return indices.contains(index)
        }
        
        func isMoveLegal(from index1: Int, to index2: Int) -> Bool {
            //118 REM *** CHECK LEGALITY OF MOVE
            guard isIndexValid(index1), isIndexValid(index2) else { return false }
            guard self[index1] == .checker, self[index2] == .empty else { return false }
            //Enforce diagnonal jump over square
            let matrixIndexes1 = matrixIndexes(for: index1)
            let matrixIndexes2 = matrixIndexes(for: index2)
            guard abs(matrixIndexes1.row - matrixIndexes2.row) == 2 else { return false }  //Row jump by 2
            guard abs(matrixIndexes1.column - matrixIndexes2.column) == 2 else { return false }  //Column jump by 2
            let jumpedIndex = (index1 + index2) / 2
            return self[jumpedIndex] == .checker
        }
        
        mutating func jump(from index1: Int, to index2: Int) {
            //245 REM *** UPDATE BOARD
            //Legality of move is checked on entry, not rechecked here
            self[index1] = .empty
            self[index2] = .checker
            self[(index1 + index2) / 2] = .empty
        }
    }
    
    func run() {
        printHeader(title: "One Check")
        println("Solitaire Checker Puzzle by David Ahl")
        println()
        println("48 checkers are placed on the 2 outside spaces of a")
        println("standard 64-square checkerboard.  The object is to")
        println("remove as many checkers as possible by diagonal jumps")
        println("(as in standard checkers).  Use the numbered board to")
        println("indicate the square you wish to jump from and to.  On")
        println("the board printed out on each turn '1' indicates a")
        println("checker and '0' and empty square.  When you have no")
        println("possible jumps remaining, input a '0' in response t0")
        println("question 'jump from?'")
        println()
        println("Here is the numerical board:")
        println()
        
        repeat {
            play()
        } while playAgain() == .yes
                    
        println()
        println("O.K.  Hope you had fun!!")
        end()
    }
    
    //70-
    private func play() {
        var board = Board()
        var jumps = 0

        for row in Board.numericalRows { println(row) }
        
        println()
        println("And here is the opening position of the checkers.")
        println()
        print(board: board)
        
        var move = (from: 0, to: 0)
        repeat {
            move = getMove(board: board)
            if move.from > 0 {
                board.jump(from: move.from, to: move.to)
                print(board: board)
                jumps += 1
            }
        } while move.from > 0
        
        //490 REM *** END GAME SUMMARY
        println("You made \(jumps) jumps and had \(board.checkerCount) pieces")
        println("remaining on the board.")
        println()
        if board.checkerCount == 1 { unlockEasterEgg(.oneCheck) }
    }
    
    private func getMove(board: Board) -> (from: Int, to: Int) {
        let from = input("Jump from") ?? -1
        if from == 0 { return (0, 0) }
        let to = input("To") ?? -1
        println()
        
        //118 REM *** CHECK LEGALITY OF MOVE
        guard board.isMoveLegal(from: from, to: to) else {
            println("Illegal move.  Try again...")
            return getMove(board: board)
        }
        
        return(from, to)
    }
    
    private func print(board: Board) {
        //310 REM *** PRINT BOARD
        for rowString in board.rowStrings {
            println(rowString)
        }
        println()
    }
    
    private func playAgain() -> Response {
        let response = Response(input("Try again"))
        if response.isYesOrNo {
            println("Please answer 'yes' or 'no'")
            return playAgain()
        }
        return response
    }
}
