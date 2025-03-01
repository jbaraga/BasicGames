//
//  3DTicTacToe.swift
//  play
//
//  Created by Joseph Baraga on 2/18/25.
//

import Foundation

class TDTicTacToe: BasicGame {
    
    private enum Player {
        case user
        case computer
    }
    
    private enum Square: CustomStringConvertible, Equatable {
        case empty(Double)
        case user
        case computer
        
        var description: String {
            switch self {
            case .empty: return "( )"
            case .user: return "(Y)"
            case .computer: return "(M)"
            }
        }
        
        var value: Double {
            switch self {
            case .empty(let value): return value
            case .user: return 1
            case .computer: return 5
            }
        }
        
        var isEmpty: Bool {
            switch self {
            case .empty: return true
            default: return false
            }
        }
        
        static func == (lhs: TDTicTacToe.Square, rhs: TDTicTacToe.Square) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty):
                return true
            case (.user, .user), (.computer, .computer):
                return true
            default:
                return false
            }
        }
    }
    
    private struct Board {
        private var tensor = Tensor(dimension: 4, value: Square.empty(0))
        
        var levels: [Matrix<Square>] { tensor.matrixes }
        
        var scalarIndexedLines: [[(scalar: Int, square: Square)]] {
            var lines = [[(scalar: Int, Square)]]()
            for indexedLine in tensor.indexedLines {
                lines.append(indexedLine.map { (Self.scalar(for: $0.0), $0.1) })
            }
            return lines
        }
        
        var isGameOver: Bool {
            return isUserWinner || isMachineWinner
        }
        
        var isUserWinner: Bool {
            return (tensor.lines.filter { $0 == Self.winningLine(for: .user) }).count > 0
        }
        
        var isMachineWinner: Bool {
            return (tensor.lines.filter { $0 == Self.winningLine(for: .computer) }).count > 0
        }

        //Indexing
        //coordinate is (x,y,z) tuple pointing to tensor, zero-indexed
        //scalar if coordinate converted to zxy 3 digit integer representation of coordinate, one-indexed, used in game
        //index is 1...64, indexing of one-indexed X[] array board representation in game
        
        //Common pathway to underlying tensor storage
        subscript(_ x: Int, _ y: Int, _ z: Int) -> Square {
            get { tensor[x,y,z] }
            set { tensor[x,y,z] = newValue }
        }
        
        subscript(_ coordinate: (Int, Int, Int)) -> Square {
            get { self[coordinate.0, coordinate.1, coordinate.2] }
            set { self[coordinate.0, coordinate.1, coordinate.2] = newValue }
        }
        
        subscript(_ scalar: Int) -> Square {
            get { self[coordinate(from: scalar)] }
            set { self[coordinate(from: scalar)] = newValue }
        }
        
        mutating func clearTaggedEmptySquares() {
            tensor.indexes.forEach {
                if tensor[$0].isEmpty { tensor[$0] = .empty(0) }
            }
        }
        
        func isValidSquare(scalar: Int) -> Bool {
            let xyz = coordinate(from: scalar)
            return (0...3).contains(xyz.x) && (0...3).contains(xyz.y) && (0...3).contains(xyz.z)
        }
        
        func winningSquares(for player: Player) -> [Int]? {
            let square = player == .user ? Square.user : .computer
            let targetLine = Self.winningLine(for: square)
            guard let indexedLine = scalarIndexedLines.first(where: { indexedLine in indexedLine.map { $0.1 } == targetLine }) else {
                return nil
            }
            return indexedLine.map { $0.scalar }
        }
        
        //Converts to zero-indexing
        private func coordinate(from scalar: Int) -> (x: Int, y: Int, z: Int) {
            let z = scalar / 100 - 1
            let x = scalar % 100 / 10 - 1
            let y = (scalar % 100) % 10 - 1
            return (x,y,z)
        }
        
        static func scalar(for coordinate: (x: Int, y: Int, z: Int)) -> Int {
            return (coordinate.z + 1) * 100 + (coordinate.x + 1) * 10 + coordinate.y + 1
        }
        
        //1570-1610
        static func scalar(for index: Int) -> Int {
            let value = index - 1
            return (value / 16 + 1) * 100 + ((value % 16) / 4 + 1) * 10 + (value % 4) + 1
        }
        
        static func winningLine(for square: Square) -> [Square] {
            return Array(repeating: square, count: 4)
        }
        
        static func value(for indexedLine: [(Int, Square)]) -> Double {
            return (indexedLine.map { $0.1.value }).reduce(0, +)
        }
    }
    
    func run() {
        printHeader(title: "Qubic")
        promptForInstructions()
        
        repeat {
            play()
        } while getResponse(message: "Do you want to try another game", errorMessage: "Incorrect answer.  Please type 'yes' or 'no'") == .yes
        
        end()
    }
    
    private func play() {
        var board = Board()

        let response = getResponse(message: "Do you want to move first", errorMessage: "Incorrect answer.  Please type 'yes' or 'no'.")
        var playerTurn = response == .yes ? Player.user : .computer
        println()
        
        while !board.isGameOver {
            if playerTurn == .user {
                let move = getUserMove(board: board)  //scalar
                board[move] = .user
                
                //720-780
                if let squares = board.winningSquares(for: .user) {
                    print("You win as follows ")
                    println(squares.map { " \($0) " }.joined())
                    println()
                    unlockEasterEgg(.threeDTicTacToe)
                    return
                }
                
                playerTurn = .computer
            } else {
                guard let move = computerMove(board: board) else {
                    println("The game is a draw.")  //1810
                    println()
                    return
                }
                board[move] = .computer
                playerTurn = .user
            }
        }
    }
    
    private func getUserMove(board: Board, message: String = "Your move") -> Int {
        let scalar = Int(input(message)) ?? -1
        switch scalar {
        case 0:
            print(board: board)
            println()
            return getUserMove(board: board)
        case 1:
            end()
        default:
            guard board.isValidSquare(scalar: scalar) else {
                return getUserMove(board: board, message: "Incorrect move, retype it--")
            }
            
            guard board[scalar].isEmpty else {
                println("That square is used, try again.")
                println()
                return getUserMove(board: board)
            }
            
            return scalar
        }
    }
    
    //Convoluted computer move logic
    //Selection logic mutates the board to track preferred empty spaces, which might in some instances carry over to next round
    //In this implementation mutations are discarded after each round. To carry over, change board parameter to inout or add board as a return value
    //640-1020 - check for winning or game saving blocking moves
    //1300-1480 - offensive tagging - tag empty squares in lines with 2 M's and 2 empty squares as preferred (value 1/8), on second pass selects first such line for move; on first pass selects any line with 4 tagged empty squares or 1 M and 3 empty squares for move
    //1030-1190 - defensive tagging - tag empty squares in lines with 2 Y's and 2 empty squares as preferred (value 1/8), on second pass selects first such line for move; on first pass selects any line with 4 tagged empty squares or 1 Y and 3 empty squares for move
    //2230-2350 - selects move from second pass of offensive and defensive tag; fallthrough to 2340 concedes game, which should not happen
    //2360-2480 - selects move from first pass of offensive and defensive tag
    //1830-1960 - if no move from offensive/defensive tag, evaluates lines for move based summing values of 4 adjacent lines; fallthrough to line 1950, which resets the tagged empty spaces to zero via 2500 and then jumps to set moves via 1200
    //1200-1280 - selects first empty square from preferred squares in array Y[]
    //1720-1810 - if no preferred empty squares are available, selects first empty square; if none available fallthrough to draw
    //2500-2540 - clears tagged empty spaces
    private func computerMove(board: Board) -> Int? {
        var board = board
        var indexedLines = board.scalarIndexedLines
        
        //790-1490 offense - check for line with 3 M's and empty square for win
        if let indexedLine = indexedLines.first(where: { indexedLine in Board.value(for: indexedLine) == 15 }),
           let scalar = indexedLine.first(where: { $0.square.isEmpty })?.scalar {
            let winningNumbers = indexedLine.map { $0.scalar }
            println("Machine moves to \(scalar), and wins as follows")
            println(winningNumbers.map { " \($0) "}.joined())
            return scalar
        }
        
        //930-1010 defense - check for line with 3 Y's  and empty square for block
        if let indexedLine = indexedLines.first(where: { indexedLine in Board.value(for: indexedLine) == 3 }),
           let scalar = indexedLine.first(where: { $0.square.isEmpty })?.scalar {
            println("Nice try. Machine moves to \(scalar)")
            return scalar
        }
        
        //1300-1480 offensive tagging of lines with 2 M's, 2 empty squares
        //Lines are interated and dynamically updated on each iteration via line 1320 - this may obviate need to mutate board spaces?
        for index in board.scalarIndexedLines.indices {
            let indexedLine = board.scalarIndexedLines[index]  //Dynamic calculation of values, via tagging of empty spaces and mutation of board on each iteration
            let value = Board.value(for: indexedLine)
            if value == 10 {
                //1370-1400 tag empty squares in line
                indexedLine.forEach {
                    if board[$0.scalar] == .empty(0) { board[$0.scalar] = .empty(1/8) }
                }
            } else if value > 10 && value < 11 {
                //2230-2350 - select move from row with 2 M's and 1-2 preferred empty spaces
                guard let scalar = indexedLine.first(where: { $0.square == .empty(1/8) })?.scalar else {
                    //2340 fallthrough - should not occur?
                    println("Machine concedes this game.")
                    end()
                }
                println("Let's see you get out of this:  machine moves to \(scalar)")
                return scalar
            }
        }
        
        //Fallthrough, iterate over lines after taggin, and select first line with 4 preferred empty spaces or 1 M and 3 preferred spaces
        indexedLines = board.scalarIndexedLines
        for (index, indexedLine) in indexedLines.enumerated() {
            let value = Board.value(for: indexedLine)
            if value == 0.5 || value == 5 + 3/8 {
                //2360-2480 select move from line
                //2370-2400 select open preferred edge (A=2) or central empty square (A=1) depending if line is edge or central?
                let targetLineIndexes = (index + 1) % 4 > 1 ? [1, 2] : [0, 3]
                for lineIndex in targetLineIndexes {
                    if indexedLine[lineIndex].square == .empty(1/8) {
                        println("Machine likes \(indexedLine[lineIndex].scalar)")
                        return indexedLine[lineIndex].scalar
                    }
                }
            }
        }
        
        board.clearTaggedEmptySquares()  //1470
        
        //1030-1190 defensive tagging of lines with 2 Y's, 2 empty squares
        //Lines are interated and dynamically updated on each iteration via line 1320 - this may obviate need to mutate board spaces?
        for index in board.scalarIndexedLines.indices {
            let indexedLine = board.scalarIndexedLines[index]  //Dynamic calculation of values, via tagging of empty spaces and mutation of board on each iteration
            let value = Board.value(for: indexedLine)
            if value == 2 {
                //1370-1400 tag empty squares in line
                indexedLine.forEach {
                    if board[$0.0] == .empty(0) { board[$0.0] = .empty(1/8) }
                }
            } else if value > 2 && value < 3 {
                //2230-2350 - select blocking move from row with 2 Y's and 1-2 preferred empty spaces
                guard let scalar = indexedLine.first(where: { $0.1 == .empty(1/8) })?.0 else {
                    //2340 fallthrough - should not occur?
                    println("Machine concedes this game.")
                    end()
                }
                println("You fox.  Just in nick of time, machine moves to \(scalar)")
                return scalar
            }
        }
        
        //Fallthrough, iterate over lines after taggin, and select first line with 4 preferred empty spaces or 1 M and 3 preferred spaces
        indexedLines = board.scalarIndexedLines
        for (index, indexedLine) in indexedLines.enumerated() {
            let value = Board.value(for: indexedLine)
            if value == 0.5 || value == 1 + 3/8 {
                //2360-2480 select move from line
                //2370-2400 select open preferred edge (A=2) or central empty square (A=1) depending if line is edge or central?
                let targetLineIndexes = (index + 1) % 4 > 1 ? [1, 2] : [0, 3]
                for lineIndex in targetLineIndexes {
                    if indexedLine[lineIndex].square == .empty(1/8) {
                        println("Machine likes \(indexedLine[lineIndex].scalar)")
                        return indexedLine[lineIndex].scalar
                    }
                }
            }
        }

        //1830-1960 fallthrough, evaluates for move by summing 4 adjacent lines; selects move only if value == 4..<5 or 9..<10
        //TODO: Implement 1830-1960, 1970-2020
        
        //If no selection from 1830-1960, tagged empty spaces are cleared, and move is selected from set values or first empty square
        board.clearTaggedEmptySquares()
        
        //1200-1280 - selects first empty square from preferred squares in array Y[]
        //Preferred squares - 8 corner squares, followed 4 central squares
        let preferredIndexes = [1, 49, 52, 4, 13, 61, 64, 16, 22, 39, 23, 38, 26, 42, 27, 43]
        for index in preferredIndexes {
            let scalar = Board.scalar(for: index)
            if board[scalar].isEmpty {
                println("Machine moves to \(scalar)")
                return scalar
            }
        }
        
        //1720-1810 - if no preferred empty squares are available, selects first empty square
        for index in 1...64 {
            let scalar = Board.scalar(for: index)
            if board[scalar].isEmpty {
                println("Machine likes \(scalar)")
                return scalar
            }
        }
        
        //1810 Fallthrough - no empty spaces available
        return nil
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
