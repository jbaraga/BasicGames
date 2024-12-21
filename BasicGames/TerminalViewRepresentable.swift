//
//  TerminalViewRepresentable.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/28/21.
//

import AppKit
import SwiftUI
import SwiftTerm


struct TerminalViewRepresentable: NSViewRepresentable {
    typealias NSViewType = GameTerminalView
    
    let frame: CGRect
    let game: Game
    var isTerminated: Bool = false
    
    @ObservedObject private var settings = Preferences.shared
        
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> GameTerminalView {
        let terminalView = GameTerminalView(frame: frame)
        guard let path = Bundle.main.path(forResource: game.executableName, ofType: nil) else {
            return terminalView
        }
        terminalView.nativeForegroundColor = settings.foregroundColor
        terminalView.caretColor = settings.foregroundColor
        terminalView.caretTextColor = settings.foregroundColor
        terminalView.nativeBackgroundColor = .terminalBackground
        let terminal = terminalView.getTerminal()
        terminal.setCursorStyle(settings.isBlinkingCursor ? .blinkBlock : .steadyBlock)
        context.coordinator.terminal = terminal
        terminalView.delegate = context.coordinator
        
        Task {
            try await Task.sleep(seconds: 1)
            await MainActor.run {
                terminalView.startProcess(executable: path, args: [], environment: nil, execName: nil)
            }
        }
        return terminalView
    }
    
    func updateNSView(_ nsView: GameTerminalView, context: Context) {
        if isTerminated { nsView.terminateProcess() }
        
        if nsView.nativeForegroundColor != settings.foregroundColor {
            nsView.nativeForegroundColor = settings.foregroundColor
            nsView.caretColor = settings.foregroundColor
            nsView.caretTextColor = settings.foregroundColor
            nsView.send(txt: " " + .deleteCharacter)  //Forces refresh of text in TerminalView
        }
    }
    
    internal class Coordinator: NSObject, GameTerminalViewDelegate {
        var parent: TerminalViewRepresentable
        weak var terminal: Terminal?
                
        init(_ parent: TerminalViewRepresentable) {
            self.parent = parent
            super.init()
                        
            NotificationCenter.default.addObserver(forName: .cursorSettingDidChange, object: nil, queue: .main) { [weak self] notification in
                guard let self else { return }
                terminal?.setCursorStyle(Preferences.shared.isBlinkingCursor ? .blinkBlock: .steadyBlock)
            }
        }
                        
        //GameTerminalViewDelegate
        func sizeChanged(source: GameTerminalView, newCols: Int, newRows: Int) {
            return
        }
        
        func setTerminalTitle(source: GameTerminalView, title: String) {
            return
        }
        
        func hostCurrentDirectoryUpdate(source: SwiftTerm.TerminalView, directory: String?) {
            return
        }
        
        func processTerminated(source: SwiftTerm.TerminalView, exitCode: Int32?) {
            terminal?.setCursorStyle(.steadyBar)
            terminal?.hideCursor()
        }
    }
}


struct GameView: View {
    let game: Game
    
    @State private var isTerminated = false
    @FocusState private var isFocused: Bool
    
    private var contentView: some View {
        GeometryReader { geometry in
            TerminalViewRepresentable(frame: geometry.frame(in: .local), game: game, isTerminated: isTerminated)
                .navigationTitle(game.stringValue)
                .focused($isFocused)
        }
        .padding(.leading, 4)
        .padding(.bottom, 1)
        .background(Color(.terminalBackground))
        .onAppear { isFocused = true }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
            guard let window = notification.object as? NSWindow, window.title == game.title else {
                return
            }
            isTerminated = true
        }
    }
    
    var body: some View {
        if #available(macOS 14, *) {
            contentView
                .onKeyPress(.init("c"), phases: .down) { keyPress in
                    guard keyPress.modifiers == [.control] else { return .ignored }
                    DistributedNotificationCenter.default().post(name: .break, object: nil)
//                    isTerminated = true
                    return .handled
                }
        } else {
            contentView
        }
    }
}


//Duplicate of LocalProcessTerminalView, with additional access to the LocalProcess, allowing for termination
class GameTerminalView: TerminalView, TerminalViewDelegate, LocalProcessDelegate {
    private var process: LocalProcess!
    
    public var delegate: GameTerminalViewDelegate?
        
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


