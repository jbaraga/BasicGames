//
//  BasicGamesTests.swift
//  BasicGamesTests
//
//  Created by Joseph Baraga on 1/15/25.
//

import Testing
@testable import BasicGames
import Foundation

struct BasicGamesTests {

    @Test(arguments: [Game.battle])
    func playTest(game: Game) throws {
        guard let path = Bundle.main.path(forResource: "play", ofType: nil) else { throw URLError(.unsupportedURL) }
        let url = URL(fileURLWithPath: path)
        let process = Process()
        process.standardOutput = FileHandle.standardOutput
        process.executableURL = url
        process.arguments = ["-g", game.rawValue, "-t"]
        try process.run()
    }
}
