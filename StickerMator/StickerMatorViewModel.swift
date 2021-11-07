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
    func addSticker (image: UIImage, at location:(x: Int, y: Int), size: CGSize, undoManager: UndoManager?) {
        if let data = image.pngData() {
            undoPerform(with: undoManager) {
                self.stickerMator.addSticker(imageData: data, at: location, size: (Int(size.width), Int(size.height)))
            }
        }
    }
    
    
    func addSticker (url: URL, at location:(x: Int, y: Int), size: CGSize, undoManager: UndoManager?) {
        let session = URLSession.shared
        let publisher = session.dataTaskPublisher(for: url)
            .map {(data, _) in UIImage(data: data)}
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
        _ = publisher.sink { [weak self] image in
            if let uiImage = image {
                self?.addSticker (image: uiImage, at: (x: location.x, y: location.y), size: size, undoManager: undoManager)
            }
        }
    }
    
    func addSticker (path: String, at location:(x: Int, y: Int), size: CGSize, undoManager: UndoManager?) {
        if let uiImage = UIImage(named: path) {
            self.addSticker(image: uiImage, at: (x: location.x, y: location.y), size: size, undoManager: undoManager)
        }
    }
    
    func moveSticker(_ sticker: StickerMatorModel.Sticker, by offset: CGSize, undoManager: UndoManager?) {
        if let index = stickerMator.stickers.findIndex(of: sticker) {
            undoPerform(with: undoManager) {
                stickerMator.stickers[index].x += Int(offset.width)
                stickerMator.stickers[index].y += Int(offset.height)
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
    
    
    private func saveData(to url: URL) {
        do {
            let data: Data = try stickerMator.jsonEncode()
            try data.write(to: url)
            logger.info("saveData success")
        } catch {
            logger.error("Data write failed: \(error.localizedDescription)")
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
