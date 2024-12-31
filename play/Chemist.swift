//
//  Chemist.swift
//  Chemist
//
//  Created by Joseph Baraga on 12/21/24.
//


class Chemist: GameProtocol {
    
    func run() {
        printHeader(title: "Chemist")
        println(3)
        println("The fictitious chemical kryptocyanic acid can only be")
        println("diluted by the ratio of 7 parts of water to 3 parts acid.")
        println("If any other ratio is attempted, the acid becomes unstable")
        println("and soon explodes.  Given the amount of acid, you must")
        println("decide how much water to add for dilution.  If you miss")
        println("you face the consequences.")
        play()
    }
    
    private func play() {
        var rounds = 0
        var t = 0
        while t < 9 {
            let a = Int(rnd() * 50)
            let w = 7 * Double(a) / 3
            let r = Double(input("\(a) liters of kryptocyanic acid.  How much water")) ?? 0
            if abs(w - r) <= w / 20 {
                println("Good job! You may breathe now, but don't inhale the fumes.")
                println()
                rounds += 1
            } else {
                println("Sizzle!  You have just been desalinated into a blob")
                println("of quivering protoplasm!")
                t += 1
                if t < 9 {
                    println("However, you may try again with another life.")
                }
            }
            
            if rounds > 5, t > 8 { unlockEasterEgg(.chemist) }
        }
        
        println("Your 9 lives are used, but you will be long remembered for")
        println("your contributions to the field of comic book chemistry.")
        end()
    }
}
