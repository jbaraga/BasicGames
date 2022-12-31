//
//  3DPlot.swift
//  3DPlot
//
//  Created by Joseph Baraga on 3/19/22.
//

import Foundation


class TDPlot: GameProtocol {
    
    private enum Function: Int, CaseIterable {
        case e
        case squareRoot
        case cosine
        case sine1
        case eCosine
        case sine2
        
        var stringValue: String {
            switch self {
            case .e:
                return "30*exp(-z*z/100)"
            case .squareRoot:
                return "sqr(900.01-z*z)*.9-2"
            case .cosine:
                return "30*(cos(z/16)+2)"
            case .sine1:
                return "30-30*sin(z/18)"
            case .eCosine:
                return "30*exp(-cos(z/16))-30"
            case .sine2:
                return "30*sin(z/10)"
            }
        }
        
        func a(_ z: Double) -> Double {
            switch self {
            case .e:
                return 30 * exp(-z * z / 100)
            case .squareRoot:
                return sqrt(900.01 - z * z) * 0.9 - 2
            case .cosine:
                return 30 * (cos(z / 16) + 2)
            case .sine1:
                return 30 - 30 * sin(z / 18)
            case .eCosine:
                return 30 * exp(-cos(z / 16)) - 30
            case .sine2:
                return 30 * sin(z / 10)
            }
        }
    }
    
    func run() {
        printHeader(title: "3D Plot")
        println(3)
        
        //Added code to select function
        println("Select a function to plot")
        Function.allCases.forEach {
            println(" \($0.rawValue + 1): " + $0.stringValue)
        }
        
        var selection: Function?
        while selection == nil {
            selection = Function(rawValue: (Int(input("Enter (1 - \(Function.allCases.count))")) ?? 0) - 1)
        }
        
        guard let fn = selection else {
            fatalError("Selection out of bounds")
        }
        
        println(3)
        for x in stride(from: -30, through: 30, by: 1.5) {
            var l = 0
            let y1 = Double(5 * Int(sqrt(900 - x * x) / 5))
            for y in stride(from: y1, through: -y1, by: -5) {
                let z = Int(25 + fn.a(sqrt(x * x + y * y)) - 0.7 * y)
                if z > l {
                    print(tab(z), "*")
                    l = z
                }
            }
            println()
        }
        println(3)
        
        wait(.long)
        let response = Response(input("Run again"))
        switch response {
        case .yes:
            wait(.short)
            consoleIO.clear()
            run()
        case .no:
            end()
        case .easterEgg:
            showEasterEgg(.threeDPlot)
            wait(.long)
            end()
        case .other:
            end()
        }
    }
}
