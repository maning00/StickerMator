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
    var stickers: [URL]
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
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self.stickerSets = try JSONDecoder().decode([StickerSet].self, from: data)
    }
    
    init(name: String) {
        self.name = name
        try? restoreFromUserDefaults()
        if stickerSets.isEmpty {
            logger.info("Using default stickers")
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
            addStickerSet(name: "Cat", stickers: [
                URL(string: "cat_01")!, URL(string: "cat_02")!, URL(string: "cat_03")!,
                URL(string: "cat_04")!, URL(string: "cat_05")!, URL(string: "cat_06")!,
                URL(string: "cat_07")!, URL(string: "cat_08")!, URL(string: "cat_09")!,
                URL(string: "cat_10")!, URL(string: "cat_11")!, URL(string: "cat_12")!,
                URL(string: "cat_13")!, URL(string: "cat_14")!, URL(string: "cat_15")!,
                URL(string: "cat_16")!, URL(string: "cat_17")!, URL(string: "cat_18")!,
                URL(string: "cat_19")!, URL(string: "cat_20")!, URL(string: "cat_21")!,
                URL(string: "cat_22")!, URL(string: "cat_23")!, URL(string: "cat_24")!
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
    
    func jsonEncode() throws -> Data {
        return try JSONEncoder().encode(stickerSets)
    }
    
    func addStickerSet(name: String, stickers: [URL] = [], at index: Int = 0) {
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
