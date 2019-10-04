//
//  PlaySnakeViewModel.swift
//  UnitTestPractice
//
//  Created by Paul.Chou on 2019/10/1.
//  Copyright © 2019 Paul.Chou. All rights reserved.
//

import Foundation

protocol PlaySnakeViewModelDelegate: class {
    func refreshPlayView(_ playSnakeViewModel: PlaySnakeViewModelType)
    func endPlay(_ playSnakeViewModel: PlaySnakeViewModelType)
}

enum PlayViewState: Int {
    case started
    case ended
    case paused
}

protocol PlaySnakeViewModelInputs {
    func changeDirection(newDirection: Snake.Direction)
    func startGame()
    func pause()
    func reset()
    func setSnakeViewDelegate(target: PlaySnakeViewModelDelegate)
}

protocol PlaySnakeViewModelOutputs {
    func getSnakeBody() -> [Position]
    func getRedDot() -> Position
    var state: PlayViewState { get }
}

protocol PlaySnakeViewModelType {
    var inputs: PlaySnakeViewModelInputs { get }
    var outputs: PlaySnakeViewModelOutputs { get }
}

class PlaySnakeViewModel: PlaySnakeViewModelType{

    private let speedUpRatio: Double = 0.8
    private var snake = Snake.empty
    private var speed: Double
    private var redDot = Position(x: -1, y: -1)
    private var timer: Timer?
    private var gameState: PlayViewState
    weak var delegate: PlaySnakeViewModelDelegate?
    var inputs: PlaySnakeViewModelInputs { return self }
    var outputs: PlaySnakeViewModelOutputs { return self }

    init(speed: Double = 0.5) {
        self.speed = speed
        gameState = .paused
        createNewRedDot()
    }

}
extension PlaySnakeViewModel: PlaySnakeViewModelInputs {
    func changeDirection(newDirection: Snake.Direction) {
        if abs(snake.direction.rawValue - newDirection.rawValue) == 2 { return }
        snake.direction = newDirection
        self.delegate?.refreshPlayView(self)
    }

    func startGame() {
        gameState = .started
        activateTimer(speedTimeInterval: TimeInterval(speed))
    }

    func pause() {
        gameState = .paused
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

    func setSnakeViewDelegate(target: PlaySnakeViewModelDelegate) {
        self.delegate = target
    }
}

extension PlaySnakeViewModel: PlaySnakeViewModelOutputs {
    func getSnakeBody() -> [Position] {
        return snake.body
    }

    func getRedDot() -> Position {
        return redDot
    }

    var state: PlayViewState {
        return gameState
    }
}

private extension PlaySnakeViewModel {
    func end() {
        gameState = .ended
        timer?.invalidate()
        timer = nil
        delegate?.endPlay(self)
    }

    func speedUp() {
        timer?.invalidate()
        timer = nil
        speed *= speedUpRatio
        let timeInterval = TimeInterval(speed)
        activateTimer(speedTimeInterval: timeInterval)
    }

    func activateTimer(speedTimeInterval: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: speedTimeInterval, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }

            let nextStep = self.moveStep()
            let hasEatReddot = self.checkEatRedDot(nextStep)
            let hasCollision = self.checkCollision(nextStep)

            if hasCollision {
                self.end()
                return
            }
            self.moveSnakeBody(to: nextStep, needRemoveLast: !hasEatReddot)
            if hasEatReddot {
                self.createNewRedDot()
                self.speedUp()
            }

            self.delegate?.refreshPlayView(self)
        })
    }

    func moveStep() -> Position? {
        guard let firstPosition = snake.body.first else { return nil }
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
        return newPosition
    }

    func moveSnakeBody(to newPosition: Position?, needRemoveLast: Bool) {
        guard let newBodyPosition = newPosition else { return }
        snake.body.insert(newBodyPosition, at: 0)
        if needRemoveLast {
            snake.body.removeLast()
        }
    }

    func checkCollision(_ newPosition: Position?) -> Bool {
        guard let inNewPostion = newPosition else { return true }
        if inNewPostion.currentY() < 0 || inNewPostion.currentY() > Int(PlaySnakeView.height) ||
            inNewPostion.currentX() < 0 || inNewPostion.currentX() > Int(PlaySnakeView.width) {
            return true
        }
        if snake.body.contains(inNewPostion) {
            return true
        }
        return false
    }

    func checkEatRedDot(_ headPosition: Position?) -> Bool {
        guard let inHeadPostion = headPosition else { return false }
        if inHeadPostion == redDot {
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
