//
//  ImagePicker.swift
//  StickerMator
//
//  Created by Ning Ma on 11/3/21.
//

import SwiftUI

// UIKit => Coordinator => SwiftUI

/// An image picker, pick image from photo library.
///
/// ImagePicker uses Coordinator to build a bridge between SwiftUI and UIKit.
struct ImagePicker: UIViewControllerRepresentable {
    
    /// An image handler receives UIImage and process
    var imageHandleFunc: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        
        /// An UIImagePickerController created and set options.
        ///
        /// Here, allowsEditing is ``true``, user can crop image.
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = context.coordinator
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
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                self.imageHandleFunc(image)
            } else {
                self.imageHandleFunc(nil)
            }
        }
    }
    
}

