//
//  StickerMatorViewModel.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import SwiftUI

class StickerMatorViewModel: ObservableObject {
    @Published private(set) var stickerMator: StickerMatorModel
    
    init () {
        stickerMator = StickerMatorModel()
    }
    
    var stickers: [StickerMatorModel.Sticker] { stickerMator.stickers }
    
    func addSticker (image: UIImage, at location:(x: Int, y: Int), size: CGSize) {
        if let data = image.pngData() {
            self.stickerMator.addSticker(imageData: data, at: location, size: (Int(size.width), Int(size.height)))
        }
    }
    
    
    func addSticker (url: URL, at location:(x: Int, y: Int), size: CGSize) {
        let session = URLSession.shared
        let publisher = session.dataTaskPublisher(for: url)
            .map {(data, _) in UIImage(data: data)}
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
        _ = publisher.sink { [weak self] image in
            if let uiImage = image {
                self?.addSticker (image: uiImage, at: (x: location.x, y: location.y), size: size)
            }
        }
    }
    
    func addSticker (path: String, at location:(x: Int, y: Int), size: CGSize) {
        if let uiImage = UIImage(named: path) {
            self.addSticker(image: uiImage, at: (x: location.x, y: location.y), size: size)
        }
    }
    
    func moveSticker(_ sticker: StickerMatorModel.Sticker, by offset: CGSize) {
        if let index = stickerMator.stickers.findIndex(of: sticker) {
            stickerMator.stickers[index].x += Int(offset.width)
            stickerMator.stickers[index].y += Int(offset.height)
        }
    }
    
    func scaleSticker(_ sticker: StickerMatorModel.Sticker, by scale: CGFloat) {
        if let index = stickerMator.stickers.findIndex(of: sticker) {
            stickerMator.stickers[index].width = Int((CGFloat(stickerMator.stickers[index].width)*scale).rounded(.toNearestOrAwayFromZero))
            stickerMator.stickers[index].height = Int((CGFloat(stickerMator.stickers[index].height)*scale).rounded(.toNearestOrAwayFromZero))
            // Absolute value rounding
        }
    }
    
    func removeSticker(_ sticker: StickerMatorModel.Sticker) {
        stickerMator.removeSticker(sticker)
    }
    
    
    private func saveData(to url: URL) {
        do {
            let data: Data = try stickerMator.jsonEncode()
            try data.write(to: url)
            logger.info("saveData success")
        } catch {
            logger.error("Data write failed: \(error.localizedDescription)")
        }
    }
    
    
    
}
