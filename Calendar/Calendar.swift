//
//  Calendar.swift
//  Calendar
//
//  Created by Joseph Baraga on 2/19/22.
//

import Foundation


class Calendar: GameProtocol {
    
    func run() {
        printHeader(title: "Calendar")
        println(3)
        
        //Line 100 REM  VALUES FOR 1978 - SEE NOTES
        
        //Modification to allow user entry of year; uses algorithm from weekday to get first day of year
        var year = -1
        while year < 0 {
            let response = Int(input("Enter year")) ?? -1
            if response == 0 {
                showEasterEgg(.calendar)
                end()
                return
            }
            
            if response >= 1582 {
                year = response
            } else {
                println("Not able to provide a calendar prior to year MDLXXXII.")
            }
        }
        
        let isLeapYear: Bool = {
            if year % 400 == 0 {
                return true
            } else {
                if year % 100 == 0 {
                    return false
                } else {
                    if year % 4 == 0 {
                        return true
                    }
                }
            }
            return false
        }()
        
        var d = firstWeekday(for: year)
        let m = monthlyDays(isLeapYear: isLeapYear)
        var s = 0
        
        consoleIO.startHardcopy()
        
        //Lines 180-590
        for n in 1...12 {
            println(2)
            s += m[n-1]
            print("** \(s)")
            print(tab(7), String(repeating: "*", count: 18))
            switch n {
            case 1: print(" January ")
            case 2: print(" February")
            case 3: print("  March  ")
            case 4: print("  April  ")
            case 5: print("   May   ")
            case 6: print("   June  ")
            case 7: print("   July  ")
            case 8: print("  August ")
            case 9: print("September")
            case 10: print(" October ")
            case 11: print(" November")
            case 12: print(" December")
            default:
                fatalError("month index n out of range")
            }
            
            //Line 350
            print(String(repeating: "*", count: 18))
            print(" \(isLeapYear ? 366 - s : 365 - s) ")
            println("**")
            println()  //CHR$(10) = line feed
            println(tab(5), ["S","M","T","W","T","F","S"].joined(separator: String(repeating: " ", count: 7)))
            println()
            print(String(repeating: "*", count: 59))
                        
            //Line 420 REM
            var d2 = 0
            while d2 < m[n] {
                println(2) //CHR$(10) = Linefeed
                print(tab(4))
                //Line 460 REM
                for g in 1...7 {
                    d += 1
                    d2 = d - s
                    if d2 > m[n] {
                        d -= g  //Line 580
                        break
                    } else {
                        if d2 > 0 {
                            print(" \(d2) ")
                        }
                        print(tab(4 + 8 * g))
                    }
                }
            }
            println()
        }
        println(4)
        
        consoleIO.endHardcopy()
        wait(.long)
        
        let hardcopy = input("Would you like a hardcopy")
        if hardcopy.isYes {
            consoleIO.printHardcopy()
            wait(.long)
        }

        end()
    }
    
    //Lines 610-620
    private func monthlyDays(isLeapYear: Bool = false) -> [Int] {
        if isLeapYear {
            return [0,31,29,31,30,31,30,31,31,30,31,30,31]
        } else {
            return [0,31,28,31,30,31,30,31,31,30,31,30,31]
        }
    }
    
    //Line 1300 REM 1978 START ON SUNDAY (0=SUN, -1=MON, -2=TUES...)
    //Doomsday algorithm from Weekday, with d = 1, m = 1.
    private func firstWeekday(for y: Int) -> Int {
        let i1 = floor((Double(y) - 1500) / 100)  //Centuries since 1500 (? ref date)
        let a1 = i1 * 5 + (i1 + 3) / 4
        let i2 = Int(a1 - fnb(a1) * 7)
        let y2 = Int(Double(y) / 100)  //Centuries
        let y3 = Double(y - y2 * 100)  //Number of years since begin of century
        let a2 = y3 / 4 + y3 + Double(1 + i2)
        var b = Int(a2 - fnb(a2) * 7) + 1
        
        let t1 = y3 == 0 ? Int(a2 - fna(a2) * 4) : y - fna(y) * 4  //Zero if leap year
        if t1 == 0 {
            if b == 0 { b = 6 }
            b -= 1
        }
        if b == 0 { b = 7 }
        
        return 1 - b
    }
        
    private func fna(_ a: Int) -> Int {
        return a / 4
    }
    
    private func fna(_ a: Double) -> Double {
        return floor(a / 4)
    }
    
    private func fnb(_ a: Double) -> Double {
        return floor(a / 7)
    }
}
