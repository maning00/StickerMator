//
//  StickerSetEditor.swift
//  StickerMator
//
//  Created by Ning Ma on 11/2/21.
//

import SwiftUI

struct StickerSetEditor: View {
    
    @Binding var stickerSetToEdit: StickerSet
    
    @State private var imagePicker: ImagePickerType? = nil
    @Environment(\.dismiss) var dissmiss
    
    var body: some View {
        Form {
            Section(header: Text("name")) {
                TextField(text: $stickerSetToEdit.name) {}
            }
            editStickerSection
        }
        .frame(minWidth: 400, minHeight: 500, alignment: .center)
        .navigationTitle("Edit \(stickerSetToEdit.name)")
    }
    
    // save picked image and append its URL to stickerset
    private func handlePickedSticker(_ image: UIImage?) {
        logger.info("Function handlePickedSticker catched image")
        if let image = image {
            let userFileName = UUID().uuidString
            if let data = image.pngData() {
                let filename = getDocumentsDirectory().appendingPathComponent(userFileName)
                logger.info("Image saved to \(filename)")
                try? data.write(to: filename)
            }
            if let urlStr = getSavedImage(named: userFileName) {
                stickerSetToEdit.stickers.append(urlStr)
            } else {
                logger.warning("Get URL failed")
            }
        }
        imagePicker = nil
    }
    
    
    var imagePickerMenu: some View {
        Menu {
            AnimatedActionButton(title: "From Camera", systemImage: "camera") {
                imagePicker = .camera
            }
            AnimatedActionButton(title: "From Photos", systemImage: "photo.on.rectangle") {
                imagePicker = .library
            }
        } label: {
            Label("", systemImage: "plus.circle").font(.system(size: 45))
        }
    }
    
    var editStickerSection: some View {
        Section(header: Text("Tap + to add, double tap to delete")) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                imagePickerMenu
                ForEach(stickerSetToEdit.stickers, id: \.self) { url in
                    if let uiImage = UIImage(named: url) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(maxWidth: 80, maxHeight: 80)
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    stickerSetToEdit.stickers.removeAll(where: {$0 == url})
                                    do {
                                        try FileManager.default.removeItem(atPath: url)
                                    } catch let error {
                                        logger.error("\(error.localizedDescription): \(url)")
                                    }
                                }
                            }
                    }
                }
            }
            .sheet(item: $imagePicker) { pickerType in
                switch pickerType {
                case .camera:
                    Camera(imageHandleFunc: handlePickedSticker)
                case .library:
                    ImagePicker(imageHandleFunc: handlePickedSticker)
                }
            }
        }
    }
}


