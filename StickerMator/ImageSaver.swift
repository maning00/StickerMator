//
//  ImageSaver.swift
//  StickerMator
//
//  Created by Ning Ma on 11/8/21.
//

import UIKit

/// A class saves UIImage to photo album.
///
class ImageSaver: NSObject {
    func saveToAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }
    
    /// completionSelector for ``UIImageWriteToSavedPhotosAlbum``
    ///
    /// This method conform to the following signature:
    /// ````
    /// (void)image:(UIImage *)image
    /// didFinishSavingWithError:(NSError *)error
    /// contextInfo:(void *)contextInfo;
    /// ````
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            logger.error("Save Image Error: \(error.localizedDescription)")
        }
    }
}
