//
//  EmptyDataView.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 28.08.2023.
//

import UIKit
import SnapKit

class EmptyDataView: UIView {

    // MARK: - UI Elements
    private lazy var title: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.font          = .systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 0
        label.textColor     = UIColor(named: "Black-White")
        label.accessibilityIdentifier = "title"
        return label
    }()

    lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor         = .systemPink
        button.titleLabel?.font        = .systemFont(ofSize: 14, weight: .bold)
        button.titleLabel?.textColor   = .white
        button.tintColor               = .white
        button.clipsToBounds           = true
        button.layer.cornerRadius      = 4
        button.accessibilityIdentifier = "actionButton"
        button.contentEdgeInsets       = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
        return button
    }()

    // MARK: - Public Variables
    var tapAction: (() -> Void)?

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        layout()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("deinit EmptyDataView")
    }

    // MARK: - Setup
    private func setup() {
        addSubview(title)
        addSubview(actionButton)
    }

    private func layout() {
        actionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.greaterThanOrEqualTo(40)
        }

        title.snp.makeConstraints { make in
            make.bottom.equalTo(self.actionButton.snp.top).offset(-30)
            make.leading.equalTo(55)
            make.trailing.equalTo(-55)
            make.height.greaterThanOrEqualTo(30)
            make.top.greaterThanOrEqualTo(30)
        }
    }

    // MARK: - Public Methods
    func prepareView(text: String, buttonText: String? = nil) {
        self.title.text = text
        guard let buttonText else {
            title.snp.remakeConstraints { make in
                make.leading.equalTo(55)
                make.trailing.equalTo(-55)
                make.centerY.equalToSuperview().multipliedBy(0.5)
                make.height.greaterThanOrEqualTo(30)
            }
            actionButton.removeFromSuperview()
            return
        }
        self.actionButton.setTitle(buttonText, for: .normal)
    }

    @objc private func tapped(_ sender: UIButton) {
        tapAction?()
    }

    func buttonTapAction(tapAction: @escaping () -> Void) {
        self.tapAction = tapAction
    }
}

extension UITableView {
    func addEmptyDataView(text: String, buttonText: String?, isScrollEnabled: Bool = false, completion: (() -> Void)? = nil) {
        let view = EmptyDataView(frame: .zero)
        view.prepareView(text: text, buttonText: buttonText)
        view.buttonTapAction {
            completion?()
        }
        removeEmptyView()
        self.backgroundView = view

        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.width.equalToSuperview()
        }
        self.isScrollEnabled = isScrollEnabled
        /*
         Örnek kullanım
         self.tableView.addEmptyDataView(text: "Bültende aktif koşu bulunmamaktadır.", buttonText: "Yarış Sonuçlarına Git") {
         print("Butona basıldııııı.")
         }
         */
    }

    func removeEmptyView() {
        self.backgroundView = nil
        self.isUserInteractionEnabled = true
    }
}
