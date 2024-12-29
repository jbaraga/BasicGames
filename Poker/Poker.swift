//
//  Poker.swift
//  Poker
//
//  Created by Joseph Baraga on 1/14/24.
//

import Foundation

class Poker: GameProtocol {
    
    private var computerPurse = 200  //C - computer account
    private var userPurse = 200  //S - user account
    private var pot = 0  //P
    
    //variable O tracks watch and tie tack - separated into two Booleans
    private var userHasWatch = true
    private var userHasTieTack = true
    
    private func fna() -> Int { Int(10 * rnd(1)) }
    private func fnb(x: Int) -> Int { x - 100 * Int(Double(x) / 100) }
    
    private enum Player {
        case user
        case computer
    }
    
    private enum HandCategory: CustomStringConvertible {
        case fourOfAKind, fullHouse, flush, straight, threeOfAKind, twoPair, pair
        case schmaltz
        case partialStraight  //Only for internal tracking of hand being played
        
        //H$ I$
        var description: String {
            switch self {
            case .fourOfAKind: return "Four "
            case .fullHouse: return "Full House, "
            case .flush: return "A Flush in "
            case .straight: return "Straight"
            case .threeOfAKind: return "Three "
            case .twoPair: return "Two Pair, "
            case .pair: return "A Pair of "
            case .schmaltz: return "Schmaltz, "
            case .partialStraight: fatalError("Invalid description case: partial straight")
            }
        }
        
        //U
        var score: Int {
            switch self {
            case .fourOfAKind: return 17
            case .fullHouse: return 16
            case .flush: return 15
            case .straight: return 14
            case .threeOfAKind: return 13
            case .twoPair: return 12
            case .pair: return 11
            case .schmaltz: return 9
            case .partialStraight: return 10
            }
        }
    }
    
    private struct Hand {
        var player: Player
        
        var cards = [Int]()  //array A: values 0-8 == card values 2-10, 9-12 == card values J,Q,K,A. Hundreds digit holds suit - 0 clubs, 1 - diamonds, 2 - hearts, 3 - spades
        
        private var discards = [Int]()  //
        
        //Lines 1850-2160
        var stringValues: [String] {
            cards.map { faceValue(for: $0) + " of " + suit(for: $0) }
        }
        
        var usedCards: [Int] { cards + discards }
        
        var numberOfDiscards: Int { discards.count }
        
        init(player: Player, cards: [Int] = [Int]()) {
            self.player = player
            self.cards = cards
        }
        
        private func faceValue(for value: Int) -> String {
            let number = value.fnb
            switch number {
            case 0...8: return " \(number + 2)"
            case 9: return "Jack"
            case 10: return "Queen"
            case 11: return "King"
            case 12: return "Ace"
            default:
                fatalError("Invalid card value: \(value).")
            }
        }
        
        private func suit(for value: Int) -> String {
            switch value.hundreds {
            case 0: return "Clubs"
            case 1: return "Diamonds"
            case 2: return "Hearts"
            case 3: return "Spades"
            default:
                fatalError("Invalid card value: \(value).")
            }
        }
        
        mutating func replaceCard(at u: Int, with card: Int) {
            let index = u - 1
            guard cards.indices.contains(index) else { return }
            discards.append(cards[index])
            cards[index] = card
        }

        //2170-3040
        //x integer encapsulates hold/discard logic for computer. x is discard mask for hand sorted by ascending card value, encoded as digit value == 0 is discard, digit value 1 or 2 is hold. Digit position corresponds to card position in hand array: 1's digit corresponds to A[0], 10's digit corresponds to A[1], etc.
        //d is highest card for HandCategory in most hands, except flush where it is first card in unsorted hand. d is not set for partial straight (0 is returned).
        //i is an integer flag, set to 6 for schmaltz or for pair/2 pair if face value is <=8
        //card are not sorted for flush
        mutating func evaluate() -> (category: HandCategory, x: Int, d: Int) {
            //Check for flush
            let uniqueSuits = Array(Set(cards.map { suit(for: $0) }))
            if uniqueSuits.count == 1 {
                return (.flush, 11111, (cards.map { $0.fnb }).max() ?? cards[0])  //Bug in original, does not return max value
            }
            
            //Lines 2310-2400
            cards = cards.sorted(by: { $0.fnb < $1.fnb })  //Sorted by face value
            let b = cards.map { $0.fnb }  //integer values of sorted cards, suit removed

            //2410-2470, 2760-3040 sets x and evaluates for pair and higher; if none, falls through to straight or schmaltz
            var x = 0
            var d = 0
            var category = HandCategory.schmaltz
            b.enumerated().forEach { index, value in
                if index + 1 < b.count, value == b[index + 1] {
                    x += 11 * Int(pow(10.0, Double(index)))
                    d = cards[index]
                    
                    switch category {
                    case .schmaltz: 
                        category = .pair
                    case .pair:
                        if b[index - 1] == value {
                            category = .threeOfAKind
                        } else {
                            category = .twoPair
                        }
                    case .threeOfAKind:
                        if b[index - 1] == value {
                            category = .fourOfAKind
                        } else {
                            category = .fullHouse
                        }
                    case .twoPair:
                        category = .fullHouse
                    default:
                        break
                    }
                }
            }
            
            //2480 category pair or higher if x > 0
            if x > 0 {
                //2720-2750 pair or two pair, set i to bluffing if high card less than or equal to 8 - done by caller
//                if category.score > 12, d.fnb <= 6 { i = 6 }
                return (category, x, d)
            }
            
            //2490-2620 - check for straight or partial straight; partial straight u = 10
            if b[0] + 3 == b[3] {
                category = .partialStraight
                x = 1111
            }
            
            if b[1] + 3 == b[4] {
                if category == .partialStraight {
                    d = cards[4]
                    return (.straight, 11111, d)
                } else {
                    category = .partialStraight
                    x = 11110
                }
            }
            
            if category == .partialStraight {
                d = cards[4]  //Not set in original, but set for schmaltz after draw for result() function - partial straight is schmaltz
                return (category, x, d)
            }
            
            //Lines 2630-2750 - fallthrough to schmaltz; i set to 6 - done by caller
            d = cards[4]
            //I=6
            return (.schmaltz, 11000, d)
        }
        
        mutating func result() -> (HandCategory, Int) {
            var (category, _, highCard) = evaluate()
            if category == .partialStraight { category = .schmaltz }  //Replaces .partialStraight with schmaltz after draw, not done in original code?
            return (category, highCard)
        }
        
        //3690-3820
        mutating func resultDescription() -> String {
            let (category, highCard) = result()
            switch category {
            case .flush:
                return category.description + suit(for: cards[0])
            case .fourOfAKind, .fullHouse, .threeOfAKind, .twoPair, .pair:
                return category.description + faceValue(for: highCard) + " s"
            case .straight, .schmaltz:
                return category.description + faceValue(for: highCard) + " high"
            case .partialStraight:
                fatalError("Invalid result")
            }
        }
    }
    
    func run() {
        printHeader(title: "Poker")
        println(3)
        
        println("Welcome to the Casino.  We each have $200")
        println("I will open the betting before the draw; you open after")
        println("When you fold, bet 0; to check, bet .5")
        println("Enough talk -- let's get down to business")
        println()
        
        wait(.short)
        play()
    }
    
    //150
    private func play() {
        while computerPurse > 5 {
//            var i = 2  //i logic flag; first deal i==6 computer is bluffing (schmaltz, one or two pair with high card <=4); after drawing more cards i==6 computer goes lower risk if not bluffing first deal
            
            println("The ante is $5.  I will deal")
            println()
            
            if userPurse <= 5 { userPurse += getMoreMoney() }
            
            pot += 10
            computerPurse -= 5
            userPurse -= 5
            
            //230-250 first deal
            var (userHand, computerHand) = dealHands()
            
            //260-280
            println("Your hand:")
            print(hand: userHand)
            
            //290-
            var z = 10  //Numerical value which determines computer aggressiveness in betting, higher value == higher betting
            var (category, x, d) = computerHand.evaluate()
            println()
            
            var isComputerBluffing = false  //i for first deal: true if i==6
            switch category {
            case .schmaltz:
                isComputerBluffing = true  //Line 2740
            case .pair, .twoPair:
                if d.fnb <= 6 { isComputerBluffing = true }  //Lines 2730-2740
            default:
                break
            }
            
            //Convoluted betting logic to determine baseline bet z, also alters discard mask x, var i, and introduced var k
            var computerChecks = false
            if isComputerBluffing {
                //340-460, 520-530
                z = 23
                if fna() > 7 {
                    x = 11100
                } else {
                    if fna() > 7 {
                        x = 11110
                    } else {
                        if fna() < 1 {
                            x = 11111
                        } else {
                            //520
                            computerChecks = true
                        }
                    }
                }
            } else {
                //470-530
                if category.score < 13 {  //Backwards?  higher category should have higher bet z
                    //Lines 480-530
                    if fna() < 2 {
                        isComputerBluffing = true
                        z = 23
                    } else {
                        //520
                        computerChecks = true
                    }
                } else {
                    //540-570
                    //TODO: potentially lower bet for highest hand (4 of a kind) - error?
                    if category.score > 16 {
                        z = fna() < 1 ? 2 : 35
                    } else {
                        z = 35  //3 of a kind or hights
                    }
                }
            }
            
            //580 - current bet is opening bet
            var v = 0
            if computerChecks {
                z = 0
                println("I check")
            } else {
                v = getComputerBet(currentBet: z, totalBet: 0)
                println("I'll open with \(v)")
            }
            
            //620
            if let winner = bet(user: 0, computer: v, z: z) {  //g, k
                handWin(by: winner)
            } else {
                //Second deal
                //820-890
                println()
                var t = -1
                print("Now we draw -- how many cards do you want")
                while t < 0 {
                    if let number = Int(input()), number >= 0 {
                        if number > 3 {
                            println("You can't draw more than three cards")
                        } else {
                            t = number
                        }
                    }
                }
                
                //900-970
                println("What are their numbers")
                for _ in 1...t {
                    if let u = Int(input()) {
                        let newCard = dealCard(usedCards: userHand.usedCards + computerHand.usedCards)
                        userHand.replaceCard(at: u, with: newCard)
                    }
                }
                
                println("Your new hand:")
                print(hand: userHand)
                
                //980-1100
                for u in 1...5 {
                    if Int(Double(x) / pow(10, Double(u-1))) == 10 * Int(Double(x) / pow(10, Double(u))) {
                        let newCard = dealCard(usedCards: userHand.usedCards + computerHand.usedCards)
                        computerHand.replaceCard(at: u, with: newCard)
                    }
                }
                println("I am taking \(computerHand.numberOfDiscards) card" + (computerHand.numberOfDiscards == 1 ? "" : "s"))
                println()
                
                //1110
                var isComputerBettingLow = false //i after draw; true if i==6
                (category, d) = computerHand.result()
                
                //Set i
                switch category {
                case .schmaltz, .partialStraight:
                    isComputerBettingLow = true
                case .pair, .twoPair:
                    if d.fnb <= 6 { isComputerBettingLow = true }  //Lines 2730-2740
                default:
                    break
                }

                //1140-1330
                z = 2  //fallthrough for code below
                if isComputerBluffing {
                    z = 28  //continue bluffing
                } else {
                    if isComputerBettingLow {
                        z = 1  //go low
                    } else {
                        if category.score < 13 {
                            z = 2
                            if fna() == 6 { z = 19 }
                        } else {
                            if category.score < 16 {
                                z = 19
                                if fna() == 8 { z = 11 }
                            }
                        }
                    }
                }
                
                //1340-1450
                let currentPot = pot
                var winner = bet(computer: 0, z: z)

                //1350 user checks t == 0.5 - now give computer a chance to bet
                if winner == nil, pot == currentPot {
                    if isComputerBluffing || !isComputerBettingLow { //isBluffing (first deal) or isTakingRisk (second deal
                        //1400
                        let v = getComputerBet(currentBet: 0, totalBet: 0)
                        println("I'll bet \(v)")
                        winner = bet(computer: v, z: z)
                    } else {
                        println("I'll check")
                    }
                }
                
                if let winner {
                    handWin(by: winner)
                } else {
                    //1460-
                    println("Now we compare hands")
                    println("My hand:")
                    print(hand: computerHand)
                    println()
                    
                    print("You have ")
                    println(userHand.resultDescription())
                    print("and I have ")
                    println(computerHand.resultDescription())
                    
                    if let winner = compare(userHand, to: computerHand) {
                        handWin(by: winner)
                    } else {
                        println("The hand is drawn")
                        println("All $\(pot) remains in the pot")
                    }
                }
            }
        }
        
        computerBust()
    }
    
    //650-810
    private func handWin(by player: Player) {
        println()
        switch player {
        case .user:
            println("You win")
            userPurse += pot
        case .computer:
            println("I win")
            computerPurse += pot
        }
        pot = 0
        println("Now I have $\(computerPurse) and you have $\(userPurse)")
        
        var response = Response.other
        while response == .other {
            response = Response(input("Do you wish to continue"))
            switch response {
            case .yes:
                return
            case .no:
                end()
            default:
                println("Answer yes or no, please.")
                response = .other
            }
        }
    }
    
    //1640-1720
    private func compare(_ hand1: Hand, to hand2: Hand) -> Player? {
        var hand1 = hand1
        var hand2 = hand2
        let (category1, highcard1) = hand1.result()
        let (category2, highcard2) = hand2.result()
        if category1.score == category2.score {
            if highcard1.fnb == highcard2.fnb { return nil }
            return highcard1.fnb > highcard2.fnb ? hand1.player : hand2.player
        }
        return category1.score > category2.score ? hand1.player : hand2.player
    }
    
    //1740-1840 opening deal
    private func dealHands() -> (user: Hand, computer: Hand) {
        //Generate 10 unique randomized cards
        var a = [Int]()
        while a.count < 10 {
            a.append(dealCard(usedCards: a))
        }
        return (Hand(player: .user, cards: Array(a[0...4])), Hand(player: .computer, cards: Array(a[5...9])))
    }
    
    //1740-1790 returns random card from unused cards
    private func dealCard(usedCards: [Int]) -> Int {
        //Generate unique randomized cards
        var value = -1
        while value < 0 {
            value = 100 * Int(4 * rnd()) + Int(100 * rnd())
            if value.hundreds > 3 || value.fnb > 12 || usedCards.contains(value) {
                value = -1
            }
        }
        return value
    }

    
    //1850-2160
    private func print(hand: Hand) {
        let cardValues = hand.stringValues
        cardValues.enumerated().forEach { (index, card) in
            print(" \(index + (hand.player == .user ? 1 : 6)) --  " + card)
            if (index + 1) % 2 > 0 {
                print(tab(28))
            } else {
                println()
            }
        }
        println()
    }
    
    //3050-3510
    //Returns winning player .computer if user folds (i=3), .user if computer folds (i=4)
    private func bet(user g: Int = 0, computer k: Int, z: Int) -> Player? {
        var k = k
        var g = g
        
        guard let t = getUserBet(currentBet: k, totalBet: g) else {
            //Player folds
            commitBets(user: g, computer: k)
            return .computer
        }
               
        //3230-3240
        g += t
        if g == k {
            //Player calls
            commitBets(user: g, computer: k)
            return nil
        }
        
        /*
        //3250-3510
        if z != 1 {
            //3420
            if g > 3 * z {
                //3350  z!=1, g>3*z
                if z == 2 {
                    //3430-3470  z!=1, g>3*z, z==2
                    let v = getComputerBet(currentBet: g, totalBet: k)
                    println("I'll see you, and raise you \(v)")
                    k += g + v
                    return bet(user: g, computer: k, z: z)
                } else {
                    //3360
                    println("I'll see you")
                    k = g
                    commitBets(user: g, computer: k)
                    return nil
                }
            } else {
                //3430-3470  z!=1, g<=3*z
                let v = getComputerBet(currentBet: g, totalBet: k)
                println("I'll see you, and raise you \(v)")
                k += g + v
                return bet(user: g, computer: k, z: z)
            }
        } else {
            if g > 5 {
                //3300  z==1, g>5
                if z == 1 || t > 25 {
                    println("I fold")
                    return .user
                } else {
                    //3350  z==1, g>5, z!=1, t<=25  - should never execute
                    if z == 2 {
                        //3430-3470
                        let v = getComputerBet(currentBet: g, totalBet: k)
                        println("I'll see you, and raise you \(v)")
                        k += g + v
                        return bet(user: g, computer: k, z: z)
                    } else {
                        //3360
                        println("I'll see you")
                        k = g
                        commitBets(user: g, computer: k)
                        return nil
                    }
                }
            } else {
                //3270  z==1, g<=5
                if z < 2 {  //redundant
                    //3280 v = 5  not used?
                    //3420  z==1, z<2, g<=5
                    if g > 3 * z {
                        //3350  z==1, g<=5, g>3*z, z<2
                        if z == 2 {
                            //3430-3470  z==1, g>3*z, z==2  - should never execute
                            let v = getComputerBet(currentBet: g, totalBet: k)
                            println("I'll see you, and raise you \(v)")
                            k += g + v
                            return bet(user: g, computer: k, z: z)
                        } else {
                            //3360
                            println("I'll see you")
                            k = g
                            commitBets(user: g, computer: k)
                            return nil
                        }
                    } else {
                        //3430-3470
                        let v = getComputerBet(currentBet: g, totalBet: k)
                        println("I'll see you, and raise you \(v)")
                        k += g + v
                        return bet(user: g, computer: k, z: z)
                    }
                } else {
                    //should never execute
                    //3350
                    if z == 2 {
                        //3430
                        let v = getComputerBet(currentBet: g, totalBet: k)
                        println("I'll see you, and raise you \(v)")
                        k += g + v
                        return bet(user: g, computer: k, z: z)
                    } else {
                        //3360
                        println("I'll see you")
                        k = g
                        commitBets(user: g, computer: k)
                        return nil
                    }
                }
            }
        }
        */
        
        //3250-3510 Convoluted and sometimes illogical betting logic
        if z == 1 {
            if g > 5 {
                //3300  ?bug line 3310 should never execute
                println("I fold")
                return .user
            } else {
                if g <= 3 * z  {
                    //3430-3470
                    let v = getComputerBet(currentBet: g, totalBet: k)
                    if v > g {
                        println("I'll see you, and raise you \(v)")
                        k += g + v
                        return bet(user: g, computer: k, z: z)
                    } else {
                        println("I'll see you")
                        k = g
                        commitBets(user: g, computer: k)
                        return nil
                    }
                }
            }
        } else {
            //3420
            if (z == 2 && g > 3 * z) || g <= 3 * z {
                //3430-3470
                let v = getComputerBet(currentBet: g, totalBet: k)
                if v > g {
                    println("I'll see you, and raise you \(v)")
                    k += g + v
                    return bet(user: g, computer: k, z: z)
                } else {
                    println("I'll see you")
                    k = g
                    commitBets(user: g, computer: k)
                    return nil
                }
            }
        }
        
        //3360-3410  Fallthrough - does not check for sufficient computer funds ? bug
        println("I'll see you")
        k = g
        commitBets(user: g, computer: k)
        return nil
        
    }
    
    //3060-3220
    private func getUserBet(currentBet k: Int, totalBet g: Int) -> Int? {
        let bet = getBet()
        if bet == 0.5, k == 0 && g == 0 { return 0 }  //Check
        
        let t = Int(bet)
        if bet - Double(t) > 0 {
            println("No small change, please")
            return getUserBet(currentBet: k, totalBet: g)
        }
        
        if t == 0 { return nil }
        
        if g + t < k {
            println("If you can't see my bet, then fold")
            return getUserBet(currentBet: k, totalBet: g)
        }
        
        return t
    }

    private func getBet() -> Double {
        guard let t = Double(input("What is your bet")), t >= 0 else { return getBet() }
        return t
    }
    
    //3430, 3480-3680 - returns v
    private func getComputerBet(currentBet g: Int, totalBet k: Int) -> Int {
        let v = g - k + fna()
        return verifyBet(currentBet: g, proposedBet: v)
    }
    
    //3480-3680 Check for sufficient funds
    private func verifyBet(currentBet g: Int, proposedBet v: Int) -> Int {
        if computerPurse - g - v >= 0 { return v }
        
        if g == 0 {
            return computerPurse
        } else {
            if computerPurse - g < 0 {
                //3530
                let proceeds = sellItemsToComputer()
                if proceeds == 0 {
                    computerBust()
                } else {
                    computerPurse += proceeds
                    return v
                }
            } else {
                //3520
                //TODO: goto out of subroutine without return to "I'll see you", here replaced by returning g
                return g
            }
        }
    }
    
    //3380-3400
    private func commitBets(user g: Int, computer k: Int) {
        userPurse -= g
        computerPurse -= k
        pot += g + k
    }
    
    //3530-3660
    private func sellItemsToComputer() -> Int {
        if !userHasWatch {
            if Response("Would you like to buy back your watch for $50") == .yes {
                userHasWatch = true
                return 50
            }
        }
        
        if !userHasTieTack {
            if Response("Would you like to buy back your tie tack for $50") == .yes {
                userHasTieTack = true
                return 50
            }
        }
        
        return 0
    }
        
    //3830-4100
    private func getMoreMoney() -> Int {
        println()
        println("You can't bet what you haven't got")
        
        if userHasWatch {
            if Response(input("Would you like to sell your watch")) == .yes {
                userHasWatch = false
                if fna() < 7 {
                    println("I'll give you $75 for it")
                    return 75
                } else {
                    println("That's a pretty crummy watch - I'll give you $25")
                    return 25
                }
            }
        }
        
        if userHasTieTack {
            if Response(input("Will you part with that diamond tie tack")) == .yes {
                userHasTieTack = false
                if fna() < 6 {
                    println("You are now $100 richer")
                    return 100
                } else {
                    println("It's paste. $25")
                    return 25
                }
            }
        }
        
        println("Your wad is shot.  So long, sucker!")
        wait(.short)
        end()
    }
    
    //3670-3680
    private func computerBust() -> Never {
        println("I'm busted.  Congratulations.")
        wait(.short)
        unlockEasterEgg(.poker)
        end()
    }
}


fileprivate extension Int {
    //L30 FNB(X): removes hundreds digit - gives card value 0-12
    var fnb: Int { self - 100 * Int(Double(self) / 100) }
    var hundreds: Int { Int(self / 100) }
}
