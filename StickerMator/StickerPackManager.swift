//
//  StickerPackManager.swift
//  StickerMator
//
//  Created by Ning Ma on 11/2/21.
//

import SwiftUI

/// A manager view that can manage sticker packs.
///
/// This view shows existed sticker packs, packs can be removed or reordered.
struct StickerPackManager: View {
    @EnvironmentObject var store: StickerStorage
    @Environment(\.dismiss) var dissmiss
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.stickerPacks) { stickerpack in
                    NavigationLink(destination: StickerPackEditor(stickerPackToEdit: $store.stickerPacks[stickerpack])) {
                        VStack {
                            Text(stickerpack.name)
                        }
                    }
                }
                .onDelete { indexSet in
                    store.stickerPacks.remove(atOffsets: indexSet)
                    if store.stickerPacks.isEmpty {
                        store.addStickerPack(name: "Empty", at: 1)
                    }
                }
                .onMove { indexSet, newOffset in        // edit sequence
                    store.stickerPacks.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }.navigationTitle("Manage Sticker")
                .toolbar {
                    ToolbarItem{ EditButton() }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dissmiss()
                        }
                        
                    }
                }
                .environment(\.editMode, $editMode)
        }
    }
}

struct StickerSetManager_Previews: PreviewProvider {
    static var previews: some View {
        StickerPackManager()
    }
}
