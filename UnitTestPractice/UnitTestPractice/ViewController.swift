//
//  ViewController.swift
//  UnitTestPractice
//
//  Created by Paul.Chou on 2019/9/30.
//  Copyright © 2019 Paul.Chou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var playView: PlaySnakeView?
    private var viewModel = PlaySnakeViewModel(speed: 1)
    private let actionButton = UIButton.init(type: .custom)


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupPlayView()
        setupActionButton()
        setupGestures()

    }

    private func setupPlayView() {
        playView = PlaySnakeView(with: viewModel)
        guard let playView = playView else { return }
        playView.delegate = self
        playView.backgroundColor = .orange
        playView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[playView]|", options: [], metrics: nil, views: ["playView": playView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(100)-[playView]", options: [], metrics: ["safeArea": view.safeAreaInsets.top], views: ["playView": playView]))
        view.addConstraint(NSLayoutConstraint.init(item: playView, attribute: .height, relatedBy: .equal, toItem: playView, attribute: .width, multiplier: 1, constant: 0))
    }

    private func setupActionButton() {
        actionButton.setTitle("Start", for: .normal)
        actionButton.setTitleColor(.orange, for: .normal)
        actionButton.layer.borderWidth = 2.0
        actionButton.layer.borderColor = UIColor.orange.cgColor
        actionButton.backgroundColor = .clear
        actionButton.addTarget(self, action: #selector(toggleAction), for: .touchUpInside)
        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(150)-[actionButton]-(150)-|", options: [], metrics: nil, views: ["actionButton": actionButton]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[actionButton]-(100)-|", options: [], metrics: ["safeArea": view.safeAreaInsets.top], views: ["actionButton": actionButton]))
    }

    private func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }

    @objc func handleGesture(gesture: UISwipeGestureRecognizer) {
        guard let playView = playView else { return }
        switch gesture.direction {
        case .right:
            playView.viewModel.changeDirection(newDirection: .right)
            return
        case .left:
            playView.viewModel.changeDirection(newDirection: .left)
            return
        case .up:
            playView.viewModel.changeDirection(newDirection: .up)
            return
        case .down:
            playView.viewModel.changeDirection(newDirection: .down)
            return
        default:
            playView.viewModel.changeDirection(newDirection: .right)
            return
        }
    }

    @objc func toggleAction() {
        guard let viewModel = playView?.viewModel else { return }
        switch viewModel.state {
        case .paused:
            viewModel.startGame()
        case .started:
            viewModel.pause()
        case .ended:
            viewModel.reset()
        }
        updateActionButton(with: viewModel.state)
    }

    private func updateActionButton(with state: PlayViewState) {
        switch state {
        case .ended:
            actionButton.setTitle("Retry", for: .normal)
        case .started:
            actionButton.setTitle("Pause", for: .normal)
        case .paused:
            actionButton.setTitle("Resume", for: .normal)
        }
    }
}

extension ViewController: PlaySnakeViewDelegate {
    func endPlay(_ playView: PlaySnakeView) {
        updateActionButton(with: playView.viewModel.state)
    }
}

