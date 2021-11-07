//
//  StickerMatorModel.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import Foundation
import Logging

let logger = Logger(label: "StickerMator")


struct StickerMatorModel: Codable {
    var stickers = [Sticker]()
    var mainImage: Data?  // main image to edit
    
    /// Sticker is actually an image
    struct Sticker: Identifiable, Hashable, Codable {
        /// Image data saved as pngData()
        var data: Data
        /// Abscissa position
        var x: Float
        /// Ordinate position
        var y: Float
        /// Sticker width
        var width: Int
        /// Sticker height
        var height: Int
        let id: Int
        
        fileprivate init( data: Data, x: Float, y: Float, width: Int, height: Int, id: Int) {
            self.data = data
            self.x = x
            self.y = y
            self.id = id
            self.width = width
            self.height = height
        }
    }
    
    init () {}
    
    /// Initializes a new StickerMatorModel from json data.
    init(json: Data) throws {
        self = try JSONDecoder().decode(StickerMatorModel.self, from: json)
    }
    
    /// Initializes a new StickerMatorModel from json data URL.
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try StickerMatorModel(json: data)
    }
    
    private var uniqueStickerId = 0
    
    /// Encode self to JSON
    func jsonEncode() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    
    mutating func addSticker (imageData: Data, at location:(x: Float, y: Float), size: (width: Int, height: Int)) {
        uniqueStickerId += 1
        stickers.append(Sticker(data: imageData, x: location.x, y: location.y,
                                width: size.width, height: size.height, id: uniqueStickerId))
    }
    
    mutating func removeSticker (_ sticker: Sticker) {
        if let index = stickers.findIndex(of: sticker) {
            stickers.remove(at: index)
        }
    }
    
    
}
