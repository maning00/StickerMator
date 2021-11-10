//
//  BottomBar.swift
//  StickerMator
//
//  Created by Ning Ma on 11/2/21.
//

import SwiftUI

/// A view includes horizontal slide bar and a control button.
struct StickerBottomBar: View {
    
    @EnvironmentObject var store: StickerStorage
    @Binding var showBottomBar: Bool
    
    var body: some View {
        HStack {
            body(for: store.stickerSet(at: chosenIndex))
            controlButton
        }
    }
    
    @State private var chosenIndex = 0
    
    /// selected pack to show editor.
    @State private var selectedPack: StickerPack?
    
    /// Show Manager
    @State private var managing = false
    
    /// Show sticker maker
    @State private var showStickerMaker = false
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "New", systemImage: "plus.circle") {
            store.addStickerPack(name: "New", at: chosenIndex)
            selectedPack = store.stickerSet(at: chosenIndex)
        }
        AnimatedActionButton(title: "Manager", systemImage: "slider.vertical.3") {
            managing = true
        }
        gotoMenu
        AnimatedActionButton(title: "Sticker Maker", systemImage: "wand.and.rays") {
            showStickerMaker = true
        }
    }
    
    var gotoMenu: some View {
        Menu {
            ForEach(store.stickerPacks) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = store.stickerPacks.findIndex(of: palette) {
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
                             action: { chosenIndex = (chosenIndex + 1) % store.stickerPacks.count },
                             labelFont: .system(size: 40)).contextMenu {contextMenu}
    }
    
    
    func body(for stickerSet: StickerPack) -> some View {
        HStack {
            ScrollingStickerView(images: store.stickerSet(at: chosenIndex).stickers)
            Text(stickerSet.name)
        }
        .popover(item: $selectedPack) {_ in
            StickerPackEditor(stickerPackToEdit: $store.stickerPacks[chosenIndex])
        }
        .sheet(isPresented: $managing) {
            StickerPackManager()
        }
        .sheet(isPresented: $showStickerMaker) {
            StickerMaker(editorDocument: StickerMakerDocument(), showDialogue: .imagePicker)
        }
    }
}

struct ScrollingStickerView: View {
    let images: [String]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                // map to characters
                ForEach(images, id: \.self) { image in
                    if let imgToShow = UIImage(named: image) {
                        Image(uiImage: imgToShow)
                            .resizable().padding(1).aspectRatio(contentMode: .fill)
                            .onDrag {
                                NSItemProvider(object: image as NSString)
                            }
                    }
                }
            }.frame(minHeight: 20, maxHeight: 70, alignment: .topLeading) // Limit sticker bar size
        }
    }
}
