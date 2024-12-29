//
//  AceyDucey.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/30/22.
//

import Foundation

class AceyDucey: GameProtocol {

    private var q = 100 //Total dollars
    
    func run() {
        printHeader(title: "Acey Ducey Card Game")
        println(3)
        println("Acey-Ducey is played in the following manner")
        println("The dealer (computer) deals two cards face up")
        println("You have an option to bet or not bet depending")
        println("on whether or not you feel the card will have")
        println("a value between the first two.")
        println("If you do not want to bet, input a 0")
        wait(.short)
        
        var response = Response.yes
        repeat {
            play()
            wait(.long)
            response = Response(input("Try again (yes or no)"))
        } while response.isYes
        end()
    }
    
    //Lines 110-1010
    private func play() {
        q = 100
        while q > 0 {
            println("You now have \(q) dollars")
            println()
            if q >= 200 { unlockEasterEgg(.aceyDucey) }
            playHand()
        }
        
        println(2)
        println("Sorry, friend but you blew your wad")
    }
    
    //Lines 260-970
    private func playHand() {
        println("Here are your next two cards")
        let (a, b) = getCards()
        println(cardName(for: a))
        println(cardName(for: b))
        println()
        
        let m = getBet(maximum: q)
        if m == 0 {
            println("Chicken!!")
            println()
            playHand()
            return
        }
        
        //Line 730
        let c = Int(14 * rnd(1)) + 2
        println(cardName(for: c))
        
        if c > a && c < b {
            println("You win!!!")
            q += m
        } else {
            println("Sorry, You lose")
            q -= m
        }
    }
    
    private func getBet(maximum q: Int) -> Int {
        guard let m = Int(input("What is your bet")), m >= 0 else {
            return getBet(maximum: q)
        }
        guard m <= q else {
            println("Sorry, my friend but you bet too much")
            println("You have only \(q) dollars to bet")
            println()
            return getBet(maximum: q)
        }
        return m
    }
    
    //Lines 270-630
    private func getCards() -> (a: Int, b: Int) {
        let a = Int(14 * rnd(1)) + 2
        if a < 2 || a > 14 {
            return getCards()
        }
        let b = Int(14 * rnd(1)) + 2
        if b < 2 || b > 14 {
            return getCards()
        }

        if a < b {
            return (a, b)
        } else  {
            return (b, a)
        }
    }
    
    private func cardName(for value: Int) -> String {
        switch value {
        case 2...10: return " \(value)"
        case 11: return "Jack"
        case 12: return "Queen"
        case 13: return "King"
        case 14: return "Ace"
        default: fatalError("Card value \(value) out of bounds")
        }
    }
}
