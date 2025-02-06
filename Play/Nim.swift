//
//  Nim.swift
//  play
//
//  Created by Joseph Baraga on 1/30/25.
//

import Foundation

class Nim: BasicGame {
    
    private enum WinOption: Int {
        case takeLast = 1, avoidLast
    }
    
    private enum Player {
        case user, computer
        
        var message: String { self == .computer ? "Computer wins" : "Computer loses" }
        
        mutating func next() {
            self = self == .user ? .computer : .user
        }
    }
    
    private struct Move {
        let pileNumber: Int
        let numberToRemove: Int
        
        var index: Int { pileNumber - 1 }
        
        init(pileNumber: Int, numberToRemove: Int) {
            self.pileNumber = pileNumber
            self.numberToRemove = numberToRemove
        }
        
        init?(_ string: String, piles: [Int]) {
            let stringValues = string.components(separatedBy: CharacterSet(charactersIn: " ,")).compactMap { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            guard stringValues.count == 2, let pileNumber = Int(stringValues[0]), piles.indices.contains(pileNumber - 1), let numberToRemove = Int(stringValues[1]), numberToRemove > 0, numberToRemove <= piles[pileNumber - 1] else { return nil }
            self.pileNumber = pileNumber
            self.numberToRemove = numberToRemove
        }
    }
    
    func run() {
        printHeader(title: "Nim")
        println("This is the game of Nim.")
        
        print("Do you want instructions")
        printInstructions()
        
        repeat {
            play()
            print("Do you want to play another game")
        } while playAgain() == .yes
                    
        end()
    }
    
    private func play() {
        println()
        var piles = [Int]()  //A, zero indexed
        
        //450-690 Get setup options
        let winOption = getWinOption()
        let numberOfPiles = getNumberOfPiles()
        
        println("Enter pile sizes")
        for pileNumber in 1...numberOfPiles {
            piles.append(getPileSize(for: pileNumber))
        }
        
        print("Do you want to move first")
        var player = isUserFirst() ? Player.user : .computer  //tracks current turn
        
        //Main loop
        repeat {
            switch player {
            case .computer:
                //700-930
                if winOption == .avoidLast, let winner = checkForWinner(afterMoveBy: .user, winOption: winOption, piles: piles) {
                    println(winner.message)
                    return
                }
                
                piles = computerMove(piles: piles, winOption: winOption)
                print(piles: piles)
                
                if winOption == .takeLast, let winner = checkForWinner(afterMoveBy: player, winOption: winOption, piles: piles) {
                    println(winner.message)
                    return
                }
                
            case .user:
                let move = getUserMove(piles: piles)  //1450
                piles[move.index] -= move.numberToRemove
                
                if winOption == .takeLast, let winner = checkForWinner(afterMoveBy: player, winOption: winOption, piles: piles) {
                    println(winner.message)
                    return
                }
            }
            
            player.next()
        } while (piles.filter { $0 > 0 }).count > 0
        
        fatalError("Invalid fallthrough, no winner detected")
    }
    
    //1450-1520
    private func getUserMove(piles: [Int]) -> Move {
        guard let move = Move(input("Your move - pile,number to be removed"), piles: piles) else {
            return getUserMove(piles: piles)
        }
        return move
    }
    
    //940-1370
    //TODO: Understand logic
    private func computerMove(piles: [Int], winOption: WinOption) -> [Int] {
        var piles = piles
        
        //940-1010 - B = 11 bit representation of each pile number, ordered with least significant bit first
        //words = 16 bit representation of each pile number,
        //        ordered with most significant bit first;
        //        only last 11 bits are used
        var words = piles.map { UInt32($0) }
        
        for bitIndex in 0...10 {
            let mask = UInt32(1) << (10 - bitIndex)  //Loop from most significant to least significant bit
            let indexes = words.indices.filter { (words[$0] & mask) > 0 }
            if indexes.count % 2 > 0 {
                let maximum = (indexes.map { piles[$0] }).max()
                let index = piles.indices.firstIndex(where: { piles[$0] == maximum })!  //G
                piles[index] = 0
                words.remove(at: index)
                
                for bitIndex in 0...10 {
                    let mask = UInt32(1) << bitIndex
                    let count = (words.indices.filter { (words[$0] & mask) > 0 }).count
                    piles[index] += (count % 2) << bitIndex
                }
                
                switch winOption {
                case .avoidLast:
                    if piles.max()! > 1 { return piles }
                    let count = (piles.filter { $0 == 1 }).count
                    if count % 2 == 0 { piles[index] = 1 - piles[index] }
                    return piles
                case .takeLast:
                    return piles
                }
            }
        }
        
        //1140-1180 fallthrough, no odd count of bits; get random pile number and number to remove
        let indices = piles.indices.filter { piles[$0] > 0 }
        let index = indices.randomElement()!
        piles[index] = Int.random(in: 1...piles[index])
        return piles
    }

    //700-930, 1540-1630
    private func checkForWinner(afterMoveBy player: Player, winOption: WinOption, piles: [Int]) -> Player? {
        let remainingPiles = piles.filter { $0 > 0 }
        switch winOption {
        case .takeLast:
            return remainingPiles.count == 0 ? player : nil
        case .avoidLast:
            switch player {
            case .computer:
                return nil
            case .user:
                if remainingPiles.count > 2 {
                    //Check if all remaining piles have only one object: if so computer loses if not even number, otherwise let play continue
                    let singlePiles = piles.filter { $0 == 1 }
                    if singlePiles.count == remainingPiles.count, singlePiles.count % 2 == 1 { return .user }
                } else {
                    if remainingPiles.count == 2 {
                        if remainingPiles[0] == 1 || remainingPiles[1] == 1 { return .computer }
                    } else {
                        return remainingPiles[0] > 1 ? .computer : .user
                    }
                }
                
                return nil
            }
        }
    }
    
    private func print(piles: [Int]) {
        println("Pile  Size")
        for (index, size) in piles.enumerated() {
            println(" \(index + 1)  \(size)")
        }
    }
    
    private func getWinOption() -> WinOption {
        guard let option = WinOption(rawValue: Int(input("Enter win option - 1 to take last, 2 to avoid last")) ?? 0) else {
            return getWinOption()
        }
        return option
    }
    
    private func getNumberOfPiles() -> Int {
        guard let number = Int(input("Enter number of piles")), number > 0, number <= 100 else {
            return getNumberOfPiles()
        }
        return number
    }
    
    private func getPileSize(for pileNumber: Int) -> Int {
        guard let size = Int(input("\(pileNumber) ")), size > 0, size <= 2000 else {
            return getPileSize(for: pileNumber)
        }
        return size
    }
    
    private func isUserFirst() -> Bool {
        let response = Response(input())
        switch response {
        case .yes:
            return true
        case .no:
            return false
        case .other:
            print("Please. Yes or no")
            return isUserFirst()
        }
    }
    
    private func printInstructions() {
        let response = Response(input())
        switch response {
        case .yes:
            println("The game is played with a number of piles of objects.")
            println("Any number of objects  are removed from one pile by you and")
            println("the machine alternately.  On your turn, you may take")
            println("all the objects that remain in any pile but you must")
            println("take at least one object, and you may take objects from")
            println("only one pile on a single turn.  You must specify whether")
            println("winning is defined as taking or not taking the last object,")
            println("the number of piles in the game and how many objects are")
            println("originally in each pile.  Each pile may contain a")
            println("different number of objects.")
            println("The machine will show its move by listing each pile and the")
            println("number of objects remaining in the piles after  each of its")
            println("moves.")
       case .no:
            return
        case .other:
            print("Please. Yes or no")
            printInstructions()
        }
    }
    
    private func playAgain() -> Response {
        let response = Response(input())
        guard response != .other else {
            print("Please.  Yes or no")
            return playAgain()
        }
        return response
    }
}
