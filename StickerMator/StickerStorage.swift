//
//  StickerStorage.swift
//  StickerMator
//
//  Created by Ning Ma on 11/2/21.
//

import SwiftUI

struct StickerSet: Identifiable, Hashable {
    let id: Int
    var name: String
    var stickers: [URL]?
}


class StickerStorage: ObservableObject {
    let name: String
    
    @Published var palettes = [StickerSet]()
    
    
    init(name: String) {
        self.name = name
        if palettes.isEmpty {
            addStickerSet(name: "Dogs", stickers: [
                URL(string: "dog_01")!, URL(string: "dog_02")!, URL(string: "dog_03")!,
                URL(string: "dog_04")!, URL(string: "dog_05")!, URL(string: "dog_06")!,
                URL(string: "dog_07")!, URL(string: "dog_08")!, URL(string: "dog_09")!,
                URL(string: "dog_10")!, URL(string: "dog_11")!, URL(string: "dog_12")!,
                URL(string: "dog_13")!, URL(string: "dog_14")!, URL(string: "dog_15")!,
                URL(string: "dog_16")!, URL(string: "dog_17")!
            ])
            addStickerSet(name: "IceBear", stickers: [
                URL(string: "icebear_01")!, URL(string: "icebear_02")!, URL(string: "icebear_03")!,
                URL(string: "icebear_04")!, URL(string: "icebear_05")!, URL(string: "icebear_06")!,
                URL(string: "icebear_07")!, URL(string: "icebear_08")!, URL(string: "icebear_09")!,
                URL(string: "icebear_10")!, URL(string: "icebear_11")!, URL(string: "icebear_12")!,
                URL(string: "icebear_13")!, URL(string: "icebear_14")!, URL(string: "icebear_15")!,
                URL(string: "icebear_16")!, URL(string: "icebear_17")!, URL(string: "icebear_18")!,
                URL(string: "icebear_19")!, URL(string: "icebear_20")!, URL(string: "icebear_21")!,
                URL(string: "icebear_22")!, URL(string: "icebear_23")!, URL(string: "icebear_24")!,
                URL(string: "icebear_25")!, URL(string: "icebear_26")!
            ])
            addStickerSet(name: "Monkey", stickers: [
                URL(string: "monkey_01")!, URL(string: "monkey_02")!, URL(string: "monkey_03")!,
                URL(string: "monkey_04")!, URL(string: "monkey_05")!, URL(string: "monkey_06")!,
                URL(string: "monkey_07")!, URL(string: "monkey_08")!, URL(string: "monkey_09")!,
                URL(string: "monkey_10")!, URL(string: "monkey_11")!, URL(string: "monkey_12")!,
                URL(string: "monkey_13")!, URL(string: "monkey_14")!, URL(string: "monkey_15")!,
                URL(string: "monkey_16")!, URL(string: "monkey_17")!, URL(string: "monkey_18")!,
                URL(string: "monkey_19")!, URL(string: "monkey_20")!, URL(string: "monkey_21")!,
                URL(string: "monkey_22")!, URL(string: "monkey_23")!, URL(string: "monkey_24")!
            ])
            addStickerSet(name: "Penguin", stickers: [
                URL(string: "penguin_01")!, URL(string: "penguin_02")!, URL(string: "penguin_03")!,
                URL(string: "penguin_04")!, URL(string: "penguin_05")!, URL(string: "penguin_06")!,
                URL(string: "penguin_07")!, URL(string: "penguin_08")!, URL(string: "penguin_09")!,
                URL(string: "penguin_10")!, URL(string: "penguin_11")!, URL(string: "penguin_12")!,
                URL(string: "penguin_13")!, URL(string: "penguin_14")!, URL(string: "penguin_15")!,
                URL(string: "penguin_16")!, URL(string: "penguin_17")!, URL(string: "penguin_18")!,
                URL(string: "penguin_19")!, URL(string: "penguin_20")!, URL(string: "penguin_21")!,
                URL(string: "penguin_22")!, URL(string: "penguin_23")!, URL(string: "penguin_24")!,
                URL(string: "penguin_25")!, URL(string: "penguin_26")!, URL(string: "penguin_27")!,
                URL(string: "penguin_28")!
            ])
        }
    }
    
    private var uniqueStickerSetId = 0
    
    func addStickerSet(name: String, stickers: [URL]? = nil) {
        uniqueStickerSetId += 1
        let palette = StickerSet(id: uniqueStickerSetId, name: name, stickers: stickers)
        palettes.append(palette)
    }
    
    func removeStickerSet(at index: Int) {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
    }
}
