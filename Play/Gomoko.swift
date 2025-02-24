//
//  Gomoko.swift
//  play
//
//  Created by Joseph Baraga on 1/16/25.
//

import Foundation

class Gomoko: BasicGame {
    
    private enum Player: Int {
        case user = 1
        case computer
        
        var other: Player { return self == .user ? .computer : .user }
        var fiveInRow: [Int] { return [Int](repeating: self.rawValue, count: 5) }
    }
    
    private struct Board {
        let size: Int
        private var matrix: Matrix<Int>
        
        var rowDescriptions: [String] {
            matrix.rows.map { ($0.map { " \($0) " }).joined() }
        }
        
        init(size: Int) {
            self.size = size
            self.matrix = .init(rows: size, columns: size, value: 0)
        }
        
        //1 indexed
        subscript(_ location: Point) -> Int {
            get { matrix[location.x - 1, location.y - 1] }
            set { matrix[location.x - 1, location.y - 1] = newValue}
        }
        
        //1 indexed location
        func containsSquare(at location: Point) -> Bool {
            let point = Point(location.x - 1, location.y - 1)
            return matrix.isValid(point: point)
        }
        
        //1 indexed location
        func isSquareOpen(at location: Point) -> Bool {
            let point = Point(location.x - 1, location.y - 1)
            return matrix.isValid(point: point) && matrix[point] == 0
        }
        
        //1 indexed location
        mutating func setSquare(at location: Point, to player: Player) {
            let point = Point(location.x - 1, location.y - 1)
            self.matrix[point] = player.rawValue
        }
        
        //Returns 1 indexed location
        func chooseSquare(for player: Player, lastMove: Point) -> Point? {
            //500 REM *** COMPUTER TRIES AN INTELLIGENT MOVE ***
            //Look at squares surrounding lastMove, if two in a row, try to select square opposite the two in a row
            let array = [Int](-1...1)
            let offsets = array.reduce(into: [(x: Int, y: Int)]()) { result, x in result += (array.map { (x, $0) })}
            for (e, f) in offsets {
                let location = Point(x: lastMove.x + e, y: lastMove.y + f)  //presumed bug in original code x += f
                if containsSquare(at: location), self[location] == player.other.rawValue {
                    let oppositeLocation = Point(x: lastMove.x - e, y: lastMove.y - f)
                    if isSquareOpen(at: oppositeLocation) { return oppositeLocation }
                }
            }
            
            //600 REM *** COMPUTER TRIES A RANDOM MOVE ***
            //Original code will result in infinite loop when board is full
            let openSquares = matrix.indexes.filter { matrix[$0] == 0 }
            guard let square = openSquares.randomElement() else { return nil }
            return Point(square.row + 1, square.column + 1)
        }
        
        //Add on
        func winner() -> Player? {
            //Rows
            if (matrix.rows.filter { $0.contains(Player.user.fiveInRow) }).count > 0 { return .user }
            if (matrix.rows.filter { $0.contains(Player.computer.fiveInRow) }).count > 0 { return .computer }
            
            //Columns
            if (matrix.columns.filter { $0.contains(Player.user.fiveInRow) }).count > 0 { return .user }
            if (matrix.columns.filter { $0.contains(Player.computer.fiveInRow) }).count > 0 { return .computer }
            
            //Diagonals
            if (matrix.forwardDiagonals.filter { $0.contains(Player.user.fiveInRow) }).count > 0 { return .user }
            if (matrix.forwardDiagonals.filter { $0.contains(Player.computer.fiveInRow) }).count > 0 { return .computer }
            
            if (matrix.backwardDiagonals.filter { $0.contains(Player.user.fiveInRow) }).count > 0 { return .user }
            if (matrix.backwardDiagonals.filter { $0.contains(Player.computer.fiveInRow) }).count > 0 { return .computer }

            return nil
        }
    }
    
    private let endPoint = Point(-1,-1)

    func run() {
        printHeader(title: "Gomoko")
        println("Welcome to the Oriental game of Gomoko")
        println()
        println("The game is played on an n by n grid of a size")
        println("that you specify.  During your play, you may cover one grid")
        println("intersection with a marker. The object of the game is to get")
        println("5 adjacent markers in a row -- horizontally, vertically, or")
        println("diagonally.  On the board diagram, your moves are marked")
        println("with a '1' and the computer moves with a '2'.")
        println()
        println("The computer does not keep track of who has won.")
        println("To end the game, type -1,-1 for your move.")
        println()
        
        repeat {
            play()
        } while Int(input("Play again (1 for yes, 0 for no)")) ?? 0 == 1
        
        end()
    }
    
    private func play() {
        let size = getSize()
        var board = Board(size: size)
        var isDone = false
        
        println()
        println("We alternate moves.  You go first...")
        println()
        
        repeat {
            let userMove = getMove(board: board)
            isDone = userMove == endPoint
            if !isDone {
                board.setSquare(at: userMove, to: .user)
                if let square = board.chooseSquare(for: .computer, lastMove: userMove) {
                    board.setSquare(at: square, to: .computer)
                }
                
                print(board: board)
            }
            
        } while !isDone
        
        if let winner = board.winner(), winner == .user {
            println("You win!")
            unlockEasterEgg(.gomoko)
        }
                    
        println()
        println("Thanks for the game!!")
    }
    
    private func getSize() -> Int {
        guard let size = Int(input("What is your board size (min 7/ max 19)")), size > 6 && size < 20 else {
            println("I said, the minimum is 7, the maximum is 19.")
            return getSize()
        }
        return size
    }

    private func getMove(board: Board) -> Point {
        guard let location: Point = input("Your play (i,j)"), board.containsSquare(at: location) || location == endPoint else {
            println("Illegal move.  Try again...")
            return getMove(board: board)
        }
        if location == endPoint { return endPoint }
        guard board.isSquareOpen(at: location) else {
            println("Square occupied.  Try again...")
            return getMove(board: board)
        }
        return location
    }
    
    private func print(board: Board) {
        //800 REM *** PRINT THE BOARD ***
        board.rowDescriptions.forEach { println($0) }
        println()
    }
    
    func test() {
        var userWins = 0
        var computerWins = 0
        var noWinner = 0
        var total = 0
        let size = 10
        
        repeat {
            var board = Board(size: size)
            let center = Point((size/2, size/2))
            board.setSquare(at: center, to: .user)
            board.setSquare(at: Point((center.x + 1, center.y)), to: .computer)
            board.setSquare(at: Point((center.x, center.y + 1)), to: .user)
            var lastMove = Point((center.x, center.y + 1))
            var player = Player.computer
            
            while let move = board.chooseSquare(for: player, lastMove: lastMove) {
                board.setSquare(at: move, to: player)
                lastMove = move
                player = player.other
            }
            
            if let winner = board.winner() {
                if winner == .user {
                    userWins += 1
                } else {
                    computerWins += 1
                }
            } else {
                noWinner += 1
            }
            
            total += 1
        } while total < 100
        
        Swift.print("Results: total \(total), userWins \(userWins), computerWins \(computerWins), noWinner \(noWinner)")
    }
}

