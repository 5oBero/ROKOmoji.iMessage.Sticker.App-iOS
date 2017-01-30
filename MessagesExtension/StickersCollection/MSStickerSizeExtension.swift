//
//  MSStickerSizeExtension.swift
//  iMessageStickers
//
//  Created by Maslov Sergey on 30.01.17.
//  Copyright © 2017 ROKO. All rights reserved.
//

import UIKit
import Messages

extension MSStickerSize {
    static func fromInt(_ value: Int) -> MSStickerSize {
        if value < 3 {
            if let stickerSize = MSStickerSize(rawValue: value) {
                return stickerSize
            }
        }
        return .large
    }
}
