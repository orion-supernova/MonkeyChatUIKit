//
//  ChatRoomViewController.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 16.02.2022.
//

import UIKit

class ChatRoomViewController: UIViewController {

     // MARK: - UI Elements




    // MARK: - Private Properties
    let messages = [Message]()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    override func viewDidLayoutSubviews() {
        title = ""
    }

    //MARK: - Setup
    func setup() {

    }
    func layout() {

    }

    // MARK: - Functions


}
