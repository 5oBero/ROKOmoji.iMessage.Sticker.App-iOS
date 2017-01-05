//
//  Config.swift
//  iMessageStickers
//
//  Created by Maslov Sergey on 22.11.16.
//  Copyright © 2016 ROKO. All rights reserved.
//

import Foundation
import Messages

struct StickersConfig {
    var stickerSize: MSStickerSize
    var backgroundColor: UIColor
    var logoFileName: String
    
    static var `default`: StickersConfig {
        return StickersConfig(stickerSize: .regular, backgroundColor: UIColor.white, logoFileName: "logo")
    }
}
