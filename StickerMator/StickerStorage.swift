//
//  StickerStorage.swift
//  StickerMator
//
//  Created by Ning Ma on 11/2/21.
//

import SwiftUI

struct StickerSet: Identifiable, Hashable, Codable {
    let id: Int
    var name: String
    var stickers: [String]
}


class StickerStorage: ObservableObject {
    var name: String = "Default"
    
    @Published var stickerSets = [StickerSet]() {
        didSet {
            do {
                let data = try jsonEncode()
                UserDefaults.standard.set(data, forKey: name)
            } catch {
                logger.error("Userdefaults set failed:\(error.localizedDescription)")
            }
        }
    }
    
    private func restoreFromUserDefaults() throws {
        if let stickerSetsPlist = UserDefaults.standard.data(forKey: name) {
            self.stickerSets = try JSONDecoder().decode([StickerSet].self, from: stickerSetsPlist)
            logger.info("Loaded defaults: \(stickerSets)")
        }
    }
    
    init(json: Data) throws {
        self.stickerSets = try JSONDecoder().decode([StickerSet].self, from: json)
    }
    
    init(url: String) throws {
        let data = try Data(contentsOf: URL(string: url)!)
        self.stickerSets = try JSONDecoder().decode([StickerSet].self, from: data)
    }
    
    init(name: String) {
        self.name = name
        try? restoreFromUserDefaults()
        if stickerSets.isEmpty {
            logger.info("Using default stickers")
            addStickerSet(name: "Dogs", stickers: [
                "dog_01", "dog_02", "dog_03",
                "dog_04", "dog_05", "dog_06",
                "dog_07", "dog_08", "dog_09",
                "dog_10", "dog_11", "dog_12",
                "dog_13", "dog_14", "dog_15",
                "dog_16", "dog_17"
            ])
            addStickerSet(name: "IceBear", stickers: [
                "icebear_01", "icebear_02", "icebear_03",
                "icebear_04", "icebear_05", "icebear_06",
                "icebear_07", "icebear_08", "icebear_09",
                "icebear_10", "icebear_11", "icebear_12",
                "icebear_13", "icebear_14", "icebear_15",
                "icebear_16", "icebear_17", "icebear_18",
                "icebear_19", "icebear_20", "icebear_21",
                "icebear_22", "icebear_23", "icebear_24",
                "icebear_25", "icebear_26"
            ])
            addStickerSet(name: "Cat", stickers: [
                "cat_01", "cat_02", "cat_03",
                "cat_04", "cat_05", "cat_06",
                "cat_07", "cat_08", "cat_09",
                "cat_10", "cat_11", "cat_12",
                "cat_13", "cat_14", "cat_15",
                "cat_16", "cat_17", "cat_18",
                "cat_19", "cat_20", "cat_21",
                "cat_22", "cat_23", "cat_24"
            ])
            addStickerSet(name: "Penguin", stickers: [
                "penguin_01", "penguin_02", "penguin_03",
                "penguin_04", "penguin_05", "penguin_06",
                "penguin_07", "penguin_08", "penguin_09",
                "penguin_10", "penguin_11", "penguin_12",
                "penguin_13", "penguin_14", "penguin_15",
                "penguin_16", "penguin_17", "penguin_18",
                "penguin_19", "penguin_20", "penguin_21",
                "penguin_22", "penguin_23", "penguin_24",
                "penguin_25", "penguin_26", "penguin_27",
                "penguin_28"
            ])
        }
    }
    
    func jsonEncode() throws -> Data {
        return try JSONEncoder().encode(stickerSets)
    }
    
    func addStickerSet(name: String, stickers: [String] = [], at index: Int = 0) {
        let unique = (stickerSets.max(by: { $0.id < $1.id })?.id ?? 0) + 1// get maxID + 1
        let safeIndex = min(max(index, 0), stickerSets.count)
        let set = StickerSet(id: unique, name: name, stickers: stickers)
        stickerSets.insert(set, at: safeIndex)
    }
    
    func stickerSet(at index: Int) -> StickerSet {
        let safeIndex = min(max(index, 0), stickerSets.count - 1)
        return stickerSets[safeIndex]
    }
    
    func removeStickerSet(at index: Int) {
        if stickerSets.count > 1, stickerSets.indices.contains(index) {
            stickerSets.remove(at: index)
        }
    }
}
