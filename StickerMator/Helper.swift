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
