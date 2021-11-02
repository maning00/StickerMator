//
//  StickerMatorModel.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import Foundation


struct StickerMatorModel {
    var stickers = [Sticker]()
    
    
    enum StickerSource: Hashable {
        init (_ imageData: Data) {
            self = .imageData(imageData)
        }
        
        init (_ url: URL) {
            self = .url(url)
        }
        
        case imageData(Data)
        case url(URL)
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var imageData: Data? {
            switch self {
            case .imageData(let data):
                return data
            default: return nil
            }
        }
    }
    
    
    // Sticker is an image
    struct Sticker: Identifiable, Hashable {
        let content: StickerSource
        var x: Int
        var y: Int
        var width: Int
        var height: Int
        let id: Int
        
        fileprivate init(content: StickerSource, x: Int, y: Int, width: Int, height: Int, id: Int) {
            self.content = content
            self.x = x
            self.y = y
            self.id = id
            self.width = width
            self.height = height
        }
    }
    
    init () {}
    
    private var uniqueStickerId = 0
    
    
    mutating func addSticker (content: StickerSource, at location:(x: Int, y: Int), size: (width: Int, height: Int)) {
        uniqueStickerId += 1
        stickers.append(Sticker(content: content, x: location.x, y: location.y, width: size.width, height: size.height, id: uniqueStickerId))
    }
    
    mutating func removeSticker (_ sticker: Sticker) {
        if let index = stickers.findIndex(of: sticker) {
            stickers.remove(at: index)
        }
    }
    
    
}
