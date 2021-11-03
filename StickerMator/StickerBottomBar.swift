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
            body(for: store.stickerSet(at: chosenIndex))
        }
    }
    
    @State private var chosenIndex = 0
    @State private var stickersetToEdit: StickerSet? = nil
    @State private var managing = false
    @State private var showImagePicker = false
    @State private var showCameraPicker = false
    
    var labelFont: Font {.system(size: 40)}  // to set button size
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil.circle"){
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
        addMenu
    }
    
    var addMenu: some View {
        Menu {
            AnimatedActionButton(title: "From Camera", systemImage: "camera") {
                showCameraPicker = true
            }
            AnimatedActionButton(title: "From Photos", systemImage: "photo.on.rectangle") {
                showImagePicker = true
            }
        } label: {
            Label("Add Photo", systemImage: "plus")
        }
    }
    
    var gotoMenu: some View {
        Menu {
            ForEach (store.stickerSets) { palette in
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
                             labelFont: labelFont).contextMenu {contextMenu}
    }
    
    
    func body(for stickerSet: StickerSet) -> some View {
        HStack {
            Text(stickerSet.name)
            ScrollingStickerView(images: store.stickerSet(at: chosenIndex).stickers)
        }
        .popover(item: $stickersetToEdit) { stickerset in
                StickerSetEditor(stickerSetToEdit: $store.stickerSets[chosenIndex])
        }
        .sheet(isPresented: $managing) {
            StickerSetManager()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(imageHandleFunc: {_ in })
        }
        .sheet(isPresented: $showCameraPicker) {
            Camera(imageHandleFunc: {_ in })
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
            }.frame(minHeight: 20,maxHeight: 70, alignment: .topLeading) // Limit sticker bar size
        }
    }
}


struct BottomBar_Previews: PreviewProvider {
    static var previews: some View {
        StickerBottomBar()
    }
}
