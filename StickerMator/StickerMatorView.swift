//
//  StickerMatorView.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import SwiftUI



struct StickerMatorView: View {
    
    var ele: [UIImage?] = [UIImage(named: "dog_01"), UIImage(named: "dog_02"),UIImage(named: "dog_03"),UIImage(named: "dog_04"),UIImage(named: "dog_05"),UIImage(named: "dog_06"),UIImage(named: "dog_07"),UIImage(named: "dog_08")]
    
    var body: some View {
        VStack {
            Color.red.overlay {
            }
            
            palette
        }
    }
    
    var palette: some View {
        ScrollingStickerView(images: ele, emojis: testemojis)
    }
    
    let testemojis = "🕎☸️🇲🇳🧑‍🌾 👨‍🌾 👩‍🍳 🧑‍🍳 👨‍🍳 👩‍🎓 🧑‍🎓 👨‍🎓 👩‍🎤 🧑‍🎤 👨‍🎤 👩‍🏫 🧑‍🏫 👨‍🏫 👩‍🏭 🧑‍🏭 👨‍🏭 👩‍💻 🧑‍💻 👨‍💻"
}

struct ScrollingStickerView: View {
    
    init(images: [UIImage?], emojis: String? = nil) {
        self.images = images
        self.emojis = emojis
    }
    
    let images: [UIImage?]
    let emojis: String?
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 0) {
                // map to characters
                ForEach(images, id:\.self) { img in
                    Image(uiImage: img!).resizable().padding(1).aspectRatio(contentMode: .fill)
                }
                if let elements = emojis {
                    ForEach(elements.map {String($0)}, id:\.self) { element in
                        Text(element).font(.system(size: 60))
                }
                }
            }.frame(minHeight: 20,maxHeight: 70, alignment: .topLeading)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StickerMatorView()
    }
}
