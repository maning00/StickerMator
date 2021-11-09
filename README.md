# StickerMator
StickerMator is a SwiftUI based iOS app that runs with iPhone and iPad. using this app you can add stickers to your photos, image manipulation of stickers, and make your own sticker packs.  It is a free app and you can use it for free.  This project is also part of my Swift learning track.
<div align="center">
<img src="https://dsc.cloud/8532ed/skm-1.jpg" height="230px" alt="skm-1" >
<img src="https://dsc.cloud/8532ed/skm-2.jpg" height="230px" alt="skm-2" >
</div>

## Features
- **Sticker Maker**: A simple sticker editing tool that allows you to select images from photo albums for processing. CoreML-based image segmentation enables automatic background removal for sticker creation. In addition, a variety of filters are provided for you to freely choose to adjust.
<div align="center">
<img src="https://dsc.cloud/8532ed/skm-3.PNG" height="240px" alt="skm-3" >
<img src="https://dsc.cloud/8532ed/skm-4.PNG" height="240px" alt="skm-4" >
</div>
<div align="center">
<img src="https://dsc.cloud/8532ed/IMG_0150.PNG" height="240px" alt="skm-5" >
<img src="https://dsc.cloud/8532ed/skm-5.PNG" height="240px" alt="skm-5" >
</div>

- **Sticker Packs**: You can customize your own sticker packs, manage them at will, add and delete.
<div align="center">
<img src="https://dsc.cloud/8532ed/skm-6.PNG" height="240px" alt="skm-6" >
<img src="https://dsc.cloud/8532ed/skm-7.PNG" height="240px" alt="skm-7" >
</div>

- **CoreML**: CoreML is a powerful machine learning framework that makes it easy to apply machine learning techniques to apps, StickerMator uses CoreML's DeepLab V3 model for image processing to quickly acquire target areas and use the CoreImage API for image background removal, this makes sticker editing even more powerful.

- **Gesture support**: You can freely use different gestures to make adjustments to images or stickers, such as zooming using two fingers, moving and adjusting stickers and images.

- **Document-based interface**: With Apple's document API, StickerMator can store files locally or in iCloud using Document Manager, StickerMator also created the **skm** file format, which is a simple format for storing user data and sticker packs.

## Requirements
- **iOS 15.0** or later
- **Swift 5**
- **Xcode 13**

## Known Issues
- **Zoom anchor point**: When the overall scaling is performed, the scaling anchor points of the sticker and the background image will have inconsistent problems, and displacement will occur between the sticker and the background image when scaling. To solve this problem, you need to fix the scaling anchor points of the sticker and the background image.
- **Save to photo albums**: Still haven't found a better way to save as an image, when trying to use UIHostingController to read the View and render it with UIGraphicsImageRenderer, the position of the background image and the sticker will be wrong, this problem is to be solved.


## See also
- [CS193p - Developing Apps for iOS](https://cs193p.sites.stanford.edu/)
- [hollance/CoreMLHelpers](https://github.com/hollance/CoreMLHelpers)