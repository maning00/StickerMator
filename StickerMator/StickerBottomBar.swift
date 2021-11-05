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
    @Binding var showBottomBar: Bool
    
    var body: some View {
        HStack {
            controlButton
            body(for: store.stickerSet(at: chosenIndex))
        }
    }
    
    @State private var chosenIndex = 0
    @State private var stickersetToEdit: StickerSet? = nil
    @State private var managing = false
    @State private var showEditor = false
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil.circle") {
            stickersetToEdit = store.stickerSet(at: chosenIndex)
        }
        AnimatedActionButton(title: "New", systemImage: "plus.circle") {
            store.addStickerSet(name: "New", at: chosenIndex)
            stickersetToEdit = store.stickerSet(at: chosenIndex)
        }
        AnimatedActionButton(title: "Manager", systemImage: "slider.vertical.3") {
            managing = true
        }
        gotoMenu
        AnimatedActionButton(title: "Filter", systemImage: "wand.and.rays") {
                    showEditor = true
                }
        AnimatedActionButton(title: "Hide Bar", systemImage: "eye.slash") {
            showBottomBar = false
        }
    }
    
    var gotoMenu: some View {
        Menu {
            ForEach(store.stickerSets) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = store.stickerSets.findIndex(of: palette) {
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
                             action: { chosenIndex = (chosenIndex + 1) % store.stickerSets.count },
                             labelFont: .system(size: 40)).contextMenu {contextMenu}
    }
    
    
    func body(for stickerSet: StickerSet) -> some View {
        HStack {
            Text(stickerSet.name)
            ScrollingStickerView(images: store.stickerSet(at: chosenIndex).stickers)
        }
        .popover(item: $stickersetToEdit) { _ in
            StickerSetEditor(stickerSetToEdit: $store.stickerSets[chosenIndex])
        }
        .sheet(isPresented: $managing) {
            StickerSetManager()
        }
        .sheet(isPresented: $showEditor) {
            ImageEditor(editorDocument: ImageEditorDocument(), showDialogue: .imagePicker)
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
