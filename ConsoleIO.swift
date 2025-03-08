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
            case .afterEntry: return 0.2
            case .short: return 1
            case .long: return 2
            }
        }
    }
    
    public struct Tab {
        let position: Int
    }
    
    static let shared = ConsoleIO()
    
    public var promptCharacter = "? "
            
    //Terminal color strings
    private let darkGrayColor = "{3000, 3000, 3000}"
    private let grayColor = "{5000, 5000, 5000}"
    private let whiteColor = "{65535, 65535, 65535}"
    private let greenColor = "{0, 50000, 0}"
    
    private var baudRate = 128.0
    private var delayAfterCharacter: Double { 1 / baudRate }
    private var delayAfterNewLine: Double { 5 / baudRate }
    
    private var cursor = 0  //x position for tab
    private var lines = 0  //For display block
    private var isRecording = false
    private var hardcopyString = ""
    private var isTerminated = false
        
    private var player: AVAudioPlayer?  //Need to keep reference for sound to play
    
    private init() {
        //***must specify queue for notification to be received***
        let queue = OperationQueue()
        queue.name = "com.starwaresoftware.consoleIO"
        queue.qualityOfService = .userInteractive

        DistributedNotificationCenter.default().addObserver(forName: .terminalCommand, object: nil, queue: queue) { [weak self] notification in
            guard let self, let string = notification.object as? String, let command = TerminalCommand(rawValue: string) else { return }
            switch command {
            case .break:
                forceQuit()
            case .bell:
                ringBell()
            default:
                send(command: command)
            }
        }

        //Uncomment to customize Terminal app
        //setUpTerminalApp()
    }
       
    //Customizations for mac Terminal app
    private func setUpTerminalApp() {
        freopen("", "a+", stderr)  //Suppresses error logging
        
        //Terminal setup control sequences
        var scriptString = "tell application \"Terminal\"\n"
        scriptString += "set background color of the front window to \(grayColor)\n"
        scriptString += "set normal text color of the front window to \(greenColor)\n"
        scriptString += "set cursor color of the front window to \(greenColor)\n"
        scriptString += "set title displays custom title of the front window to true\n"
        scriptString += "set custom title of the front window to \"\"\n"  //Suppresses duplicate name
        scriptString += "set title displays window size of the front window to false\n"
        scriptString += "set title displays device name of the front window to false\n"
        scriptString += "set title displays shell path of the front window to false\n"
        scriptString += "set title displays file name of the front window to false\n"
        scriptString += "end tell"
        executeAppleScript(with: scriptString)
    }
    
    private func executeAppleScript(with scriptString: String) {
        guard let appleScript = NSAppleScript(source: scriptString) else { return }
        var errorDict: NSDictionary?
        appleScript.executeAndReturnError(&errorDict)
        if let errorDict = errorDict {
            #if DEBUG
            print("\(errorDict)")
            #endif
        }
    }
    
    func wait(_ delay: Delay) {
        Thread.sleep(forTimeInterval: delay.value)
    }
    
    func set(baudRate: Double) {
        self.baudRate = baudRate
    }
    
    private func forceQuit() {
        isTerminated = true
        "\n\nProcess Terminated".uppercased().forEach {
            Swift.print($0, terminator: "")
            fflush(stdout)  //Needed after print with terminator, or freezes
            Thread.sleep(forTimeInterval: delayAfterCharacter)
        }
        exit(EXIT_SUCCESS)
    }
    
    func close(_ message: String? = nil) -> Never {
        println()
        println(message ?? "Process Terminated")
        exit(EXIT_SUCCESS)
    }
    
    func clear() {
        send(command: .clearScreen)
        send(command: .cursorHome)
    }
    
    func saveCursorLocation() {
        send(command: .cursorSavePosition)
    }
    
    func restoreCursorLocation() {
        send(command: .cursorRestorePosition)
    }
    
    func moveCursorUp(lines: Int) {
        Swift.print(TerminalCommand.moveCursorUp(lines: lines), terminator: "")
        fflush(stdout)
    }
    
    func ringBell(_ count: Int = 1) {
        do {
            guard let url = Bundle.main.url(forResource: "Bell Buoy", withExtension: "mp3") else { throw CocoaError(.fileNoSuchFile) }
            let player = try AVAudioPlayer(contentsOf: url)
            self.player = player
            player.enableRate = true
            switch count {
            case 1: player.rate = 1
            case 2: player.rate = 2
            default: player.rate = 4
            }
            player.numberOfLoops = count - 1
            player.play()
         } catch {
            for _ in 1...count {
                print(TerminalCommand.bell.escapeSequence)
                wait(.veryShort)
            }
        }
    }
    
    private func throttledWrite(_ message: String, terminateWithNewLine: Bool = true) {
        if isRecording { hardcopyString += message.uppercased() + (terminateWithNewLine ? "\n" : "") }
        
        message.uppercased().forEach {
            if isTerminated { return }
            Swift.print($0, terminator: "")
            fflush(stdout)  //Needed after print with terminator, or freezes
            if $0 == "\n" { lines += 1 }
            Thread.sleep(forTimeInterval: delayAfterCharacter)
        }
        
        cursor += message.count
        
        if terminateWithNewLine {
            if isTerminated { return }
            Swift.print()
            cursor = 0
            lines += 1
            Thread.sleep(forTimeInterval: delayAfterNewLine)
        }
    }
    
    //Capped at 40
    private func throttledNewLine(_ number: Int = 1, eraseLine: Bool = false) {
        if number < 1 { return }
        if number > 40 { return }
        (1...number).forEach {_ in
            throttledWrite("")
            if eraseLine { send(command: .eraseLine) }
        }
    }
    
    func print(_ message: String) {
        throttledWrite(message, terminateWithNewLine: false)
    }
    
    func println(_ message: String) {
        throttledWrite(message)
    }
        
    func println(_ number: Int = 1, eraseLine: Bool = false) {
        throttledNewLine(number, eraseLine: eraseLine)
    }
    
    func print(tab: Tab) {
        guard cursor < tab.position else { return }
        print(String(repeating: " ", count: tab.position - cursor))
    }
        
    func send(command: TerminalCommand) {
        Swift.print(command.escapeSequence, terminator: "")
        fflush(stdout)
    }
        
    func getInput(terminator: String? = nil) -> String {
        defer {
            cursor = 0
            lines += 1
        }

        print(terminator ?? promptCharacter)
        let keyboard = FileHandle.standardInput
        guard let inputString = String(data: keyboard.availableData, encoding: .utf8) else { return "" }
        if isRecording { hardcopyString += inputString }
        return inputString.trimmingCharacters(in: .newlines)
    }
    
    func pauseForEnter() -> String {
        defer { cursor = 0 }
        let keyboard = FileHandle.standardInput
        guard let inputString = String(data: keyboard.availableData, encoding: .utf8) else { return "" }
        return inputString.trimmingCharacters(in: .newlines)
    }
    
    //MARK: CRT functions
    func saveLinePosition() {
        lines = 0
    }
    
    func restoreLinePosition() {
        moveCursorUp(lines: lines)
        lines = 0
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


