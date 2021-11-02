//
//  StickerMatorView.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import SwiftUI
import MobileCoreServices

typealias StickerSource = StickerMatorViewModel.StickerSource

struct StickerMatorView: View {
    @ObservedObject var document: StickerMatorViewModel
    
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                documentBody
                deleteSelectedStickerButton.padding(.vertical)  //
            }
            palette
        }
    }
    
    var defaultFontSize: CGFloat = 200
    
    @ViewBuilder
    private var deleteSelectedStickerButton: some View {
        if !selectedSticker.isEmpty {
            Button {
                withAnimation {
                    for sticker in selectedSticker {
                        document.removeSticker(sticker)
                    }
                    selectedSticker.removeAll()
                }
            } label: {
                Label("Delete", systemImage: "trash")
                    .foregroundColor(.red)
                }
            }
        }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    ForEach(document.stickers) { sticker in
                        switch sticker.content {
                        case .imageData(let data):
                            if let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage).position(position(for: sticker, in: geometry))
                            }
                        case .url(let url):
                            if let uiImage = UIImage(named: url.absoluteString) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .border(Color.blue, width: selectedSticker.containsMatching(sticker) ? 4 : 0)
                                    .frame(width: frameSize(for: sticker), height: frameSize(for: sticker))
                                    .offset(selectedSticker.containsMatching(sticker) ? stickerGesturePanOffset : .zero) // if selected seprate panoff
                                    .position(position(for: sticker, in: geometry))
                                    .onTapGesture {
                                        withAnimation {
                                            selectedSticker.toggleMatching(sticker)
                                        }
                                    }.scaleEffect(selectedSticker.containsMatching(sticker) ? zoomScale * stickerGestureZoomScale : zoomScale)
                                    .gesture(panGesture(for: sticker))
                            }
                        }
                    }
                
                    .scaleEffect(zoomScale)
            }
            .clipped()
            .onDrop(of: [String(kUTTypeURL)], isTargeted: nil) { providers, location in
                    drop(providers: providers, at: location, in: geometry)
            }
            .gesture(zoomGesture().simultaneously(with: singleTapToDeselectAllSticker().simultaneously(with: panGesture())))
        }
    }
    
    @State private var selectedSticker = Set<StickerMatorModel.Sticker>()
    
    private func singleTapToDeselectAllSticker() -> some Gesture {
        TapGesture()
            .onEnded {
                withAnimation {
                    selectedSticker.removeAll()
                }
            }
        
    }
    
    // drag & drop
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        providers.loadObjects(ofType: URL.self) { url in
            print(url)
            document.addSticker(StickerSource(url), at: convertToEmojiCoordinates(location, in: geometry), size: defaultFontSize / zoomScale)
        }
    }
    
    var palette: some View {
        ScrollingStickerView(images: document.builtinImage)
    }
    
    // Position the view
    private func position(for sticker: StickerMatorModel.Sticker, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((sticker.x, sticker.y), in: geometry)
    }
    
    private func frameSize(for sticker: StickerMatorModel.Sticker) -> CGFloat {
        CGFloat(sticker.size)
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
            y:  CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    // Scale
    
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
                        document.scaleSticker(sticker, by: gestureScaleAtEnd)
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
                    document.moveSticker(sticker, by: finalValue.translation / zoomScale)
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

struct ScrollingStickerView: View {
    init(images: [URL?]) {
        self.images = images
    }
    
    let images: [URL?]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                // map to characters
                ForEach(images, id:\.self) { image in
                    if let image = image {
                        Image(uiImage: UIImage(named: image.absoluteString)!)
                        .resizable().padding(1).aspectRatio(contentMode: .fill)
                        .onDrag {
                            NSItemProvider(item: image as NSSecureCoding, typeIdentifier: String(kUTTypeURL))
                        }
                    }
                }
            }.frame(minHeight: 20,maxHeight: 70, alignment: .topLeading)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StickerMatorView(document: StickerMatorViewModel())
    }
}

