//
//  StickersDataProvider.swift
//  ROKOKeyboard
//
//  Created by Maslov Sergey on 21.10.16.
//  Copyright © 2016 ROKOLABS. All rights reserved.
//

import ROKOMobi

let kStickersExtensionName = "Stickers"
let kStickersDataFile = "StickersDataFile." + kStickersExtensionName
let kStickersWarmCacheKey = "isWarmCacheCopyed"
let kWarmDirectoryName = "WarmCache"
let kFirstTimeKey = "FirstTimeKey"

class StickersDataProvider: NSObject {
    var stickerPacks: [ROKOStickerPack]?
    
    func initWithDataSource(stickerPacks: [ROKOStickerPack]?) {
        guard let stickerPacks = stickerPacks else {
            return
        }

        let packs = stickerPacks
		
        if let _ = UserDefaults.standard.object(forKey: kFirstTimeKey) as? Int {
        } else {
            UserDefaults.standard.set(1, forKey: kFirstTimeKey)
            self.stickerPacks = packs
        }
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: packs)
        do {
            try encodedData.write(to: storePathURL)
        } catch {
			// Catch errors
        }
    }
    
    func loadData() -> Bool {
        guard let packs = NSKeyedUnarchiver.unarchiveObject(withFile: storePathURL.path) as? [ROKOStickerPack] else {
            return false
        }
        stickerPacks = packs
        return packs.count > 0
    }
    
    fileprivate var storePathURL: URL {
        return URL.getStickersDirectory.appendingPathComponent(kStickersDataFile)
    }
}

extension StickersDataProvider: StickerDataSource {
    func numberOfStickerPacks() -> Int {
        guard let stickerPacks = stickerPacks else {
            return 0
        }
        return stickerPacks.count
    }
    
    func numberOfStickersInPack(at packIndex: Int) -> Int {
        guard let stickerPacks = stickerPacks else {
            return 0
        }
        
        guard packIndex < stickerPacks.count else {
            return 0
        }
 
		guard let pack = self.composer(infoForStickerPackAt: packIndex) else {return 0}
        return pack.stickers.count
    }
    
    
    func composer(infoForStickerPackAt packIndex: Int) -> ROKOStickerPack? {
		let packCount = stickerPacks?.count ?? 0
        guard packIndex >= 0 && packIndex < packCount else {
            return nil
        }
		
        let pack = stickerPacks![packCount - packIndex - 1]
        return pack
    }
    
    func composer(infoForStickerAt stickerIndex: Int, pack packIndex: Int) -> ROKOSticker? {
        guard packIndex >= 0 && packIndex < stickerPacks!.count else {
            return nil
        }
		
        let pack = self.composer(infoForStickerPackAt: packIndex)! //stickerPacks![packIndex]
        
        guard stickerIndex < pack.stickers.count else {
            return nil
        }
        let sticker = pack.stickers[stickerIndex] as! ROKOSticker
		return sticker
    }
}

extension StickersDataProvider {
    func saveWarmCache() {
        guard let stickerPacks = stickerPacks else {
            return
        }
        let packs = [stickerPacks.last!]
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: packs)
        do {
            try encodedData.write(to: storePathURL)
        } catch {

        }
        
        for pack in packs {
			
            for sticker in (pack.stickers as! [ROKOSticker]) {
                let urls = [FileManager.imageURL(forSticker: sticker, inPack: pack),
                            FileManager.packIconURL(forPack: pack),
                            FileManager.selectedPackIconURL(forPack: pack)]
                
                for url in urls {
                    let array = url.path.components(separatedBy: "/")
                    let packName = array[array.count - 2]
                    let stickerName = array[array.count - 1]
                    let newName = "\(packName).\(stickerName).\(kStickersExtensionName)"
                    
                    let destinationURL = URL.getWarmStickersDirectory
                    let atPath = url.path
                    let toPath = destinationURL.path.appending("/").appending(newName)
                    do {
                        try FileManager.default.copyItem(atPath: atPath, toPath: toPath)
                    } catch {
                    }
                }
            }
        }
        let atPath = storePathURL.path
        let destinationURL = URL.getWarmStickersDirectory
        let toPath = destinationURL.path.appending("/").appending(kStickersDataFile)
        print("save WARM cache to \(toPath)")
        do {
            try FileManager.default.copyItem(atPath: atPath, toPath: toPath)
        } catch {
        }
    }
    
	func getWarmCache(completionBlock:@escaping ()->Void) {
		let cachePath = FileManager.stickerPackCacheURL()
		let cacheMarker = cachePath.appendingPathComponent("marker")
		if FileManager.default.fileExists(atPath: cacheMarker.path) {
			completionBlock()
			return
		}
		NSDictionary().write(to: cacheMarker, atomically: true)
		
        let docPath = Bundle.main.resourcePath!
        let fileManager = FileManager.default
        let dataFile = docPath.appending("/").appending(kStickersDataFile)
        if fileManager.fileExists(atPath: dataFile) {
            do {
                let toPath = URL.getStickersDirectory.path.appending("/").appending(kStickersDataFile)
                try fileManager.copyItem(atPath: dataFile, toPath: toPath)
            } catch {
				// Catch errors
            }
			do {
				let filesFromBundle = try fileManager.contentsOfDirectory(atPath: docPath)
				let stickerFiles = filesFromBundle.filter{ $0.hasSuffix(kStickersExtensionName) }
				for stickerFile in stickerFiles {
					guard stickerFile != kStickersDataFile else {
						continue
					}
					let atPath = docPath.appending("/").appending(stickerFile)
					
					let array = stickerFile.components(separatedBy: ".")
					let packName = array[0]
					let stickerName = array[1]
					
					let paths = fileManager.urls(for: .cachesDirectory, in:.userDomainMask)
					let newDirectory = paths.first!.appendingPathComponent(kStickersDirectoryName, isDirectory: true).appendingPathComponent(packName, isDirectory: true)
					
					if !fileManager.fileExists(atPath: newDirectory.path) {
						do {
							try fileManager.createDirectory(at: newDirectory, withIntermediateDirectories: true, attributes: nil)
						} catch {
						}
					}
					
					let newStickerName = "\(stickerName).png"
					let toPath = newDirectory.appendingPathComponent(newStickerName).path
					do {
						try fileManager.copyItem(atPath: atPath, toPath: toPath)
					} catch {
						// Catch errors
					}
				}
				DispatchQueue.main.async {
					completionBlock()
				}
			} catch {
				// Catch errors
			}
		}
	}
}
