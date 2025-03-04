//
//  Chomp.swift
//  play
//
//  Created by Joseph Baraga on 1/18/25.
//

import Foundation

class Chomp: BasicGame {
    
    private enum Square: String, CustomStringConvertible {
        case empty = " "
        case cookie = "*"
        case poison = "p"
        
        var description: String { rawValue }
    }
    
    private struct Board {
        private var matrix: Matrix<Square>
        
        var rows: [[Square]] { matrix.rows }
        
        init(rows: Int, columns: Int) {
            self.matrix = .init(rows: rows, columns: columns, value: .cookie)
            self.matrix[0,0] = .poison
        }
        
        //One-indexed
        subscript(_ location: Point) -> Square {
            get { matrix[location.x - 1, location.y - 1] }
            set { matrix[location.x - 1, location.y - 1] = newValue}
        }
        
        //1 indexed location
        func containsSquare(at location: Point) -> Bool {
            let point = Point(location.x - 1, location.y - 1)
            return matrix.isValid(point: point)
        }
        
        //1 indexed location
        func isEmpty(at location: Point) -> Bool {
            let point = Point(location.x - 1, location.y - 1)
            return matrix[point] == .empty
        }
        
        //1 indexed location
        mutating func chomp(at location: Point) {
            let point = Point(location.x - 1, location.y - 1)
            for rowIndex in point.x..<matrix.rows.count {
                for columnIndex in point.y..<matrix.columns.count {
                    matrix[rowIndex, columnIndex] = .empty
                }
            }
        }
    }
    
    func run() {
        printHeader(title: "Chomp")
        //100 REM *** THE GAME OF CHOMP *** COPYRIGHT PCC 1973 ***
        println()
        println("This is the game of Chomp (Scientific American, Jan 1973)")
        
        if Int(input("Want the rules (1=yes, 0=no!)")) ?? 0 == 1 {
            println("Chomp is for 1 or more players (humans only).")
            println()
            println("Here's how the board looks (this one is 5 by 7):")
            print(board: Board(rows: 5, columns: 7))
            println()
            println("The board is a big cookie - r rows high and c columns")
            println("wide. You input r and c at the start. In the upper left")
            println("corner of the cookie is a poison square (p). The one who")
            println("chomps the poison square loses. To take a chomp, type the")
            println("row and column of one of the squares on the cookie.")
            println("All of the squares below and to the right of that square")
            println("(including that square, too) disappear -- chomp!!")
            println("No fair chomping squares that have already been chomped,")
            println("or that are outside the original dimensions of the cookie.")
            println()
        }
        
        repeat {
            play()
        } while Int(input("Again (1=yes); 0=no!)")) ?? 0 == 1
        
        end()
    }
    
    private func play() {
        println("Here we go...")
        println()
        //350 REM

        let players = Int(input("How many players")) ?? 1  //P
        let rows = getDimension(for: "rows")  //R
        let columns = getDimension(for: "columns")  //C
        println()
        
        var board = Board(rows: rows, columns: columns)
        print(board: board)
        
        repeat {
            //770 REM GET CHOMPS FOR EACH PLAYER IN TURN
            for player in 1...players {
                let point = getChomp(for: player, board: board)
                
                if board[point] == .poison {
                    //1000 REM END OF GAME DETECTED IN LINE 900
                    println("You lose, player  \(player)")
                    println()
                    wait(.short)
                    unlockEasterEgg(.chomp)
                    return
                }
                
                board.chomp(at: point)
                print(board: board)
            }
        } while true
    }
    
    //420-510
    private func getDimension(for label: String) -> Int {
        print("How many " + label)
        guard let dimension = Int(input()), dimension <= 9 else {
            print("Too many \(label) (9 is maximum). Now, ")
            return getDimension(for: label)
        }
        return dimension
    }
    
    //540-760
    private func print(board: Board) {
        //600 REM PRINT THE BOARD
        println()
        println(tab(7), "1 2 3 4 5 6 7 8 9")
        for (index, row) in board.rows.enumerated() {
            println("\(index + 1)", tab(7), (row.map { "\($0)" }).joined(separator: " "))
        }
        println()
    }
    
    private func getChomp(for player: Int, board: Board) -> Point {
        println("Player  \(player)")
        guard let point: Point = input("Coordinates of chomp (row,column)"), board.containsSquare(at: point), !board.isEmpty(at: point) else {
            println("No fair. You're trying to chomp on empty space!")
            return getChomp(for: player, board: board)
        }
        return point
    }
}
