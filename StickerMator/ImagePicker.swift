//
//  ImagePicker.swift
//  StickerMator
//
//  Created by Ning Ma on 11/3/21.
//

import SwiftUI

// UIKit => Coordinator => SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    var imageHandleFunc: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {  //create
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(imageHandleFunc: imageHandleFunc)
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var imageHandleFunc: (UIImage?) -> Void
        
        init (imageHandleFunc: @escaping (UIImage?) -> Void) {
            self.imageHandleFunc = imageHandleFunc
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                self.imageHandleFunc(image)
            } else {
                self.imageHandleFunc(nil)
            }
        }
    }
    
}

