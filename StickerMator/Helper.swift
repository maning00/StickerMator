//
//  Helper.swift
//  StickerMator
//
//  Created by Ning Ma on 11/1/21.
//

import Foundation
import SwiftUI

extension Collection where Element: Identifiable {
    func findIndex(of element: Element) -> Self.Index? {
        firstIndex(where: {$0.id == element.id })
    }
}


// from CS193p
extension Array where Element == NSItemProvider {
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
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
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
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
    func loadFirstObject<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
        loadObjects(ofType: theType, firstOnly: true, using: load)
    }
    func loadFirstObject<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        loadObjects(ofType: theType, firstOnly: true, using: load)
    }
}


extension CGSize {
    static func -(left: Self, right: Self) -> CGSize {
        CGSize(width: left.width - right.width, height: left.height - right.height)
    }
    
    static func +(left: Self, right: Self) -> CGSize {
        CGSize(width: left.width + right.width, height: left.height + right.height)
    }
    
    static func *(left: Self, right: CGFloat) -> CGSize {
        CGSize(width: left.width * right, height: left.height * right)
    }
    
    static func /(left: Self, right: CGFloat) -> CGSize {
        CGSize(width: left.width / right, height: left.height / right)
    }
}

extension Set where Element: Identifiable {
    mutating func toggleMatching(_ element: Element) {
        // has element -> remove, else -> insert
        if let matchingIndex = firstIndex(where: {$0.id == element.id}) {
            remove(at: matchingIndex)
        } else {
            insert(element)
        }
    }
    
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
    mutating func remove(_ element: Element) {
        if let index = findIndex(of: element) {
            remove(at: index)
        }
    }

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
