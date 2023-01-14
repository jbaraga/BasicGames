//
//  Orbit.swift
//  Orbit
//
//  Created by Joseph Baraga on 1/1/23.
//

import Foundation


class Orbit: GameProtocol {
    
    func run() {
        printHeader(title: Game.orbit.title)
        println(3)
        println("Somewhere above your planet is a Romulan ship.")
        println()
        println("The ship is in a constant polar orbit.  Its")
        println("distance from the center of your planet is from")
        println("10,000 to 30,000 miles and at its present velocity can")
        println("circle your plane once every 12 to 36 hours.")
        println()
        println("Unfortunately they are using a cloaking device so")
        println("you are unable to see them, but with a special")
        println("instrument you can tell how near their ship your")
        println("photon bomb exploded.  You have seven hours until they")
        println("have built up sufficient power in order to escape")
        println("your planet's gravity.")
        println()
        println("Your planet has enough power to fire one bomb an hour.")
        println()
        println("At the beginning of each hour you will be asked to give an")
        println("angle (between 0 and 360) and a distance in units of")
        println("100 miles (between 100 and 300), after which your bomb's")
        println("distance from the enemy ship will be given.")
        println()
        println("An explosion within 5,000 miles of the Romulan ship")
        println("will destroy it.")
        println()
        println("Below is a diagram to help you visualize your plight.")
        println(2)
        println("                          90")
        println("                          ^")
        println("                    0000000000000")
        println("                 0000000000000000000")
        println("               000000           000000")
        println("             00000                 00000")
        println("            00000    XXXXXXXXXXX    00000")
        println("           00000    XXXXXXXXXXXXX    00000")
        println("          0000     XXXXXXXXXXXXXXX     0000")
        println("         0000     XXXXXXXXXXXXXXXXX     0000")
        println("        0000     XXXXXXXXXXXXXXXXXXX     0000")
        println("180<== 00000     XXXXXXXXXXXXXXXXXXX     00000 ==>0")
        println("        0000     XXXXXXXXXXXXXXXXXXX     0000")
        println("         0000     XXXXXXXXXXXXXXXXX     0000")
        println("          0000     XXXXXXXXXXXXXXX     0000")
        println("           00000    XXXXXXXXXXXXX    00000")
        println("            00000    XXXXXXXXXXX    00000")
        println("             00000                 00000")
        println("               000000           000000")
        println("                 0000000000000000000")
        println("                    0000000000000")
        println("                          !")
        println("                         270")
        println()
        println("X - Your planet")
        println("0 - The orbit of the Romulan ship")
        println()
        println("On the above diagram, the Romulan ship is circling")
        println("counterclockwise around your planet.  Don't forget")
        println("without sufficient power the Romulan ship's altitude")
        println("and orbital rate will remain constant.")
        println()
        println("Good luck.  The Federation is counting on you.")
        
        play()
    }
    
    private func play() {
        //Ship location in polar coordinates
        var a = Int(360 * rnd(1))  //angle of ship in direction of orbit
        //Line 280 - let d = Int(200 * rnd(1) + 200) - bug?
        let d = Int(100 * rnd(1) + 200)  //Altitude of ship
        let r = Int(20 * rnd(1) + 10)  //Radial velocity of ship
        
        var h = 0  //Hours
        while h < 7 {
            h += 1
            println(2)
            println("Hour \(h) , at what angle do you wish to send")
            let a1 = Int(input("your photon bomb")) ?? 0
            let d1 = Int(input("How far out do you wish to detonate it")) ?? 0
            println()
            
            a += r
            if a >= 360 { a -= 360 }
            var t = abs(a - a1)  //Angular separation between bomb and ship
            if t >= 180 { t = 360 - t }
            let c = sqrt(Double(d * d) + Double(d1 * d1) - 2 * Double(d * d1) * cos(Double(t) * .pi / 180))
            
            println("Your photon bomb exploded \(Int(round(c))) *10^2 miles from the")
            println("Romulan ship.")
                    
            if c <= 50 {
                println("You have successfully completed your mission.")
                tryAgain(success: true)
                return
            }
        }
        
        println("You have allowed the Romulans to escape.")
        tryAgain()
    }
    
    private func tryAgain(success: Bool = false) {
        println("Another Romulan ship has gone into orbit.")
        let response = Response(input("Do you wish to try to destroy it"))
        switch response {
        case .yes:
            play()
            return
        case .easterEgg:
            if success {
                showEasterEgg(.orbit)
            }
        default:
            break
        }
        
        println("Good bye.")
        end()
    }
}
