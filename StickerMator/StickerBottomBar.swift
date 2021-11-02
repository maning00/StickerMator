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
    
    var labelFont: Font {.system(size: 40)}  // to set button size
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil.circle"){}
        AnimatedActionButton(title: "New", systemImage: "plus.circle") {
        }
        AnimatedActionButton(title: "Manager", systemImage: "slider.vertical.3") {
        }
        gotoMenu
    }
    
    var gotoMenu: some View {
        Menu {
            ForEach (store.palettes) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = store.palettes.findIndex(of: palette) {
                        chosenIndex = index
                    }
                }
            }
        } label: {
            Label("Go To", systemImage: "text.insert")
        }
    }
    
    var controlButton: some View {
        AnimatedActionButton(systemImage: "circle.grid.cross",
                             action: { chosenIndex = (chosenIndex + 1) % store.palettes.count },
                             labelFont: labelFont).contextMenu {contextMenu}
    }
    
    
    func body(for stickerSet: StickerSet) -> some View {
        HStack {
            ScrollingStickerView(images: store.palettes[chosenIndex].stickers)
        }
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
