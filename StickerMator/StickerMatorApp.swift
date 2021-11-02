//
//  StickerMatorApp.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import SwiftUI

@main
struct StickerMatorApp: App {
    let document = StickerMatorViewModel()
    @StateObject var stickerSet = StickerStorage(name: "Default")
    var body: some Scene {
        WindowGroup {
            StickerMatorView(document: document).environmentObject(stickerSet)
        }
    }
}
