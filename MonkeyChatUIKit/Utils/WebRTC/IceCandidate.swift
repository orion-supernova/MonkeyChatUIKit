//
//  IceCandidate.swift
//  MonkeyChatUIKit
//
//  Created by Murat Can KOÇ on 13.05.2023.
//

import Foundation
import WebRTC

struct IceCandidate: Codable {
    var sdpMid: String?
    var sdpMLineIndex: Int32
    var sdp: String

    init(from iceCandidate: RTCIceCandidate) {
        self.sdpMid = iceCandidate.sdpMid
        self.sdpMLineIndex = iceCandidate.sdpMLineIndex
        self.sdp = iceCandidate.sdp
    }

    func getRTCIceCandidate() -> RTCIceCandidate {
        RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
    }
}
