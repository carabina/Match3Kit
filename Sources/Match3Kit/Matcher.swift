//
//  Matcher.swift
//  Match3Kit
//
//  Created by Alexey on 15.02.2020.
//  Copyright © 2020 Alexey. All rights reserved.
//

/// Matches detector
open class Matcher<Filling: GridFilling> {

    public let fillings: [Filling]
    public let minSeries: Int

    public required init(fillings: [Filling], minSeries: Int) {
        self.minSeries = minSeries
        self.fillings = fillings
    }

    public func findAllMatches(on grid: Grid<Filling>) -> Set<Index> {
        return grid.allIndices().reduce(Set()) { result, index in
            result.union(findMatches(on: grid, at: index))
        }
    }

    public func findMatches(on grid: Grid<Filling>, at index: Index) -> Set<Index> {
        let cell = grid.cell(at: index)
        guard fillings.contains(cell.filling) else {
            return Set()
        }

        func matchCellsInRow(sequence: UnfoldFirstSequence<Index>) -> [Index] {
            sequence.prefix {
                grid.size.isOnBounds($0) && grid.cell(at: $0).match(with: cell)
            }
        }

        let verticalIndicies = matchCellsInRow(sequence: index.upperSequence()) +
            matchCellsInRow(sequence: index.lowerSequence()) + [index]
        let horizontalIndicies = matchCellsInRow(sequence: index.rightSequence()) +
            matchCellsInRow(sequence: index.leftSequence()) + [index]

        var result = Set<Index>()
        if verticalIndicies.count >= minSeries {
            result.formUnion(verticalIndicies)
        }
        if horizontalIndicies.count >= minSeries {
            result.formUnion(horizontalIndicies)
        }
        return result
    }
}
