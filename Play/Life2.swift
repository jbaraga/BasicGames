//
//  Life2.swift
//  play
//
//  Created by Joseph Baraga on 1/13/25.
//

import Foundation

class Life2: BasicGame {
    //TODO: Original game may have bug - too many cells survive from from round 1 to round 2
    private var board = Board()
    
    private enum Player: Int, CaseIterable, CustomStringConvertible {
        case first = 1
        case second = 2
        
        var description: String { "\(rawValue)" }
        var cell: String { self == .first ? "*" : "#" }
    }
    
    private struct Board {
        private var n = Matrix(rows: 5, columns: 5, value: Self.emptyCell)
        
        var columnIndices: Range<Int> { n.rows[0].indices }
        
        static let emptyCell = " "

        mutating func nextGeneration() {
            let copy = n.rows
            for rowIndex in copy.indices {
                let row = copy[rowIndex]
                let firstRowIndex = max(rowIndex - 1, copy.startIndex)
                let lastRowIndex = min(rowIndex + 1, copy.endIndex - 1)
                for columnIndex in row.indices {
                    let firstColumnIndex = max(columnIndex - 1, row.startIndex)
                    let lastColumnIndex = min(columnIndex + 1, row.endIndex - 1)
                    let neighbors = (firstRowIndex...lastRowIndex).reduce(into: [String]()) {
                        if $1 == rowIndex {
                            if firstColumnIndex < columnIndex { $0.append(row[firstColumnIndex]) }
                            if lastColumnIndex > columnIndex { $0.append(row[lastColumnIndex])}
                        } else {
                            $0 += copy[$1][firstColumnIndex...lastColumnIndex]
                        }
                    }

                    let stars = (neighbors.filter { $0 == Player.first.cell }).count
                    let pounds = (neighbors.filter { $0 == Player.second.cell }).count
                    let living = stars + pounds
                    
                    if copy[rowIndex, columnIndex] == Self.emptyCell {
                        if living == 3 {
                            n[rowIndex, columnIndex] = stars > pounds ? Player.first.cell : Player.second.cell
                        }
                    } else {
                        if living < 2 || living > 3 {
                            n[rowIndex, columnIndex] = Self.emptyCell
                        }
                    }
                }
            }
        }
        
        //Coordinate 1 indexed
        subscript(_ coordinate: Point) -> String {
            get { n[coordinate.x - 1, coordinate.y - 1] }
            set { n[coordinate.x - 1, coordinate.y - 1] = newValue }
        }
        
        func isValid(coordinate: Point) -> Bool {
            return (0...4).contains(coordinate.x - 1) && (0...4).contains(coordinate.y - 1)
        }
        
        func rowsEnumerated() -> EnumeratedSequence<[[String]]> { n.rows.enumerated() }
        
        func livingCells(for player: Player) -> Int {
            return (n.rows.joined().filter { $0 == player.cell }).count
        }
        
        mutating func testSetup() {
            self[Point((1,1))] = Player.first.cell
            self[Point((1,2))] = Player.first.cell
            self[Point((2,1))] = Player.first.cell
            self[Point((3,3))] = Player.second.cell
            self[Point((4,3))] = Player.second.cell
            self[Point((5,3))] = Player.second.cell
        }
    }
    
    func run() {
        printHeader(title: "Life2")
        println(tab(10), "U.B. Life Game")
        wait(.short)
        play()
    }
    
    private func play() {
        //519-542 initial setup
        var coordinates = [Point]()
        for player in Player.allCases {
            println("Player \(player)  - 3 live pieces.")
            for _ in 1...3 {
                var isDuplicate = false
                let coordinate = getCoordinate()
                if player == .first {
                    coordinates.append(coordinate)
                } else {
                    isDuplicate = coordinates.contains(coordinate)
                }
                
                if isDuplicate { println("Same coord.  Set to 0.") }
                board[coordinate] = isDuplicate ? Board.emptyCell : player.cell
            }
        }
        
        print(board: board)
        board.nextGeneration()
        print(board: board)
        
        while board.livingCells(for: .first) > 0 && board.livingCells(for: .second) > 0 {
            print("Player \(Player.first) ")
            let coordinate1 = getCoordinate()
            println()
            print("Player \(Player.second) ")
            let coordinate2 = getCoordinate()
            if coordinate1 == coordinate2 {
                println("Same coord.  Set to 0.")
                board[coordinate1] = Board.emptyCell
            } else {
                board[coordinate1] = Player.first.cell
                board[coordinate2] = Player.second.cell
            }
            println()
            
            board.nextGeneration()
            print(board: board)
        }
        
        //574-575
        println()
        let cellsFirst = board.livingCells(for: .first)
        let cellsSecond = board.livingCells(for: .second)
        if cellsFirst == cellsSecond {
            println("A draw")
        } else {
            println("Player \(cellsFirst > cellsSecond ? Player.first : .second) is the winner")
        }
        unlockEasterEgg(.lifeForTwo)
        end()
    }
    
    private func print(board: Board) {
        println()
        let columnIndices = board.columnIndices.map { $0 + 1 }
        let xAxis = (([0] + columnIndices + [0]).map { "\($0)" }).joined(separator: "  ")
        println(xAxis)
        for (rowIndex, row) in board.rowsEnumerated() {
            let rowString = (["\(rowIndex + 1)"] + row + ["\(rowIndex + 1)"]).joined(separator: "  ")
            println(rowString)
        }
        println(xAxis)
    }
    
    private func getCoordinate() -> Point {
        println("x,y")
        print(String(repeating: "X", count: 6), chr$(13))
        guard let coordinate: Point = input("", terminator: ""), board.isValid(coordinate: coordinate), board[coordinate] == " " else {
            moveCursorUp(lines: 1)
            println(String(repeating: "█", count: 6))
            println("Illegal coords. Retype")
            return getCoordinate()
        }
        moveCursorUp(lines: 1)
        println(String(repeating: "█", count: 6))
        return coordinate
    }
}
