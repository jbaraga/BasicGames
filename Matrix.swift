//
//  Matrix.swift
//  play
//
//  Created by Joseph Baraga on 1/18/25.
//

import Foundation


//MARK: Size
struct Size: Equatable {
    var width = 0
    var height = 0
    
    static let zero = Self.init()
}

extension Size: LosslessStringConvertible {
    var description: String { "\(width) x \(height)" }
    
    init?(_ description: String) {
        let stringValues = description.components(separatedBy: CharacterSet(charactersIn: " ,")).compactMap { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        guard stringValues.count == 2, let width = Int(stringValues[0]), width >= 0, let height = Int(stringValues[1]), height >= 0 else { return nil }
        self.init(width: width, height: height)
    }
}


//MARK: Point
struct Point: Equatable {
    var x = 0
    var y = 0
    
    static let zero = Self.init()
}

extension Point: LosslessStringConvertible {
    var description: String { "\(x),\(y)" }
    
    init?(_ description: String) {
        let stringValues = description.components(separatedBy: CharacterSet(charactersIn: " ,")).compactMap { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        guard stringValues.count == 2, let x = Int(stringValues[0]), let y = Int(stringValues[1]) else { return nil }
        self.init(x: x, y: y)
    }
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    init(_ tuple: (Int, Int)) {
        self.x = tuple.0
        self.y = tuple.1
    }
}


//MARK: Matrix
struct Matrix<Element> {
    var array2D: [[Element]]
    
    var rows: [[Element]] { array2D }
    var columns: [[Element]] { array2D.transposed() }
    
    var forwardDiagonals: [[Element]] { diagonals(for: array2D) }
    var backwardDiagonals: [[Element]] { diagonals(for: array2D.flipped()).flipped() }
    
    var indices: [(row: Int, column: Int)] {
        array2D.indices.reduce([(Int, Int)]()) { result, row in
            let columnIndices = [Int](array2D[row].indices)
            return result + columnIndices.map { (row, $0) }
        }
    }
    
    var elements: [Element] { Array(array2D.joined()) }

    init(rows: Int, columns: Int, value: Element) {
        array2D = Array(repeating: Array(repeating: value, count: columns), count: rows)
    }
    
    init(array2D: [[Element]]) {
        let columnCounts = Set(array2D.map { $0.count })
        assert(array2D.count > 0 && columnCounts.count == 1 && array2D[0].count > 0, "Invalid matrix initialization")
        self.array2D = array2D
    }
    
    func isValid(point: Point) -> Bool {
        return indexIsValid(row: point.x, column: point.y)
    }
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        guard array2D.indices.contains(row) else { return false }
        return array2D[row].indices.contains(column)
    }
        
    subscript(_ row: Int, _ column: Int) -> Element {
        get {
            assert(indexIsValid(row: row, column: column), "Index out for range")
            return array2D[row][column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out for range")
            array2D[row][column] = newValue
        }
    }
    
    subscript(_ index: (row: Int, column: Int)) -> Element {
        get { self[index.row, index.column] }
        set { self[index.row, index.column] = newValue }
    }
    
    subscript(_ point: Point) -> Element {
        get { self[point.x, point.y] }
        set { self[point.x, point.y] = newValue }
    }
    
    subscript(_ row: Int, _ columnRange: Range<Int>) -> ArraySlice<Element> {
        get { array2D[row][columnRange] }
    }
    
    //Only valid for square matrices
    private func diagonals(for array2D: [[Element]]) -> [[Element]] {
        guard let row = array2D.first else { return [] }
        assert(array2D.count == row.count, "Matrix is not square")
        let n = 2 * array2D.count - 1
        var diagonals = dim(n, n, value: Optional<Element>.none)
        array2D.indices.forEach { x in
            array2D[x].indices.forEach { y in
                let i = x + y
                let j = y - x + array2D.endIndex - 1
                diagonals[i][j] = array2D[x][y]
            }
        }
        return diagonals.map { $0.compactMap { $0 } }
    }
}

