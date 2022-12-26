//
//  Rocket.swift
//  Rocket
//
//  Created by Joseph Baraga on 2/10/22.
//

import Foundation


class Rocket: GameProtocol {
    
    func run() {
        printHeader(title: "Rocket")
        println(3)
        println("Lunar Landing Simulation")
        println("----- ------- ----------")
        println()
        let response = input("Do you want instructions (yes or no)")
        if response.isYes {
            printInstructions()
            wait(.long)
        }
        
        performLanding()
    }
    
    private func performLanding() {
        println("Beginning landing procedure.....")
        println()
        println("G O O D  L U C K ! ! !")
        println(2)
        println("SEC" + tab(2) + "FEET" + tab(3) + "SPEED" + tab(3) + "FUEL" + tab(5) + "PLOT OF DISTANCE")
        println()
        
        var t = 0  //Elapsed time (s)
        var h = 500.0  //Height (ft)
        var v = 50.0  //Velocity (ft/s)
        var v1 = 50.0  //End segment velocity (ft/s)
        var f = 120.0  //Fuel remaining (fuel units)
        var b = 0.0  //Burn (fuel units) - 1 unit = 1 ft/s decrease in end velocity
        
        //Main loop
        while h > 0 {
            printTab(" \(t)", tab: 5)
            printTab(String(format: "%.1f", h), tab: 7)
            printTab(String(format: "%.1f", v), tab: 8)
            printTab(String(format: "%.1f", f), tab: 9)
            println("I" + tab(Int(round(h/12))) + "*")
            b = f > 0 ? Double(input()) ?? 0 : 0  //Only input for burn rate while fuel available
            if b < 0 { b = 0 }
            if b > 30 { b = 30 }
            if b > f { b = f }
            v1 = v - b + 5  //Segment end velocity = start velocity - burn + gravity * 1 sec?
            f -= b
            h = h - 0.5 * (v + v1)  //Average velocity used to calculate distance
            if h > 0 {
                t += 1
                v = v1
                if f <= 0 && f + b > 0  {
                    println("**** OUT OF FUEL ****")
                }
            }
        }
        
        //Contact
        println("**** CONTACT ****")
        h = h + 0.5 * (v + v1)
        let d = b == 5 ? h / v : (-v + sqrt(v * v + h * (10 - 2 * b))) / (5 - b)
        v1 = v + (5 - b) * d
        let timeString = formatter.string(from: Double(t) + d)
        let velocityString = formatter.string(from: v1)
        println("Touchdown at " + timeString + " seconds.")
        println("Landing velocity = " + velocityString + " feet/sec.")
        println("\(Int(round(f))) units of fuel remaining.")
        
        let v2 = Int(abs(v1))
        switch v2 {
        case 0:
            println("Congratulations!  A perfect landing!")
            println("Your license will be renewed.......later")
        case _ where v2 >= 2:
            println("***** Sorry, but you blew it!!!!")
            println("Appropriate condolences will be sent to your next of kin.")
        default:
            break
        }
        println(3)
        wait(.short)
        
        let response = input("Another mission")
        
        if response.isEasterEgg, v2 < 2 {
            showEasterEgg(Egg.rocket.filename)
        }
        
        if response.isYes {
            performLanding()
        } else {
            println("Control out.")
            end()
        }
    }
    
    private func printInstructions() {
        println()
        println("You are landing on the moon and have taken over manual")
        println("control 500 feet above a good landing spot.  You have a")
        println("downward velocity of 50 ft/sec.  120 units of fuel remain.")
        println()
        println("Here are the rules that govern your space vehicle:")
        println("(1) After each second, the height, velocity, and remaining")
        println("    fuel will be reported.")
        println("(2) After the report, a '?' will be typed.  Enter the")
        println("    number of units of fuel you wish to burn during the")
        println("    next second.  Each unit of fuel will slow your descent")
        println("    by 1 ft/sec.")
        println("(3) The maximum thrust of your enging is 30 ft/sec/sec or")
        println("    30 units of fuel per second.")
        println("(4) When you contact the lunar surface, your descent engine")
        println("    will automatically cut off and you will be given a")
        println("    report of your landing speed and remaining fuel.")
        println("(5) If you run out of fuel, the '?' will no longer appear,")
        println("    but your second-by-second report will continue until")
        println("    you contact the lunar surface.")
        println()
    }
}
