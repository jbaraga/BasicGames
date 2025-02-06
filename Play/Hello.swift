//
//  Hello.swift
//  BasicGames
//
//  Created by Joseph Baraga on 1/8/25.
//

import Foundation

class Hello: BasicGame {
    
    func run() {
        printHeader(title: "Hello", newlines: 0)
        
        while true {
            println(3)
            play()
        }
        end()
    }
    
    private func play() {
        println("Hello.  My name is Creative Computer.")
        println(2)
        let name = input("What's your name").trimmingCharacters(in: .whitespaces)  //B$
        println()
        
        var response = Response.other
        print("  Hi there \(name), are you enjoying yourself here")
        repeat {
            let string = input()
            println()
            response = Response(string)
            if response == .other {
                println("  \(name), I don't understand your answer is '\(string)'.")
                print("Please answer 'yes' or 'no'.  Do you like it here")
            }
        } while response == .other
        if response == .yes {
            println("I'm glad to hear that, \(name).")
            println()
        } else {
            println("Oh, I'm sorry to hear that, \(name), maybe we can")
            println("brighten up your visit a bit.")
        }
        
        println()
        println("Say \(name), I can solve all kinds of problems except")
        println("those dealing with Greece.  What kind of problems do")
        print("you have (answer sex, health, money, or job)")
        
        repeat {
            let kind = input().lowercased()  //C$
            switch kind {
            case "sex":
                //200
                var string = input("Is your problem too much or too little").lowercased()
                println()
                while !(string == "too much" || string == "too little") {
                    println("Don't get all shook, \(name), just answer the question")
                    string = input("with 'too much' or 'too little'")
                    println()
                }
                if string == "too much" {
                    println("You call that a problem?!!  I should have such problems!")
                    println("If it bothers you, \(name), take a cold shower.")
                } else {
                    println("Why are you here, \(name)?  You should be")
                    println("in Tokyo or New York or Amsterdam or someplace with some")
                    println("real action.")
                }
            case "health":
                //180
                println("My advice to you \(name) is:")
                println("     1.  Take two aspirin")
                println("     2.  Drink plenty of fluids (orange juice, not beer!)")
                println("     3.  Go to bed (alone)")
            case "money":
                //160
                println("Sorry, \(name), I'm broke too.  Why don't you sell")
                println("encyclopedias or marry someone rich or stop eating")
                println("so you won't need so much money?")
            case "job":
                //145
                println("I can sympathize with you \(name).  I have to work")
                println("very long hours for no pay -- and some of my bosses")
                println("really beat on my keyboard.  My advice to you, \(name),")
                println("is to open a retail computer store.  It's great fun.")
            default:
                //138
                println("Oh, \(name), your answer of \(kind) is Greek to me.")
            }
            
            //250
            println()
            repeat {
                response = Response(input("Any more problems you want solved, \(name)"))
                if response == .other {
                    println("Just a simple 'yes' or 'no' please, \(name).")
                }
            } while response == .other
            
            if response == .yes {
                print("What kind (sex, money, health, job)")
            }
        } while response == .yes
        
        println()
        println("That will be $5.00 for the advice, \(name).")
        println("Please leave the money on the terminal.")
        wait(.long)
        println(3)
        repeat {
            let string = input("Did you leave the money")
            println()
            response = Response(string)
            if response == .other {
                println("Your answer of \(string) confuses me, \(name).")
                println("Please respond with 'yes' or 'no'.")
            }
        } while response == .other
        
        if response == .yes {
            println("Hey, \(name)??? You left no money at all!")
            println("You are cheating me out of my hard-earned living.")
            println("Rip off, \(name)" + String(repeating: "*", count: 37))
        } else {
            println("That's honest, \(name), but how do you expect")
            println("me to go on with my psychology studies if my patients")
            println("don't pay their bills?")
            println(2)
            println("Now let me talk to someone else.")
            unlockEasterEgg(.hello)
        }
        println("Nice meeting you, \(name), have a nice day.")
        wait(.short)
    }
}
