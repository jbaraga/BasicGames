//
//  3DTicTacToe.swift
//  play
//
//  Created by Joseph Baraga on 2/18/25.
//

import Foundation

class TDTicTacToe: BasicGame {
    
    private enum Square: CustomStringConvertible {
        case empty
        case user
        case computer
        
        var description: String {
            switch self {
            case .empty: return "( )"
            case .user: return "(Y)"
            case .computer: return "(M)"
            }
        }
    }
    
    private struct Board {
        private var tensor = Tensor(dimension: 4, value: Square.empty)
        
        var levels: [Matrix<Square>] { tensor.matrixes }
        
        //Convert from zero to one indexing
        subscript(_ x: Int, _ y: Int, _ z: Int) -> Square {
            get { tensor[x - 1, y - 1, z - 1] }
            set { tensor[x - 1, y - 1, z - 1] = newValue }
        }
        
        subscript(_ xyz: (Int, Int, Int)) -> Square {
            get { self[xyz.0, xyz.1, xyz.2] }
            set { self[xyz.0, xyz.1, xyz.2] = newValue }
        }
        
        subscript(_ number: Int) -> Square {
            get { self[xyz(from: number)] }
            set { self[xyz(from: number)] = newValue }
        }
        
        func isValidSquare(number: Int) -> Bool {
            let xyz = xyz(from: number)
            return (1...4).contains(xyz.x) && (1...4).contains(xyz.y) && (1...4).contains(xyz.z)
        }
        
        var isUserWinner: Bool {
            return (tensor.lines.filter { $0 == Self.winningLine(for: .user) }).count > 0
        }
        
        var userWinningSquares: [Int] {
            let coordinates = (tensor.lineIndexes.filter { indexes in
                (indexes.map { tensor[$0] }) == Self.winningLine(for: .user)
            }).first ?? []
            return coordinates.map { ($0.z + 1) * 100 + ($0.x + 1) * 10 + $0.y + 1 }
        }
        
        private func xyz(from number: Int) -> (x: Int, y: Int, z: Int) {
            let z = number / 100
            let x = number % 100 / 10
            let y = (number % 100) % 10
            return (x,y,z)
        }
        
        static func winningLine(for square: Square) -> [Square] {
            return Array(repeating: square, count: 4)
        }
    }
    
    func run() {
        printHeader(title: "Qubic")
        
        promptForInstructions()
        
        repeat {
            play()
        } while getResponse(message: "Do you want to try another game", errorMessage: "Incorrect answer.  Please type 'yes' or 'no'") == .yes
    }
    
    private func play() {
        var board = Board()
        
        let response = getResponse(message: "Do you want to move first", errorMessage: "Incorrect answer.  Please type 'yes' or 'no'.")
        
        while !board.isUserWinner {
            println()
            
            let move = getUserMove(board: board)
            board[move] = .user
            
            if board.isUserWinner {
                print("You win as follows ")
                println(board.userWinningSquares.map { " \($0) " }.joined())
                println()
                return
            }
        }
    }
    
    private func getUserMove(board: Board, message: String = "Your move") -> Int {
        let number = Int(input(message)) ?? -1
        switch number {
        case 0:
            print(board: board)
            println()
            return getUserMove(board: board)
        case 1:
            end()
        default:
            guard board.isValidSquare(number: number) else {
                return getUserMove(board: board, message: "Incorrect move, retype it--")
            }
            
            guard board[number] == .empty else {
                println("That square is used, try again.")
                println()
                return getUserMove(board: board)
            }
        }
        
        return number
    }
    
    private func getResponse(message: String, errorMessage: String? = nil) -> Response {
        let response = Response(input(message))
        switch response {
        case .other:
            return getResponse(message: errorMessage ?? message)
        case .yes, .no:
            return response
        }
    }
    
    private func promptForInstructions() {
        switch getResponse(message: "Do you want instructions", errorMessage: "Incorrect answer.  Please type 'yes' or 'no' ") {
        case .yes:
            printInstructions()
        default:
            break
        }
    }
    
    private func printInstructions() {
        println()
        println("The game is Tic-Tac-Toe in a 4 x 4 x 4 cube.")
        println("Each move is indicated by a 3 digit number, with each")
        println("digit between 1 and 4 inclusive.  The digits indicate the")
        println("level, row, and column, respectively, of the occupied")
        println("place.")
        println()
        println("To print the playing board, type 0 (zero) as your move.")
        println("The program will print the board with your moves indi-")
        println("cated with a (Y), the machine's moves with an (M), and")
        println("unused squares with a ( ).")
        println()
        println("To stop the program, type 1 as your move.")
        println(2)
    }
    
    private func print(board: Board) {
        for level in board.levels {
            for (index, row) in level.rows.enumerated() {
                println(tab(index * 3), row.map { "   \($0)   " }.joined())
                println()
            }
            println(2)
        }
    }
}
