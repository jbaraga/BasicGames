//
//  Preferences.swift
//  BasicGames
//
//  Created by Joseph Baraga on 2/11/22.
//

import Foundation
import SwiftUI
import CryptoKit
import SwiftTerm

class Preferences: ObservableObject {
    static let shared = Preferences()
    
    @Published private var _cursorStyle: CursorStyle = .blinkBlock
    @Published private var _foregroundColor = NSColor.terminalWhite
    @Published private var _category: Category = .all
    @Published private var _unlockedEggs = [Data]()
    
    var cursorStyle: CursorStyle {
        get { _cursorStyle }
        set {
            _cursorStyle = newValue
            UserDefaults.standard.setValue(newValue, forKey: "cursorStyle")
        }
    }
    
    var foregroundColor: NSColor {
        get { _foregroundColor }
        set {
            _foregroundColor = newValue
            UserDefaults.standard.set(try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false), forKey: "foregroundColor")
        }
    }
    
    var category: Category {
        get { _category }
        set {
            _category = newValue
            UserDefaults.standard.setValue(newValue, forKey: "category")
        }
    }
    
    private var unlockedEggs: [Data] {
        get { _unlockedEggs }
        set {
            _unlockedEggs = newValue
            let data = newValue.reduce(Data()) { $0 + $1 }
            UserDefaults.standard.set(data, forKey: "data")
        }
    }
    
    private init() {
        _cursorStyle = UserDefaults.standard.value(for: "cursorStyle") ?? CursorStyle.blinkBlock
        _foregroundColor = UserDefaults.standard.color(for: "foregroundColor") ?? NSColor.terminalWhite
        _category = UserDefaults.standard.value(for: "category") ?? Category.all
        
        if let data = UserDefaults.standard.value(forKey: "data") as? Data {
            _unlockedEggs = stride(from: 0, to: data.count, by: SHA512.Digest.byteCount).map {
                data[$0..<($0 + SHA512.Digest.byteCount)]
            }
        }
    }
    
    func isUnlocked(_ game: Game) -> Bool {
        guard let serialNumber = Device.serialNumber else { return false }
        guard let hashData = (game.rawValue + serialNumber).data(using: .utf8) else { return false }
        let data = Data(SHA512.hash(data: hashData))
        return unlockedEggs.contains(data)
    }
    
    func unlock(_ game: Game) {
        if isUnlocked(game) { return }
        guard let serialNumber = Device.serialNumber else { return }
        guard let hashData = (game.rawValue + serialNumber).data(using: .utf8) else { return }
        let data = Data(SHA512.hash(data: hashData))
        unlockedEggs.append(data)
    }
    
    private struct Device {
        static var serialNumber: String? {
            let entry: io_service_t = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
            defer { IOObjectRelease(entry) }
            guard let serialNumberRef = IORegistryEntryCreateCFProperty(entry, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0) else { return nil }
            return serialNumberRef.takeUnretainedValue() as? String
        }

        static var hardwareUUID: String? {
            let matchingDict = IOServiceMatching("IOPlatformExpertDevice")
            let service = IOServiceGetMatchingService(kIOMainPortDefault, matchingDict)
            guard service != 0 else { return nil }
            defer { IOObjectRelease(service) }
            guard let uuidRef = IORegistryEntryCreateCFProperty(service, kIOPlatformUUIDKey as CFString, kCFAllocatorDefault, 0) else { return nil }
            return uuidRef.takeRetainedValue() as? String
        }
    }
}


//MARK: UserDefaults
extension UserDefaults {
    func set(_ color: NSColor, for key: String) {
        self.set(try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false), forKey: key)
    }
    
    func color(for key: String) -> NSColor? {
        guard let data = self.data(forKey: key) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)
    }

    func value<T>(for key: String) -> T? where T: Codable {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func setValue<T: Codable>(_ value: T?, forKey key: String) {
        let data = try? JSONEncoder().encode(value)
        set(data, forKey: key)
    }
}


