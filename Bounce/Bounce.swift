//
//  Bounce.swift
//  Bounce
//
//  Created by Joseph Baraga on 3/27/22.
//

import Foundation


class Bounce: GameProtocol {
    
    func run() {
        printHeader(title: "Bounce")
        println(3)
        println("This simulation lets you specify the initial velocity")
        println("of a ball thrown straight up, and the coefficient of")
        println("elasticity of the ball.  Please use a decimal fraction")
        println("coefficiency (less than 1).")
        println()
        println("You also specify the time increment to be used in")
        println("'strobing' the ball's flight (try .1 initially).")
        println("")
        bounce()
    }
    
    private func bounce() {
        let increment = Double(input("Time increment (sec)")) ?? 0.1  //s2
        println()
        let velocity = Double(input("Velocity (fps)")) ?? 30  //v
        println()
        let coefficient = Double(input("Coefficient")) ?? 0.9  //c
        println()
        println("Feet")
        println()
        
        //Need egg
        
        //Number of up-down parabolas; time to first bounce is velocity * 2 / g = velocity / 16
        //Number of time increments to first bounce is velocity / 16 / increment; 70 if maximum total number of time increments plotted
        //Total number of up-down parabolas plotted is floor of 70 / number of time increments to first bounce (subsequent bounces will be shorter
        let s1 = Int(70 / (velocity / (16 * increment)))
        let t = [0.0] + ((1...s1).map { velocity * pow(coefficient, Double($0 - 1)) / 16 })  //1 indexed - time interval to complete each up-down parabola (bounce to bounce)
        
        //Maximum height is reached at time t = v / g, maximum height = v²/(2*g); original adds 0.5 to effectively round up
        let max = round(velocity * velocity / 64)  //Original code Int(-16 * pow(velocity / 32, 2) + pow(velocity, 2) / 32 + 0.5)
        var l = 0.0
        for h in stride(from: max, through: 0, by: -0.5) {
            var cursor = 0 //Cursor position in current line, for correct tab calcuation
            if floor(h) == h {
                let yLabel = " \(Int(h))"
                print(yLabel)
                cursor += yLabel.count
            }
            l = 0.0  //Time increment counter
            for i in 1...s1 {  //Iterates through each bounce
                let v0 = velocity * pow(coefficient, Double(i - 1))  //Initial velocity at beginning of parabola (after bounce)
                for t1 in stride(from: 0, through: t[i], by: increment) {
                    l += increment
                    //Ball height after bounce = v * t - 1/2 * g * t² where v = velocity at start of bounce, and t is elapsed time since bounce
                    //v = v0 * coefficient^(bounce #) where v0 = initial velocity
                    if abs(h - (v0 * t1 - 16 * t1 * t1)) <= 0.25 {
                        print(tab(Int(l / increment) + 2 - cursor) + "O")   //Adds left padding of 3 so curve starts correctly at time 0 on printout
                        cursor = Int(l / increment) + 3
                    }
                }
                
//In original code, to shorten loop; if peak height of bounce less than current height can end loop
//                let t1 = i + 1 < t.count ? t[i + 1] / 2 : 0
//                if v0 * t1 - 16 * t1 * t1 < h {
//                    break
//                }
            }
            println()
        }
        
        //In original the x axis if shifted to left by 2
        print(tab(2))
        println(String(repeating: ".", count: Int((l + 1) / increment + 1)))
        print(tab(2))
        Array(0...Int(l + 0.9995)).forEach { value in
            printTab("\(value)", tab: Int(1 / increment))
        }
        println()
        println(tab(Int((l + 1) / (2 * increment) - 2) + 1) + "Seconds")
        println(3)
        wait(.long)
    }
}
