//
//  BottomBar.swift
//  StickerMator
//
//  Created by Ning Ma on 11/2/21.
//

import SwiftUI
import MobileCoreServices

struct StickerBottomBar: View {
    
    @EnvironmentObject var store: StickerStorage
    
    var body: some View {
        HStack {
            controlButton
            body(for: store.palettes[chosenIndex])
        }
    }
    
    @State private var chosenIndex = 0
    
    var labelFont: Font {.system(size: 40)}
    
    var controlButton: some View {
        Button {
            withAnimation {
                chosenIndex = (chosenIndex + 1) % store.palettes.count
            }
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(labelFont)
    }
    
    
    func body(for stickerSet: StickerSet) -> some View {
        HStack {
            ScrollingStickerView(images: store.palettes[chosenIndex].stickers)
        }
        .transition (
            AnyTransition.asymmetric(insertion: .offset(x: 0, y: 300), removal: .offset(x: 0, y: -300))
        )
    }
}

struct ScrollingStickerView: View {
    let images: [URL]?
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                // map to characters
                if let images = images {
                ForEach(images, id:\.self) { image in
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


struct BottomBar_Previews: PreviewProvider {
    static var previews: some View {
        StickerBottomBar()
    }
}
