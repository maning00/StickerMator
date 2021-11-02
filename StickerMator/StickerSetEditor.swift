//
//  StickerSetEditor.swift
//  StickerMator
//
//  Created by Ning Ma on 11/2/21.
//

import SwiftUI

struct StickerSetEditor: View {
    
    @Binding var stickerSetToEdit: StickerSet
    
    
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
    
    var editStickerSection: some View {
        Section(header: Text("Tap + to add, double tap to delete")) {
            if !stickerSetToEdit.stickers.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                    Image(systemName: "plus").scaleEffect(2)  // Tap to add
                    ForEach(stickerSetToEdit.stickers, id:\.self) { url in
                        if let uiImage = UIImage(named: url.absoluteString) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(maxWidth: 80, maxHeight: 80)
                                .onTapGesture(count: 2) {
                                    withAnimation {
                                        print("tapped \(url)")
                                        print("\(stickerSetToEdit.stickers)")
                                        stickerSetToEdit.stickers.removeAll(where: {$0 == url})
                                    }
                                }
                        }
                    }
                }
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                    Image(systemName: "plus").scaleEffect(2)  // Tap to add
                }
            }
        }
    }
}


