//
//  StickerMakerDocument.swift
//  StickerMator
//
//  Created by Ning Ma on 11/4/21.
//

import SwiftUI

class StickerMakerDocument: ObservableObject {
    
    struct Filter: Identifiable, Hashable {
        var name: String
        let id: Int
        var ciFilter: CIFilter
    }
    
    
    @Published private(set) var filters: [Filter]
    
    init() {
        self.filters = [Filter(name: "SepiaTone", id: 1, ciFilter: CIFilter.sepiaTone()),
                        Filter(name: "Crystallize", id: 2, ciFilter: CIFilter.crystallize()),
                        Filter(name: "Edges", id: 3, ciFilter: CIFilter.edges()),
                        Filter(name: "Glass Lozenge", id: 4, ciFilter: CIFilter.glassLozenge()),
                        Filter(name: "ZoomBlur", id: 5, ciFilter: CIFilter.zoomBlur()),
                        Filter(name: "Pixellate", id: 6, ciFilter: CIFilter.pixellate()),
                        Filter(name: "Bloom", id: 7, ciFilter: CIFilter.bloom()),
                        Filter(name: "Unsharp Mask", id: 8, ciFilter: CIFilter.unsharpMask()),
                        Filter(name: "Gaussian Blur", id: 9, ciFilter: CIFilter.gaussianBlur()),
                        Filter(name: "Vignette", id: 10, ciFilter: CIFilter.vignette())]
    }
}
