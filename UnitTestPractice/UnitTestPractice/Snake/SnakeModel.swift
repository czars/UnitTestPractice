//
//  SnakeModel.swift
//  UnitTestPractice
//
//  Created by Paul.Chou on 2019/10/1.
//  Copyright © 2019 Paul.Chou. All rights reserved.
//

import Foundation

struct Position: Equatable {
    private let x: Int
    private let y: Int

    init(x: Int = 0, y: Int = 0) {
        self.x = x
        self.y = y
    }

    func currentX() -> Int { return x }
    func currentY() -> Int { return y }
}

struct Snake {
    var head: Position
    var body: [Position]
    var direction: Direction

    enum Direction: Int {
        case right = 0
        case up
        case left
        case down
    }

    static let empty = Snake(head: Position(), body: [Position(x: 22, y: 10), Position(x: 21, y: 10), Position(x: 20, y: 10),], direction: .right)
}
