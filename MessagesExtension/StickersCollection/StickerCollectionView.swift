//
//  StickerCollectionView.swift
//  iMessageStickers
//
//  Created by Alexey Golovenkov on 30.11.16.
//  Copyright © 2016 ROKO. All rights reserved.
//

import UIKit

class StickerCollectionView: UICollectionView {

	override var contentInset: UIEdgeInsets {
		get {
			return super.contentInset
		}
		set {
			super.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		}
	}

}
