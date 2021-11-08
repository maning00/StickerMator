//
//  ImageSaver.swift
//  StickerMator
//
//  Created by Ning Ma on 11/8/21.
//

import UIKit

class ImageSaver: NSObject {
    func saveToAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            logger.error("Save Image Error: \(error.localizedDescription)")
        }
    }
}
