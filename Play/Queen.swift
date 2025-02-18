//
//  Queen.swift
//  play
//
//  Created by Joseph Baraga on 2/13/25.
//

import Foundation

class Queen: BasicGame {
    
    private struct Board {
        var queenPosition = 0
        
        var isGameOver: Bool { queenPosition == 158 }
                
        static var indexesByRow: [[Int]] {
            (0...7).reduce(into: [[Int]]()) { array, row in
                let columns = (0...7).map { (row + 1) * 11 + $0 * 10 }
                array.append(columns.reversed())
            }
        }
        
        static var indexes: [Int] { Self.indexesByRow.reduce([Int](), +) }
        
        //120-150
        //Invalid large positions or negative positions are not checked
        static func isValidStart(position: Int) -> Bool {
            return (position - 11) % 10 == 0 || (position - 11) % 11 == 0
            
            /*Original code method
            let t1 = position / 10
            let u1 = position - 10 * t1
            return u1 == 1 || u1 == t1
             */
        }
        
        //231-300
        // position / 10 = tens digit
        // position % 10 = ones digit =  row, 1 indexed
        // Moves to invalid indexes > 158 are not prevented
        func isValid(moveTo position: Int) -> Bool {
            //Streamlined version
            let delta = position - queenPosition
            guard delta > 0 else { return false }
            if delta % 10 == 0 { return true }  //Left
            if delta % 11 == 0 { return true }  //Down
            if delta % 21 == 0 { return true }  //Diagonally down and left
            return false
            
            /*Original code method
            guard position > queenPosition else { return false }  //239 - must move left and/or down
            let tens1 = position / 10  //column + (row - 1), 1 indexed == position tens digit
            let unit1 = position % 10  //row, 1 indexed == position ones digit
            let tens = queenPosition / 10
            let units = queenPosition % 10
            let deltaRows = unit1 - units  //P = delta rows
            let delta = tens1 - tens  //L = delta columns + delta rows
            if deltaRows == 0 {
                return delta > 0  //280-290 - must move to left (higher column)
            } else {
                return delta == deltaRows || delta == 2 * deltaRows  //300-330 - move down or diagonally down and left
            }
             */
        }
        
        //2000-3140
        func getComputerMove() -> Int {
            //1990 REM     LOCATE MOVE FOR COMPUTER
            let preferredPositions = [158,127,126,75,73]  //Move to one of these positions guarantees computer win
            
            //Streamlined method
            for move in preferredPositions {
                if isValid(moveTo: move) { return move }
            }
            
            return getRandomMove()
            
            /*Original code method
            //If already placed in a preferred position by user, or in start position 41 or 44 - which guarantees user win if properly played; this could be skipped, as if the queen is in this position, a move to a preferred position is not possible, and fall through to random result will occur
            if [41,44,73,75,126,127].contains(queenPosition) {
                return getRandomMove()  //2180 GOSUB 3000
            }
            
            //2065-2150, 3500-3580
            // moves:
            //  increment tens and ones by k - move down k rows
            //  increment tens by k - move left k columns
            //  increment tens by 2k and ones by k - move diagonally down and left by k rows and k columns
            let units1 = queenPosition % 10  //row, 1 indexed == index tens digit
            let tens1 = queenPosition / 10  //column + (row - 1), 1 indexed == index ones digit
            //Search for longest valid move to preferred position
            for k in stride(from: 7, through: 1, by: -1) {
                var move = 10 * (tens1 + k) + units1  //Move left
                if preferredPositions.contains(move) { return move }
                move = 10 * (tens1 + k) + units1 + k  //Move down
                if preferredPositions.contains(move) { return move }
                move = 10 * (tens1 + k + k) + units1 + k  //Move diagonally
                if preferredPositions.contains(move) { return move }
            }
            */
        }
        
        //3000-3140
        private func getRandomMove() -> Int {
            //2990 REM     RANDOM MOVE
            let z = Double.random(in: 0..<1)
            if z > 0.6 {
                return queenPosition + 11  //3110 move down 1
            } else if z > 0.3 {
                return queenPosition + 21  //3070 move diagonally down and left 1
            } else {
                return queenPosition + 10  //3030 move left 1
            }

            /*Original code method
            let u1 = queenPosition % 10  //index tens digit = row, 1 indexed
            let t1 = queenPosition / 10  //index ones digit = column + (row - 1), 1 indexed
            if z > 0.6 {
                return 10 * (t1 + 1) + u1 + 1  //3110 move down 1
            } else if z > 0.3 {
                return 10 * (t1 + 2) + u1 + 1  //3070 move diagonally down and left 1
            } else {
                return 10 * (t1 + 1) + u1  //3030 move left 1
            }
             */
        }
   }
    
    func run() {
        printHeader(title: "Queen")
        promptForInstructions()
        printBoardLayout()
        
        repeat {
            play()
        } while playAgain() == .yes
                    
        println("OK --- thanks again.")
        end()
    }
    
    private func play() {
        var board = Board()
        var userMove = getStartingPosition()  //M1
        
        repeat {
            if userMove == 0 {
                println()
                println("It looks like I have won by forfeit.")
                println()
                return
            }
            
            board.queenPosition = userMove
            if board.isGameOver {
                //3290 REM     PLAYER WINS
                println()
                println("C o n g r a t u l a t i o n s . . .")
                println("You have won--very well played.")
                println("It looks like I have met my match.")
                println("Thanks for playing---I can't win all the time.")
                println()
                unlockEasterEgg(.queen)
                return
            }
            
            let computerMove = board.getComputerMove()  //M
            println("Computer moves to square \(computerMove)")
            board.queenPosition = computerMove
            
            if board.isGameOver {
                //3390 REM     COMPUTER WINS
                println()
                println("Nice try, but it looks like I have won.")
                println("Thanks for playing.")
                println()
                return
            }
            
            print("What is your move")
            userMove = getUserMove(board: board)
        } while !board.isGameOver
    }
    
    private func promptForInstructions() {
        switch Response(input("Do you want instructions")) {
        case .other(_):
            println("Please answer 'yes' or 'no'.")
            promptForInstructions()
        case .no:
            return
        case .yes:
            printInstructions()
        }
    }
    
    //100-180
    private func getStartingPosition() -> Int {
        //90 REM     ERROR CHECKS
        guard let m1 = Int(input("Where would you like to start")), (m1 == 0 || Board.isValidStart(position: m1)) else {
            println("Please read the directions again.")
            println("You have begun illegally.")
            return getStartingPosition()
        }
        return m1
    }
    
    //220-330
    private func getUserMove(board: Board) -> Int {
        guard let m1 = Int(input()), m1 == 0 || board.isValid(moveTo: m1) else {
            //3190 REM     ILLEGAL MOVE MESSAGE
            println()
            print("Y o u   c h e a t . . .  Try again")
            return getUserMove(board: board)
        }
        return m1
    }
        
    //4000-4050
    private func playAgain() -> Response {
        //3990 REM     ANOTHER GAME??
        let response = Response(input("Anyone else care to try"))
        if response.isOther {
            println("Please answer 'yes' or 'no'.")
            return playAgain()
        }
        return response
    }
    
    //5000-5140
    private func printInstructions() {
        //4990 REM     DIRECTIONS
        println("We are going to play a game based on one of the chess")
        println("moves.  Our queen will be able to move only to the left,")
        println("down, or diagonally down and to the left.")
        println()
        println("The object of the game is to place the queen in the lower")
        println("left hand square by alternating moves between you and the")
        println("computer.  The first one to place the queen there wins.")
        println()
        println("You go first and place the queen in any one of the squares")
        println("on the top row or right hand column.")
        println("That will be your first move.")
        println("We alternate moves.")
        println("You may forfeit by typing '0' as your move.")
        println("Be sure to press the return key after each response.")
        println()
    }
    
    //5150-5260
    private func printBoardLayout() {
        println(2)
        Board.indexesByRow.forEach { row in
            println((row.map { " \($0) " }).joined())
            println(2)
        }
        println()
    }
}
