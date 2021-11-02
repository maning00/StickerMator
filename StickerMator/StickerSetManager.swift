//
//  StickerSetManager.swift
//  StickerMator
//
//  Created by Ning Ma on 11/2/21.
//

import SwiftUI

struct StickerSetManager: View {
    @EnvironmentObject var store: StickerStorage
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.stickerSets) { stickerset in
                    NavigationLink(destination: StickerSetEditor(stickerSetToEdit: $store.stickerSets[stickerset.id])) {
                        VStack {
                            Text(stickerset.name)
                        }
                    }
                }
            }.navigationTitle("Manage Sticker")
        }
    }
}

struct StickerSetManager_Previews: PreviewProvider {
    static var previews: some View {
        StickerSetManager()
    }
}
