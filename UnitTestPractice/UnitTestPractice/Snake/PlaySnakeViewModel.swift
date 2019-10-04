//
//  PlaySnakeViewModel.swift
//  UnitTestPractice
//
//  Created by Paul.Chou on 2019/10/1.
//  Copyright © 2019 Paul.Chou. All rights reserved.
//

import Foundation

protocol PlaySnakeViewModelDelegate: class {
    func refreshPlayView(_ playSnakeViewModel: PlaySnakeViewModel)
    func endPlay(_ playSnakeViewModel: PlaySnakeViewModel)
}

enum PlayViewState: Int {
    case started
    case ended
    case paused
}

class PlaySnakeViewModel {

    private let speedUpRatio: Double = 0.8
    private var snake = Snake.empty
    private var speed: Double
    private var redDot = Position(x: -1, y: -1)
    private var timer: Timer?
    var state: PlayViewState
    weak var delegate: PlaySnakeViewModelDelegate?

    init(speed: Double = 0.5) {
        self.speed = speed
        state = .paused
        createNewRedDot()
    }

    func activateTimer(speedTimeInterval: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: speedTimeInterval, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.moveStep()
            self.delegate?.refreshPlayView(self)
        })
    }

    func speedUp() {
        timer?.invalidate()
        timer = nil
        speed *= speedUpRatio
        let timeInterval = TimeInterval(speed)
        activateTimer(speedTimeInterval: timeInterval)
    }

    func changeDirection(newDirection: Snake.Direction) {
        if abs(snake.direction.rawValue - newDirection.rawValue) == 2 { return }
        snake.direction = newDirection
        self.delegate?.refreshPlayView(self)
    }

    func toggleAction() {
        switch state {
        case .paused:
            startGame()
        case .ended:
            reset()
        case .started:
            pause(with: .paused)
        }
    }

    func startGame() {
        state = .started
        activateTimer(speedTimeInterval: TimeInterval(speed))
    }

    func pause(with state: PlayViewState) {
        self.state = state
        timer?.invalidate()
        timer = nil
        delegate?.endPlay(self)
    }

    func reset() {
        snake = Snake.empty
        speed = 0.5
        createNewRedDot()
        startGame()
    }
}

extension PlaySnakeViewModel {
    func getSnakeBody() -> [Position] {
        return snake.body
    }

    func getRedDot() -> Position {
        return redDot
    }
}

private extension PlaySnakeViewModel {
    func moveStep() {
        guard let firstPosition = snake.body.first else { return }
        var newPosition: Position
        switch snake.direction {
        case .right:
            newPosition = Position(x: firstPosition.currentX()+1, y: firstPosition.currentY())
            break
        case .left:
            newPosition = Position(x: firstPosition.currentX()-1, y: firstPosition.currentY())
            break
        case .up:
            newPosition = Position(x: firstPosition.currentX(), y: firstPosition.currentY()-1)
            break
        case .down:
            newPosition = Position(x: firstPosition.currentX(), y: firstPosition.currentY()+1)
            break
        }

        if checkCollision(newPosition) {
            print("There's collision")
            pause(with: .ended)
            return
        }

        snake.body.insert(newPosition, at: 0)
        if !checkEatRedDot(newPosition) {
            snake.body.removeLast()
        }
    }

    func checkCollision(_ newPosition: Position) -> Bool {
        var isCollision = false

        if newPosition.currentY() < 0 || newPosition.currentY() > Int(PlaySnakeView.height) ||
            newPosition.currentX() < 0 || newPosition.currentX() > Int(PlaySnakeView.width) {
            isCollision = true
        }

        if snake.body.contains(newPosition) {
            isCollision = true
        }

        return isCollision
    }

    func checkEatRedDot(_ headPosition: Position) -> Bool {
        if headPosition == redDot {
            createNewRedDot()
            speedUp()
            return true
        }
        return false
    }

    func createNewRedDot() {
        let randomX = Int.random(in: 0...Int(PlaySnakeView.width))
        let randomY = Int.random(in: 0...Int(PlaySnakeView.height))
        redDot = Position(x: randomX, y: randomY)
        if checkCollision(redDot) {
            createNewRedDot()
            return
        }
    }
}
