//
//  StickerMatorViewModel.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import SwiftUI

class StickerMatorViewModel: ObservableObject {
    @Published private(set) var stickerMator: StickerMatorModel
    
    typealias StickerSource = StickerMatorModel.StickerSource
    
    init () {
        stickerMator = StickerMatorModel()
    }

    var stickers: [StickerMatorModel.Sticker] { stickerMator.stickers }
    
    func addSticker(_ sticker: StickerSource, at location:(x: Int, y: Int), size: CGFloat) {
        stickerMator.addSticker(content: sticker, at: location, size: Int(size))
    }
    
    func moveSticker(_ sticker: StickerMatorModel.Sticker, by offset: CGSize) {
        if let index = stickerMator.stickers.findIndex(of: sticker) {
            stickerMator.stickers[index].x += Int(offset.width)
            stickerMator.stickers[index].y += Int(offset.height)
        }
    }
    
    func scaleSticker(_ sticker: StickerMatorModel.Sticker, by scale: CGFloat) {
        if let index = stickerMator.stickers.findIndex(of: sticker) {
            stickerMator.stickers[index].size = Int((CGFloat(stickerMator.stickers[index].size)*scale).rounded(.toNearestOrAwayFromZero)) // Absolute value rounding
        }
    }
}
