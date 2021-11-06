//
//  StickerMatorApp.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import SwiftUI

@main
struct StickerMatorApp: App {
    @StateObject var stickerSet = StickerStorage(name: "Default")
    var body: some Scene {
        DocumentGroup(newDocument: { StickerMatorViewModel() }) { editor in
            StickerMatorView(document: editor.document).environmentObject(stickerSet)
        }
    }
}
