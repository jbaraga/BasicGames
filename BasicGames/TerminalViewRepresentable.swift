//
//  TerminalViewRepresentable.swift
//  BasicGames
//
//  Created by Joseph Baraga on 12/28/21.
//

import SwiftUI
import SwiftTerm


struct TerminalViewRepresentable: NSViewRepresentable {
    typealias NSViewType = GameTerminalView
    
    let frame: CGRect
    let game: Game
    var isTerminated: Bool = false
    
    @ObservedObject private var settings = Preferences.shared
        
    func makeCoordinator() -> Coordinator { .init() }
    
    func makeNSView(context: Context) -> GameTerminalView {
        let terminalView = GameTerminalView(frame: frame)
        guard let path = Bundle.main.path(forAuxiliaryExecutable: "play") else { return terminalView }
        terminalView.hasFocus = true  //For proper rendering of cursor outline
        terminalView.foregroundColor = settings.foregroundColor
        terminalView.nativeBackgroundColor = .terminalBackground
        terminalView.setCursorStyle(style: settings.cursorStyle)

        context.coordinator.terminal = terminalView.getTerminal()
        terminalView.delegate = context.coordinator
        
        Task {
            try await Task.sleep(seconds: 1)
            await MainActor.run {
                terminalView.startProcess(executable: path, args: ["-g", game.rawValue], environment: nil, execName: nil)
            }
        }
        return terminalView
    }
    
    func updateNSView(_ nsView: GameTerminalView, context: Context) {
        if isTerminated {
            nsView.send(txt: "\n\nPROCESS TERMINATED")
            nsView.terminateProcess()
        }
        
        nsView.foregroundColor = settings.foregroundColor
        nsView.setCursorStyle(style: settings.cursorStyle)
    }
    
    internal class Coordinator: GameTerminalViewDelegate {
        weak var terminal: Terminal?
                
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
            terminal?.hideCursor()
        }
    }
}


struct GameView: View {
    let game: Game
    
    @State private var isTerminated = false  //For termination, currently not used for macOS 13 compatibility
    @FocusState private var isFocused: Bool
    
    private var contentView: some View {
        GeometryReader { geometry in
            TerminalViewRepresentable(frame: geometry.frame(in: .local), game: game, isTerminated: isTerminated)
                .navigationTitle(game.description)
                .focused($isFocused)
        }
        .padding(.leading, 4)
        .padding(.bottom, 1)
        .background(Color(.terminalBackground))
        .onAppear { isFocused = true }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { notification in
            guard let window = notification.object as? NSWindow, window.title == game.description else { return }
            isTerminated = true  //Process is not killed for user window close
        }
    }
    
    var body: some View {
        if #available(macOS 14, *) {
            contentView
                .onKeyPress(.init("c"), phases: .down) { keyPress in
                    guard keyPress.modifiers == [.control] else { return .ignored }
                    //                    isTerminated = true
                    DistributedNotificationCenter.default().post(name: .terminalCommand, object: TerminalCommand.break.rawValue)
                    return.handled
                }
        } else {
            contentView
        }
    }
}

