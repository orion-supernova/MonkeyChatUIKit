//
//  SocketClient.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 13.05.2023.
//

import Foundation
import Starscream

protocol SocketClientDelegate: AnyObject {
    func changedSocketStatus(with status: SocketStatus)
    func handleSocketMessage(with message: SocketMessage)
}

protocol SocketClientProtocol {
    var delegate: SocketClientDelegate? { get set }
    func send(data: Data)
}

class SocketClient: SocketClientProtocol {
    weak var delegate: SocketClientDelegate?
    private var socket: WebSocket?

    init() {
        var request = URLRequest(url: URL(string: "http://localhost:8080")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }

    func send(data: Data) {
        socket?.write(data: data)
    }
}

extension SocketClient: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
            case .connected(let headers):
                debugPrint("websocket is connected: \(headers)")
                delegate?.changedSocketStatus(with: .connected)
            case .disconnected(let reason, let code):
                debugPrint("websocket is disconnected: \(reason) with code: \(code)")
                delegate?.changedSocketStatus(with: .disconnected)
            case .binary(let data):
                debugPrint("Received data: \(data.count)")
                let socketMessage = SocketMessage.decodeSocketMessage(from: data)
                delegate?.handleSocketMessage(with: socketMessage)
            default:
                print("Received data")
        }
    }
}
