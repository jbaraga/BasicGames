//
//  Splat.swift
//  Splat
//
//  Created by Joseph Baraga on 3/22/22.
//

import Foundation


class Splat: GameProtocol {
    
    private var chuteOpenAltitudes = [Double]()  //Array A - history of chute opening altitudes
    static let key = "altitudes"
    
    init() {
        if let array = UserDefaults.standard.array(forKey: Self.key) as? [Double] {
            chuteOpenAltitudes = array
        }
    }
    
    func run() {
        printHeader(title: "Splat")
        println(3)
        
        println("Welcome to 'Splat' -- the game that simulates a parachute")
        println("jump.  Try to open your chute at the last possible")
        println("moment without going splat.")
        
        getInputs()
    }
    
    //Lines 118-
    private func getInputs() {
        println(2)
        
        var v1 = 0.0  //Terminal velocity (mi/hr)
        var a2 = 0.0  //Acceleration (ft/sec/sec)
        let d1 = round(9001 * rnd(1) + 1000)
        
        var response = Response.other
        print(" Select your own terminal velocity (yes or no)")
        while !response.isYesOrNo {
            response = Response(input())
            if !response.isYesOrNo {
                print("Yes or no")
            }
        }
        if response.isYes, let velocity = Double(input("What terminal velocity (mi/hr)")), velocity > 0 {
            v1 = velocity * 5280 / 3600  //Convert to feet per second
        } else {
            let velocity = round(1000 * rnd(1))
            println("Ok.  Terminal velocity = \(Int(velocity)) mi/hr")
            v1 = velocity * 5280 / 3600  //Convert to feet per second
        }
        let v = v1 + (v1 * rnd(1) / 20) - (v1 * rnd(1) / 20)  //Add random error
        
        response = .other
        print("Want to select accleration due to gravity (yes or no)")
        while !response.isYesOrNo {
            response = Response(input())
            if !response.isYesOrNo {
                print("Yes or no")
            }
        }
        
        if response.isYes, let accel = Double(input("What acceleration (ft/sec/sec)")), accel > 0 {
            a2 = accel
        } else {
            switch Int(1 + 10 * rnd(1)) {
            case 1:
                println("Fine. You're on Mercury. Acceleration=12.2ft/sec/sec")
                a2 = 12.2
            case 2:
                println("Alright. You're on Venus. Acceleration=28.3ft/sec/sec")
                a2 = 28.3
            case 3:
                println("The you're on Earth. Acceleration=32.16ft/sec/sec")
                a2 = 32.16
            case 4:
                println("Fine. You're on the Moon. Acceleration=5.15ft/sec/sec")
                a2 = 5.15
            case 5:
                println("Alright. you're on Mars. Acceleration=12.5ft/sec/sec")
                a2 = 12.5
            case 6:
                println("Then you're on Jupiter. Acceleration=85.2ft/sec/sec")
                a2 = 85.2
            case 7:
                println("Fine. You're on Saturn. Acceleration=37.6ft/sec/sec")
                a2 = 37.6
            case 8:
                println("Alright. You're on Uranus. Acceleration=33.8ft/sec/sec")
                a2 = 33.8
            case 9:
                println("Then you're on Neptune. Acceleration=39.6ft/sec/sec")
                a2 = 39.6
            case 10:
                println("Fine. You're on the Sun. Acceleration=896ft/sec/sec")
                a2 = 12.2
            default:
                fatalError("Impossible case")
            }
        }
        let a = a2 + (a2 * rnd(1) / 20) - (a2 * rnd(1) / 20)  //Add random error

        println()
        println("    Altitude         = \(Int(d1)) ft")
        println("    Term.Velocity    = \(Int(v1)) ft/sec +-5%")
        println("    Acceleration     = " + String(format: "%.1f", a2) + " ft/sec/sec +-5%")
        println("Set the timer for your freefall.")
        
        let t = Double(input("How many seconds")) ?? 0
        print("Here we go.")
        println()
        
        jump(d1: d1, v: v, a: a, t: t)
        
        //Line 2000
        response = .other
        print("Do you want to play again")
        while !response.isYesOrNo {
            response = Response(input())
            if response == .easterEgg {
                showEasterEgg(Egg.splat.filename)
                wait(.long)
                end()
                return
            }
            if response == .other {
                print("Yes or no")
            }
        }
        
        if response == .yes {
            getInputs()
            return
        }
        
        println("SSSSSSSSSS.")
        wait(.short)
        
        println()
        promptForReset()
        
        end()
    }
    
    //Lines 218-
    private func jump(d1: Double, v: Double, a: Double, t: Double) {
        println("Time (sec)" + tab(4) + "Dist to Fall (Ft)")
        println(String(repeating: "=", count: 10) + tab(4) + String(repeating: "=", count: 17))
        
        var d = d1
        for i in stride(from: 0, through: t, by: t / 8) {
            if i < v/a {
                d = d1 - ((a / 2) * i * i)
                if d <= 0 {
                    //Line 1000
                    println(String(format: "%.6f Splat", sqrt(2 * d1 / a)))
                    splatMessage()
                    return
                }
                
                printTab("\(i)", tab: 15)
                println("\(d)")
            } else {
                println(String(format: "Terminal velocity reached at T plus %.6f seconds", v / a))
                for i1 in stride(from: i, through: t, by: t / 8) {
                    d = d1 - ((v * v / (2 * a)) + v * (i1 - v / a))
                    if d <= 0 {
                        //Line 1010
                        println(String(format: "%.6f Splat", v / a + (d1 - v * v / (2 * a))))
                        splatMessage()
                        return
                    }
                    
                    printTab("\(i1)", tab: 15)
                    println("\(d)")
                }
                break
            }
        }
        
        //Line 500
        println("Chute Open")
        
        //Lines 510-751 - Rewritten using shootOpenAltitudes array
        let k = chuteOpenAltitudes.count
        if k < 3 {
            let jumpNumber = k == 0 ? "1st" : ( k == 1 ? "2nd" : "3rd")
            println("Amazing!!! Not bad for your " + jumpNumber + " successful jump!!!")
            chuteOpenAltitudes.append(d)
        } else {
            let sortedAltitudes = chuteOpenAltitudes.sorted()
            let placement = sortedAltitudes.firstIndex(where: { d < $0 }) ?? k  // k - k1
            chuteOpenAltitudes.append(d)
            
            if placement <= Int(0.1 * Double(k)) {
                println("Wow!  That's some jumping.  Of the \(k) successful jumps")
                println("before yours, only \(placement) opened their chutes lower than")
                println("you did.")
            }
            else if placement <= Int(0.25 * Double(k)) {
                println("Pretty good!  \(k) successful jumps preceded yours and only")
                println("\(placement) of them got lower than you did before their chutes")
                println("opened.")
            }
            else if placement <= Int(0.5 * Double(k)) {
                println("Not bad.  There have been \(k) successful jumps before yours.")
                println("You were beaten out by \(placement) of them.")
            }
            else if placement <= Int(0.75 * Double(k)) {
                println("Conservative, aren't you?  You ranked only \(k) in the")
                println("\(k) successful jumps before yours.")
            }
            else if placement <= Int(0.9 * Double(k)) {
                println("Humph!  Don't you have any sporting blood?  There were")
                println("\(k) successful jumps before yours and you came in \(k - placement) jumps")
                println("better than the worst.  Shape up!!!")
            }
            else {
                println("Hey!  You pulled the rip cord much too soon.  \(k) successful")
                println("jumps before yours and you came in number \(placement)!  Get with it!")
            }
        }
    }
    
    private func splatMessage() {
        switch Int(1 + 10 * rnd(1)) {
        case 1: println("Requiescat in pace.")
        case 2: println("May the angel of heaven lead you into paradise")
        case 3: println("Rest in peace")
        case 4: println("Son-of-a-gun")
        case 5: println("#$%&&&!$")
        case 6: println("A kick in the pants is a boost if you're headed right")
        case 7: println("Hmmm. Should have picked a shorter time.")
        case 8: println("Mutter. Mutter. Mutter.")
        case 9: println("Pushing up daisies.")
        case 10: println("Easy come, easy go.")
        default:
            fatalError("Impossible case - you and the program crashed.")
        }
        
        println("I'll give you another chance.")
    }
    
    private func promptForReset() {
        if input("Do you want to save the prior jumps").isYes {
            UserDefaults.standard.set(chuteOpenAltitudes, forKey: Self.key)
            println("Jump history saved.")
        } else {
            UserDefaults.standard.set(nil, forKey: Self.key)
        }
    }
}
