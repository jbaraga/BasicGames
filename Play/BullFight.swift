//
//  BullFight.swift
//  play
//
//  Created by Joseph Baraga on 2/5/25.
//

import Foundation

class BullFight: BasicGame {
    
    private enum CapeMove: Int {
        case veronica, outside, swirl
        
        //850-920
        var doubleValue: Double {  //M
            //850 REM
            switch self {
            case .veronica: return 3
            case .outside: return 2
            case .swirl: return 0.5
            }
        }
    }
    
    private enum KillMethod: Int {
        case overHorns = 4, chest
    }
    
    private enum Grade: Int, CustomStringConvertible, CaseIterable {
        case superb = 1, good, fair, poor, awful
        
        var description: String {
            switch self {
            case .superb: return "Superb"
            case .good: return "Good"
            case .fair: return "Fair"
            case .poor: return "Poor"
            case .awful: return "Awful"
            }
        }
        
        //1610-1750
        init(b: Double) {
            if b < 0.37 { self = .awful }  // 3/8
            else if b < 0.5 { self = .poor }  // 4/8
            else if b < 0.63 { self = .fair }  // 5/8
            else if b < 0.87 { self = .good }  // 7/8
            else { self = .superb }
        }
        
        var doubleValue: Double { Double(rawValue) / 10 }  //C
    }
    
    private enum Fighter: CustomStringConvertible {
        case picador, toreador, matador
        
        var description: String {
            switch self {
            case .picador: return "picadores"
            case .toreador: return "toreadores"
            case .matador: return "matador"
            }
        }
    }
    
    private struct Status {
        var bullGrade: Grade  //A
        var picatoreGrade: Grade  // D(1)
        var toreadorGrade: Grade  // D(2)
        var pass = 0  // D(3)
        var matadorScore = 1.0  // D(4)
        var isBullAlive = true  // D(5)
        var capeMoveSum = 1.0  // L
        var attemptedKill = false  //Z
        
        var a: Double { Double(bullGrade.rawValue) }
        var d1: Double { picatoreGrade.doubleValue }
        var d2: Double { toreadorGrade.doubleValue }
        var d3: Double { Double(pass) }
        var d4: Double { matadorScore }
        var d5: Double { isBullAlive ? 1 : 2 }
        var l: Double { capeMoveSum }
        
        
        //940, factoring out rnd()
        func factor(for capeMove: CapeMove) -> Double {
            let m = capeMove.doubleValue
            return (6 - a + m / 10) / ((d1 + d2 + d3 / 10) * 5)
        }
        
        //1230
        func k(for rnd: Double) -> Double { (6 - a) * 10 * rnd / ((d1 + d2) * 5 * d3) }
        
        //1390 here q is used to pass rnd(1)
        func fnc(q: Double) -> Double { fncd() * q }
        
        //1395
        func fncd() -> Double { 4.5 + l / 6 - (d1 + d2) * 2.5 + 4 * d4 + 2 * d5 - d3 * d3 / 120 - a }
        
        mutating func nextPass() -> Int {
            pass += 1
            return pass
        }
    }
    
    func run() {
        printHeader(title: "Bull")
        
        if Response(input("Do you want instructions")) != .no {
            println("Hello, all you bloodlovers and aficionados")
            println("Here is your big chance to kill a bull")
            println()
            println("On each pass of the bull, you may try")
            println("0 - Veronica (dangerous inside move of the cape)")
            println("1 - less dangerous outside move of the cape")
            println("2 - ordinary swirl of the cape")
            println()
            println("Instead of the above, you may try to kill the bull")
            println("on any turn: 4 (over the horns), 5 (in the chest)")
            println("but if I were you,")
            println("I wouldn't try it before the seventh pass.")
            println()
            println("The crowd will determine what award you deserve")
            println("posthumously if necessary")
            println("The braver you are, the better award you receive")
            println()
            println("The better a job the picadores and toreadores do,")
            println("the better your chances are")
        }
        
        println()
        println()
        
        play()
    }
    
    private func play() {
        let bullGrade = Grade.allCases.randomElement() ?? .superb  //L$[A]
        println("You have drawn a \(bullGrade) bull.")
        if bullGrade.rawValue > 4 {
            println("You're lucky.")
        } else if bullGrade.rawValue < 2 {
            println("Good luck.  You'll need it.")
            println()
        }
        println()
        
        let picadoreGrade = attack(by: .picador, bullGrade: bullGrade)  //D(1)
        let toreadoreGrade = attack(by: .toreador, bullGrade: bullGrade)  //D(2)
        var status = Status(bullGrade: bullGrade, picatoreGrade: picadoreGrade, toreadorGrade: toreadoreGrade)
        
        //660-1100
        repeat {
            println(2)
            if status.attemptedKill { finale(status: status) }
            
            println("Pass number \(status.nextPass())")
            
            if status.pass < 3 {
                println("The bull is charging at you!  Your are the Matador--")
                print("Do you want to kill the bull")
            } else {
                print("Here comes the bull.  Try for a kill")
            }
            
            if getResponse() == .yes {
                killBull(status: &status)
            } else {
                print(status.pass < 3 ? "What move do you make with the cape" : "Cape move")
                let capeMove = getCapeMove()
                status.capeMoveSum += capeMove.doubleValue
                let f = status.factor(for: capeMove) * rnd()  //940
                if f >= 0.51 {
                    println("The bull has gored you")  //960
                    bullGore(status: &status)
                }
            }
        } while status.isBullAlive
    }
    
    //800-840
    private func getCapeMove() -> CapeMove {
        guard let rawValue = Int(input()), let move = CapeMove(rawValue: rawValue) else {
            println("Don't panic, you idiot!  Put down a correct number")
            return getCapeMove()
        }
        return move
    }
    
    //970-1120
    private func bullGore(status: inout Status) {
        switch fna() {
        case 1:
            println("You are dead")
            status.matadorScore = 1.5
            finale(status: status)
        case 2:
            println("You are still alive")
            print("Do you run from the ring")
            if getResponse() == .no {
                println("You are brave.  Stupid, but brave.")
                switch fna() {
                case 1:
                    status.matadorScore = 2
                case 2:
                    println("You are gored again")
                    bullGore(status: &status)
                default:
                    fatalError(#function)
                }
            } else {
                println("Coward")
                status.matadorScore = 0
                finale(status: status)
            }
        default:
            fatalError(#function)
        }
    }
    
    //1130-1300
    private func killBull(status: inout Status) {
        //1130 REM
        status.attemptedKill = true
        println("It is the moment of truth.")
        guard let rawValue = Int(input("How do you try to kill the bull")), let method = KillMethod(rawValue: rawValue) else {
            println("You panicked.  The bull gored you.")
            bullGore(status: &status)
            return
        }
        
        let k = status.k(for: rnd())
        //Line 140 bug, J should be K
        let goreThreshold = method == .overHorns ? 0.8 : 0.2
        if k > goreThreshold {
            println("The bull has gored you")
            bullGore(status: &status)
        } else {
            println("You killed the bull")
            status.isBullAlive = false
            finale(status: status)
        }
    }
     
    //1310-1570
    private func finale(status: Status) -> Never {
        println(3)
        if status.matadorScore == 0 {
            println("The crowd boos for ten minutes.  If you ever dare to show")
            println("your face in a ring again, they swear they will kill you--")
            println("unless the bull does first.")
            adios()
        }
        
        if !status.isBullAlive {
            println("The crowd cheers" + ( status.matadorScore == 2 ? " wildly" : ""))
        }
        println("The crowd awards you")
        
        //1460-1570 FNC(Q) is recomputed for each if statement
        if status.fnc(q: rnd()) < 2.5 {
            println("Nothing at all")
        } else if status.fnc(q: rnd()) < 4.9 {
            println("One ear of the bull")
        } else if status.fnc(q: rnd()) < 7.4 {
            println("Both ears of the bull")
            println("Ole!")
        } else {
            println("Ole!  You are 'Muy Hombre'!! Ole!  Ole!")
            unlockEasterEgg(.bullfight)
        }
        
        adios()
    }
    
    //1580-1600
    private func adios() -> Never {
        println()
        println("Adios")
        end()
    }
    
    //1610-1910
    private func attack(by fighter: Fighter, bullGrade: Grade) -> Grade {
        let attackGrade = Grade(b: 3 / Double(bullGrade.rawValue) * rnd())
        println("The \(fighter) did a \(attackGrade) job.")
        switch attackGrade {
        case .poor: //1790 T == 4
            if fna() == 1 {
                println("One of the \(fighter) was killed.")
            } else {
                println("No \(fighter) were killed.")
            }
            //1800-1820 should never be executed
        case .awful:  //1870 T == 5
            switch fighter {
            case .toreador:
                println(" \(fna()) of the horses of the \(fighter) killed.")
            case .picador:
                println(" \(fna()) of the \(fighter) killed.")
            case .matador:
                break
            }
        default:
            break
        }
        
        println()
        return attackGrade
    }
    
    //1920-2020
    private func getResponse() -> Response {
        //1920 REM
        let response = Response(input())
        if response.isOther {
            println("Incorrect answer - - please type 'yes' or 'no")
            return getResponse()
        }
        return response
    }
    
    //30
    private func fna() -> Int { Int.random(in: 1...2) }
}
