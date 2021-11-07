//
//  StickerMatorView.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import SwiftUI
import MobileCoreServices

struct StickerMatorView: View {
    @ObservedObject var document: StickerMatorViewModel
    @Environment(\.undoManager) var undoManager
    @State private var showBottomBar = true
    @State private var imagePicker: ImagePickerType? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                documentBody
            }
            if showBottomBar {
                StickerBottomBar(showBottomBar: $showBottomBar)
            }
        }
    }
    
    var defaultStickerSize: CGSize = CGSize(width: 300, height: 300)
    
    @ViewBuilder
    private var deleteSelectedStickerButton: some View {
        if !selectedSticker.isEmpty {
            Button {
                withAnimation {
                    for sticker in selectedSticker {
                        document.removeSticker(sticker, undoManager: undoManager)
                    }
                    selectedSticker.removeAll()
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }.foregroundColor(.red)
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                if let mainImage = document.mainImage {
                    Image(uiImage: mainImage)
                        .scaleEffect(zoomScale)
                        .position(positionForMainImage(geometry: geometry))
                } else {
                    Color.white
                }
                ForEach(document.stickers) { sticker in
                    if let uiImage = UIImage(data: sticker.data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .border(Color.blue, width: selectedSticker.containsMatching(sticker) ? 4 : 0)
                            .frame(width: frameSize(for: sticker).width, height: frameSize(for: sticker).height)
                            .scaleEffect(selectedSticker.containsMatching(sticker) ? zoomScale * stickerGestureZoomScale : zoomScale)
                            .offset(selectedSticker.containsMatching(sticker) ? stickerGesturePanOffset : .zero)
                            .position(position(for: sticker))
                            .onTapGesture {
                                withAnimation {
                                    selectedSticker.toggleMatching(sticker)
                                }
                            }
                            .gesture(panGesture(for: sticker))
                    }
                }
            }
            .adaptiveMenuToolBar {
                deleteSelectedStickerButton
                UndoButton(undoManager: undoManager)
                pickPhotoMenu
                if showBottomBar == true {
                    AnimatedActionButton(title: "Hide StickerBar",systemImage: "theatermasks.fill",
                                         action: { showBottomBar.toggle() })
                } else {
                    AnimatedActionButton(title: "Show StickerBar",systemImage: "theatermasks.fill",
                                         action: { showBottomBar.toggle() })
                }
                
            }
            .clipped()
            .onDrop(of: [.url, .image, .plainText], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            .gesture(zoomGesture()
                        .simultaneously(with: singleTapToDeselectAllSticker().simultaneously(with: panGesture())))
            .sheet(item: $imagePicker) { pickerType in
                switch pickerType {
                case .camera:
                    Camera(imageHandleFunc: handlePickedPhoto)
                case .library:
                    ImagePicker(imageHandleFunc: handlePickedPhoto)
                }
            }
        }
    }
    
    /// A  Set to store selected Sticker, the selected sticker will have a border
    @State private var selectedSticker = Set<StickerMatorModel.Sticker>()
    
    @ViewBuilder
    private var pickPhotoMenu: some View {
        Menu {
            Button("From Photos") {
                imagePicker = .library
            }
            Button("From Camera") {
                imagePicker = .camera
            }
        } label: {
            Label("Add Photo", systemImage: "photo.on.rectangle.angled")
        }
    }
    
    /// Handle picked image and set as mainImage
    private func handlePickedPhoto(_ image: UIImage?) {
        logger.info("handlePickedPhoto catched image")
        if let image = image {
            document.setMainImage(image: image, undoManager: undoManager)
        } else {
            logger.warning("Get URL failed")
        }
        imagePicker = nil
    }
    
    private func singleTapToDeselectAllSticker() -> some Gesture {
        TapGesture()
            .onEnded {
                withAnimation {
                    selectedSticker.removeAll()
                }
            }
    }
    
    // MARK: - drag & drop
    
    /// Drop Handler
    ///
    /// There're 3 types of object to handle: URL, UIImage and String:
    /// - **URL** is online content, should be downloaded and handle
    /// - **UIImage** is image that can display directly
    /// - **String** is path of the image, the image is already downloaded on the device
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.addSticker(url: url, at: location,
                                size: defaultStickerSize / zoomScale, undoManager: undoManager)
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                document.addSticker(image: image, at: location,
                                    size: defaultStickerSize / zoomScale, undoManager: undoManager)
                
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { path in
                document.addSticker(path: path, at: location,
                                    size: defaultStickerSize / zoomScale, undoManager: undoManager)
            }
        }
        return found
    }
    
    
    // MARK: - Position the view
    
    /// Get initial main image position,
    /// main image position is in the center of the view
    /// - Returns: CGPoint of main image's center
    private func positionForMainImage(geometry: GeometryProxy) -> CGPoint {
        return CGPoint (
            x: geometry.frame(in: .local).midX + panOffset.width,
            y: geometry.frame(in: .local).midY + panOffset.height
        )
    }
    
    /// Get sticker's position in view
    /// Sticker's position is sticker's coordinate plus global panoffset
    /// - Returns: CGPoint of sticker's center
    private func position(for sticker: StickerMatorModel.Sticker) -> CGPoint {
        return CGPoint(
            x: CGFloat(sticker.x) + panOffset.width,
            y: CGFloat(sticker.y) + panOffset.height
        )
    }
    
    private func frameSize(for sticker: StickerMatorModel.Sticker) -> CGSize {
        CGSize(width: sticker.width, height: sticker.height)
    }
    
    // MARK: - Scale Gesture
    
    @State private var steadyZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    @GestureState private var stickerGestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        steadyZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        // once selected zoomGesture will apply in all area
        
        return MagnificationGesture()
            .updating($stickerGestureZoomScale) { latestGestureScale, stickerGestureZoomScale, _ in
                if !selectedSticker.isEmpty {
                    stickerGestureZoomScale = latestGestureScale
                }
            }
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                if selectedSticker.isEmpty {
                    gestureZoomScale = latestGestureScale
                }
            }
            .onEnded { gestureScaleAtEnd in
                if selectedSticker.isEmpty {
                    steadyZoomScale *= gestureScaleAtEnd
                } else {
                    for sticker in selectedSticker {
                        document.scaleSticker(sticker, by: gestureScaleAtEnd, undoManager: undoManager)
                    }
                }
            }
        
    }
    
    // MARK: - Pan Gesture
    
    @State private var steadyPanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    @GestureState private var stickerGesturePanOffset: CGSize = CGSize.zero  // single sticker panoff
    
    private var panOffset: CGSize {
        (steadyPanOffset + gesturePanOffset)
    }
    
    private func panGesture(for sticker: StickerMatorModel.Sticker? = nil) -> some Gesture {
        if let sticker = sticker, selectedSticker.containsMatching(sticker) {
            
            return DragGesture()
                .updating($stickerGesturePanOffset) { latestvalue, stickerGesturePanOffset, _ in
                    stickerGesturePanOffset = latestvalue.translation
                }
                .onEnded { finalValue in
                    for sticker in selectedSticker {
                        document.moveSticker(sticker, by: finalValue.translation, undoManager: undoManager)
                    }
                }
        } else {
            return DragGesture()
                .updating($gesturePanOffset) { latestvalue, gesturePanOffset, _ in
                    gesturePanOffset = latestvalue.translation
                }
                .onEnded { finalValue in
                    steadyPanOffset = steadyPanOffset + (finalValue.translation)
                }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StickerMatorView(document: StickerMatorViewModel())
    }
}

