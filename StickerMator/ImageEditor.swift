//
//  ImageEditor.swift
//  StickerMator
//
//  Created by Ning Ma on 11/4/21.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ImageEditor: View {
    
    @State private var filterIntensity = 0.5
    @State var showImagePicker = false
    @EnvironmentObject var store: StickerStorage
    @Environment(\.dismiss) var dissmiss
    
    @State var imageToShow: UIImage?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    
    @State private var originalImage: UIImage?
    
    var context = CIContext()
    
    var body: some View {
        let intensity = Binding<Double> (
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
                            showImagePicker = true
                        }
                    }
                Spacer()
                HStack {
                    Slider(value: intensity).padding(.horizontal)
                }
                ScrollView(.horizontal) {
                    HStack(alignment: .top) {
                        IconAboveTextButton(title: "SepiaTone", systemImage: "1.circle.fill", textFont: .system(size: 10), iconSize: 30) {
                            setFilter(CIFilter.sepiaTone())
                        }.padding(.horizontal)
                        IconAboveTextButton(title: "Crystallize", systemImage: "2.circle.fill", textFont: .system(size: 10), iconSize: 30) {
                            setFilter(CIFilter.crystallize())
                        }.padding(.horizontal)
                        IconAboveTextButton(title: "Edges", systemImage: "3.circle.fill", textFont: .system(size: 10), iconSize: 30) {
                            setFilter(CIFilter.edges())
                        }.padding(.horizontal)
                        IconAboveTextButton(title: "Glass Lozenge", systemImage: "4.circle.fill", textFont: .system(size: 10), iconSize: 30) {
                            setFilter(CIFilter.glassLozenge())
                        }.padding(.horizontal)
                        IconAboveTextButton(title: "ZoomBlur", systemImage: "5.circle.fill", textFont: .system(size: 10), iconSize: 30) {
                            setFilter(CIFilter.edges())
                        }.padding(.horizontal)
                        IconAboveTextButton(title: "Pixellate", systemImage: "6.circle.fill", textFont: .system(size: 10), iconSize: 30) {
                            setFilter(CIFilter.pixellate())
                        }.padding(.horizontal)
                        IconAboveTextButton(title: "Bloom", systemImage: "7.circle.fill", textFont: .system(size: 10), iconSize: 30) {
                            setFilter(CIFilter.bloom())
                        }.padding(.horizontal)
                        IconAboveTextButton(title: "Unsharp Mask", systemImage: "8.circle.fill", textFont: .system(size: 10), iconSize: 30) {
                            setFilter(CIFilter.unsharpMask())
                        }.padding(.horizontal)
                        IconAboveTextButton(title: "Gaussian Blur", systemImage: "9.circle.fill", textFont: .system(size: 10), iconSize: 30) {
                            setFilter(CIFilter.gaussianBlur())
                        }.padding(.horizontal)
                        IconAboveTextButton(title: "Vignette", systemImage: "10.circle.fill", textFont: .system(size: 10), iconSize: 30) {
                            setFilter(CIFilter.vignette())
                        }.padding(.horizontal)
                    }
                    .padding()
                }
            }.navigationTitle(Text("Filter"))
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(imageHandleFunc: loadImage)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dissmiss()
                        }
                    }
                }
        }.navigationBarTitleDisplayMode(.inline)
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        processImage()
    }
    
    func loadImage(uiImage: UIImage?) {
        if let uiImage = uiImage {
            originalImage = uiImage
            processImage()
        }
        showImagePicker = false
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
            currentFilter.setValue(filterIntensity * 10 , forKey: kCIInputScaleKey)
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
        ImageEditor(imageToShow: image)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
