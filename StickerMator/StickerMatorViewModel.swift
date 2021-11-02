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
    
    func addSticker (_ sticker: StickerSource, at location:(x: Int, y: Int), size: CGFloat) {
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
    
    func removeSticker(_ sticker: StickerMatorModel.Sticker) {
        stickerMator.removeSticker(sticker)
    }
    
    //
    // test
    
    @Published var builtinImage : [URL?] = [
    URL(string: "dog_01"), URL(string: "dog_02"), URL(string: "dog_03"),
    URL(string: "dog_04"), URL(string: "dog_05"), URL(string: "dog_06"),
    URL(string: "dog_07"), URL(string: "dog_08"), URL(string: "dog_09"),
    URL(string: "dog_10"), URL(string: "dog_11"), URL(string: "dog_12"),
    URL(string: "dog_13"), URL(string: "dog_14"), URL(string: "dog_15"),
    URL(string: "dog_16"), URL(string: "dog_17")
    ]
    
    
    // @Published var selectedImages: [Img] = []
    
    
    
}
