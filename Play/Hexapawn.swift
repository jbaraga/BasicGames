//
//  Hexapawn.swift
//  play
//
//  Created by Joseph Baraga on 2/10/25.
//

import Foundation

class Hexapawn: BasicGame {
    
    private enum Player {
        case user, computer
        
        var square: Square { self == .user ? .o : .x }
        var other: Player { self == .user ? .computer : .user }
    }
    
    private enum Square: Int, CustomStringConvertible {
        case o = 1  //User
        case x = -1  //Computer
        case empty = 0
        
        var description: String {
            switch self {
            case .o: return "O"
            case .x: return "X"
            case .empty: return "."
            }
        }
    }
    
    private struct Board {
        private var s = Array(repeating: Square.empty, count: 9)
        
        var rows: [[Square]] {
            return Array(0...2).map { Array(s[($0 * 3)..<($0 * 3 + 3)]) }
        }
        
        var pattern: [Int] { s.map { $0.rawValue } }
        var patternFlipped: [Int] { ((rows.map { $0.reversed() }).joined()).map { $0.rawValue } }
        
        //210-223 user wins, 641 computer win
        var winner: Player? {
            if let row = self.rows.first, row.contains(Player.user.square) { return .user }
            if !self.contains(Player.computer.square) { return .user }
            
            if let row = self.rows.last, row.contains(Player.computer.square) { return .computer }
            if !self.contains(Player.user.square) { return .computer }

            return nil
        }
        
        init() {
            (1...3).forEach { self[$0] = .x }
            (7...9).forEach { self[$0] = .o }
        }
        
        init(array: [Int]) {
            self.s = array.compactMap { Square(rawValue: $0) }
        }
        
        subscript(_ x: Int) -> Square {
            get { s[(x - 1)] }
            set { s[(x - 1)] = newValue }
        }
        
        func contains(_ square: Square) -> Bool {
            return s.contains(square)
        }
        
        func isCoordinateLegal(from index1: Int, to index2: Int) -> Bool {
            return (1...9).contains(index1) && (1...9).contains(index2)
        }
        
        func isMoveValid(player: Player, from index1: Int, to index2: Int) -> Bool {
            guard self[index1] == player.square else { return false }
            
            let allowedRowChange = player == .user ? -1 : 1
            guard (index2 - 1) / 3 - (index1 - 1) / 3 == allowedRowChange else { return false }
            
            switch self[index2] {
            case .empty:
                return (index2 % 3) == (index1 % 3)  //Same column
            case player.other.square:
                return abs(((index2 - 1) % 3) - ((index1 - 1) % 3)) == 1  //Diagonal
            default:
                return false
            }
        }
        
        //230-340, 650-810 for user
        func isMoveAvailable(player: Player) -> Bool {
            switch player {
            case .user:
                for index1 in 4...9 {
                    for index2 in 1...6 {
                        if isMoveValid(player: player, from: index1, to: index2) { return true }
                    }
                }
                return false
                
            case .computer:
                for index1 in 1...6 {
                    for index2 in 4...9 {
                        if isMoveValid(player: player, from: index1, to: index2) { return true }
                    }
                }
                return false
            }
        }
        
        mutating func move(player: Player, from index1: Int, to index2: Int) {
            self[index1] = .empty
            self[index2] = player.square
        }
    }
    
    private struct MoveMatrix {
        private var m: [[Int]]
        private let b: [[Int]]  //b + b.rows.reversed == all posssible board patterns
        
        var x = 0
        var y = 0
        
        init() {
            var array = [[Int]]()
            array.append([24,25,36,00])
            array.append([14,15,36,00])
            array.append([15,35,36,47])
            array.append([36,58,59,00])
            array.append([15,35,36,00])
            array.append([24,25,26,00])
            array.append([26,57,58,00])
            array.append([26,35,00,00])
            array.append([47,48,00,00])
            array.append([35,36,00,00])
            array.append([35,36,00,00])
            array.append([36,00,00,00])
            array.append([47,58,00,00])
            array.append([15,00,00,00])
            array.append([26,47,00,00])
            array.append([47,58,00,00])
            array.append([35,36,47,00])
            array.append([28,58,00,00])
            array.append([15,47,00,00])
            self.m = array
            
            array = []
            array.append([-1,-1,-1,1,0,0,0,1,1])
            array.append([-1,-1,-1,0,1,0,1,0,1])
            array.append([-1,0,-1,-1,1,0,0,0,1])
            array.append([0,-1,-1,1,-1,0,0,0,1])
            array.append([-1,0,-1,1,1,0,0,1,0])
            array.append([-1,-1,0,1,0,1,0,0,1])
            array.append([0,-1,-1,0,-1,1,1,0,0])
            array.append([0,-1,-1,-1,1,1,1,0,0])
            array.append([-1,0,-1,-1,0,1,0,1,0])
            array.append([0,-1,-1,0,1,0,0,0,1])
            array.append([0,-1,-1,0,1,0,1,0,0])
            array.append([-1,0,-1,1,0,0,0,0,1])
            array.append([0,0,-1,-1,-1,1,0,0,0])
            array.append([-1,0,0,1,1,1,0,0,0])
            array.append([0,-1,0,-1,1,1,0,0,0])
            array.append([-1,0,0,-1,-1,1,0,0,0])
            array.append([0,0,-1,-1,1,0,0,0,0])
            array.append([0,-1,0,1,-1,0,0,0,0])
            array.append([-1,0,0,-1,1,0,0,0,0])
            self.b = array
        }
        
        /*
         Half of possible board patterns (s array as rawValues) are contained in b array, other half are these patterns flipped horizontally, i.e. each entry row of b reversed (created in the T array row by row). The m array is indexed by the matching pattern index, and encodes the possible moves as from = tens digit, to = ones digit for forward matching pattern; and from = fnr(tens digit), to = fnr(ones digit) for reversed pattern, with the fnr function mirroring the indexes horizontally.
         Each row of m contains possible moves for given pattern, move is selected randomly from the non-zero moves; if the last move results in loss, that move option is removed (zeroed) i.e. machine learning.
         */
        mutating func move(for board: Board) -> Coordinate? {
            if let x = b.firstIndex(of: board.pattern) {
                self.x = x
                guard let y = (m[x].indices.filter { m[x,$0] != 0 }).randomElement() else {
                    return Coordinate(index1: -1, index2: -1)
                }
                self.y = y
                return Coordinate(index1: m[x,y] / 10, index2: fnm(m[x,y]))
            }
            
            if let x = b.firstIndex(of: board.patternFlipped) {
                self.x = x
                guard let y = (m[x].indices.filter { m[x,$0] != 0 }).randomElement() else {
                    return Coordinate(index1: -1, index2: -1)
                }
                self.y = y
                return Coordinate(index1: fnr(m[x,y] / 10), index2: fnr(fnm(m[x,y])))
            }
            
            //Fallthrough
            //511 REMEMBER THE TERMINATION OF THIS LOOP IS IMPOSSIBLE
            return nil
        }
        
        mutating func updateForLoss() {
            m[x,y] = 0
        }
        
        private func fnr(_ x: Int) -> Int {
            switch x {
            case 1: return 3
            case 3: return 1
            case 4: return 6
            case 6: return 4
            case 7: return 9
            case 9: return 7
            case 2, 5, 8: return x
            default: fatalError(#function + " invalid x \(x)")
            }
        }
        
        private func fns(_ x: Int) -> Int {
            switch x {
            case 2, 5, 8: return x
            default: return 0
            }
        }
        
        private func fnm(_ y: Int) -> Int {
            return y - (y / 10) * 10  //Returns the unit digit
        }
        
        func test() {
            let boards = b.map { Board(array: $0) }
            for index in 0...2 {
                Swift.print((boards.map { $0.rows[index].reduce("") { $0 + "\($1)" }}).joined(separator: "   "))
            }
        }
    }
    
    func run() {
        printHeader(title: "Hexapawn")
        
        //4 REM  HEXAPAWN:  INTERPRETATION OF HEXAPAWN GAME AS PRESENTED IN
        //5 REM  MARTIN GARDNER'S "THE UNEXPECTED HANGING AND OTHERR MATHEMATIC-
        //6 REM  AL DIVERSIONS", CHAPTER EIGHT:  A MATCHBOX GAME-LEARNING MACHINE
        //7 REM  ORIGINAL VERSION FOR H-P TIMESHARE SYSTEM BY R. A. KAAPKE 5/5/76
        //8 REM  INSTRUCTIONS BY JEFF DALTON
        //9 REM  CONVERSION TO MITS BASIC BY STEVE NORTH
        
        promptForInstructions()
        play()
    }
    
    private func play() {
        var moveMatrix = MoveMatrix()
        var userWins = 0
        var computerWins = 0
        
        repeat {
            var board = Board()  //111-115
            var winner: Player?
            print(board: board)
            repeat {
                let move = getUserMove(board: board)
                board.move(player: .user, from: move.index1, to: move.index2)
                print(board: board)
                
                if let userWinner = board.winner, userWinner == .user {
                    winner = userWinner
                    break
                }
                
                guard board.isMoveAvailable(player: .computer) else {
                    winner = .user
                    break
                }
                
                //Computer move
                guard let computerMove = moveMatrix.move(for: board) else {
                    println("Illegal board pattern.")
                    end()
                }
                
                if computerMove.index1 < 0 {
                    println("I resign.")
                    winner = .user
                }
                
                println("I move from  \(computerMove.index1) to  \(computerMove.index2)")
                board.move(player: .computer, from: computerMove.index1, to: computerMove.index2)
                print(board: board)
                
                if let computer = board.winner, computer == .computer {
                    winner = .computer
                    break
                }
                
                guard board.isMoveAvailable(player: .user) else {
                    print("You can't move, so ")
                    winner = .computer
                    break
                }
            } while winner == nil
            
            guard let winner else { fatalError("No winner") }
            
            switch winner {
            case .user:
                println("You win.")
                userWins += 1
                moveMatrix.updateForLoss()
                if userWins > 5, userWins > computerWins { unlockEasterEgg(.hexapawn) }
            case .computer:
                println("I win.")
                computerWins += 1
            }
            
            println("I have won \(computerWins) and you \(userWins) out of \(computerWins + userWins) games.")
        } while true
    }
    
    //120-186
    private func getUserMove(board: Board) -> Coordinate {
        guard let coordinate = Coordinate(input("Your move")), board.isCoordinateLegal(from: coordinate.index1, to: coordinate.index2) else {
            println("Illegal co-ordinates.")
            return getUserMove(board: board)
        }
        
        guard board.isMoveValid(player: .user, from: coordinate.index1, to: coordinate.index2) else {
            println("Illegal move.")
            return getUserMove(board: board)
        }
        
        return coordinate
    }
    
    //1000-1080
    private func print(board: Board) {
        println()
        for row in board.rows {
            println(tab(10), row.reduce("") { $0 + "\($1)" })
        }
        println()
    }
    
    private func promptForInstructions() {
        switch Response(input("Instructions (y-n)")) {
        case .yes: printInstructions()
        case .no: return
        case .other: promptForInstructions()
        }
    }
    
    //2000-2220
    private func printInstructions() {
        println()
        println("This program plays the game of Hexapawn.")
        println("Hexapawn is played with chess pawns on a 3 by 3 board.")
        println("The pawns are moved as in chess - one space forward and diagonally to")
        println("capture an opposing man.  On the board, your pawns")
        println("are 'O', the computer's pawns are 'X', and empty ")
        println("squares are '.'.  To enter a move, type the number of")
        println("the square you are moving from, followed by the number")
        println("of the square you will move to.  The numbers must be")
        println("separated by a comma.")
        println()
        println("The computer starts a series of games knowing only when")
        println("the game is won (a draw is impossible) and how to move.")  //Missing from the code, present in the output
        println("It has no strategy at first and just moves randomly.")
        println("However, it learns from each game.  Thus, it becomes")
        println("more and more difficult.  Also, to help offset your")
        println("initial advantage, you will not be told how to win the")
        println("game but must learn this by playing.")
        println()
        println("The numbering of the board is as follows:")
        println(tab(10), "123")
        println(tab(10), "456")
        println(tab(10), "789")
        println()
        println("For example, to move your rightmost pawn forward")
        println("you would type 9,6 in response to the question")
        println("'Your move ?'.  Since I'm a good sport, you'll always")
        println("go first.")
        println()
    }
    
    func test() {
        MoveMatrix().test()
    }
}


private struct Coordinate: Equatable {
    let index1: Int  //from
    let index2: Int  //to
}

extension Coordinate: LosslessStringConvertible {
    var description: String { "\(index1) to \(index2)" }
    
    init?(_ description: String) {
        let stringValues = description.components(separatedBy: CharacterSet(charactersIn: " ,")).compactMap { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        guard stringValues.count == 2, let index1 = Int(stringValues[0]), let index2 = Int(stringValues[1]) else { return nil }
        self.init(index1: index1, index2: index2)
    }
}
