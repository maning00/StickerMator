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
            setMainImage(url: stickerMator.mainImage, undoManager: nil)
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
    func setMainImage(url: URL?, undoManager: UndoManager?) {
        undoPerform(with: undoManager) {
            stickerMator.mainImage = url
            guard let urlString = url?.absoluteString else { return }
            mainImage = UIImage(named: urlString)
        }
    }
    
    
    // MARK: - Sticker operation
    func addSticker (image: UIImage, at location:(x: Int, y: Int), size: CGSize, undoManager: UndoManager?) {
        if let urlStr = saveFileAndReturnURLString(image: image),
           let url = URL(string: urlStr) {
            undoPerform(with: undoManager) {
                stickerMator.addSticker(imageURL: url, at: (x: location.x, y: location.y), size: (Int(size.width), Int(size.height)))
            }
        } else {
            logger.warning("Get URL failed")
        }
    }
    
    
    func addSticker (url: URL, at location:(x: Int, y: Int), size: CGSize, undoManager: UndoManager?) {
        let session = URLSession.shared
        let publisher = session.dataTaskPublisher(for: url)
            .map {(data, _) in UIImage(data: data)}
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
        _ = publisher.sink { [weak self] image in
            if let image = image {
                if let urlStr = saveFileAndReturnURLString(image: image),
                   let url = URL(string: urlStr) {
                    self?.undoPerform(with: undoManager) {
                        self?.stickerMator.addSticker(imageURL: url, at: (x: location.x, y: location.y), size: (Int(size.width), Int(size.height)))
                    }
                } else {
                    logger.warning("Get URL failed")
                }
            }
        }
    }
    
    func addSticker (path: String, at location:(x: Int, y: Int), size: CGSize, undoManager: UndoManager?) {
        if let url = URL(string: path) {
            undoPerform(with: undoManager) {
                stickerMator.addSticker(imageURL: url, at: (x: location.x, y: location.y), size: (Int(size.width), Int(size.height)))
            }
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
