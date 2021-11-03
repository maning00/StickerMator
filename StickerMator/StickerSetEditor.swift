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
    
    enum ImagePickerType: Identifiable {
        case camera
        case library
        var id: ImagePickerType {self}
    }
    
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
        print("start handle")
        if let image = image {
            let userFileName = UUID().uuidString
            if let data = image.pngData() {
                let filename = getDocumentsDirectory().appendingPathComponent(userFileName)
                print(filename)
                try? data.write(to: filename)
            }
            if let urlStr = getSavedImage(named: userFileName) {
                stickerSetToEdit.stickers.append(URL(string: urlStr)!)
            } else {
                print("failed")
            }
        }
        imagePicker = nil
    }
    
    // get path URL string
    func getSavedImage(named: String) -> String? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path
        }
        return nil
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
            Label("", systemImage: "doc.badge.plus").font(.system(size: 35))
        }
    }
    
    var editStickerSection: some View {
        Section(header: Text("Tap + to add, double tap to delete")) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                imagePickerMenu
                ForEach(stickerSetToEdit.stickers, id:\.self) { url in
                    if let uiImage = UIImage(named: url.absoluteString) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(maxWidth: 80, maxHeight: 80)
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    stickerSetToEdit.stickers.removeAll(where: {$0 == url})
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


