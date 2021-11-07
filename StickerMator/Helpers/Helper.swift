//
//  Helper.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

extension Collection where Element: Identifiable {
    /// This function returns index of specified element
    func findIndex(of element: Element) -> Self.Index? {
        firstIndex(where: {$0.id == element.id })
    }
}


/// From CS193p
///  load object from NSItemProvider
extension Array where Element == NSItemProvider {
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false,
                        using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType) }) {
            provider.loadObject(ofClass: theType) { object, error in
                if let value = object as? T {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false,
                        using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType) }) {
            let _ = provider.loadObject(ofClass: theType) { object, error in
                if let value = object {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
    func loadFirstObject<T>(ofType theType: T.Type,
                            using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
        loadObjects(ofType: theType, firstOnly: true, using: load)
    }
    func loadFirstObject<T>(ofType theType: T.Type,
                            using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        loadObjects(ofType: theType, firstOnly: true, using: load)
    }
}

// Add operator to CGSize
extension CGSize {
    static func - (left: Self, right: Self) -> CGSize {
        CGSize(width: left.width - right.width, height: left.height - right.height)
    }
    
    static func + (left: Self, right: Self) -> CGSize {
        CGSize(width: left.width + right.width, height: left.height + right.height)
    }
    
    static func * (left: Self, right: CGFloat) -> CGSize {
        CGSize(width: left.width * right, height: left.height * right)
    }
    
    static func / (left: Self, right: CGFloat) -> CGSize {
        CGSize(width: left.width / right, height: left.height / right)
    }
}

/// **containsMatching**: Check if the element is in the set
extension Set where Element: Identifiable {
    
    /// If there is this **element** in the Set, delete it, otherwise insert this element
    mutating func toggleMatching(_ element: Element) {
        if let matchingIndex = firstIndex(where: {$0.id == element.id}) {
            remove(at: matchingIndex)
        } else {
            insert(element)
        }
    }
    
    /// Check if the **element** is in the set
    func containsMatching(_ element: Element) -> Bool {
        contains(where: {$0.id == element.id})
    }
}


struct AnimatedActionButton: View {
    var title: String? = nil
    var systemImage: String? = nil
    let action: () -> Void
    var labelFont: Font? = nil
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            if title != nil && systemImage != nil {
                Label(title!, systemImage: systemImage!)
            } else if title != nil {
                Text(title!)
            } else if systemImage != nil {
                Image(systemName: systemImage!)
            }
        }.font(labelFont)
    }
}


extension RangeReplaceableCollection where Element: Identifiable {
    
    /// Find the element and remove it
    mutating func remove(_ element: Element) {
        if let index = findIndex(of: element) {
            remove(at: index)
        }
    }
    
    /// Return the element the same as giving element value
    subscript(_ element: Element) -> Element {
        get {
            if let index = findIndex(of: element) {
                return self[index]
            } else {
                return element
            }
        }
        set {
            if let index = findIndex(of: element) {
                replaceSubrange(index...index, with: [newValue])
            }
        }
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

/// A view with a button on the top and label on the bottom
struct IconAboveTextButton: View {
    
    var title: String
    var systemImage: String? = nil
    var textFont: Font? = nil
    var iconSize: CGFloat? = nil
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 5) {
            AnimatedActionButton(title: "", systemImage: systemImage, action: action, labelFont: .system(size: iconSize ?? 40))
            Text(title).font(textFont)
        }
        
    }
}

func getSavedImage(named: String) -> String? {
    if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
        return URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path
    }
    return nil
}

/// Handling horizontal and vertical screens,
/// combine content into a menu in portrait mode
struct AdaptiveMenu: ViewModifier {
    
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var compact: Bool { horizontalSizeClass == .compact }
    
    func body(content: Content) -> some View {
        if compact {
            Menu {
                content
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        } else {
            content
        }
    }
}

extension View {
    func adaptiveMenuToolBar<Content>(@ViewBuilder content: () -> Content) -> some View where Content: View {
        self.toolbar {
            content().modifier(AdaptiveMenu())
        }
    }
}


enum ImagePickerType: Identifiable {
    case camera
    case library
    var id: ImagePickerType {self}
}

func saveFileAndReturnURLString(image: UIImage) -> String? {
    let userFileName = UUID().uuidString
    if let data = image.pngData() {
        let filename = getDocumentsDirectory().appendingPathComponent(userFileName)
        logger.info("Image saved to \(filename)")
        try? data.write(to: filename)
    }
    if let urlStr = getSavedImage(named: userFileName) {
        return urlStr
    }
    return nil
}


struct UndoButton: View {
    
    var undoManager: UndoManager?
    
    var body: some View {
        if let undoManager = undoManager {
            Menu {
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
            } label: {
                Label("Undo/Redo", systemImage: "arrow.counterclockwise.circle")
            }
        }
    }
}
