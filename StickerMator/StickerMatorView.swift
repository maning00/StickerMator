//
//  StickerMatorView.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import SwiftUI
import UIKit

typealias StickerSource = StickerMatorViewModel.StickerSource
struct StickerMatorView: View {
    @ObservedObject var document: StickerMatorViewModel
    
    var testimage: [UIImage?] = [UIImage(named: "dog_01"), UIImage(named: "dog_02"),UIImage(named: "dog_03"),UIImage(named: "dog_04"),UIImage(named: "dog_05"),UIImage(named: "dog_06"),UIImage(named: "dog_07"),UIImage(named: "dog_08")]
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }
    
    var defaultFontSize: CGFloat = 40
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                ForEach(document.stickers) { sticker in
                    switch sticker.content {
                    case .emoji(let emoji):
                        Text(emoji).font(.system(size: 60))
                            .position(position(for: sticker, in: geometry))
                    case .imageData(let data):
                        if let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                        }
                    default: Color.red        // default
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText], isTargeted: nil) { providers, location in
                        drop(providers: providers, at: location, in: geometry)
                }
        }
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        return providers.loadObjects(ofType: String.self) { string in
            if let emoji = string.first, emoji.isEmoji {
                                document.addSticker(
                                    StickerSource(emoji: String(emoji)),
                                    at: convertToEmojiCoordinates(location, in: geometry),
                                    size: defaultFontSize
                                )
                }
        }
        }
    
    var palette: some View {
        ScrollingStickerView(images: testimage, emojis: testemojis)
    }
    
    let testemojis = "🕎☸️🇲🇳🧑‍🌾 👨‍🌾 👩‍🍳 🧑‍🍳 👨‍🍳 👩‍🎓 🧑‍🎓 👨‍🎓 👩‍🎤 🧑‍🎤 👨‍🎤 👩‍🏫 🧑‍🏫 👨‍🏫 👩‍🏭 🧑‍🏭 👨‍🏭 👩‍💻 🧑‍💻 👨‍💻"
    
    private func position(for sticker: StickerMatorModel.Sticker, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((sticker.x, sticker.y), in: geometry)
    }
    
    private func fontSize(for sticker: StickerMatorModel.Sticker) -> CGFloat {
        CGFloat(sticker.size)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - center.x),
            y: (location.y - center.y)
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x),
            y: center.y + CGFloat(location.y)
        )
    }

}

struct ScrollingStickerView: View {
    init(images: [UIImage?], emojis: String? = nil) {
        self.images = images
        self.emojis = emojis
    }
    
    let images: [UIImage?]
    let emojis: String?
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                // map to characters
                ForEach(images, id:\.self) { img in
                    Image(uiImage: img!)
                        .resizable().padding(1).aspectRatio(contentMode: .fill)
                }
                if let elements = emojis {
                    ForEach(elements.map {String($0)}, id:\.self) { element in
                        Text(element).font(.system(size: 60))
                            .onDrag { NSItemProvider(object: element as NSString)}
                }
                }
            }.frame(minHeight: 20,maxHeight: 70, alignment: .topLeading)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StickerMatorView(document: StickerMatorViewModel())
    }
}

