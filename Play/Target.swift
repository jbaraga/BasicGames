//
//  Target.swift
//  Target
//
//  Created by Joseph Baraga on 3/24/22.
//

import Foundation


class Target: BasicGame {
    
    //Line 100
    //let r = 1
    //let r1 = 57.296 (180 / pi) - degrees per radian
    //let p = 3.141592  //pi
    
    func run() {
        printHeader(title: "Target")
        println("You are the weapons officer on the Starship Enterprise")
        println("and this is a test to see how accurate a shot you")
        println("are in a three-dimensional range.  You will be told")
        println("the radian offset for the x and z axes, the location")
        println("of the target in three dimensional rectangle coordinates,")
        println("the approximate number of degrees from the x and z")
        println("axes, and the approximate distance to the target.")
        println("You will then proceed to shoot at the target until it is")
        println("destroyed!")
        println()
        println("Good Luck!!")
        println(2)
        
        while true {
            newTarget()
            wait(.short)
            
            //Lines 580-590
            println(5)
            println("Next target...")
            wait(.short)
            println()
        }
    }
    
    //Lines 220-570
    private func newTarget() {
        let a = rnd(1) * 2 * .pi  //radians deviation from x axis
        let b = rnd(1) * 2 * .pi  //radians deviation from z axis
        let q = Int(round(a * 180 / .pi))
        let w = Int(round(b * 180 / .pi))
        println(String(format: "Radians from x axis = %.5f;   from z axis = %.5f", a, b))
        println("Approx degrees from x axis = \(q)   from z axis = \(w)")  //From original 1975 code
        
        let p1 = 100000 * rnd(1) + rnd(1)
        let x = sin(b) * cos(a) * p1
        let y = sin(b) * sin(a) * p1
        let z = cos(b) * p1
        println(String(format: "Target sighted: approx coordinates x =%.1f   y=%.1f   z=%.1f", x, y, z))
        
        var d = p1
        var r = 0
        //Line 345 - loop
        repeat {
            r += 1
            
            let p3: Double
            switch r {
            case 1: p3 = floor(p1 * 0.05) * 20
            case 2: p3 = floor(p1 * 0.1) * 10
            case 3: p3 = floor(p1 * 0.5) * 2
            case 4: p3 = floor(p1)
            default: p3 = p1
            }
            let digits = r < 4 ? 0 : 1
            println(String(format: "     Estimated distance= %.\(digits)f", p3))
            
            let parameters = getTargetParameters()
            println()

            let a1 = parameters.x * .pi / 180
            let b1 = parameters.z * .pi / 180
            let p2 = parameters.distance
            
            if p2 < 20 {
                wait(.short)
                return
            }
            
            println(String(format: "Radians from x axis = %.5f from z axis = %.5f", a1, b1))
            let x1 = p2 * sin(b1) * cos(a1)
            let y1 = p2 * sin(b1) * sin(a1)
            let z1 = p2 * cos(b1)
            let x2 = x1 - x
            let y2 = y1 - y
            let z2 = z1 - z
            d = sqrt(pow(x2, 2) + pow(y2, 2) + pow(z2, 2))
            
            if d > 20 {
                //Lines 670-830
                if x2 < 0 {
                    println(String(format: "Shot behind target %.3f kilometers.", -x2))
                } else {
                    println(String(format: "Shot in front of target %.3f kilometers.", x2))
                }
                
                if y2 < 0 {
                    println(String(format: "Shot to right of target %.3f kilometers.", -y2))
                } else {
                    println(String(format: "Shot to left of target %.3f kilometers.", y2))
                }
                
                if z2 < 0 {
                    println(String(format: "Shot below target %.3f kilometers.", -z2))
                } else {
                    println(String(format: "Shot above target %.3f kilometers.", z2))
                }
                
                println(String(format: "Approx position of explosion:  x=%.2f   y=%.2f   z=%.2f", x1, y1, z1))
                println(String(format: "     Distance from target = %.3f", d))
                println(3)
                wait(.short)
            }
        } while d > 20
        
        println()
        println(" * * * Hit * * *   Target is non-functional")
        println()
        println(String(format: "Distance of explosion from target was %.4f kilometers", d))
        println()
        println("Mission accomplished in \(r) shots.")
        wait(.short)
        
        if r < 4 { unlockEasterEgg(.target) }
    }
    
    //Lines 400-405
    private func getTargetParameters() -> (x: Double, z: Double, distance: Double) {
        let string = input("Input angle deviation from x, deviation from z, distance")
        let values = string.components(separatedBy: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        guard values.count == 3 else {
            return getTargetParameters()
            
        }
        return (values[0], values[1], values[2])
    }
}
