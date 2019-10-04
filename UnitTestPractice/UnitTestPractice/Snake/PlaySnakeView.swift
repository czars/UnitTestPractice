//
//  PlaySnakeView.swift
//  UnitTestPractice
//
//  Created by Paul.Chou on 2019/10/1.
//  Copyright © 2019 Paul.Chou. All rights reserved.
//

import UIKit

protocol PlaySnakeViewDelegate: class {
    func endPlay(_ playView: PlaySnakeView)
}

class PlaySnakeView: UIView {

    static let width: CGFloat = 40.0
    static let height: CGFloat = 40.0

    var viewModel: PlaySnakeViewModel
    var rectWidth = 0
    var rectHeight = 0
    weak var delegate: PlaySnakeViewDelegate?

    init(with viewModel: PlaySnakeViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.viewModel.delegate = self
        rectWidth = Int(UIScreen.main.bounds.width / PlaySnakeView.width)
        rectHeight = Int(UIScreen.main.bounds.width / PlaySnakeView.height)
    }
    required init?(coder: NSCoder) {
        fatalError("should not go into here")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
          return
        }
        drawSnake(in: context)
        drawRedDot(in: context)
    }
}

extension PlaySnakeView: PlaySnakeViewModelDelegate {
    func refreshPlayView(_ playSnakeViewModel: PlaySnakeViewModel) {
        self.setNeedsDisplay()
    }

    func endPlay(_ playSnakeViewModel: PlaySnakeViewModel) {
        delegate?.endPlay(self)
    }
}

private extension PlaySnakeView {
    func drawSnake(in context: CGContext) {
        viewModel.getSnakeBody().forEach { position in
            let rect = CGRect(x: position.currentX()*rectWidth, y: position.currentY()*rectHeight, width: rectWidth, height: rectHeight)
            self.drawSquare(at: rect, in: context)
        }
        drawRedDot(in: context)
    }

    func drawRedDot(in context: CGContext) {
        let reddot = viewModel.getRedDot()
        let rect = CGRect(x: reddot.currentX()*rectWidth, y: reddot.currentY()*rectHeight, width: rectWidth, height: rectHeight)
        context.saveGState()
        context.setFillColor(UIColor.red.cgColor)
        context.fill(rect)
        context.restoreGState()
    }

    func drawSquare(at rect: CGRect, in context: CGContext) {
        context.saveGState()
        context.setFillColor(UIColor.blue.cgColor)
        context.fill(rect)
        context.restoreGState()
    }
}
