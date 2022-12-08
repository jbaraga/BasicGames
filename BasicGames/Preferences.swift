//
//  Preferences.swift
//  BasicGames
//
//  Created by Joseph Baraga on 2/11/22.
//

import Foundation
import SwiftUI
import Combine

class Preferences: ObservableObject {
    static let shared = Preferences()
    
    fileprivate static var cancellableSet: Set<AnyCancellable> = []

    @AppStorage("cursorBlink") var isBlinkingCursor = false
    @Published(key: "foregroundColor") var foregroundColor = NSColor.terminalWhite
    @Published(key: "category") var category = Category.all
    
    private init() {}
}


extension Published where Value == NSColor {
    init(wrappedValue defaultValue: Value, key: String) {
        let data = UserDefaults.standard.data(forKey: key) ?? Data()
        self.init(initialValue: (try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)) ?? defaultValue)
        projectedValue.sink { value in
            UserDefaults.standard.set(try? NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false), forKey: key)
        }
        .store(in: &Preferences.cancellableSet)
    }
}

extension Published where Value == Category {
    init(wrappedValue defaultValue: Value, key: String) {
        let rawValue = UserDefaults.standard.string(forKey: key) ?? ""
        self.init(initialValue: Category(rawValue: rawValue) ?? defaultValue)
        projectedValue.sink { value in
            UserDefaults.standard.set(value.rawValue, forKey: key)
        }
        .store(in: &Preferences.cancellableSet)
    }
}

extension UserDefaults {
    func set(_ color: NSColor, for key: String) {
        self.set(try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false), forKey: key)
    }
    
    func color(for key: String) -> NSColor? {
        guard let data = self.data(forKey: key) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)
    }
    
    var data: Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
    }
}

