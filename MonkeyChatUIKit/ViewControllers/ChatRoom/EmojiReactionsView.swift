//
//  EmojiReactionsView.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 26.06.2022.
//

import UIKit
import SnapKit
import RiveRuntime

class EmojiReactionsView: UIView {
    enum State {
        case added
        case removed
    }
    // MARK: - UI Elements
    private lazy var mainStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [love,mindBlown,bullsEye,joy,tada,onFire])
        view.axis = .horizontal
        view.spacing = 5
        view.distribution = .fillEqually
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 20
        return view
    }()

    private lazy var love: RiveView = {
        let view = RiveView()
        riveViewModelLove.setView(view)
        riveViewModelLove.play(animationName: "Heart_play", loop: Loop.loopAuto, direction: Direction.directionAuto)
        return view
    }()
    private lazy var mindBlown: RiveView = {
        let view = RiveView()
        riveViewModelMindblown.setView(view)
        riveViewModelMindblown.play(animationName: "Brain_play", loop: Loop.loopAuto, direction: Direction.directionAuto)
        return view
    }()
    private lazy var bullsEye: RiveView = {
        let view = RiveView()
        riveViewModelBullseye.setView(view)
        return view
    }()
    private lazy var joy: RiveView = {
        let view = RiveView()
        riveViewModelJoy.setView(view)
        return view
    }()
    private lazy var tada: RiveView = {
        let view = RiveView()
        riveViewModelTada.setView(view)
        riveViewModelTada.play(animationName: "Dart_board_play", loop: Loop.loopAuto, direction: Direction.directionAuto)
        return view
    }()
    private lazy var onFire: RiveView = {
        let view = RiveView()
        riveViewModelOnfire.setView(view)
        riveViewModelBullseye.play(animationName: "Dart_board_play", loop: Loop.loopAuto, direction: Direction.directionAuto)
        return view
    }()

    private lazy var person: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        return imageView
    }()

    // MARK: - Public Properties
    var indexPath: IndexPath?
    var riveViewModelOnfire = RiveViewModel(fileName: "animated-emojis",
                                            fit: .fitScaleDown,
                                            alignment: .alignmentCenter,
                                            autoPlay: true,
                                            artboardName: "Onfire")
    var riveViewModelMindblown = RiveViewModel(fileName: "animated-emojis",
                                               fit: .fitFitWidth,
                                               alignment: .alignmentCenter,
                                               autoPlay: true,
                                               artboardName: "Mindblown")
    var riveViewModelBullseye = RiveViewModel(fileName: "animated-emojis",
                                              fit: .fitFitWidth,
                                              alignment: .alignmentCenter,
                                              autoPlay: true,
                                              artboardName: "Bullseye")
    var riveViewModelLove = RiveViewModel(fileName: "animated-emojis",
                                          fit: .fitFitWidth,
                                          alignment: .alignmentCenter,
                                          autoPlay: true,
                                          artboardName: "love")
    var riveViewModelJoy = RiveViewModel(fileName: "animated-emojis",
                                         fit: .fitFitWidth,
                                         alignment: .alignmentCenter,
                                         autoPlay: true,
                                         artboardName: "joy")
    var riveViewModelTada = RiveViewModel(fileName: "animated-emojis",
                                          fit: .fitFitWidth,
                                          alignment: .alignmentCenter,
                                          autoPlay: true,
                                          artboardName: "Tada")


    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        layout()
    }
    deinit {
        print("DEINIT EMOJIREACTIONSVIEW")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    // MARK: - Setup & Layout
    private func setup() {
        self.addSubview(mainStackView)
    }

    private func layout() {
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
