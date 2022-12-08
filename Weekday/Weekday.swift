//
//  Weekday.swift
//  Weekday
//
//  Created by Joseph Baraga on 2/17/22.
//

import Foundation


class Weekday: GameProtocol {
    
    private typealias Interval = (years: Int, months: Int, days: Int)
    
    func run() {
        printHeader(title: "Weekday")
        println(3)
        println("Weekday is a computer demonstration that")
        println("gives facts about a date of interest to you.")
        println()
        let (m1,d1,y1) = date(from: input("Enter today's date in the form: 3,24,1978"))
        
        //150 REM THIS PROGRAM DETERMINES THE DAY OF THE WEEK
        //160 REM  FOR A DATE AFTER 1582
        
        let (m,d,y) = date(from: input("Enter day of birth (or other day of interest)"))
        println()
        
        if m == 0 && d == 0 && y == 0 {
            showEasterEgg("Weekday")
            end()
        }
        
        //280 REM TEST FOR DATE BEFORE CURRENT CALENDAR.
        guard y >= 1582 else {
            println("Not prepared to give day of week prior to MDLXXXII.")
            stop()
            return
        }
        
        guard m > 0 && m < 13 && d > 0 && d < 32 else {
            fatalError("Illegal date")
        }
        
        let b = weekday(y: y, m: m, d: d)
        let days1 = (y1 * 12 + m1) * 31 + d1
        let days = (y * 12 + m) * 31 + d
        print("\(m) / \(d) / \(y)  ")
        switch days {
        case _ where days1 < days:
            print("will be a ")
        case _ where days1 > days:
            print("was a ")
        case _ where days1 == days:
            print("is a ")
        default:
            fatalError("Impossible case days / days1")
        }
        
        //560 REM PRINT THE DAY OF THE WEEK THE DATE FALLS ON.
        switch b {
        case 1: println("Sunday")
        case 2: println("Monday")
        case 3: println("Tuesday")
        case 4: println("Wednesday")
        case 5: println("Thursday")
        case 6: println("Friday")
        case 7: println("Saturday")
        default:
            fatalError("Illegal day of week")
        }
        
        //Line 710
        if days1 == days {
            stop()
            return
        }
        
        println()
        //Lines740-835
        var deltaY = y1 - y  //i5
        var deltaM = m1 - m  //i6
        var deltaD = d1 - d  //i7
        
        if deltaD < 0 {
            deltaM -= 1
            deltaD += 30
        }
        
        if deltaM < 0 {
            deltaY -= 1
            deltaM += 12
        }
        
        if deltaY < 0 {
            stop()
        }
        
        var delta = Interval(deltaY, deltaM, deltaD)
        let a8 = Double(delta.years * 365 + delta.months * 30 + delta.days + delta.months / 2)  //Total number of days
        
        if deltaD == 0 && deltaM == 0 {
            println("***Happy Birthday***")
        }
        
        print(tab(27))
        printTab("Years", tab: 12)
        printTab("Months", tab: 12)
        println("Days")
        printInterval(message: "Your age if birthdate", delta)
        
        //910 REM CALCULATE RETIREMENT DATE.
        let e = y + 65
        
        //930 REM CALCULATE TIME SPENT IN THE FOLLOWING FUNCTIIONS.
        printInterval(message: "You have slept", calculateInterval(0.35 * a8, &delta))
        printInterval(message: "You have eaten", calculateInterval(0.17 * a8, &delta))
        
        let message: String
        switch delta.years {
        case _ where delta.years <= 3:
            message = "You have played"
        case _ where delta.years <= 9:
            message = "You have played/studied"
        default:
            message = "You have worked/played"
        }
        printInterval(message: message, calculateInterval(0.23 * a8, &delta))
        printInterval(message: "You have relaxed", delta)
        println()
        println(tab(12) + "*You may retire in \(e)*")
        wait(.short)
        stop()
    }
    
    //MARK: Helper functions
    //Lines 300-480
    //Doomsday algorithm (based on Tomohiko Sakamoto variant?). 1 = Sunday
    private func weekday(y: Int, m: Int, d: Int) -> Int {
        let t: [Int] = [0, 3, 3, 6, 1, 4, 6, 2, 5, 0, 3, 5]  //Line 1330
        let i1 = floor((Double(y) - 1500) / 100)  //Centuries since 1500 (? ref date)
        let a1 = i1 * 5 + (i1 + 3) / 4
        let i2 = Int(a1 - fnb(a1) * 7)
        let y2 = Int(Double(y) / 100)  //Centuries
        let y3 = Double(y - y2 * 100)  //Number of years since begin of century
        let a2 = y3 / 4 + y3 + Double(d + t[m - 1] + i2)  //Mystery formula
        var b = Int(a2 - fnb(a2) * 7) + 1
        
        //Lines 360-480 - Correction for leap year adjustment
        if m < 3 {
            let t1 = y3 == 0 ? Int(a2 - fna(a2) * 4) : y - fna(y) * 4
            if t1 == 0 {
                if b == 0 { b = 6 }
                b -= 1
            }
        }
        
        return b == 0 ? 7 : b
    }
    
    //Compact method
    //From https://www.hackerearth.com/blog/developers/how-to-find-the-day-of-a-week/, adjusting b so that 1 = Sundat
    func wd(y: Int, m: Int, d: Int) -> Int {
        let t: [Int] = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
        let y0 = m < 3 ? y - 1 : y
        let b = (y0 + y0 / 4 - y0 / 100 + y0 / 400 + t[m-1] + d) % 7 + 1
        return b > 7 ? 1 : b
    }
    
    private func printInterval(message: String, _ interval: Interval) {
        printTab(message, tab: 28)
        printTab("\(interval.years)", tab: 12)
        printTab("\(interval.months)", tab: 12)
        println("\(interval.days)")
    }

    //1360 REM CALCULATE TIME IN YEARS, MONTHS, AND DAYS
    //Lines 1370
    private func calculateInterval(_ days: Double, _ delta: inout Interval) -> Interval {
        let k1 = Int(days)
        let years = k1 / 365
        let remainder = k1 % 365
        let months = remainder / 30
        let days = remainder % 30
        let outputInterval = Interval(years, months, days)
        
        delta = Interval(delta.years - outputInterval.years, delta.months - outputInterval.months, delta.days - outputInterval.days)
        if delta.days < 0 {
            delta.days += 30
            delta.months -= 1
        }
        if delta.months < 0 {
            delta.months += 12
            delta.years -= 1
        }
        
        return outputInterval
    }
        
    //Lines 1140-1240
    private func stop() {
        println(10)
        wait(.short)
        end()
    }
    
    private func date(from string: String) -> (month: Int, day: Int, year: Int) {
        let components = string.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let dateArray = components.compactMap { Int($0) }
        guard dateArray.count == 3 else { return (0,0,0) }
        return (dateArray[0], dateArray[1], dateArray[2])
    }
    
    //Line 170
    private func fna(_ a: Int) -> Int {
        return a / 4
    }
    
    private func fna(_ a: Double) -> Double {
        return floor(a / 4)
    }
    
    //Line 190
    private func fnb(_ a: Int) -> Int {
        return a / 7
    }
    
    private func fnb(_ a: Double) -> Double {
        return floor(a / 7)
    }
}
