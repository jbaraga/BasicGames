//
//  Checkers.swift
//  Checkers
//
//  Created by Joseph Baraga on 1/4/24.
//

import Foundation


fileprivate typealias Board = [[Piece]]

class Checkers: GameProtocol {
    
    private var board = Board()  //S
    
    func run() {
        printHeader(title: "Checkers")
        println("This is the game of Checkers.  The computer is X,")
        println("and you are O.  The computer will move first.")
        println("Squares are referred to by a coordinate system.")
        println("(0,0) is the lower left corner")
        println("(0,7) is the upper left corner")
        println("(7,0) is the lower right corner")
        println("(7,7) is the upper right corner")
        println("The computer will type '+to' when you have another ")
        println("jump.  Type two negative numbers when you cannot jump.")
        println(3)
        
        board = setupBoard()
        wait(.short)
        
        while let (fromSquare, toSquare) = getComputerMove() {
            print(chr$(30) + "From \(fromSquare.stringValue) To \(toSquare.stringValue)")
            moveComputer(from: fromSquare, to: toSquare)
            printBoard()
            wait(.short)
            
            //Lines 1552-1570 - test for end
            let computerPieces = (board.reduce([], { $0 + $1 })).filter { $0.isX }
            if computerPieces.count == 0 { gameover(isUserWinner: true) }
            let userPieces = (board.reduce([], { $0 + $1 })).filter { $0.isO }
            if userPieces.count == 0 { gameover(isUserWinner: false) }
            
            let square1 = getFrom()  //E,H
            let square2 = getTo(from: square1)  //A,B
            moveUser(from: square1, to: square2)
        }
        
        gameover(isUserWinner: true)
    }
    
    //Lines 1880-1885
    private func gameover(isUserWinner: Bool) {
        println()
        println((isUserWinner ? "You" : "I") + "win.")
        
        if isUserWinner { unlockEasterEgg(.checkers) }
        end()
    }
    
    //Lines 90-200
    private func setupBoard() -> Board {
        var board = dim(2, 8, value: Piece.none)
        var row: [Piece] = [.oMan, .none, .oMan, .none, .oMan, .none, .oMan, .none]
        for _ in 0...2 {
            board.insert(row, at: 0)
            row.append(row.removeFirst())
            board.append(row.map { -$0})
        }
        return board
    }
    
    //Lines 230-1100 computer move. Returns nil if no move available [R(0)=99]
    private func getComputerMove() -> (from: Square, to: Square)? {
        var score = -99  // [R(0)]
        var fromSquare = Square()
        var toSquare = Square()
        
        for x in 0...7 {
            for y in 0...7 {
                let square = Square(x: x, y: y)
                var squares = [Square]()
                switch board[square] {
                case .xMan:
                    squares = [Square(x: x-1, y: y-1), Square(x: x+1, y: y-1)].filter { !$0.isOff }
                case .xKing:
                    squares = [Square(x: x-1, y: y-1), Square(x: x-1, y: y+1), Square(x: x+1, y: y-1), Square(x: x+1, y: y+1)].filter { !$0.isOff }
                default:
                    break
                }
                
                squares.forEach {
                    let (q, destination) = scoreMove(from: square, to: $0)
                    if q > score {
                        score = q
                        fromSquare = square
                        toSquare = destination
                    }
                }

            }
        }
        
        return score > -99 ? (fromSquare, toSquare) : nil
        
    }
    
    //Lines 650-870 - score move from square1 to square2; returns new square2 if move is a jump
    private func scoreMove(from square1: Square, to square2: Square) -> (score: Int, tosquare: Square) {
        //U = square2.x, V = square2.y
        switch board[square2] {
        case .xMan, .xKing: return (-99, square2)  //square2 occupied by friendly
        case .none:
            return (getScoreForMove(from: square1, to: square2), square2)  //evaluate move to open square
        case .oMan, .oKing:
            //evaluate for jump
            let jumpsquare = Square(x: square2.x + (square2.x - square1.x), y: square2.y + (square2.y - square1.y))
            if jumpsquare.isOff { return (-99, square2) }
            return (getScoreForMove(from: square1, to: jumpsquare), jumpsquare)
        }
    }
    
    //Lines 910-1100
    private func getScoreForMove(from square1: Square, to square2: Square) -> Int {
        var q = 0
        if square2.y == 0 && board[square1] == .xMan { q += 2 }  //Increase score 2 move to bottom
        if abs(square1.y - square2.y) == 2 { q += 5 }  //Increase score 5 for jump to square2
        if square1.y == 7 { q -= 2 }  //Decrease score 2 for move from bottom edge
        if square2.x == 0 || square2.x == 7 { q += 1 }  //Increase score 1 for move to right or left edge
        
        //Lines 1030-1080 - check squares in row below and adjacent to square2
        let squares = [Square(x: square2.x - 1, y: square2.y - 1), Square(x: square2.x + 1, y: square2.y - 1)].filter { !$0.isOff }
        squares.forEach { square in
            if board[square].isX {
                q += 1  //Increase score 1 if adjacent square contains friendly
            } else {
                //Check for enemy jump block
                let backSquare = Square(x: square2.x - (square.x - square2.x), y: square2.y - (square.y - square2.y))
                if backSquare.isOn {
                    if board[square].isO && (board[backSquare].isOpen || backSquare == square1) {
                        q -= 2  //Decrease score if backsquare is open
                    }
                }
            }
        }
        return q
    }
    
    //Lines 1230-1400
    private func moveComputer(from square1: Square, to square2: Square) {
        if square2.y == 0 {
            board[square2] = .xKing
//            return  //Bug - if result of jump, user chip not removed
        } else {
            board[square2] = board[square1]
        }
        
        board[square1] = .none
        
        //Test for jump
        if abs(square1.x - square2.x) == 2 {
            let jumpedsquare = Square(x: (square1.x + square2.x) / 2, y: (square1.y + square2.y) / 2)
            board[jumpedsquare] = .none
            
            //Look for second jump
            var squares = [Square]()
            switch board[square2] {
            case .xMan:
                squares = [Square(x: square2.x-2, y: square2.y-2), Square(x: square2.x+2, y: square2.y-2)].filter { !$0.isOff }
            case .xKing:
                squares = [Square(x: square2.x-2, y: square2.y-2), Square(x: square2.x-2, y: square2.y+2), Square(x: square2.x+2, y: square2.y-2), Square(x: square2.x+1, y: square2.y+1)].filter { !$0.isOff }
            default:
                return
            }
            
            var score = -99
            var square3 = Square()
            squares.forEach { square in
                let jumpedSquare = Square(x: (square.x + square2.x) / 2, y: (square.y + square2.y) / 2)
                if board[square].isOpen && board[jumpedSquare].isO {
                    let q = getScoreForMove(from: square2, to: square)
                    if q > score {
                        square3 = square
                        score = q
                    }
                }
            }
            if score > -99 {
                print(" To \(square3.stringValue)")
                moveComputer(from: square2, to: square3)
            }
        }
    }
    
    //Lines 1700-1810
    private func moveUser(from square1: Square, to square2: Square) {
        board[square2] = board[square1]
        board[square1] = .none
        if abs(square1.x - square2.x) == 2 {
            //Jump
            let jumpedSquare = Square(x: (square1.x + square2.x) / 2, y: (square1.y + square2.y) / 2)
            board[jumpedSquare] = .none
            if let square3 = getJumpTo(from: square2) { moveUser(from: square2, to: square3) }
        }
        
        if square2.y == 7 { board[square1] = .oKing }
    }
    
    //Lines 1420-1550
    private func printBoard() {
        println(3)
        board.reversed().forEach { row in
            row.enumerated().forEach { index, piece in
                print(tab(5 * index))
                print(piece)
            }
            println(2)
        }
        println()
    }
    
    //Line 1590
    private func getFrom() -> Square {
        guard let square = Square(input("From")), square.isOn, board[square].isO else {
            return getFrom()
        }
        return square
    }
    
    //Lines 1670-1690
    private func getTo(from square1: Square) -> Square {
        guard let square2 = Square(input("To")), square2.isOn, board[square2].isOpen, abs(square2.x - square1.x) <= 2, abs(square2.x - square1.x) == abs(square2.y - square1.y) else {
            print(chr$(7) + chr$(11))
            return getTo(from: square1)
        }
        return square2
    }
    
    //Lines 1802-1804
    private func getJumpTo(from square1: Square) -> Square? {
        guard let square2 = Square(input("+To")) else { return getJumpTo(from: square1) }
        if square2.x < 0 { return nil }
        guard square2.isOn, board[square2].isOpen, abs(square2.x - square1.x) == 2, abs(square2.y - square1.y) == 2 else {
            return getJumpTo(from: square1)
        }
        return square2
    }
}

fileprivate enum Piece: CustomStringConvertible {
    case xMan
    case xKing
    case oMan
    case oKing
    case none
    
    var description: String {
        switch self {
        case .xMan: return "X"
        case .xKing: return "X*"
        case .oMan: return "O"
        case .oKing: return "O*"
        case .none: return "."
        }
    }
    
    var isX: Bool { self == .xMan || self == .xKing }
    var isO: Bool { self == .oMan || self == .oKing }
    var isOpen: Bool { self == .none }
}

fileprivate prefix func -(_ piece: Piece)  -> Piece {
    switch piece {
    case .xMan: return .oMan
    case .xKing: return .oKing
    case .oMan: return .xMan
    case .oKing: return .xKing
    case .none: return .none
    }
}

fileprivate struct Square {
    var x = 0
    var y = 0
    
    var isOff: Bool {
        return x < 0 || x > 7 || y < 0 || y > 7
    }
    
    var isOn: Bool { !isOff }
    
    var stringValue: String { "\(x)  \(y)" }  //Columns and rows are transposed
}

extension Square: Equatable {}

extension Square: LosslessStringConvertible {
    var description: String { stringValue }
    
    init?(_ string: String) {
        let numbers = string.components(separatedBy: CharacterSet(charactersIn: " ,")).compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
        guard numbers.count == 2 else { return nil }
        self.init(x: numbers[0], y: numbers[1])
    }
}

//Transposed indexing to match S(X,Y) - x == column, y == row
fileprivate extension Array where Element == [Piece] {
    subscript(index: Square) -> Element.Element {
        get {
            return self[index.y][index.x]
        }
        set {
            self[index.y][index.x] = newValue
        }
    }
}

