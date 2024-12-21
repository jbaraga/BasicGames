//
//  StockMarket.swift
//  StockMarket
//
//  Created by Joseph Baraga on 3/20/22.
//

import Foundation


class StockMarket: GameProtocol {
    
    private let x = 1.0  //For rnd
    private var a = 0.0
    private var isFirstDay = true  //X9 == 0
    private var n1 = 0  //Large change day counts
    private var n2 = 0  //Large change day counts
    private var e1 = 0  //Large change misc
    private var e2 = 0  //Large change misc
    private var t8 = 0  //Random days interval to change trend (a) and slope
    
    private var t = 0.0  //Total stock assets
    private var t5 = 0  //Total value of transactions
    
    private var z5 = 0.0  //NYSE average
    
    private class Stock {
        let initials: String
        let name: String
        
        var s: Double  //Value per share
        var p = 0  //Current holding
        var z = 0  //Transaction (temp variable)
        
        //Change in stock value
        var c = 0.0 {
            didSet {
                if c == 0 { return }
                //Lines 957-967
                s += c
                s = round(s * 100) / 100
                if s < 0 {
                    s = 0
                    c = 0
                }
            }
        }
        
        var value: Double {
            return Double(p) * s
        }
        
        var purchaseValue: Double {
            guard z > 0 else { return 0 }
            return Double(z) * s
        }
        
        var salesValue: Double {
            guard z < 0 else { return 0 }
            return -Double(z) * s
        }
        
        init(initials: String, name: String, s: Double) {
            self.initials = initials
            self.name = name
            self.s = s
        }
    }
    
    //200 REM GENERATION OF STOCK TABLE; INPUT REQUESTS
    //210 REM INITIAL STOCK VALUES
    private var stocks: [Stock] = [
        Stock(initials: "IBM", name: "Int. Ballistic Missiles", s: 100),
        Stock(initials: "RCA", name: "Red Cross of America", s: 85),
        Stock(initials: "LBJ", name: "Lichtenstein, Bumrap & Joke", s: 150),
        Stock(initials: "ABC", name: "American Bankrupt Co.", s: 140),
        Stock(initials: "CBS", name: "Censured Books Store", s: 110)
    ]
    
    //333 REM INITIALIZE CASH ASSETS:C
    private var cash = 10000.0
    
    func run() {
        printHeader(title: "Stock Market")
        println(3)
        
        //100 REM STOCK MARKET SIMULATION    -STOCK-
        //101 REM REVISED 8/18/70 (D. PESSEL, L. BRAUN, C. LOSIK)
        //102 REM IMP VRBLS: A-MRKT TRND SLP; B5-BRKRGE FEE; C-TTL CSH ASSTS;
        //103 REM C5-TTL CSH ASSTS (TEMP); C(I)-CHNG IN STK VAL; D-TTL ASSTS;
        //104 REM E1,E2-LRG CHNG MISC; I-STCK #; I1,I2-STCKS W LRG CHNG;
        //105 REM N1,N2-LRG CHNG DAY CNTS; P5-TTL DAYS PRCHSS; P(I)-PRTFL CNTNTS;
        //106 REM Q9-NEW CYCL?; S4-SGN OF A; S5-TTL DYS SLS; S(I)-VALUE/SHR;
        //107 REM T-TTL STCK ASSTS; T5-TTL VAL OF TRNSCTNS;
        //108 REM W3-LRG CHNG; X1-SMLL CHNG(<$1); Z4,Z,Z6-NYSE AVE.; Z(I)-TRNSCT
        
        //121 REM INTRODUCTION
        if Int(input("Do you want the instructions (yes-type 1, no-type 0)")) ?? 0 == 1 {
            instructions()
        }
        
        //265 REM INITIAL T8 - # DAYS FOR FIRST TREND SLOPE (A)
        t8 = Int(4.99 * rnd(x) + 1)
        
        //267 REM RANDOMIZE SIGN OF FIRST TREND SLOPE (A) - includes line 114
        a = floor((rnd(x) / 10) * 100 + 0.5) / 100 * (rnd(x) > 0.5 ? 1 : -1)
        
        //270 REM RANDOMIZE INITIAL VALUES
        newStockValues()
    
        //338 REM PRINT INITIAL PORTFOLIO
        println(2)
        println("Stock", tab(28), "Initials", tab(42), "Price/Share")
        stocks.forEach { stock in
            println(stock.name, tab(30), stock.initials, tab(42), String(format: " %.2f", stock.s))
        }
        println()
        
        nextDay()
    }
    
    //Lines 360-810
    private func nextDay() {
        let z4 = z5
        z5 = round(100 * stocks.reduce(0, { $0 + $1.s }) / 5) / 100  //Compute average price and round to hundredths
        
        if isFirstDay {
            println(String(format: "NYSE Average:  %.2f", z5))
        } else {
            println(String(format: "NYSE Average:  %.2f   Net Change: %.2f", z5, z5 - z4))
        }
        println()
        
        //Assets and cash, rounded to hundredths
        let stockAssets = round(100 * stocks.reduce(t, { $0 + $1.value })) / 100  //T
        cash = round(cash * 100) / 100
        //393 REM TOTAL ASSETS:D
        let d = stockAssets + cash
        println(String(format: "Total stock assets are   $ %.2f", stockAssets))
        println(String(format: "Total cash assets are    $ %.2f", cash))
        println(String(format: "Total assets are         $ %.2f", d))
        println()

        if !isFirstDay {
            let response = Int(input("Do you wish to continue (yes-type 1, no-type 0)")) ?? 1
            if response == 0 {
                stop()
                return
            }
            if cash > 20000, response == Response.easterEggCode {
                showEasterEgg(.stockMarket)
                wait(.long)
            }
        }
        
        getTransactions()
        
        //710 REM CALCULATE NEW STOCK VALUES
        newStockValues()
        
        //750 REM PRINT PORTFOLIO
        //751 REM BELL RINGING-DIFFERENT ON MANY COMPUTERS
        consoleIO.ringBell()
        
        println()
        println("**********  End of Day's Trading")
        println(2)
        
        println("Stock", "Price/Share", "Holdings", "Value", "Net Price Change")
        
        stocks.forEach { stock in
            println(stock.initials, String(format: " %.2f", stock.s), " \(stock.p)", String(format: " %.2f", stock.value), String(format: stock.c < 0 ? "%.2f" : " %.2f", stock.c))
        }

        isFirstDay = false
        println(2)
        nextDay()
    }
    
    //416 REM INPUT TRANSACTIONS
    private func getTransactions() {
        println("What is your transaction in")
        stocks.forEach { stock in
            stock.z = Int(input(stock.initials)) ?? 0
        }
        println()
        
        //530 REM TOTAL DAY'S PURCHASES IN $:P5
        let p5 = stocks.reduce(0, { $0 + $1.purchaseValue })
        //550 REM TOTAL DAY'S SALES IN $:S5
        let s5 = stocks.reduce(0, { $0 + $1.salesValue })
        
        let isOversold = stocks.reduce(false, { $0 || ($1.z < 0 ? -$1.z > $1.p : false) })
        if isOversold {
            println("You have oversold a stock; try again.")
            getTransactions()
            return
        }
        
        //622 REM TOTAL VALUE OF TRANSACTIONS T5
        let t5 = p5 + s5
        //630 REM BROKERAGE FEE:B5
        let b5 = round(0.01 * t5 * 100) / 100
        //652 REM -BROKERAGE FEES+TOTAL SALES:C5
        let c5 = cash - p5 - b5 + s5
        if c5 < 0 {
            println(String(format: "You have used $ %.2f more than you have.", -c5))
            getTransactions()
            return
        }
        cash = c5
        
        //675 REM CALCULATE NEW PORTFOLIO
        stocks.forEach { stock in
            stock.p += stock.z
        }
    }
    
    //829 REM NEW STOCK VALUES - SUBROUTINE
    //830 REM RANDOMLY PRODUCE NEW STOCK VALUES BASED ON PREVIOUS
    //831 REM DAY'S VALUES
    //832 REM N1,N2 ARE RANDOM NUMBERS OF DAYS WHICH RESPECTIVELY
    //833 REM DETERMINE WHEN STOCK I1 WILL INCREASE 10 PTS. AND STOCK
    //834 REM I2 WILL DECREASE 10 PTS.
    private func newStockValues() {
        let i1 = Int(round(4.99 * rnd(x)))  //Stocks array is zero indexed
        let i2 = Int(round(4.99 * rnd(x)))  //Stocks array is zero indexed
        
        //840 REM IF N1 DAYS HAVE PASSED, PICK AN I1, SET E1, DETERMINE NEW N1
        if n1 <= 0 {
            n1 = Int(4.99 * rnd(x) + 1)
            e1 = 1
        }
        
        //850 REM IF N2 DAYS HAVE PASSED PICK AN I2, SET E2, DETERMINE NEW N2
        if n2 <= 0 {
            n2 = Int(4.99 * rnd(x) + 1)
            e2 = 1
        }
        
        //860 REM DEDUCT ONE DAY FROM N1 AND N2
        n1 -= 1
        n2 -= 1
        
        //890 REM LOOP THROUGH ALL STOCKS
        for (index, stock) in stocks.enumerated() {
            var x1 = rnd(x)
            if x1 < 0.25 {
                x1 = 0.25
            } else if x1 < 0.5 {
                x1 = 0.5
            } else if x1 < 0.75 {
                x1 = 0.75
            } else {
                x1 = 0.0
            }
            
            //931 REM BIG CHANGE CONSTANT:W3  (SET TO ZERO INITIALLY)
            var w3 = 0.0
            if e1 > 0, i1 == index {
                //938 REM ADD 10 PTS. TO THIS STOCK;  RESET E1
                w3 = 10
                e1 = 0
            }
            
            if e2 > 0, i2 == index {
                //948 REM SUBTRACT 10 PTS. FROM THIS STOCK;  RESET E2
                w3 -= 10
                e2 = 0
            }
            
            //954 REM C(I) IS CHANGE IN STOCK VALUE - local var change
            var change = floor(Double(a) * stock.s) + x1 + floor(3 - 6 * rnd(x) + 0.5) + w3
            change = round(100 * change) / 100  //Rounds to one hundredths
            stock.c = change  //Stock class updates price per share (s)
        }
        
        //972 REM AFTER T8 DAYS RANDOMLY CHANGE TREND SIGN AND SLOPE
        t8 -= 1
        if t8 < 1 {
            //985 REM RANDOMLY CHANGE TREND SIGN AND SLOPE (A), AND DURATION
            //986 REM OF TREND (T8)
            t8 = Int(4.99 * rnd(x) + 1)
            a = floor((rnd(x) / 10) * 100 + 0.5) / 100 * (rnd(x) > 0.5 ? -1 : 1)
        }
    }
    
    //Lines 130-147
    private func instructions() {
        println("This program plays the stock market.  You will be given")
        println("$10,000 and may buy or sell stocks.  The stock prices will")
        println("be generated randomly and therefore this model does not")
        println("represent exactly what happens on the exchange.  A table")
        println("of available stocks, their prices, and the number of shares")
        println("in your portfolio wll be printed.  Following this, the")
        println("initials of each stock will be printed with a question")
        println("mark.  Here you indicate a transaction.  To buy a stock")
        println("type +nnn, to sell a stock type -nnn, where nnn is the")
        println("number of shares.  A brokerage fee of 1% will be charged")
        println("on all transactions.  Note that if a stock's value drops")
        println("to zero it may rebound to a positive value again.  You")
        println("have $10,000 to invest.  Use integers for all your inputs.")
        println("(Note:  to get a 'feel' for the market run for at least")
        println("10 days)")
        println("-----Good Luck!-----")
    }
    
    private func stop() {
        println("Hope you had fun!!")
        end()
    }
}
