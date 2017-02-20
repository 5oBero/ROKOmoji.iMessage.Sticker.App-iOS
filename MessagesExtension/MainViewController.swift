//
//  MainViewController.swift
//  iMessageStickers
//
//  Created by Maslov Sergey on 22.11.16.
//  Copyright © 2016 ROKO. All rights reserved.
//
import UIKit
import Messages
import ROKOMobi

let sliderValueKey = "sliderValueKey"

class MainViewController: MSMessagesAppViewController {
    let packsPanelTopConstant:CGFloat = 84
    
    @IBOutlet weak var stickersPackPanel: StickerPacksPanel!
    @IBOutlet weak var stickersPanel: MyStickersPanel!
    
    @IBOutlet weak var stickersView: UIView!
    @IBOutlet weak var packsPanelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    var dataSource: ROKOPortalStickersDataSource!
    var stickersDataProvider = StickersDataProvider()
    var guid = NSUUID().uuidString
    var stickersConfig = StickersConfig(stickerSize: .small, backgroundColor: #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9647058824, alpha: 1), logoFileName: "rokolabs_logo")
    var firstTime = true
    
    // For Analitics
	var linkManager: ROKOLinkManager?
    var info: RLStickerInfo?
    var packInfo: RLStickerPackInfo?
    var item: ROKOStickersEventItem?
    var currentOffet = CGPoint(x: 0, y: 0)
    var activateTime = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = stickersConfig.backgroundColor
        logoImage.image = UIImage(named: stickersConfig.logoFileName)
		
		let sliderValue = UserDefaults.standard.value(forKey: sliderValueKey)
		if sliderValue != nil {
			slider.value = sliderValue as! Float
			sliderDidChange(slider)
		} else {
			stickersPanel.stickerSize = stickersConfig.stickerSize
			slider.value = Float(stickersConfig.stickerSize.rawValue)
		}
		
		stickersDataProvider.getWarmCache {
			self.stickersPackPanel.reloadCollection()
			self.stickersPanel.reloadCollection()
        }
		
        updateBottomComponents(isHide: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if firstTime {
            firstTime = false
            configureStikers()
        } else {
            ROKOLogger.addEvent("_ROKO.Active User", withParameters: nil)
        }
		
		// Workaround for deeplinks receiving
		NotificationCenter.default.post(Notification.init(name: .UIApplicationDidBecomeActive))
		
        activateTime = Date()
        self.sendSavedEvent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let interval = Date().timeIntervalSince(activateTime)
        self.saveTime(interval)
		UserDefaults.standard.set(self.slider.value, forKey: sliderValueKey)
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        ROKOStickers.logEnteredStickersPanel()
    }
    
    override func didResignActive(with conversation: MSConversation) {
        ROKOStickers.logExitedStickersPanel()
    }
    
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
        
        guard let item = item, let info = info, let packInfo = packInfo else { return }
        ROKOStickers.logStickerSelection(info, inPack: packInfo, withImageId: guid)
        ROKOStickers.logSaving(withStickers: [item], onImageWithId: guid, fromCamera: false)
        self.item = nil
        self.info = nil
        self.packInfo = nil
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
        
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        currentOffet = self.stickersPanel.collectionView.contentOffset
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        guard let collectionView = self.stickersPanel.collectionView else {return}
        
        if collectionView.contentSize.height - self.stickersPanel.collectionView.contentOffset.y < collectionView.bounds.size.height {
            currentOffet = CGPoint(x:0, y:0)
        }
        self.stickersPanel.collectionView.contentOffset = currentOffet
        updateBottomComponents(isHide: presentationStyle == .compact)
    }
    
    func configureStikers(){
        ROKOComponentManager.shared().apiToken = kAPIToken
        ROKOComponentManager.shared().baseURL = kBaseURL
		
		linkManager = ROKOLinkManager.init(manager: ROKOComponentManager.shared())
		
        stickersPackPanel.delegate = self
        stickersPanel.delegate = self
        
        let isDefaultPackProvided = stickersDataProvider.loadData()
        if  isDefaultPackProvided {
            stickersPackPanel.configure(withDatasource: stickersDataProvider, stickersPanel: nil)
            stickersPanel.configure(withDatasource: stickersDataProvider)
            
            if let oldPackIndex = UserDefaults.standard.object(forKey: kLastPackKey) as? Int {
                if oldPackIndex < (stickersDataProvider.numberOfStickerPacks()) {
                    stickersPackPanel.selectedPackIndex = oldPackIndex
                    stickersPanel.selectedPackIndex = oldPackIndex
                }
            }
            
            stickersPackPanel.reloadCollection()
            stickersPanel.reloadCollection()
			
			self.stickersPanel.didLoadStickers = true
        }
        
        dataSource =  ROKOPortalStickersDataSource(manager: ROKOComponentManager.shared())
        dataSource.reloadStickers { [weak self](object, error) in
            if error == nil {
                if let stickerPacksRaw = object as? [ROKOStickerPack] {
                    let stickerPacks = Array(stickerPacksRaw.prefix(kMaxPackCount))
					
					// If the same packs provided by portal there is nothing to reload
					if let loadedPacks = self?.stickersDataProvider.stickerPacks {
						if stickerPacks.elementsEqual(loadedPacks) {
							return
						}
					}
					
                    self?.stickersDataProvider.initWithDataSource(stickerPacks: stickerPacks)
                    
                    var packsCount = stickerPacks.count
                    for pack in stickerPacks {
                        StickerCache.load(stickerPack: pack) { (pack) in
                            packsCount -= 1
                            if packsCount == 0 {
                                DispatchQueue.main.async() { () -> Void in
                                    self?.stickersDataProvider.stickerPacks = stickerPacks
                                    self?.stickersPanel.reloadCollection()
                                    self?.stickersPackPanel.reloadCollection()
									
									self?.stickersPanel.didLoadStickers = true
                                    //                                    self?.stickersDataProvider.saveWarmCache()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func clickInfoButton(_ sender: Any) {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String  ?? "1.0"
        let alertController = UIAlertController(title: String(format: kInfoAlertTitle, version),
                                                message: kInfoAlertMessage,
                                                preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    @IBAction func sliderDidChange(_ sender: Any) {
        if let sender = sender as? UISlider {
            let stickerSize = MSStickerSize.fromInt(Int(round(sender.value)))
            stickersPanel.stickerSize = stickerSize
        }
    }
    
    func updateBottomComponents(isHide: Bool) {
        infoButton.isHidden = isHide
        slider.isHidden = isHide
    }
}

extension MainViewController: StickerPacksPanelDelegate {
    func didSelectPack(at packPosition: Int) {
        UserDefaults.standard.set(packPosition, forKey: kLastPackKey)
        stickersPanel.selectedPackIndex = packPosition
        stickersPanel.reloadCollection()
    }
}

extension MainViewController: MyStickersPanelDelegate {
    func didSelect(image: UIImage!, pack: ROKOStickerPack, stickerInfo: ROKOSticker, positionInPack: Int) {
        info = RLStickerInfo()
        info!.stickerID = stickerInfo.imageInfo.objectId as Int
        info!.scale = CGFloat(stickerInfo.scaleFactor)
        info!.positionInPack = positionInPack
        
        packInfo = RLStickerPackInfo()
        packInfo!.packID = pack.objectId as Int
        packInfo!.title = pack.name
        
        item = ROKOStickersEventItem()
        item!.stickerId = stickerInfo.objectId as Int
        item!.stickerPackId = pack.objectId as Int
        item!.stickerPackName = pack.name
        item!.positionInPack = positionInPack
    }
    
    func didDrag(image: UIImage!, pack: ROKOStickerPack, stickerInfo: ROKOSticker, positionInPack: Int) {
        let info = RLStickerInfo()
        info.stickerID = stickerInfo.imageInfo.objectId as Int
        info.scale = CGFloat(stickerInfo.scaleFactor)
        info.positionInPack = positionInPack
        
        let packInfo = RLStickerPackInfo()
        packInfo.packID = pack.objectId as Int
        packInfo.title = pack.name
        ROKOStickers.logStickerSelection(info, inPack: packInfo, withImageId: guid)
        
        
        let item = ROKOStickersEventItem()
        item.stickerId = stickerInfo.objectId as Int
        item.stickerPackId = pack.objectId as Int
        item.stickerPackName = pack.name
        item.positionInPack = positionInPack
        ROKOStickers.logSaving(withStickers: [item], onImageWithId: guid, fromCamera: false)
    }
}

// MARK: Life cycle handling
let durationKey = "Duration"

extension MainViewController {
    
    func saveTime(_ interval: TimeInterval) {
        
        let durationDict = [durationKey: interval]
        guard let url = self.timeFileURL() else {return}
        let dict = durationDict as NSDictionary
        dict.write(to: url, atomically: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {[weak self] in
            self?.sendSavedEvent()
        }
    }
    
    func timeFileURL() -> URL? {
        guard let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {return nil}
        return url.appendingPathComponent("time.plist")
    }
    
    func sendSavedEvent() {
        guard let url = self.timeFileURL() else {return}
        let dict = NSDictionary(contentsOf: url)
        guard let duration = dict?[durationKey] as? TimeInterval else {return}
        let parameters = ["Time spent": duration];
        ROKOLogger.addEvent("_ROKO.Inactive User", withParameters: parameters)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            
        }
    }
}
