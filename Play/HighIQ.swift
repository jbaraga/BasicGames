//
//  HighIQ.swift
//  play
//
//  Created by Joseph Baraga on 1/22/25.
//

import Foundation

class HighIQ: BasicGame {
    
    private enum BoardLocation: String, CustomStringConvertible {
        case hole = "O"
        case peg = "!"
        case none = " "
        
        var description: String { rawValue }
    }
    
    private var testMoves: [(Int, Int)] {
        [(59,41), (32, 50), (43, 41)]
    }
    
    private struct Board {
        private var t: Matrix<BoardLocation>  //T
        
        var rowIndexes: [ClosedRange<Int>] { [13...15, 22...24, 29...35, 38...44, 47...53, 58...60, 67...69] }
        var indexes: [Int] { rowIndexes.reduce([]) { $0 + [Int]($1) } }
        
        var rows: [[BoardLocation]] {
            return t.rows.map { $0.filter { hole in hole != .none } }
        }
        
        var rowStrings: [String] {
            t.rows.map { row in (row.map { "\($0)" }).joined(separator: " ") }
        }
        
        var remainingPegs: Int { t.rows.reduce(0) { $0 + ($1.filter { $0 == .peg }).count }}  //F
        
        var isGameOver: Bool {
            //1500 REM*** CHECK IF GAME IS OVER
            //Check for remaining legal move
            //At least one row or column must contain [.peg, .peg, .hole] or [.hole, .peg, .peg] for a legal move
            let allowedMove: [BoardLocation] = [.peg, .peg, .hole]
            for row in t.rows {
                if row.contains(allowedMove) || row.contains(allowedMove.reversed()) { return false }
            }
            for column in t.columns {
                if column.contains(allowedMove) || column.contains(allowedMove.reversed()) { return false }
            }
            return true
        }
        
        var sampleRowStrings: [String] {
            rowIndexes.reduce(into: [String]()) { strings, range in
                let pegRow = (Array(repeating: BoardLocation.none.description, count: (7 - range.count) / 2) + Array(repeating: BoardLocation.peg.description, count: range.count)).joined(separator: "    ")
                strings.append(pegRow)
                var numberRow = (Array(repeating: "  ", count: (7 - range.count) / 2) + range.map { "\($0)" }).joined(separator: "   ")
                if numberRow.prefix(1) == " " { numberRow.removeFirst() }  //Duplicates original alignment of numbers
                strings.append(numberRow)
                strings.append("")
            }
        }
        
        init() {
            t = Matrix(rows: 7, columns: 7, value: BoardLocation.none)
            rowIndexes.forEach { range in
                range.forEach { index in
                    self[index] = .peg
                }
            }
            self[41] = .hole
        }
        
        subscript(_ index: Int) -> BoardLocation {
            get { t[matrixIndexes(for: index)] }
            set { t[matrixIndexes(for: index)] = newValue }
        }
        
        private func matrixIndexes(for index: Int) -> (row: Int, column: Int) {
            //Row indexes are separated by 9. Indexes are set such that legal jumps are even-even or odd-odd, horizontal jumps separated by 2, vertical jumps separated by 18; jumped indices are halfway between from and to indices
            let rowIndex = index / 9 - 1
            let columnIndex = index - ((rowIndex + 1) * 9 + 2)
            return (rowIndex, columnIndex)
        }
        
        func isIndexValid(_ index: Int) -> Bool {
            return indexes.contains(index)
        }
        
        func isMoveLegal(from pegIndex: Int, to holeIndex: Int) -> Bool {
            guard self[pegIndex] == .peg, self[holeIndex] == .hole else { return false }
            guard abs(pegIndex - holeIndex) % 2 == 0 || abs(pegIndex - holeIndex) % 2 == 18 else { return false }
            let jumpedIndex = (pegIndex + holeIndex) / 2
            guard isIndexValid(jumpedIndex) else { return false }
            guard self[(pegIndex + holeIndex) / 2] == .peg else { return false }
            return true
        }
        
        mutating func jump(from pegIndex: Int, to holeIndex: Int) {
            //100 REM *** UPDATE BOARD
            //Legality of move is checked on entry, not rechecked here
            self[pegIndex] = .hole
            self[(pegIndex + holeIndex) / 2] = .hole
            self[holeIndex] = .peg
        }
    }
    
    func run() {
        printHeader(title: "H-I-Q")
        println("Here is the board:")
        println()
        Board().sampleRowStrings.forEach { println($0) }
        println("To save typing time, a compressed version of the game board")
        println("will be used during play.  Refer to the above one for peg")
        println("numbers.  OK, let's begin.")
        
        repeat {
            play()
            println()
        } while Response(input("Play again (yes or no)")) != .no
                    
        println()
        println("So long for now.")
        println()
        end()
    }
    
    private func play() {
        //28 REM *** SET UP BOARD
        var board = Board()
        print(board: board)
        
        repeat {
            let (pegIndex, holeIndex) = getMove(board: board)
            board.jump(from: pegIndex, to: holeIndex)
            print(board: board)
        } while !board.isGameOver
                    
        //1600 REM *** GAME IS OVER
        println("The game is over.")
        println("You have \(board.remainingPegs) pieces remaining.")
        if board.remainingPegs == 1 {
            println("Bravo!  You made a perfect score!")
            println("Save this paper as a record of your accomplishment!")
            unlockEasterEgg(.highIQ)
        }
    }
    
    private func getMove(board: Board) -> (from: Int, to: Int) {
        //70 REM INPUT MOVE AND CHECK ON LEGALITY
        guard let pegIndex = Int(input("Move which piece")), board.isIndexValid(pegIndex), board[pegIndex] == .peg else {
            println("Illegal move, try again...")
            return getMove(board: board)
        }
        
        guard let holeIndex = Int(input("To where")), board.isIndexValid(holeIndex), board.isMoveLegal(from: pegIndex, to: holeIndex) || holeIndex == pegIndex else {
            println("Illegal move, try again...")
            return getMove(board: board)
        }
        if holeIndex == pegIndex { return getMove(board: board) }
        
        return (pegIndex, holeIndex)
    }
    
    //500-640
    private func print(board: Board) {
        //500 REM *** PRINT BOARD
        println()
        board.rowStrings.forEach { println(tab(4), $0) }
        println()
    }
}
