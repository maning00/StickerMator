//
//  ImageEditor.swift
//  StickerMator
//
//  Created by Ning Ma on 11/4/21.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct StickerMaker: View {
    
    @State private var filterIntensity = 0.5
    @EnvironmentObject var store: StickerStorage
    @Environment(\.dismiss) var dissmiss
    @ObservedObject var editorDocument: StickerMakerDocument
    
    @State var imageToShow: UIImage?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var selectedFilter = Set<StickerMakerDocument.Filter>()
    @State private var originalImage: UIImage?
    
    enum DialogueType: Identifiable {
        case imagePicker
        case saveList
        var id: DialogueType {self}
    }
    
    @State var showDialogue: DialogueType? = nil
    
    var context = CIContext()
    
    var body: some View {
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
    
    var saveList: some View {
        NavigationView {
            List {
                ForEach(store.stickerSets) { stickerset in
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
    
    
    private func saveImageToStickerSet(_ image: UIImage?, stickerSetToAdd: StickerSet) {
        logger.info("saveImageToStickerSet catched image")
        if let image = image {
            let userFileName = UUID().uuidString
            if let data = image.pngData() {
                let filename = getDocumentsDirectory().appendingPathComponent(userFileName)
                logger.info("Image saved to \(filename)")
                try? data.write(to: filename)
            }
            if let urlStr = getSavedImage(named: userFileName) {
                if let index = store.stickerSets.findIndex(of: stickerSetToAdd) {
                    store.stickerSets[index].stickers.append(urlStr)
                }
            } else {
                logger.warning("Get URL failed")
            }
        }
        showDialogue = nil
    }
    
    // MARK: - filters
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        processImage()
    }
    
    func loadImage(uiImage: UIImage?) {
        if let uiImage = uiImage {
            originalImage = uiImage
            processImage()
        }
        showDialogue = nil
    }
    
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
