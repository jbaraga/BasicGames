//
//  Animal.swift
//  Animal
//
//  Created by Joseph Baraga on 3/16/22.
//

import Foundation


class Animal: BasicGame {
    
    private var a$ = Animal.defaultList
    static let defaultList = ["4", "/qDoes it swim/y2/n3", "/aFish", "/aBird"]
    static let key = "animals"
    
    init() {
        if let array = UserDefaults.standard.array(forKey: Self.key) as? [String] {
            a$ = array
        }
    }
    
    func run() {
        printHeader(title: "Animal")        
        println("Play 'Guess the Animal'")
        println("Think of an animal and the computer will try to guess it.")
        println()
        
        var entry = ""
        while !entry.isNo {
            entry = mainControlSection()
        }
    }
    
    //120 REM MAIN CONTROL SECTION
    private func mainControlSection() -> String {
        let entry = input("Are you thinking of an animal").lowercased()
        switch entry {
        case "list":
            printAnimals()
        case "reset":
            reset()
        case _ where entry.isYes:
            guessAnimal()
        case _ where entry.isNo:
            stop()
        default:
            break
        }
        
        return entry
    }
    
    //Lines 160-380
    private func guessAnimal() {
        var index = 1  //K
        while index < a$.count, a$[index].hasPrefix("/q") {
            index = askNextQuestion(at: index)
        }
        
        guard index < a$.count else {
            end()
        }
        
        let guess = a$[index].removingFirst(2)
        let response = input("Is it a " + guess)
        if response.isYes {
            println("Why not try another animal?")
        } else {
            let animal = input("The animal you were thinking of was a ")
            println("Please type in a question that would distinguish a")
            println(animal + " from a " + guess)
            let question = input()
            
            var answer = Response()
            while answer.isOther {
                answer = Response(input("For a " + animal + " the answer would be "))
            }
            
            a$.append(a$[index])
            a$.append("/a" + animal)
            let a1 = answer.isYes ? "/y" : "/n"
            let b1 = answer.isYes ? "/n" : "/y"
            a$[index] = "/q" + question + a1 + "\(a$.count - 1)" + b1 + "\(a$.count - 2)"
            a$[0] = "\(a$.count)"
        }
    }
    
    //390 REM SUBROUTINE TO PRINT QUESTIONS
    private func askNextQuestion(at index: Int) -> Int {
        var index = index
        let entry = a$[index].removingFirst(2)
        let components = entry.components(separatedBy: "/")
        guard components.count == 3 else {
            fatalError("Invalid question entry")
        }
        let question = components[0]
        let answer1 = components[1]
        let answer2 = components[2]
        
        var response = Response()
        while response.isOther {
            response = Response(input(question))
            if response.isYesOrNo {
                let t$ = response.isYes ? "y" : "n"
                if answer1.hasPrefix(t$) {
                    index = Int(answer1.removingFirst(1)) ?? a$.count
                    return index
                }
                if answer2.hasPrefix(t$) {
                    index = Int(answer2.removingFirst(1)) ?? a$.count
                    return index
                }
                 //Fallthrough line 505
                end()
            }
        }
        fatalError("A$ error")
    }
    
    //Lines 600-680
    private func printAnimals() {
        println()
        println("Animals I already know are:")
        var x = 0
        a$.forEach { entry in
            if entry.left(2) == "/a" {
                print(tab(x * 12), entry.removingFirst(2))
                x += 1
                if x > 5 {
                    println()
                    x = 0
                }
            }
        }
        println(2)
    }
    
    //Bonus save feature
    private func stop() {
        let count = a$.count
        let response = Response(input("Do you want to save the animal list"))
        switch response {
        case .yes:
            UserDefaults.standard.set(a$, forKey: Self.key)
            println("Animal list saved.")
        case .no:
            reset()
        default:
            break
        }
        
        if count > 4 { unlockEasterEgg(.animal) }
        end()
    }
    
    private func reset() {
        if input("Do you want to reset the list (this cannot be undone)").isYes {
            UserDefaults.standard.set(nil, forKey: Self.key)
            a$ = Self.defaultList
            println("Animal list reset to original.")
        }
    }
}
