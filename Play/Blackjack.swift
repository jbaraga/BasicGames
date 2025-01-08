//
//  Blackjack.swift
//  Blackjack
//
//  Created by Joseph Baraga on 2/20/22.
//

import Foundation


class Blackjack: GameProtocol {
    
    private enum Action: String, CaseIterable {
        case doubleDown = "D"
        case stand = "S"
        case hit = "H"
        case split = "/"
        
        init?(string: String) {
            self.init(rawValue: string.uppercased())
        }
        
        static func options(for h1: Int) -> [Action] {
            return Array(allCases[0..<h1])
        }
    }
    
    private let d$ = "N A  2  3  4  5  6  7N 8  9 10  J  Q  K"

    //Lines 20-80 - matrices are 1 indexed
    private var p: [[Int]] = [[Int]](repeating: [Int](repeating: 0, count: 13), count: 16)  //P[I,J] IS JTH CARD IN HAND I
    private var q = [Int]()  //Q[I] IS THE TOTAL OF HAND I (total value of cards)
    private var c = [Int](repeating: 0, count: 53)  //C IS THE SHUFFLED DECK BEING DEALT FROM
    
    //D = DISCARD PILE
    //1510 REM--INITIALIZE
    private var d: [Int] = {
        var d = [0]
        for i in 1...13 {
            d += [i,i,i,i]
        }
        return d
    }()
    
    private var t = [Int](repeating: 0, count: 9)  //T[I] IS THE TOTAL FOR PLAYER I
    private var s = [Int]()  //S[I] IS THE TOTAL THIS HAND FOR PLAYER I (bet - insurance + 50% bonus if blackjack
    private var b = [Int]()  //B[I] IS THE BET FOR HAND I
    private var r = [Int]()  //R[I] IS THE LENGTH OF P[I,*]
    
    private var cardIndex = 53  //Index of next card to deal on shuffled deck
    private var discardIndex = 52  //Index of last card on unshuffled deck
    
    private var n = 0  //Number of players
    private var d1: Int {  //d1 is index of dealer
        return n + 1
    }
    
    func run() {
        printHeader(title: "Black Jack")
                
        //Lines 1610-1630
        if input("Do you want instructions").isYes {
            printInstructions()
            wait(.short)
        }
        
        n = getNumberOfPlayers()
        
        //In original code, no stopping point
        while true {
            mainLoop()
        }
    }
    
    //Lines 1760-1780
    private func getNumberOfPlayers() -> Int {
        guard let n = Int(input("Number of players")), n > 0 && n < 8 else {
            return getNumberOfPlayers()
        }
        return n
    }
    
    private func mainLoop() {
        if 2 * d1 + cardIndex >= 52 {
            shuffle()
            let _ = getCard()  //First card discarded - casino rules - burn first card
        }
        if cardIndex == 2 { cardIndex -= 1 }
        
        var z = [Int](repeating: 0, count: n + 1)
        b = [Int](repeating: 0, count: 16)
        q = [Int](repeating: 0, count: 16)
        s = [Int](repeating: 0, count: 8)
        r = [Int](repeating: 0, count: 16)
        
        //Line 1880
        println("Bets")
        for i in 1...n {
            var bet = 0
            while bet == 0 {
                bet = Int(input("# \(i) ")) ?? 0
                if bet > 0 && bet <= 500 {
                    b[i] = bet
                } else {
                    bet = 0
                }
            }
        }
        
        //Line 1940
        print("Player")
        for i in 1...n {
            print(" \(i)    ")
        }
        println("Dealer")
        
        for j in 1...2 {
            print(tab(5))
            for i in 1...d1 {
                p[i,j] = getCard()
                
                if j == 1 || i <= n {
                    altPrint(card: p[i,j])
                }
            }
            println()
        }
        
        //Line 2080
        for i in 1...d1 {
            r[i] = 2
        }
        
        //2110 REM--TEST FOR INSURANCE
        if !(p[d1,1] > 1) {
            if input("Any insurance").isYes {
                println("Insurance bets")
                for i in 1...n {
                    var bet = -1
                    while bet < 0 || bet > b[i] / 2 {
                        bet = Int(input("# \(i)")) ?? -1
                    }
                    z[i] = bet
                    s[i] = z[i] * (3 * ((p[d1,2] >= 10 ? 1 : 0)) - 1)  //Booleans evaluate to -1 if true, 0 if false
                }
            }
        }
        
        
        //2240 REM--TEST FOR DEALER BLACKJACK
        let isBlackjack = (p[d1,1] == 1 && p[d1,2] > 9) || (p[d1,2] == 1 && p[d1,1] > 9)
        if isBlackjack {
            println("Dealer has a" + d$.mid(3 * p[d1,2] - 2, length: 3) + " in the hole for blackjack")
            for i in 1...d1 {
                q[i] = evaluateHand(forPlayer: i)
            }
            showResults()
            return
        }
        
        //2320 REM--NO DEALER BLACKJACK
        if !(p[d1,1] > 1 && p[d1,1] < 10) {
            println("No dealer blackjack.")
        }
        
        //2350 REM--NOW PLAY THE HANDS
        for i in 1...n {
            playHand(forPlayer: i)
        }
        
        //Line 2910 - ?evaluate hand for dealer?
        q[d1] = evaluateHand(forPlayer: d1)
        
        //2920 REM--TEST FOR PLAYING DEALER'S HAND
        var playOutDealerHand = false
        for i in 1...n {
            if r[i] > 0 || r[i+d1] > 0 {
                playOutDealerHand = true
                break
            }
        }
        
        if playOutDealerHand {
            //Lines 3010-3125
            print("Dealer has a" + d$.mid(3 * p[d1,2] - 2, length: 3) + " concealed ")
            var aa = abc(q[d1])
            println("for a total of \(aa)")
            
            if aa < 17 {
                print("Draws")
                while q[d1] > 0 && aa < 17 {
                    let x = getCard()
                    altPrint(card: x)
                    add(card: x, toPlayer: d1)
                    aa = abc(q[d1])
                }
                
                //Line 3100
                let q1 = q[d1]
                q[d1] = q1 - (q1 < 0 ? -1 : 0) / 2  //?not sure what this is doing
                if q1 >= 0 {
                    println("---Total is \(abc(q1))")
                }
            }
        } else {
            //Lines 2960-3000
            print("Dealer had a")
            print(card: p[d1,2])
            println(" concealed.")
        }
        
        println()
        showResults()
    }
    
    //Lines 2370-2890
    //Factored out to allow replay if player tries to split when not allowed
    private func playHand(forPlayer i: Int) {
        print("Player \(i)")
        let action = readReply()  //h1=7 - all actions allowed
        switch action {
        case .doubleDown:
            //2510 REM--PLAYER WANTS TO DOUBLE DOWN
            q[i] = evaluateHand(forPlayer: i)
            doubleDown(player: i)
        case .stand:
            //2410 REM--PLAYER WANTS TO STAND
            q[i] = evaluateHand(forPlayer: i)
            if q[i] == 21 {
                println("Blackjack")
                s[i] += Int(round(1.5 * Double(b[i])))
                b[i] = 0
                discardRow(forPlayer: i)
            } else {
                printTotal(forPlayer: i)
            }
        case .hit:
            //2550 REM--PLAYER WANTS TO BE HIT
            q[i] = evaluateHand(forPlayer: i)
            playOutHand(forPlayer: i, allowedActions: [.hit])
        case .split:
            //2600 REM--PLAYER WANTS TO SPLIT
            let l1 = p[i,1] > 10 ? 10 : p[i,1]
            let l2 = p[i,2] > 10 ? 10 : p[i,2]
            guard l1 == l2 else {
                println("Splitting not allowed.")
                playHand(forPlayer: i)
                return
            }
            
            //2640 REM--PLAY OUT SPLIT
            //Lines 2650-2890
            let i1 = i + d1
            r[i1] = 2
            p[i1,1] = p[i,1]
            b[i+d1] = b[i]
            
            let x1 = getCard()
            print("First hand receives a")
            print(card: x1)
            p[i,2] = x1
            q[i] = evaluateHand(forPlayer: i)
            println()
            
            let x2 = getCard()
            print("Second hand receives a")
            print(card: x2)
            p[i1,2] = x2
            q[i1] = evaluateHand(forPlayer: i1)
            println()
            
            if p[i,1] == 1 { return }
            
            //REM--NOW PLAY THE TWO HANDS
            print("Hand 1 ")
            playOutHand(forPlayer: i)
            print("Hand 2 ")
            playOutHand(forPlayer: i1)
        }
    }
    
    //MARK: Subroutines
    //100 REM--SUBROUTINE TO GET A CARD.  RESULT IS PUT IN X
    private func getCard() -> Int {
        if cardIndex > 50 { shuffle() }
        defer { cardIndex += 1 }
        return c[cardIndex]
    }
    
    //Lines 120-220
    private func shuffle() {
        println("Reshuffling")
        while discardIndex > 0 {
            cardIndex -= 1
            c[cardIndex] = d[discardIndex]
            discardIndex -= 1
        }
        for c1 in stride(from: 52, through: cardIndex, by: -1) {
            let c2 = Int(rnd(1) * Double(c1 - cardIndex + 1)) + cardIndex
            let c3 = c[c2]
            c[c2] = c[c1]
            c[c1] = c3
        }
    }
    
    //300 REM--SUBROUTINE TO EVALUATE HAND I. TOTAL IS PUT INTO
    //310 REM--Q[I]. TOTALS HAVE FOLLOWING MEANING:
    //320 REM--  2-10...HARD 2-10
    //330 REM-- 11-21...SOFT 11-21
    //340 REM-- 22-32...HARD 11-21
    //350 REM--  33+....BUSTED
    //This version returns the total, caller sets q
    //Lines 360-420
    private func evaluateHand(forPlayer i: Int) -> Int {
        var q = 0
        for q2 in 1...r[i] {
            add(card: p[i,q2], toTotal: &q)
        }
        return q
    }
    
    //500 REM--SUBROUTINE TO ADD CARD X TO TOTAL Q.
    //Lines 510-620
    private func add(card x: Int, toTotal q: inout Int) {
        let x1 = x > 10 ? 10 : x
        let q1 = q + x1
        if q < 11 {
            //Line 540
            if x > 1 {
                //Line 570
                q = q1 - 11 * (q1 >= 11 ? -1 : 0)
            } else {
                //Line 550
                q += 11
            }
        } else {
            //Line 590
            q = q1 - (q <= 21 && q1 > 21 ? -1 : 0)
            if q < 33 { return }
            q = -1
        }
    }
    
    //700 REM--CARD PRINTING SUBROUTINE
    private func print(card x: Int) {
        print(d$.mid(3 * x - 2, length: 3) + "  ")
    }
    
    //750 REM--ALTERNATIVE PRINTING ROUTINE
    private func altPrint(card x: Int) {
        print(" " + d$.mid(3 * x - 1, length: 2) + "   ")
    }
    
    //800 REM--SUBROUTINE TO PLAY OUT A HAND.
    //810 REM--NO SPLITTING OR BLACKJACKS ALLOWED
    //Lines 820-1010; lines 860-920
    private func playOutHand(forPlayer i: Int, allowedActions: [Action] = [.doubleDown, .hit, .stand]) {
        let action = allowedActions == [.hit] ? .hit : readReply(allowedActions: allowedActions)
        switch action {
        case .doubleDown:
            doubleDown(player: i)
            playOutHand(forPlayer: i, allowedActions: [.hit, .stand])
        case .hit:
            //Line 950
            let x = getCard()
            print("Received a")
            print(card: x)
            add(card: x, toPlayer: i)
            if q[i] < 1 {
                return
            }
            print("Hit")
            playOutHand(forPlayer: i, allowedActions: [.hit, .stand])
        case .stand:
            //Line 930
            printTotal(forPlayer: i)
        case .split:
            fatalError("split action not allowed")
        }
    }
    
    //Lines 860-920
    //This is embedded within the playOutHand subroutine, but appears to be separate
    private func doubleDown(player i: Int) {
        let x = getCard()
        b[i] *= 2
        print("Received a")
        print(card: x)
        add(card: x, toPlayer: i)
        if q[i] > 0 {
            printTotal(forPlayer: i)
        }
    }
    
    //1100 REM--SUBROUTINE TO ADD A CARD TO ROW I
    //Lines 1110-1190
    private func add(card x: Int, toPlayer i: Int) {
        r[i] += 1
        p[i,r[i]] = x
        var q1 = q[i]
        add(card: x, toTotal: &q1)
        q[i] = q1
        if q1 < 0 {
            println("...Busted")
            discardRow(forPlayer: i)
        }
    }
    
    //1200 REM--SUBROUTINE TO DISCARD ROW I
    private func discardRow(forPlayer i: Int) {
        while r[i] > 0 {
            discardIndex += 1
            d[discardIndex] = p[i,r[i]]
            r[i] -= 1
        }
    }
    
    //1300 REM--PRINTS TOTAL OF HAND I
    //Caller must add println() if gosub 1310
    private func printTotal(forPlayer i: Int) {
        let aa = abc(q[i])
        println("Total is \(aa)")
    }
    
    //1400 REM--SUBROUTINE TO READ REPLY
    //h1 value must mapped allowedOptions
    private func readReply(allowedActions: [Action] = Action.allCases) -> Action {
        guard let reply = Action(string: input()), allowedActions.contains(reply) else {
            print("Type " + (allowedActions.map { $0.rawValue }).joined(separator: " or ") + "please")
            return readReply(allowedActions: allowedActions)
        }
        return reply
    }
    
    //3140 REM TALLY THE RESULT
    //Lines 3160-3360
    private func showResults() {
        for i in 1...n {
            let aa = abc(q[i])
            let ab = abc(q[i + d1])
            let ac = abc(q[d1])
            s[i] += b[i] * sgn(aa - ac) + b[i+d1] * sgn(ab - ac)
            b[i+d1] = 0
            
            print("Player \(i) ")
            switch sgn(s[i]) {
            case -1: print("loses")
            case 0: print("pushes")
            case 1: print("wins")
            default: fatalError("Illegal sgn result")
            }
            print(s[i] == 0 ? "      " : " \(abs(s[i])) ")
            t[i] += s[i]
            println("Total = \(t[i])")
            
            discardRow(forPlayer: i)
            t[d1] -= s[i]
            discardRow(forPlayer: i + d1)
            
            if t[i] > 1000, t[i] > t[d1] { unlockEasterEgg(.blackjack) }
        }
        
        println("Dealer's total = \(t[d1])")
        discardRow(forPlayer: d1)  //?n
    }
    
    //Lines 3400-3420
    private func abc(_ a: Int) -> Int {
        return a + 11 * (a >= 22 ? -1 : 0)
    }
    
    //Lines 1640-1750
    private func printInstructions() {
        println("This is the game of 21.  As many as 7 players may play the")
        println("game.  On each deal, bets will be asked for, and the")
        println("players' bets should be typed in.  The cards will then be")
        println("dealt, and each player in turn plays his hand.  The")
        println("first response should be either 'd', indicating that the")
        println("player is doubling down, 's', indicating that he is")
        println("standing, 'h', indicating he wants another card, or '/',")
        println("indicating that he wants to split his cards.  After the")
        println("initial response, all further responses should be 's' or")
        println("'h', unless the cards were split, in which case doubling")
        println("down again is permitted.  In order to collect for")
        println("blackjack, the initial response should be 's'.")
    }
}
