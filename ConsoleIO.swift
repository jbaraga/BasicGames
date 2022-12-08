//
//  ConsoleIO.swift
//  OregonTrail
//
//  Created by Joseph Baraga on 10/30/18.
//  Copyright © 2018 Joseph Baraga. All rights reserved.
//

import Foundation
import AppKit

class ConsoleIO {
    public struct TerminalCommands {
        static let reset = "\u{1B}[c"
        static let foregroundColorGreen = "\u{1B}[32m"
        static let cursorHome = "\u{1B}[H"
        static let cursorBack = "\u{1B}[1D"
        static let cursorForward = "\u{1B}[1D"
        static let cursorSavePosition = "\u{1B}7"
        static let cursorRestorePosition = "\u{1B}8"
        static let eraseToEndOfLine = "\u{1B}[K"
        static let clearScreen = "\u{1B}[2J"
        static let bell = "\u{7}"
    }
    
    public enum Delay {
        case afterEntry
        case short
        case long
        
        var value: Double {
            switch self {
            case .afterEntry: return 0.5
            case .short: return 1
            case .long: return 2
            }
        }
    }
    
    static let shared = ConsoleIO()
    
    public var promptCharacter = "?"
            
    //Terminal color strings
    private let darkGrayColor = "{3000, 3000, 3000}"
    private let grayColor = "{5000, 5000, 5000}"
    private let whiteColor = "{65535, 65535, 65535}"
    private let greenColor = "{0, 50000, 0}"
    
    private let delayAfterCharacter = 0.007
    private let delayAfterNewLine = 0.05
    
    let formatter: NumberFormatter = {
        let form = NumberFormatter()
        form.usesSignificantDigits = true
        form.maximumSignificantDigits = 6
        return form
    }()
    
    private var isRecording = false
    private var hardcopyString = ""
    
    private var isAwaitingInput = false {
        didSet {
            let center = DistributedNotificationCenter.default()
            //object has to be the string, userInfo nil for this to properly post
            center.post(name: NSNotification.Name("com.starwaresoftware.basicGames.input"), object: isAwaitingInput.description, userInfo: nil)
        }
    }
    
    private init() {
//        freopen("", "a+", stderr)  //Suppresses error logging

        let center = DistributedNotificationCenter.default()
        let queue = OperationQueue()
        queue.name = "com.starwaresoftware.consoleIO"
        queue.qualityOfService = .userInteractive

        center.addObserver(forName: NSNotification.Name("com.starwaresoftware.basicGames.close"), object: nil, queue: queue) { notification in
            if let executableName = Bundle.main.executableURL?.lastPathComponent, let string = notification.object as? String, executableName == string {
                exit(EXIT_SUCCESS)
            } else {
                exit(EXIT_SUCCESS)
            }
        }
        
//        reset()
//
//        //Terminal setup control sequences
//        var scriptString = "tell application \"Terminal\"\n"
//        scriptString += "set background color of the front window to \(grayColor)\n"
//        scriptString += "set normal text color of the front window to \(greenColor)\n"
//        scriptString += "set title displays custom title of the front window to true\n"
//        scriptString += "set custom title of the front window to \"\"\n"  //Suppresses duplicate name
//        scriptString += "set title displays window size of the front window to false\n"
//        scriptString += "set title displays device name of the front window to false\n"
//        scriptString += "set title displays shell path of the front window to false\n"
//        scriptString += "set title displays file name of the front window to false\n"
//        scriptString += "end tell"
//        executeAppleScript(with: scriptString)
    }
    
//    private func executeAppleScript(with scriptString: String) {
//        guard let appleScript = NSAppleScript(source: scriptString) else { return }
//        var errorDict: NSDictionary?
//        appleScript.executeAndReturnError(&errorDict)
//        if let errorDict = errorDict {
//            #if DEBUG
//            print("\(errorDict)")
//            #endif
//        }
//    }
//    
//    func reset() {
//        Swift.print(TerminalCommands.reset, terminator: "")  //Resets terminal, clears screen
//        fflush(__stdoutp)
//    }
    
    func wait(_ delay: Delay) {
        Thread.sleep(forTimeInterval: delay.value)
    }
    
    func close() {
        wait(.short)
        println()
        println("Process Terminated")
        exit(EXIT_SUCCESS)
    }
    
    func clear() {
        print(TerminalCommands.clearScreen)
        print(TerminalCommands.cursorHome)
    }
    
    func ringBell() {
        print(TerminalCommands.bell)
//        NSSound.beep()
    }
    
    private func throttledWrite(_ message: String, suppressNewline: Bool = false) {
        if isRecording {
            hardcopyString += message.uppercased() + (suppressNewline ? "" : "\n")
        }
        
        message.uppercased().forEach {
            Swift.print($0, terminator: "")
            fflush(__stdoutp)  //Needed after print with terminator, or freezes
            Thread.sleep(forTimeInterval: delayAfterCharacter)
        }
        
        if !suppressNewline {
            Swift.print()
            Thread.sleep(forTimeInterval: delayAfterNewLine)
        }
    }
    
    private func throttledNewLine(_ number: Int = 1) {
        if number < 1 { return }
        if number > 20 { return }
        (1...number).forEach {_ in throttledWrite("") }
    }
    
    func print(_ message: String) {
        throttledWrite(message, suppressNewline: true)
    }
    
    func println(_ message: String) {
        throttledWrite(message)
    }
        
    func println(_ number: Int = 1) {
        throttledNewLine(number)
    }
    
    func printPrompt(_ message: String) {
        throttledWrite(message, suppressNewline: true)
    }
    
    func getInput(terminator: String? = nil) -> String {
        throttledWrite((terminator ?? promptCharacter) + " ", suppressNewline: true)

        isAwaitingInput = true
        defer {
            isAwaitingInput = false
        }
        
        let keyboard = FileHandle.standardInput
        guard let inputString = String(data: keyboard.availableData, encoding: .utf8) else { return "" }
        if isRecording {
            hardcopyString += inputString
        }
        return inputString.trimmingCharacters(in: .newlines)
    }
        
    //MARK: Hardcopy printing functions
    func startHardcopy() {
        hardcopyString = ""
        isRecording = true
    }
    
    func endHardcopy() {
        isRecording = false
    }
    
    func printHardcopy() {
        let center = DistributedNotificationCenter.default()
        //object has to be the string, userInfo nil for this to properly post
        center.post(name: NSNotification.Name("com.starwaresoftware.basicGames.print"), object: hardcopyString, userInfo: nil)
    }
    
    //Low level terminal functions to read each input character
//    private func initStruct<S>() -> S {
//        let struct_pointer = UnsafeMutablePointer<S>.allocate(capacity: 1)
//        let struct_memory = struct_pointer.pointee
//        struct_pointer.deallocate()
//        return struct_memory
//    }
//
//    private func enterRawMode(fileHandle: FileHandle) -> termios {
//        var raw: termios = initStruct()
//        tcgetattr(fileHandle.fileDescriptor, &raw)
//
//        let original = raw
//
//        raw.c_lflag &= ~(UInt(ECHO | ICANON))
//        tcsetattr(fileHandle.fileDescriptor, TCSAFLUSH, &raw);
//
//        return original
//    }
//
//    private func exitRawMode(fileHandle: FileHandle, originalTerm: termios) {
//        var term = originalTerm
//        tcsetattr(fileHandle.fileDescriptor, TCSAFLUSH, &term);
//    }
//
//    func hitAnyKeyExceptReturn() {
//        //From stackoverflow https://stackoverflow.com/questions/49748507/listening-to-stdin-in-swift
//        let keyboard = FileHandle.standardInput
//        let terminal = enterRawMode(fileHandle: keyboard)
//
//        var inputByte: UInt8 = 13
//        repeat {
//            read(keyboard.fileDescriptor, &inputByte, 1)
//        } while inputByte == 13 || inputByte == 10  //return AND newline
//
//        exitRawMode(fileHandle: keyboard, originalTerm: terminal)
//        println()
//    }
}

