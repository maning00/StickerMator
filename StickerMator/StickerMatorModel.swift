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
        case imageData(Data)
        case url(URL)
        case emoji(String)
        
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
        
        var emoji: String? {
            switch self {
            case .emoji(let emoji): return emoji
            default: return nil
            }
        }
    }
    
    
    // Sticker is an image or emoji
    struct Sticker: Identifiable, Hashable {
        let content: StickerSource
        var x: Int  // offset from center
        var y: Int   // offset from center
        var size: Int
        let id: Int
        
        fileprivate init(content: StickerSource, x: Int, y: Int, size: Int, id: Int) {
            self.content = content
            self.x = x
            self.y = y
            self.id = id
            self.size = size
        }
    }
    
    init () {}
    
    private var uniqueStickerId = 0
    
    
    mutating func addSticker (content: StickerSource, at location:(x: Int, y: Int), size: Int) {
        uniqueStickerId += 1
        stickers.append(Sticker(content: content, x: location.x, y: location.y, size: size, id: uniqueStickerId))
    }
    
    
}
