//
//  ImageEditor.swift
//  StickerMator
//
//  Created by Ning Ma on 11/4/21.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

/// StickerMaker is a simple photo editor.
///
/// This editor can add some filters to the image and remove the background of the image.
/// When initialize, ``showDialogue`` is required to import image.
struct StickerMaker: View {
    
    /// FilterIntensity controlled by slider.
    @State private var filterIntensity = 0.5
    
    /// A StickerStorage can get stickers from.
    @EnvironmentObject var store: StickerStorage
    
    @Environment(\.dismiss) var dissmiss
    
    /// Some filters' information.
    @ObservedObject var editorDocument: StickerMakerDocument
    
    /// Image shown to the user.
    @State var imageToShow: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var selectedFilter = Set<StickerMakerDocument.Filter>()
    
    /// The first image imported.
    @State private var originalImage: UIImage?
    
    /// Show different dialogs based on DialogueType
    enum DialogueType: Identifiable {
        case imagePicker
        case saveList
        var id: DialogueType {self}
    }
    
    @State var showDialogue: DialogueType? = nil
    
    /// CIContext used to create the image.
    var context = CIContext()
    
    var body: some View {
        
        /// If intensity is set, process the image.
        let intensity = Binding<Double>(
            get: { self.filterIntensity },
            set: {
                self.filterIntensity = $0
                self.processImage() // on change, refresh image
            })
        
        NavigationView {
            VStack {
                ZStack {
                    if imageToShow != nil {
                        Image(uiImage: imageToShow!).resizable()
                            .scaledToFit()
                    }
                }.padding()
                    .onTapGesture {
                        if imageToShow == nil {
                            showDialogue = .imagePicker
                        }
                    }
                Spacer()
                HStack {
                    Slider(value: intensity).padding(.horizontal)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        IconAboveTextButton(title: "Remove Background", systemImage: "person.crop.rectangle", textFont: .system(size: 10), iconSize: 30) {
                            if let originalImage = originalImage {
                                let removal = BackgroundRemoval(input: originalImage)
                                imageToShow = removal.getResult()
                                if let imageToShow = imageToShow {
                                    self.originalImage = imageToShow
                                }
                            }
                            selectedFilter.removeAll()
                        }.padding()
                        ForEach(editorDocument.filters) { filter in
                            IconAboveTextButton(title: filter.name, systemImage: String(filter.id)+".circle.fill", textFont: .system(size: 10), iconSize: 30) {
                                setFilter(filter.ciFilter)
                                selectedFilter.removeAll()
                                selectedFilter.insert(filter)
                            }.padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue, lineWidth: selectedFilter.containsMatching(filter) ? 2 : 0)
                                )
                        }
                        
                    }
                }.padding()
            }.navigationTitle(Text("StickerMaker"))
                .sheet(item: $showDialogue) { pickerType in
                    switch pickerType {
                    case .imagePicker:
                        ImagePicker(imageHandleFunc: loadImage)
                    case .saveList:
                        saveList
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dissmiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            showDialogue = .saveList
                        }
                    }
                }
        }.navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - save option
    
    /// A list showing existing sticker packs
    var saveList: some View {
        NavigationView {
            List {
                ForEach(store.stickerPacks) { stickerset in
                    VStack {
                        AnimatedActionButton(title: stickerset.name) {
                            saveImageToStickerSet(imageToShow, stickerSetToAdd: stickerset)
                        }.foregroundColor(Color.primary)
                    }
                }
            }.navigationTitle("Save To")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showDialogue = nil
                        }
                    }
                }
        }
    }
    
    /// Save to the sticker pack specified by the user.
    private func saveImageToStickerSet(_ image: UIImage?, stickerSetToAdd: StickerPack) {
        logger.info("saveImageToStickerSet catched image")
        if let image = image {
            if let urlStr = saveFileAndReturnURLString(image: image) {
                if let index = store.stickerPacks.findIndex(of: stickerSetToAdd) {
                    store.stickerPacks[index].stickers.append(urlStr)
                }
            } else {
                logger.warning("Get URL failed")
            }
        }
        showDialogue = nil
    }
    
    // MARK: - filters
    
    /// Set the current filter
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        processImage()
    }
    
    /// Load chosen image from photo library.
    func loadImage(uiImage: UIImage?) {
        if let uiImage = uiImage {
            originalImage = uiImage
            processImage()
        }
        showDialogue = nil
    }
    
    /// Process images using filter.
    func processImage() {
        guard let originalImage = originalImage else { return }
        let beginImage = CIImage(image: originalImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        // Keys that meet the needs of different filters
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterIntensity * 20, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            imageToShow = uiImage
        }
    }
}


var image = UIImage(named: "dog_13")!
struct ImageEditor_Previews: PreviewProvider {
    
    static var previews: some View {
        StickerMaker(editorDocument: StickerMakerDocument(), imageToShow: image)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
