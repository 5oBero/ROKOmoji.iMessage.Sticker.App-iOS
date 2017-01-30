//
//  MyStickersPanel.swift
//  iMessageStickers
//
//  Created by Maslov Sergey on 29.11.16.
//  Copyright © 2016 ROKO. All rights reserved.
//

import UIKit
import ROKOMobi
import Messages

protocol MyStickersPanelDelegate: class {
    func didSelect(image: UIImage!, pack: ROKOStickerPack, stickerInfo: ROKOSticker, positionInPack: Int)
    func didDrag(image: UIImage!, pack: ROKOStickerPack, stickerInfo: ROKOSticker, positionInPack: Int)
}

class MyStickersPanel: UIView {
    static let stickerIconSize: CGFloat = 100.0
    static let stickerSpacing: CGFloat = 17.0
    let sizeDelta: CGFloat = -MyStickersPanel.stickerSpacing
    
    var dataSource: StickerDataSource?
    weak var delegate: MyStickersPanelDelegate?
    var collectionView: UICollectionView!
    
    var selectedPackIndex: Int = 0
    var _iconSize = CGSize(width: stickerIconSize, height: stickerIconSize)
    var _stickerSize = MSStickerSize.large
    
    var stickerSize: MSStickerSize {
        set(newSize) {
            _stickerSize = newSize
            let screenWidth = UIScreen.main.bounds.size.width
            switch newSize {
            case .large: iconSize = CGSize(width: screenWidth / 2 + sizeDelta, height: screenWidth / 2 + sizeDelta)
            case .regular: iconSize = CGSize(width: screenWidth / 3 + sizeDelta, height: screenWidth / 3 + sizeDelta)
            case .small: iconSize = CGSize(width: screenWidth / 4 + sizeDelta, height: screenWidth / 4 + sizeDelta)
            }
        }
        get {
            return _stickerSize
        }
    }
    
    fileprivate var iconSize: CGSize {
        set(newSize) {
            if (newSize.width != _iconSize.width || newSize.height != _iconSize.height) {
                _iconSize = newSize
                collectionView.reloadData()
            }
        }
        get {
            return _iconSize
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = iconSize
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = MyStickersPanel.stickerSpacing
        flowLayout.minimumLineSpacing = MyStickersPanel.stickerSpacing
        flowLayout.invalidateLayout()
        
        collectionView = StickerCollectionView(frame: self.frame, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.frame = self.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = UIColor.clear
        let nib = UINib(nibName: StickerCell.identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: StickerCell.identifier)
        self.addSubview(collectionView)
    }
    
    func configure(withDatasource: StickerDataSource) {
        self.dataSource = withDatasource
    }
    
    func reloadCollection() {
        collectionView.reloadData()
    }
}

extension MyStickersPanel: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataSource = dataSource {
            return dataSource.numberOfStickersInPack(at: self.selectedPackIndex)
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCell.identifier, for: indexPath) as! StickerCell
        guard let stickerInfo = dataSource!.composer(infoForStickerAt: indexPath.item, pack: self.selectedPackIndex) else { return cell }
        
        guard let pack = dataSource!.composer(infoForStickerPackAt: self.selectedPackIndex)  else {return cell}
        
        cell.configure(for: stickerInfo, inPack: pack)
        cell.stickerCellDelegate = self
        cell.position = indexPath.row
        return cell
    }
}

extension MyStickersPanel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? StickerCell {
            let image = StickerCache.sticker(sticker: cell.sticker!, fromPack: cell.pack!)
            delegate?.didSelect(image: image, pack: cell.pack!, stickerInfo: cell.sticker!, positionInPack: cell.position)
        }
    }
}

extension MyStickersPanel : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return iconSize
    }
}

extension MyStickersPanel : StickerCellDelegate {
    func didSelectCell(cell: StickerCell) {
        let image = StickerCache.sticker(sticker: cell.sticker!, fromPack: cell.pack!)
        delegate?.didSelect(image: image, pack: cell.pack!, stickerInfo: cell.sticker!, positionInPack: cell.position)
    }
    
    func didDragCell(cell: StickerCell) {
        let image = StickerCache.sticker(sticker: cell.sticker!, fromPack: cell.pack!)
        delegate?.didDrag(image: image, pack: cell.pack!, stickerInfo: cell.sticker!, positionInPack: cell.position)
    }
}
