//
//  Horserace.swift
//  play
//
//  Created by Joseph Baraga on 1/22/25.
//

import Foundation

class Horserace: BasicGame {
    
    private struct Horse {
        let name: String  //V$[]
        let number: Int  //A
        let odds: Int  //D[A] Unnormalized
        var oddsRatio: Double = 1.1  //D/R
        var distance = 0  //S
        
        //740-1000
        mutating func incrementDistance() {
            var y = Int.random(in: 1...100)
            if y < 10 { y = 1 } else {
                let s = Int(oddsRatio + 0.5)  //Round to nearest Int
                if y < s + 17 { y = 2 }
                else if y < s + 37 { y = 3 }
                else if y < s + 57 { y = 4 }
                else if y < s + 77 { y = 5 }
                else if y < s + 92 { y = 6 }
                else { y = 7 }
            }
            distance += y
        }
    }
    
    private struct Player {
        let name: String
        var horseNumber = 0
        var amount = 0
    }
    
    private struct Bet: LosslessStringConvertible {
        let horseNumber: Int
        let amount: Int
        
        var description: String { "" }
        
        init?(_ description: String) {
            let stringValues = description.components(separatedBy: CharacterSet(charactersIn: " ,")).compactMap { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            guard stringValues.count == 2, let number = Int(stringValues[0]), number > 0, let amount = Int(stringValues[1]), amount > 0, amount <= 100000 else { return nil }
            self.horseNumber = number
            self.amount = amount
        }
    }
    
    private let line = String(repeating: "-", count: 60)
    private let horseNames = ["Joe Maw", "L.B.J.", "Mr.Washburn", "Miss Karen", "Jolly", "Horse", "Jelly Do Not", "Midnight"]
    private let testOddsRatios = [4.444444444, 6.666666667, 20, 40, 4, 40, 40, 4]
    
    private var isCRT = false
    private var players = [Player]()
    
    func run() {
        printHeader(title: "Horserace")
        println("Welcome to South Portland High Racetrack")
        println(tab(22), "...owned by Laurie Chevalier")
        
        if Response(input("Do you want directions")) != .no {
            println("Up to 10 may play.  A table of odds will be printed.  You")
            println("may bet any + amount under 100000 on one horse.")
            println("During the race, a horse will be shown by its")
            println("number.  The horses race down the paper!")
            println()
        }
        
        isCRT = Response(input("Are you running on a CRT")) == .yes  //Add on
        guard let number = Int(input("How many want to bet")), number > 0 else {
            end()
        }
        
        println("When ? appears,type name")
        for _ in 1...number {
            players.append(Player(name: input()))
        }
        
        repeat {
            play()
            println("Do you want to bet on the next race?")
        } while Response(input("Yes or no")) == .yes
        
        end()
    }
    
    private func play() {
        //380
        var horses = horseNames.enumerated().map { Horse(name: $0.1, number: $0.0 + 1, odds: Int(10 * rnd() + 1)) }
        let total = Double(horses.reduce(0) { $0 + $1.odds })
        horses.indices.forEach { horses[$0].oddsRatio = total / Double(horses[$0].odds) }
        
        println()
        println("Horse", "", "Number", "Odds")
        println()
        for horse in horses {
            println(horse.name, "", " \(horse.number)", " \(horse.oddsRatio.formatted(.basic)) :1")
        }
        println(line)
        
        println("Place your bets...horse # then amount")
        for (index, player) in players.enumerated() {
            let bet = getBet(player: player)
            players[index].horseNumber = bet.horseNumber
            players[index].amount = bet.amount
        }
        
        println()
        if isCRT { enterCRTmode() }
        println(horses.indices.map { "\($0 + 1)" }.joined(separator: " "))
        
        //720-1250
        let trackLength = 28  //vertical lines of track
        repeat {
            println("XXXXSTARTXXXX")
            
            horses.indices.forEach { horses[$0].incrementDistance() }
            horses = horses.sorted(by: { $0.distance < $1.distance })
            var cumulativeDistance = 0
            horses.forEach { horse in
                if horse.distance < trackLength {
                    if horse.distance > cumulativeDistance {
                        println(horse.distance - cumulativeDistance, eraseLine: isCRT)
                        cumulativeDistance = horse.distance
                    }
                    print(" \(horse.number) ")
                }
            }
            println(trackLength - cumulativeDistance, eraseLine: isCRT)
            
            println("XXXXFINISHXXXX")
            println(2)
            println(line)
            println()
            
            if isCRT, (horses.map { $0.distance }).max() ?? 0 < trackLength {
                moveCursorToHome()
                eraseLine()
                println()
            }
            
        } while (horses.map { $0.distance }).max() ?? 0 < trackLength
        
        horses = horses.sorted(by: { $0.distance > $1.distance })
        println("The race results are:")
        for (index, horse) in horses.enumerated() {
            println()
            println(" \(index + 1) place horse no. \(horse.number)", tab(30), "at  \(horse.oddsRatio.formatted(.basic)) :1")
        }
        
        if let winningHorse = horses.first {
            let winners = players.filter { $0.horseNumber == winningHorse.number }
            winners.forEach { player in
                println()
                println("\(player.name) wins \((Double(player.amount) * winningHorse.oddsRatio).formatted(.currency(code: "USD")))")
            }
            if winners.count > 0 { unlockEasterEgg(.horserace) }
        }
    }
    
    //630-680 Horse number is not validated
    private func getBet(player: Player) -> Bet {
        guard let bet: Bet = input(player.name) else {
            return getBet(player: player)
        }
        return bet
    }
}
