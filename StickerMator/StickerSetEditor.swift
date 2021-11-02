//
//  StickerSetEditor.swift
//  StickerMator
//
//  Created by Ning Ma on 11/2/21.
//

import SwiftUI

struct StickerSetEditor: View {
    
    @Binding var stickerToEdit: StickerSet
    
    
    var body: some View {
        Form {
            Section(header: Text("name")) {
                TextField(text: $stickerToEdit.name) {}
            }
            editStickerSection
        }
        .frame(minWidth: 400, minHeight: 500, alignment: .center)
    }
    
    var editStickerSection: some View {
        Section(header: Text("edit")) {
            if let stickers = stickerToEdit.stickers {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                    ForEach(stickers, id:\.self) { url in
                        if let uiImage = UIImage(named: url.absoluteString) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(maxWidth: 80, maxHeight: 80)
                        }
                    }
                    }
                }
            }
        }
    }


