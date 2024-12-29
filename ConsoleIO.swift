//
//  ConsoleIO.swift
//  OregonTrail
//
//  Created by Joseph Baraga on 10/30/18.
//  Copyright © 2018 Joseph Baraga. All rights reserved.
//

import Foundation
import AppKit
import AVFAudio

class ConsoleIO {
    public enum Delay {
        case veryShort
        case afterEntry
        case short
        case long
        
        var value: Double {
            switch self {
            case .veryShort: return 0.2
            case .afterEntry: return 0.5
            case .short: return 1
            case .long: return 2
            }
        }
    }
    
    public struct Tab {
        let position: Int
    }
    
    static let shared = ConsoleIO()
    
    public var promptCharacter = "?"
            
    //Terminal color strings
    private let darkGrayColor = "{3000, 3000, 3000}"
    private let grayColor = "{5000, 5000, 5000}"
    private let whiteColor = "{65535, 65535, 65535}"
    private let greenColor = "{0, 50000, 0}"
    
    private let delayAfterCharacter = 1.0 / 128  //128 baud
    private let delayAfterNewLine = 0.05
    
    private var cursor = 0  //x position for tab
    private var isRecording = false
    private var hardcopyString = ""
        
    private var player: AVAudioPlayer?  //Need to keep reference for sound to play
    
    private init() {
        //***must specify queue for notification to be received***
        let queue = OperationQueue()
        queue.name = "com.starwaresoftware.consoleIO"
        queue.qualityOfService = .userInteractive

        DistributedNotificationCenter.default().addObserver(forName: .terminalCommand, object: nil, queue: queue) { [weak self] notification in
            guard let self, let string = notification.object as? String, let command = TerminalCommands(rawValue: string) else { return }
            switch command {
            case .break:
                println()
                close()
            case .bell:
                ringBell()
            default:
                print(string)
            }
        }
        
//For use of macOS Terminal app
//        freopen("", "a+", stderr)  //Suppresses error logging
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
    
    func close(_ message: String? = nil) -> Never {
        println()
        println(message ?? "Process Terminated")
        exit(EXIT_SUCCESS)
    }
    
    func clear() {
        print(TerminalCommands.clearScreen.escapeSequence)
        print(TerminalCommands.cursorHome.escapeSequence)
    }
    
    func ringBell(_ count: Int = 1) {
        do {
            guard let url = Bundle.main.url(forResource: "Bell Buoy", withExtension: "mp3") else { throw CocoaError(.fileNoSuchFile) }
            let player = try AVAudioPlayer(contentsOf: url)
            self.player = player
            player.enableRate = true
            player.rate = 2
            player.numberOfLoops = count - 1
            player.play()
         } catch {
            for _ in 1...count {
                print(TerminalCommands.bell.escapeSequence)
                wait(.veryShort)
            }
        }
    }
    
    private func throttledWrite(_ message: String, terminateWithNewLine: Bool = true) {
        if isRecording {
            hardcopyString += message.uppercased() + (terminateWithNewLine ? "\n" : "")
        }
        
        message.uppercased().forEach {
            Swift.print($0, terminator: "")
            fflush(stdout)  //Needed after print with terminator, or freezes
            Thread.sleep(forTimeInterval: delayAfterCharacter)
        }
        
        cursor += message.count
        
        if terminateWithNewLine {
            Swift.print()
            cursor = 0
            Thread.sleep(forTimeInterval: delayAfterNewLine)
        }
    }
    
    private func throttledNewLine(_ number: Int = 1) {
        if number < 1 { return }
        if number > 20 { return }
        (1...number).forEach {_ in throttledWrite("") }
    }
    
    func print(_ message: String) {
        throttledWrite(message, terminateWithNewLine: false)
    }
    
    func println(_ message: String) {
        throttledWrite(message)
    }
        
    func println(_ number: Int = 1) {
        throttledNewLine(number)
    }
    
    func print(tab: Tab) {
        guard cursor < tab.position else { return }
        print(String(repeating: " ", count: tab.position - cursor))
    }
        
    func getInput(terminator: String? = nil) -> String {
        print((terminator ?? promptCharacter) + " ")

        defer {
            cursor = 0
        }
        
        let keyboard = FileHandle.standardInput
        guard let inputString = String(data: keyboard.availableData, encoding: .utf8) else { return "" }
        if isRecording {
            hardcopyString += inputString
        }
        return inputString.trimmingCharacters(in: .newlines)
    }
    
    func pauseForEnter() -> String {
        defer {
            cursor = 0
        }
        
        let keyboard = FileHandle.standardInput
        guard let inputString = String(data: keyboard.availableData, encoding: .utf8) else { return "" }
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
        guard let url = URL(string: URL.basicGamesScheme + ":///" + "#string=" + hardcopyString) else { return }
        NSWorkspace.shared.open(url)
    }
    
    //MARK: Low level terminal functions to read each input character
    private func initStruct<S>() -> S {
        let struct_pointer = UnsafeMutablePointer<S>.allocate(capacity: 1)
        let struct_memory = struct_pointer.pointee
        struct_pointer.deallocate()
        return struct_memory
    }

    private func enterRawMode(fileHandle: FileHandle) -> termios {
        var raw: termios = initStruct()
        tcgetattr(fileHandle.fileDescriptor, &raw)

        let original = raw

        raw.c_lflag &= ~(UInt(ECHO | ICANON))
        tcsetattr(fileHandle.fileDescriptor, TCSAFLUSH, &raw);

        return original
    }

    private func exitRawMode(fileHandle: FileHandle, originalTerm: termios) {
        var term = originalTerm
        tcsetattr(fileHandle.fileDescriptor, TCSAFLUSH, &term);
    }

    //Does not work with SwiftTerm
    func hitAnyKeyExceptReturn() {
        //From stackoverflow https://stackoverflow.com/questions/49748507/listening-to-stdin-in-swift
        let keyboard = FileHandle.standardInput
        let terminal = enterRawMode(fileHandle: keyboard)
        
        var inputByte: UInt8 = 10
        repeat {
            read(keyboard.fileDescriptor, &inputByte, 1)
        } while inputByte == 10
        
        exitRawMode(fileHandle: keyboard, originalTerm: terminal)
    }
}


