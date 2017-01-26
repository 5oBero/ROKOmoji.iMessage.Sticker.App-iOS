//
//  StickerCell.swift
//  iMessageStickers
//
//  Created by Maslov Sergey on 29.11.16.
//  Copyright © 2016 ROKO. All rights reserved.
//

import UIKit
import Messages
import ROKOMobi

protocol StickerCellDelegate: class {
    func didSelectCell(cell: StickerCell)
    func didDragCell(cell: StickerCell)
}

class StickerCell: UICollectionViewCell {
    static let identifier = "StickerCell"
    var pack: ROKOStickerPack?
    var sticker: ROKOSticker?
	var position = 0
    
    weak var stickerCellDelegate: StickerCellDelegate?
    let tap = UITapGestureRecognizer()
    let longTap = UILongPressGestureRecognizer()
    
    
    @IBOutlet weak var stickerView: MSStickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        stickerView.isUserInteractionEnabled = true

        tap.addTarget(self, action: #selector(onSingleTap))
        tap.delegate = self
        stickerView.addGestureRecognizer(tap)
        
        longTap.addTarget(self, action: #selector(StickerCell.onLongPress))
        longTap.delegate = self
        stickerView.addGestureRecognizer(longTap)
		self.backgroundColor = UIColor.clear
		stickerView.backgroundColor = UIColor.clear
    }

    func configure(for sticker: ROKOSticker, inPack pack:ROKOStickerPack) {
        self.pack = pack
        self.sticker = sticker
        
        let url = FileManager.imageURL(forSticker: sticker, inPack: pack)
		do {
			if FileManager.default.fileExists(atPath: url.path) {
				let msSticker = try MSSticker(contentsOfFileURL: url, localizedDescription: "")
				stickerView.sticker = msSticker
				stickerView.sizeToFit()
				stickerView.startAnimating()
			} else {
				stickerView.sticker = nil;
//				print ("No image exist: \(url.path)")
			}
		} catch {
//            print("error: \(error)")
        }
    }
    
    func onSingleTap() {
        stickerCellDelegate?.didSelectCell(cell: self)
    }
    
    func onLongPress(_ gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            stickerCellDelegate?.didDragCell(cell: self)
        }
    }
}

extension StickerCell : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
