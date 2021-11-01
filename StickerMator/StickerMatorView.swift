//
//  StickerMatorView.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import SwiftUI
import MobileCoreServices

typealias StickerSource = StickerMatorViewModel.StickerSource

struct StickerMatorView: View {
    @ObservedObject var document: StickerMatorViewModel
    
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
                .clipped()
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
                    case .imageData(let data):
                        if let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage).position(position(for: sticker, in: geometry))
                        }
                    case .url(let url):
                        if let uiImage = UIImage(named: url.absoluteString) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200, alignment: .topLeading)
                                .position(position(for: sticker, in: geometry))
                        }
                    }
                }
            }
            .onDrop(of: [String(kUTTypeURL)], isTargeted: nil) { providers, location in
                    drop(providers: providers, at: location, in: geometry)
            }
//            .onDrop(of: [String(kUTTypeURL)], delegate: document)
        }
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        providers.loadObjects(ofType: URL.self) { url in
            print(url)
            document.addSticker(StickerSource(url), at: convertToEmojiCoordinates(location, in: geometry), size: defaultFontSize)
        }
    }
    
    var palette: some View {
        ScrollingStickerView(images: document.builtinImage)
    }
    
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
    init(images: [URL?]) {
        self.images = images
    }
    
    let images: [URL?]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                // map to characters
                ForEach(images, id:\.self) { image in
                    if let image = image {
                        Image(uiImage: UIImage(named: image.absoluteString)!)
                        .resizable().padding(1).aspectRatio(contentMode: .fill)
                        .onDrag {
                            NSItemProvider(item: image as NSSecureCoding, typeIdentifier: String(kUTTypeURL))
                        }
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

