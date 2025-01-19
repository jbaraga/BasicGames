//
//  GameTerminalView.swift
//  BasicGames
//
//  Created by Joseph Baraga on 1/8/25.
//

import AppKit
import SwiftTerm


//Duplicate of LocalProcessTerminalView, with additional access to the LocalProcess for termination function
class GameTerminalView: TerminalView, TerminalViewDelegate, LocalProcessDelegate {
    private var process: LocalProcess!
    
    public var delegate: GameTerminalViewDelegate?
    
    public var foregroundColor: NSColor {
        get {
            return nativeForegroundColor
        }
        set {
            if newValue == nativeForegroundColor { return }
            nativeForegroundColor = newValue
            caretColor = newValue
            caretTextColor = newValue
        }
    }
    
    public override init (frame: CGRect) {
        super.init (frame: frame)
        setup ()
    }
    
    public required init? (coder: NSCoder){
        super.init (coder: coder)
        setup ()
    }
    
    func setup () {
        terminalDelegate = self
        process = LocalProcess (delegate: self)
    }
    
    /**
     * Launches a child process inside a pseudo-terminal.
     * - Parameter executable: The executable to launch inside the pseudo terminal, defaults to /bin/bash
     * - Parameter args: an array of strings that is passed as the arguments to the underlying process
     * - Parameter environment: an array of environment variables to pass to the child process, if this is null, this picks a good set of defaults from `Terminal.getEnvironmentVariables`.
     * - Parameter execName: If provided, this is used as the Unix argv[0] parameter, otherwise, the executable is used as the args [0], this is used when the intent is to set a different process name than the file that backs it.
     */
    public func startProcess(executable: String = "/bin/bash", args: [String] = [], environment: [String]? = nil, execName: String? = nil) {
        process.startProcess(executable: executable, args: args, environment: environment, execName: execName)
    }
    
    public func terminateProcess() {
        process.terminate()
    }
    
    public func setCursorStyle(style: CursorStyle) {
        getTerminal().setCursorStyle(style)
    }
    
    //LocalProcessDelegate
    func processTerminated(_ source: SwiftTerm.LocalProcess, exitCode: Int32?) {
        delegate?.processTerminated(source: self, exitCode: exitCode)
    }
    
    func dataReceived(slice: ArraySlice<UInt8>) {
        feed(byteArray: slice)
    }
    
    func getWindowSize() -> winsize {
        let f: CGRect = self.frame
        let terminal = getTerminal()
        return winsize(ws_row: UInt16(terminal.rows), ws_col: UInt16(terminal.cols), ws_xpixel: UInt16 (f.width), ws_ypixel: UInt16 (f.height))
    }
    
    //TerminalViewDelegate
    func sizeChanged(source: SwiftTerm.TerminalView, newCols: Int, newRows: Int) {
        guard process.running else { return }
        var size = getWindowSize()
        let _ = PseudoTerminalHelpers.setWinSize(masterPtyDescriptor: process.childfd, windowSize: &size)
        delegate?.sizeChanged (source: self, newCols: newCols, newRows: newRows)
    }
    
    func hostCurrentDirectoryUpdate(source: SwiftTerm.TerminalView, directory: String?) {
        delegate?.hostCurrentDirectoryUpdate(source: self, directory: directory)
    }
    
    func send(source: SwiftTerm.TerminalView, data: ArraySlice<UInt8>) {
        process.send(data: data)
    }
    
    func scrolled(source: SwiftTerm.TerminalView, position: Double) {
        return
    }
    
    func setTerminalTitle(source: SwiftTerm.TerminalView, title: String) {
        delegate?.setTerminalTitle(source: self, title: title)
    }
    
    func clipboardCopy(source: SwiftTerm.TerminalView, content: Data) {
        if let str = String (bytes: content, encoding: .utf8) {
            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            pasteBoard.writeObjects([str as NSString])
        }
    }
    
    func rangeChanged(source: SwiftTerm.TerminalView, startY: Int, endY: Int) {
        return
    }
    
    /*Uncomment to force uppercase keyboard entry. Requires SwiftTerm added as local package, and change of keyDown(with event:) in TerminalView to open function
    override func keyDown(with event: NSEvent) {
        guard let characters = event.characters, let scalar = characters.unicodeScalars.first, CharacterSet.lowercaseLetters.contains(scalar) else {
            super.keyDown(with: event)
            return
        }
        
        guard !event.modifierFlags.contains([.command, .control, .option]) else {
            super.keyDown(with: event)
            return
        }
        
        guard let newEvent = NSEvent.keyEvent(with: event.type, location: event.locationInWindow, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: event.windowNumber, context: nil, characters: characters.uppercased(), charactersIgnoringModifiers: event.charactersIgnoringModifiers ?? "", isARepeat: event.isARepeat, keyCode: event.keyCode) else {
            super.keyDown(with: event)
            return
        }
        
        super.keyDown(with: newEvent)
    }
    */
}


protocol GameTerminalViewDelegate {
    /**
     * This method is invoked to notify that the terminal has been resized to the specified number of columns and rows
     * the user interface code might try to adjut the containing scroll view, or if it is a toplevel window, the window itself
     * - Parameter source: the sending instance
     * - Parameter newCols: the new number of columns that should be shown
     * - Parameter newRow: the new number of rows that should be shown
     */
    func sizeChanged(source: GameTerminalView, newCols: Int, newRows: Int)

    /**
     * This method is invoked when the title of the terminal window should be updated to the provided title
     * - Parameter source: the sending instance
     * - Parameter title: the desired title
     */
    func setTerminalTitle(source: GameTerminalView, title: String)

    /**
     * Invoked when the OSC command 7 for "current directory has changed" command is sent
     * - Parameter source: the sending instance
     * - Parameter directory: the new working directory
     */
    func hostCurrentDirectoryUpdate (source: TerminalView, directory: String?)

    /**
     * This method will be invoked when the child process started by `startProcess` has terminated.
     * - Parameter source: the local process that terminated
     * - Parameter exitCode: the exit code returned by the process, or nil if this was an error caused during the IO reading/writing
     */
    func processTerminated (source: TerminalView, exitCode: Int32?)
}


extension SwiftTerm.CursorStyle: Codable, @retroactive CaseIterable {
    enum CodingKeys: String, CodingKey {
        case shape
        case isBlinking
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(shape, forKey: .shape)
        try container.encode(isBlinking, forKey: .isBlinking)
    }
    
    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let shape = try values.decode(String.self, forKey: .shape)
        let isBlinking = try values.decode(Bool.self, forKey: .isBlinking)
        try self.init(shape: shape, isBlinking: isBlinking)
    }
    
    public static var allCases: [CursorStyle] { [.blinkBlock, .steadyBlock, .blinkBar, .steadyBar, .blinkUnderline, .steadyUnderline] }
}

extension SwiftTerm.CursorStyle {
    var shape: String {
        switch self {
        case .blinkBlock, .steadyBlock: return "Block"
        case .blinkUnderline, .steadyUnderline: return "Underline"
        case .blinkBar, .steadyBar: return "Bar"
        }
    }
    
    var isBlinking: Bool {
        switch self {
        case .blinkBlock, .blinkUnderline, .blinkBar: return true
        case .steadyBlock, .steadyUnderline, .steadyBar: return false
        }
    }
    
    static var allShapes: [String] { ["Block", "Underline", "Bar"] }
    
    init(shape: String, isBlinking: Bool) throws {
        guard let style = Self.allCases.first(where: { $0.shape == shape && $0.isBlinking == isBlinking }) else { throw CocoaError(.coderInvalidValue) }
        self = style
    }
}

