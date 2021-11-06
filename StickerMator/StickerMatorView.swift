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
    @State private var showBottomBar = false
    @State private var showImageChooseOption = false
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
                        .position(convertFromEmojiCoordinates((0,0), in: geometry))
                } else {
                    Color.white
                }
                ForEach(document.stickers) { sticker in
                    if let uiImage = UIImage(named: sticker.data.absoluteString) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .border(Color.blue, width: selectedSticker.containsMatching(sticker) ? 4 : 0)
                            .frame(width: frameSize(for: sticker).width, height: frameSize(for: sticker).height)
                            .offset(selectedSticker.containsMatching(sticker) ? stickerGesturePanOffset : .zero)
                            .position(position(for: sticker, in: geometry))
                            .onTapGesture {
                                withAnimation {
                                    selectedSticker.toggleMatching(sticker)
                                }
                            }.scaleEffect(selectedSticker.containsMatching(sticker) ? zoomScale * stickerGestureZoomScale : zoomScale)
                            .gesture(panGesture(for: sticker))
                    }
                }
                .scaleEffect(zoomScale)
            }
            .adaptiveMenuToolBar {
                deleteSelectedStickerButton
                UndoButton(undoManager: undoManager)
                AnimatedActionButton(title: "Add Photo", systemImage: "photo.on.rectangle.angled") {
                    showImageChooseOption = true
                }
                AnimatedActionButton(title: "Show StickerBar",systemImage: "theatermasks.fill",
                                     action: { showBottomBar.toggle() })
            }
            .clipped()
            .onDrop(of: [.url, .image, .plainText], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            .gesture(zoomGesture()
                        .simultaneously(with: singleTapToDeselectAllSticker()
                                            .simultaneously(with: panGesture())))
            .confirmationDialog("Add a Photo", isPresented: $showImageChooseOption, titleVisibility: .visible) {
                Button("From Photos") {
                    imagePicker = .library
                }
                Button("From Camera") {
                    imagePicker = .camera
                }
            }
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
    
    @State private var selectedSticker = Set<StickerMatorModel.Sticker>()
    
    private func handlePickedPhoto(_ image: UIImage?) {
        logger.info("handlePickedPhoto catched image")
        if let image = image {
            if let urlStr = saveFileAndReturnURLString(image: image) {
                document.setMainImage(url: URL(string: urlStr), undoManager: undoManager)
            } else {
                logger.warning("Get URL failed")
            }
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
    
    // MARK: drag & drop
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.addSticker(url: url, at: convertToEmojiCoordinates(location, in: geometry),
                                size: defaultStickerSize / zoomScale, undoManager: undoManager)
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                document.addSticker(image: image, at: convertToEmojiCoordinates(location, in: geometry),
                                    size: defaultStickerSize / zoomScale, undoManager: undoManager)
                
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { path in
                document.addSticker(path: path, at: convertToEmojiCoordinates(location, in: geometry),
                                    size: defaultStickerSize / zoomScale, undoManager: undoManager)
            }
        }
        return found
    }
    
    
    // MARK: Position the view
    private func position(for sticker: StickerMatorModel.Sticker, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((sticker.x, sticker.y), in: geometry)
    }
    
    private func frameSize(for sticker: StickerMatorModel.Sticker) -> CGSize {
        CGSize(width: sticker.width, height: sticker.height)
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let location = CGPoint(
            x: (location.x - panOffset.width) / zoomScale,
            y: (location.y - panOffset.height) / zoomScale
        )
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        return CGPoint(
            x: CGFloat(location.x) * zoomScale + panOffset.width,
            y: CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    // MARK: Scale
    
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
    
    @State private var steadyPanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    @GestureState private var stickerGesturePanOffset: CGSize = CGSize.zero  // single sticker panoff
    
    private var panOffset: CGSize {
        (steadyPanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture(for sticker: StickerMatorModel.Sticker? = nil) -> some Gesture {
        if let sticker = sticker, selectedSticker.containsMatching(sticker) {
            
            return DragGesture()
                .updating($stickerGesturePanOffset) { latestvalue, stickerGesturePanOffset, _ in
                    stickerGesturePanOffset = latestvalue.translation
                }
                .onEnded { finalValue in
                    for sticker in selectedSticker {
                        document.moveSticker(sticker, by: finalValue.translation / zoomScale, undoManager: undoManager)
                    }
                }
        } else {
            return DragGesture()
                .updating($gesturePanOffset) { latestvalue, gesturePanOffset, _ in
                    gesturePanOffset = latestvalue.translation
                }
                .onEnded { finalValue in
                    steadyPanOffset = steadyPanOffset + (finalValue.translation / zoomScale)
                }
        }
    }
}

struct UndoButton: View {
    
    var undoManager: UndoManager?
    
    var body: some View {
        if let undoManager = undoManager {
            Button {} label: {
                Label("Undo/Redo", systemImage: "arrow.counterclockwise.circle")
            }.contextMenu{
                Button {
                    undoManager.undo()
                } label: {
                    Label("Undo", systemImage: "arrow.uturn.backward.circle")
                }
                Button {
                    undoManager.redo()
                } label: {
                    Label("Redo", systemImage: "arrow.uturn.right.circle")
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StickerMatorView(document: StickerMatorViewModel())
    }
}

