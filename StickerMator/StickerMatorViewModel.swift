//
//  StickerMatorViewModel.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let skm = UTType(exportedAs: "edu.ustb.ningma.skm")
}

class StickerMatorViewModel: ReferenceFileDocument {
    static var readableContentTypes: [UTType] {[.skm]}
    static var writeableContentTypes: [UTType] {[.skm]}
    
    
    // MARK: - ReferenceFileDocument
    
    
    required init(configuration: ReadConfiguration) throws {
        if let json = configuration.file.regularFileContents {
            stickerMator = try StickerMatorModel(json: json)
            if let mainImage = stickerMator.mainImage {
                setMainImage(image: UIImage(data: mainImage), undoManager: nil)
            }
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        try stickerMator.jsonEncode()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    @Published private(set) var stickerMator: StickerMatorModel
    
    /// MainImage is background
    @Published var mainImage: UIImage?
    
    init () {
        stickerMator = StickerMatorModel()
    }
    
    var stickers: [StickerMatorModel.Sticker] { stickerMator.stickers }
    
    // MARK: - Main Image
    func setMainImage(image: UIImage?, undoManager: UndoManager?) {
        undoPerform(with: undoManager) {
            stickerMator.mainImage = image?.pngData()
            mainImage = image
        }
    }
    
    
    // MARK: - Sticker operation
    
    /// Add Sticker to main interface, save image data, location and size to StickerMatorModel.
    ///
    ///  - Parameters:
    ///    - image: Sticker Image, converted to UIImage.
    ///    - location: Center coordinates of the sticker.
    ///    - zoomScale: The zoom ratio of the main interface when adding stickers.
    ///    - undoManager: UndoManager.
    ///
    /// In order to avoid the original image being too large, a zoom factor is added to this function,
    /// and the shortest side of the image is fixed to 200.
    func addSticker (image: UIImage, at location: CGPoint, zoomScale: CGFloat, undoManager: UndoManager?) {
        if let data = image.pngData() {
            let factor = min(image.size.width, image.size.height) / 200
            undoPerform(with: undoManager) {
                self.stickerMator.addSticker(imageData: data,
                                             at: (Float(location.x), Float(location.y)),
                                             size: (Int(image.size.width / factor / zoomScale),
                                                    Int(image.size.height / factor / zoomScale)))
            }
        }
    }
    
    
    func addSticker (url: URL, at location: CGPoint, zoomScale: CGFloat, undoManager: UndoManager?) {
        DispatchQueue.main.async {
            do {
                let data = try Data(contentsOf: url)
                if let uiImage = UIImage(data: data) {
                    self.addSticker (image: uiImage, at: location, zoomScale: zoomScale, undoManager: undoManager)
                }
            } catch {
                logger.error("Get content error: \(error)")
            }
        }
        
    }
    
    func addSticker (path: String, at location: CGPoint, zoomScale: CGFloat, undoManager: UndoManager?) {
        if let uiImage = UIImage(named: path) {
            self.addSticker(image: uiImage, at: location, zoomScale: zoomScale, undoManager: undoManager)
        }
    }
    
    func moveSticker(_ sticker: StickerMatorModel.Sticker, by offset: CGSize, undoManager: UndoManager?) {
        if let index = stickerMator.stickers.findIndex(of: sticker) {
            undoPerform(with: undoManager) {
                stickerMator.stickers[index].x += Float(offset.width)
                stickerMator.stickers[index].y += Float(offset.height)
            }
        }
    }
    
    func scaleSticker(_ sticker: StickerMatorModel.Sticker, by scale: CGFloat, undoManager: UndoManager?) {
        if let index = stickerMator.stickers.findIndex(of: sticker) {
            undoPerform(with: undoManager) {
                stickerMator.stickers[index].width = Int((CGFloat(stickerMator.stickers[index].width)*scale).rounded(.toNearestOrAwayFromZero))
                stickerMator.stickers[index].height = Int((CGFloat(stickerMator.stickers[index].height)*scale).rounded(.toNearestOrAwayFromZero))
                // Absolute value rounding
            }
        }
    }
    
    func removeSticker(_ sticker: StickerMatorModel.Sticker, undoManager: UndoManager?) {
        undoPerform(with: undoManager) {
            stickerMator.removeSticker(sticker)
        }
    }
    
    // MARK: - Undo
    
    private func undoPerform(with undoManager: UndoManager? = nil, doit: () -> Void) {
        let oldModel = stickerMator
        doit()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoPerform(with: undoManager) {
                myself.stickerMator = oldModel
            }
        }
    }
}
