//
//  Tensor.swift
//  play
//
//  Created by Joseph Baraga on 2/19/25.
//

import Foundation


struct Tensor<Element> {
    var matrixes: [Matrix<Element>]
    
    var rowMatrixes: [Matrix<Element>] {
        guard let matrix = matrixes.first else { return [] }
        assert(matrixes.count == matrix.rows.count && matrixes.count == matrix.columns.count, "Tensor is not cubic")
        
        let indexes = matrix.rows.indices
        var matrixArray = [Matrix<Element>]()
        for index in indexes {
            let array2D = matrixes.map { $0.rows[index] }
            matrixArray.append(Matrix(array2D: array2D))
        }
        return matrixArray
    }
    
    var columnMatrixes: [Matrix<Element>] {
        guard let matrix = matrixes.first else { return [] }
        assert(matrixes.count == matrix.rows.count && matrixes.count == matrix.columns.count, "Tensor is not cubic")
        
        let indexes = matrix.columns.indices
        var matrixArray = [Matrix<Element>]()
        for index in indexes {
            let array2D = matrixes.map { $0.columns[index] }
            matrixArray.append(Matrix(array2D: array2D))
        }
        return matrixArray
    }

    var mainDiagonalMatrix: Matrix<Element> {
        guard let matrix = matrixes.first else { fatalError("Tensor empty") }
        assert(matrixes.count == matrix.rows.count && matrixes.count == matrix.columns.count, "Tensor is not cubic")
        
        let array2D = matrixes.map { $0.mainDiagonal }
        return Matrix(array2D: array2D)
    }
    
    var antiDiagonalMatrix: Matrix<Element> {
        guard let matrix = matrixes.first else { fatalError("Tensor empty") }
        assert(matrixes.count == matrix.rows.count && matrixes.count == matrix.columns.count, "Tensor is not cubic")
        
        let array2D = matrixes.map { $0.antiDiagonal }
        return Matrix(array2D: array2D)
    }

    var oldLines: [[Element]] {
        var lineArray = [[Element]]()
        //Row slices - n*10 lines
        rowMatrixes.forEach {
            lineArray += $0.rows + $0.columns + [$0.mainDiagonal, $0.antiDiagonal]
        }
        
        //Column slices - rows and diagnonals only, columns are counted in row slices - n*6 lines
        columnMatrixes.forEach {
            lineArray += $0.rows + [$0.mainDiagonal, $0.antiDiagonal]
        }
        
        //Planes - diagonals only, rows and columns counted in row and columns slices - n*2 lines
        matrixes.forEach {
            lineArray += [$0.mainDiagonal, $0.antiDiagonal]
        }
        
        //Tensor internal main- and anti-diagonals - 4 lines
        lineArray += [mainDiagonalMatrix.mainDiagonal, mainDiagonalMatrix.antiDiagonal, antiDiagonalMatrix.mainDiagonal, antiDiagonalMatrix.antiDiagonal]
        
        return lineArray
    }
    
    //Exact match for order of lines in 3d tic tac toe - lines 2040-2220
    var lines: [[Element]] {
        var lineArray = [[Element]]()
        
        matrixes.forEach { lineArray += $0.rows }
        columnMatrixes.forEach { lineArray += $0.columns}
        columnMatrixes.forEach { lineArray += $0.rows }
        matrixes.forEach { lineArray.append($0.mainDiagonal) }
        matrixes.forEach { lineArray.append($0.antiDiagonal.reversed()) }
        columnMatrixes.forEach { lineArray.append($0.mainDiagonal) }
        columnMatrixes.forEach { lineArray.append($0.antiDiagonal.reversed()) }
        rowMatrixes.forEach { lineArray.append($0.mainDiagonal) }
        rowMatrixes.forEach { lineArray.append($0.antiDiagonal.reversed()) }
        
        lineArray += [mainDiagonalMatrix.mainDiagonal, mainDiagonalMatrix.antiDiagonal, antiDiagonalMatrix.mainDiagonal, antiDiagonalMatrix.antiDiagonal]
       
        return lineArray
    }

    var lineIndexes: [[(x: Int, y: Int, z: Int)]] {
        var coordinateTensor = Tensor<(Int,Int,Int)>(dimension: 4, value: (0,0,0))
        for (z, matrix) in coordinateTensor.matrixes.enumerated() {
            for (x, array) in matrix.rows.enumerated() {
                for y in array.indices {
                    coordinateTensor[x,y,z] = (x,y,z)
                }
            }
        }
        
        return coordinateTensor.lines
    }
    
    var indexedLines: [[((x: Int, y: Int, z: Int), Element)]] {
        zip(lineIndexes, lines).map {
            return zip($0.0, $0.1).map { ($0.0, $0.1) }
        }
    }

    var elements: [Element] { matrixes.reduce([Element]()) { $0 + $1.elements }}
    
    var indexes: [(x: Int, y: Int, z: Int)] {
        var indices = [(x: Int, y: Int, z: Int)]()
        for (z, matrix) in matrixes.enumerated() {
            for (x, array) in matrix.rows.enumerated() {
                for y in array.indices {
                    indices.append((x,y,z))
                }
            }
        }
        return indices
    }

    init(rows: Int, columns: Int, planes: Int, value: Element) {
        matrixes = Array(repeating: Matrix(rows: rows, columns: columns, value: value), count: planes)
    }
    
    init(dimension: Int, value: Element) {
        self.init(rows: dimension, columns: dimension, planes: dimension, value: value)
    }
    
    init(matrices: [Matrix<Element>]) {
        self.matrixes = matrices
    }
    
    subscript(_ x: Int, _ y: Int, _ z: Int) -> Element {
        get {
            assert(indexIsValid(x: x, y: y, z: z), "Index out for range \(x), \(y), \(z)")
            return matrixes[z][x, y]
        }
        set {
            assert(indexIsValid(x: x, y: y, z: z), "Index out for range \(x), \(y), \(z)")
            return matrixes[z][x, y] = newValue
        }
    }
    
    subscript(_ index: (x: Int, y: Int, z: Int)) -> Element {
        get { self[index.x, index.y, index.z] }
        set { self[index.x, index.y, index.z] = newValue }
    }
    
    //x == row, y == column
    func indexIsValid(x: Int, y: Int, z: Int) -> Bool {
        guard matrixes.indices.contains(z) else { return false }
        return matrixes[z].indexIsValid(row: x, column: y)
    }
    
    func print() {
        matrixes.forEach {
            $0.print()
            Swift.print()
        }
    }
}

extension Tensor: Sequence {
    func makeIterator() -> IndexingIterator<[Matrix<Element>]> {
        return matrixes.makeIterator()
    }
}
