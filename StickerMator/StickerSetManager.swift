//
//  StickerSetManager.swift
//  StickerMator
//
//  Created by Ning Ma on 11/2/21.
//

import SwiftUI

struct StickerSetManager: View {
    @EnvironmentObject var store: StickerStorage
    @Environment(\.dismiss) var dissmiss
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.stickerSets) { stickerset in
                    NavigationLink(destination: StickerSetEditor(stickerSetToEdit: $store.stickerSets[stickerset])) {
                        VStack {
                            Text(stickerset.name)
                        }
                    }
                }
                .onDelete { indexSet in
                    store.stickerSets.remove(atOffsets: indexSet)
                    if store.stickerSets.isEmpty {
                        store.addStickerSet(name: "Empty",at: 1)
                    }
                }
                .onMove { indexSet, newOffset in        // edit sequence
                    store.stickerSets.move(fromOffsets: indexSet, toOffset: newOffset)
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
        StickerSetManager()
    }
}
